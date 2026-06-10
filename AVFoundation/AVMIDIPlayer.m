#import "AVMIDIPlayer.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
#include <fluidsynth.h>
#endif

static NSString *AVMIDIPlayerErrorDomain = @"AVMIDIPlayerErrorDomain";

enum
{
  AVMIDIPlayerUnsupportedError = 1,
  AVMIDIPlayerInvalidSourceError,
  AVMIDIPlayerSoundBankError,
  AVMIDIPlayerBackendError
};

static NSError *
AVMIDIPlayerMakeError(NSInteger code, NSString *description)
{
  NSDictionary *userInfo;

  userInfo = [NSDictionary dictionaryWithObject: description
                                         forKey: NSLocalizedDescriptionKey];
  return [NSError errorWithDomain: AVMIDIPlayerErrorDomain
                             code: code
                         userInfo: userInfo];
}

@implementation AVMIDIPlayer

- (id) initWithContentsOfURL: (NSURL *)inURL
                soundBankURL: (NSURL *)bankURL
                       error: (NSError **)outError
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_url, inURL);
      ASSIGN(_soundBankURL, bankURL);
      _rate = 1.0;
      if ([self prepareToPlay] == NO && outError != NULL)
        {
          *outError = _error;
        }
    }
  return self;
}

- (id) initWithData: (NSData *)data
       soundBankURL: (NSURL *)bankURL
              error: (NSError **)outError
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_data, data);
      ASSIGN(_soundBankURL, bankURL);
      _rate = 1.0;
      if ([self prepareToPlay] == NO && outError != NULL)
        {
          *outError = _error;
        }
    }
  return self;
}

- (void) dealloc
{
  [self stop];
  RELEASE(_url);
  RELEASE(_data);
  RELEASE(_soundBankURL);
  RELEASE(_error);
  RELEASE(_completionHandler);
  [super dealloc];
}

- (void) _setErrorCode: (NSInteger)code description: (NSString *)description
{
  ASSIGN(_error, AVMIDIPlayerMakeError(code, description));
}

- (NSString *) _soundBankPath
{
  NSFileManager *manager;
  NSArray *paths;
  NSUInteger i;

  manager = [NSFileManager defaultManager];
  if (_soundBankURL != nil)
    {
      if ([_soundBankURL isFileURL] == NO)
        {
          return nil;
        }
      return [_soundBankURL path];
    }

  paths = [NSArray arrayWithObjects:
    @"/usr/share/sounds/sf2/FluidR3_GM.sf2",
    @"/usr/share/sounds/sf2/default-GM.sf2",
    @"/usr/share/soundfonts/default.sf2",
    @"/usr/share/soundfonts/FluidR3_GM.sf2",
    @"/usr/share/sounds/sf3/default-GM.sf3",
    nil];

  for (i = 0; i < [paths count]; i++)
    {
      NSString *path = [paths objectAtIndex: i];
      if ([manager fileExistsAtPath: path] == YES)
        {
          return path;
        }
    }
  return nil;
}

- (BOOL) _addMIDIToPlayer
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  if (_url != nil)
    {
      if ([_url isFileURL] == NO)
        {
          [self _setErrorCode: AVMIDIPlayerInvalidSourceError
                  description: @"AVMIDIPlayer only supports file URLs."];
          return NO;
        }
      return (fluid_player_add((fluid_player_t *)_player,
        [[_url path] fileSystemRepresentation]) == FLUID_OK);
    }
  if (_data != nil)
    {
      return (fluid_player_add_mem((fluid_player_t *)_player,
        [_data bytes], [_data length]) == FLUID_OK);
    }
#endif
  [self _setErrorCode: AVMIDIPlayerInvalidSourceError
          description: @"AVMIDIPlayer requires MIDI data or a MIDI file URL."];
  return NO;
}

- (void) _updateDuration
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  int totalTicks;
  int division;
  int bpm;

  totalTicks = fluid_player_get_total_ticks((fluid_player_t *)_player);
  division = fluid_player_get_division((fluid_player_t *)_player);
  bpm = fluid_player_get_bpm((fluid_player_t *)_player);
  if (totalTicks > 0 && division > 0 && bpm > 0)
    {
      _duration = ((double)totalTicks / (double)division) * (60.0 / (double)bpm);
    }
#endif
}

- (void) _destroyFluidSynthObjects
{
  @synchronized (self)
    {
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
      if (_player != NULL)
        {
          fluid_player_stop((fluid_player_t *)_player);
          fluid_player_join((fluid_player_t *)_player);
          delete_fluid_player((fluid_player_t *)_player);
          _player = NULL;
        }
      if (_audioDriver != NULL)
        {
          delete_fluid_audio_driver((fluid_audio_driver_t *)_audioDriver);
          _audioDriver = NULL;
        }
      if (_synth != NULL)
        {
          delete_fluid_synth((fluid_synth_t *)_synth);
          _synth = NULL;
        }
      if (_settings != NULL)
        {
          delete_fluid_settings((fluid_settings_t *)_settings);
          _settings = NULL;
        }
#endif
      _prepared = NO;
      _playing = NO;
    }
}

- (BOOL) prepareToPlay
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  NSString *soundBankPath;

  if (_prepared == YES)
    {
      return YES;
    }

  [self _destroyFluidSynthObjects];
  soundBankPath = [self _soundBankPath];
  if (soundBankPath == nil)
    {
      [self _setErrorCode: AVMIDIPlayerSoundBankError
              description: @"AVMIDIPlayer requires a file URL sound bank or an installed default SoundFont."];
      return NO;
    }

  _settings = new_fluid_settings();
  if (_settings == NULL)
    {
      [self _setErrorCode: AVMIDIPlayerBackendError
              description: @"Unable to create FluidSynth settings."];
      return NO;
    }

  _synth = new_fluid_synth((fluid_settings_t *)_settings);
  if (_synth == NULL)
    {
      [self _setErrorCode: AVMIDIPlayerBackendError
              description: @"Unable to create FluidSynth synthesizer."];
      [self _destroyFluidSynthObjects];
      return NO;
    }

  if (fluid_synth_sfload((fluid_synth_t *)_synth,
    [soundBankPath fileSystemRepresentation], 1) == FLUID_FAILED)
    {
      [self _setErrorCode: AVMIDIPlayerSoundBankError
              description: @"Unable to load the MIDI sound bank."];
      [self _destroyFluidSynthObjects];
      return NO;
    }

  _audioDriver = new_fluid_audio_driver((fluid_settings_t *)_settings,
    (fluid_synth_t *)_synth);
  if (_audioDriver == NULL)
    {
      [self _setErrorCode: AVMIDIPlayerBackendError
              description: @"Unable to create FluidSynth audio driver."];
      [self _destroyFluidSynthObjects];
      return NO;
    }

  _player = new_fluid_player((fluid_synth_t *)_synth);
  if (_player == NULL || [self _addMIDIToPlayer] == NO)
    {
      [self _setErrorCode: AVMIDIPlayerInvalidSourceError
              description: @"Unable to load MIDI data."];
      [self _destroyFluidSynthObjects];
      return NO;
    }

  fluid_player_set_tempo((fluid_player_t *)_player,
    FLUID_PLAYER_TEMPO_INTERNAL, _rate);
  [self _updateDuration];
  _prepared = YES;
  return YES;
#else
  [self _setErrorCode: AVMIDIPlayerUnsupportedError
          description: @"AVMIDIPlayer was built without FluidSynth support."];
  return NO;
#endif
}

- (void) _finishPlaying
{
  AVMIDIPlayerCompletionHandler completionHandler;

#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  @synchronized (self)
    {
      if (_player != NULL)
        {
          fluid_player_join((fluid_player_t *)_player);
        }
    }
#endif

  @synchronized (self)
    {
      completionHandler = RETAIN(_completionHandler);
      _playing = NO;
    }

#if defined(__has_feature)
#  if __has_feature(blocks)
  if (completionHandler != nil)
    {
      ((void (^)(void))completionHandler)();
    }
#  endif
#endif

  RELEASE(completionHandler);
}

+ (void) _watchPlayback: (AVMIDIPlayer *)player
{
  NSAutoreleasePool *pool;

  pool = [NSAutoreleasePool new];
  [player _finishPlaying];
  RELEASE(player);
  RELEASE(pool);
}

- (void) play: (AVMIDIPlayerCompletionHandler)completionHandler
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  if ([self prepareToPlay] == NO)
    {
      return;
    }
  if (_playing == YES)
    {
      return;
    }

  ASSIGNCOPY(_completionHandler, completionHandler);
  if (fluid_player_play((fluid_player_t *)_player) == FLUID_OK)
    {
      _playing = YES;
      [NSThread detachNewThreadSelector: @selector(_watchPlayback:)
                               toTarget: [self class]
                             withObject: RETAIN(self)];
    }
#endif
}

- (void) stop
{
  [self _destroyFluidSynthObjects];
}

- (NSTimeInterval) duration
{
  return _duration;
}

- (NSTimeInterval) currentPosition
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  int tick;
  int division;
  int bpm;

  if (_player != NULL)
    {
      tick = fluid_player_get_current_tick((fluid_player_t *)_player);
      division = fluid_player_get_division((fluid_player_t *)_player);
      bpm = fluid_player_get_bpm((fluid_player_t *)_player);
      if (tick >= 0 && division > 0 && bpm > 0)
        {
          _currentPosition = ((double)tick / (double)division)
            * (60.0 / (double)bpm);
        }
    }
#endif
  return _currentPosition;
}

- (void) setCurrentPosition: (NSTimeInterval)position
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  int division;
  int bpm;
  int tick;

  if (position < 0.0)
    {
      position = 0.0;
    }
  _currentPosition = position;
  if (_player != NULL)
    {
      division = fluid_player_get_division((fluid_player_t *)_player);
      bpm = fluid_player_get_bpm((fluid_player_t *)_player);
      if (division > 0 && bpm > 0)
        {
          tick = (int)((position * (double)bpm * (double)division) / 60.0);
          fluid_player_seek((fluid_player_t *)_player, tick);
        }
    }
#else
  _currentPosition = position;
#endif
}

- (float) rate
{
  return _rate;
}

- (void) setRate: (float)rate
{
  if (rate <= 0.0)
    {
      rate = 1.0;
    }
  _rate = rate;
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  if (_player != NULL)
    {
      fluid_player_set_tempo((fluid_player_t *)_player,
        FLUID_PLAYER_TEMPO_INTERNAL, _rate);
    }
#endif
}

@end
