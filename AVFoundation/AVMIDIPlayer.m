/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import "AVMIDIPlayer.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
#include <fluidsynth.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
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

#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
static BOOL
AVMIDIPlayerFluidSynthDriverIsAvailable(fluid_settings_t *settings,
  const char *driver)
{
  char *options;
  char *token;
  char *saveptr;
  BOOL available;

  if (settings == NULL || driver == NULL)
    {
      return NO;
    }

  options = fluid_settings_option_concat(settings, "audio.driver", " ");
  if (options == NULL)
    {
      return (fluid_settings_option_count(settings, "audio.driver") == 0);
    }

  available = NO;
  token = strtok_r(options, " ", &saveptr);
  while (token != NULL)
    {
      if (strcmp(token, driver) == 0)
        {
          available = YES;
          break;
        }
      token = strtok_r(NULL, " ", &saveptr);
    }
  free(options);
  return available;
}

static BOOL
AVMIDIPlayerPathExists(NSString *path)
{
  return ([[NSFileManager defaultManager] fileExistsAtPath: path] == YES);
}

static BOOL
AVMIDIPlayerPulseAudioServerIsAvailable(void)
{
  const char *pulseServer;
  const char *runtimeDir;
  NSString *nativeSocket;

  pulseServer = getenv("PULSE_SERVER");
  if (pulseServer != NULL && strlen(pulseServer) > 0)
    {
      return YES;
    }

  runtimeDir = getenv("XDG_RUNTIME_DIR");
  if (runtimeDir == NULL || strlen(runtimeDir) == 0)
    {
      return NO;
    }

  nativeSocket = [[NSString stringWithUTF8String: runtimeDir]
    stringByAppendingPathComponent: @"pulse/native"];
  return AVMIDIPlayerPathExists(nativeSocket);
}

static BOOL
AVMIDIPlayerPipeWireServerIsAvailable(void)
{
  const char *runtimeDir;
  const char *spaPluginDir;
  NSString *nativeSocket;

  spaPluginDir = getenv("SPA_PLUGIN_DIR");
  if (spaPluginDir == NULL || strlen(spaPluginDir) == 0)
    {
      return NO;
    }

  runtimeDir = getenv("XDG_RUNTIME_DIR");
  if (runtimeDir == NULL || strlen(runtimeDir) == 0)
    {
      return NO;
    }

  nativeSocket = [[NSString stringWithUTF8String: runtimeDir]
    stringByAppendingPathComponent: @"pipewire-0"];
  return AVMIDIPlayerPathExists(nativeSocket);
}

static BOOL
AVMIDIPlayerShouldSkipFluidSynthDriver(const char *driver, BOOL explicitDriver)
{
  if (driver == NULL || explicitDriver == YES)
    {
      return NO;
    }

  if (strcmp(driver, "alsa") == 0)
    {
      return (AVMIDIPlayerPathExists(@"/dev/snd") == NO);
    }

  if (strcmp(driver, "pulseaudio") == 0)
    {
      return (AVMIDIPlayerPulseAudioServerIsAvailable() == NO);
    }

  if (strcmp(driver, "pipewire") == 0)
    {
      return (AVMIDIPlayerPipeWireServerIsAvailable() == NO);
    }

  if (strcmp(driver, "oss") == 0)
    {
      return (access("/dev/dsp", W_OK) != 0);
    }

  if (strcmp(driver, "sndio") == 0 || strcmp(driver, "portaudio") == 0)
    {
      return YES;
    }

  if (strcmp(driver, "sdl2") == 0)
    {
      return YES;
    }

  return NO;
}

static NSString *
AVMIDIPlayerAvailableFluidSynthDrivers(fluid_settings_t *settings)
{
  char *options;
  NSString *string;

  options = fluid_settings_option_concat(settings, "audio.driver", ", ");
  if (options == NULL)
    {
      return @"unknown";
    }

  string = [NSString stringWithUTF8String: options];
  free(options);
  return (string != nil) ? string : @"unknown";
}
#endif

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
      _playbackCondition = [NSCondition new];
      _rate = 1.0;
      if ([self prepareToPlay] == NO && outError != NULL)
        {
          *outError = _error;
        }
      if (_prepared == NO)
        {
          RELEASE(self);
          self = nil;
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
      _playbackCondition = [NSCondition new];
      _rate = 1.0;
      if ([self prepareToPlay] == NO && outError != NULL)
        {
          *outError = _error;
        }
      if (_prepared == NO)
        {
          RELEASE(self);
          self = nil;
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
  RELEASE(_playbackCondition);
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

- (void) _destroyFluidSynthAudioDriver
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  if (_audioDriver != NULL)
    {
      delete_fluid_audio_driver((fluid_audio_driver_t *)_audioDriver);
      _audioDriver = NULL;
    }
#endif
}

- (void) _destroyFluidSynthObjects
{
  [self _stopPlaybackThread];

  [_playbackCondition lock];
    {
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
      if (_player != NULL)
        {
          fluid_player_stop((fluid_player_t *)_player);
          delete_fluid_player((fluid_player_t *)_player);
          _player = NULL;
        }
      [self _destroyFluidSynthAudioDriver];
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
  [_playbackCondition unlock];
}

- (void) _stopPlaybackThread
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  void *player;

  player = NULL;
  [_playbackCondition lock];
    {
      _stopRequested = YES;
      _playing = NO;
      player = _player;
    }
  [_playbackCondition unlock];

  if (player != NULL)
    {
      fluid_player_stop((fluid_player_t *)player);
    }

  if (_playbackCondition != nil)
    {
      [_playbackCondition lock];
      while (_playbackThreadRunning == YES)
        {
          [_playbackCondition wait];
        }
      [_playbackCondition unlock];
    }
#endif
}

- (BOOL) _createFluidSynthAudioDriver
{
#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  const char *drivers[] = {
    "alsa",
    "pulseaudio",
    "pipewire",
    "oss",
    "sndio",
    "portaudio",
    "sdl2",
    NULL
  };
  const char *envDriver;
  int i;

  if (_audioDriver != NULL)
    {
      return YES;
    }

  envDriver = getenv("AVFOUNDATION_FLUIDSYNTH_AUDIO_DRIVER");
  if (envDriver != NULL && strlen(envDriver) > 0)
    {
      if (AVMIDIPlayerFluidSynthDriverIsAvailable((fluid_settings_t *)_settings,
        envDriver) == NO)
        {
          [self _setErrorCode: AVMIDIPlayerBackendError
                  description: [NSString stringWithFormat:
                    @"FluidSynth audio driver '%s' is not available. Available drivers: %@.",
                    envDriver,
                    AVMIDIPlayerAvailableFluidSynthDrivers(
                      (fluid_settings_t *)_settings)]];
          return NO;
        }
      if (fluid_settings_setstr((fluid_settings_t *)_settings,
        "audio.driver", envDriver) != FLUID_OK)
        {
          [self _setErrorCode: AVMIDIPlayerBackendError
                  description: [NSString stringWithFormat:
                    @"Unable to select FluidSynth audio driver '%s'.",
                    envDriver]];
          return NO;
        }
      _audioDriver = new_fluid_audio_driver((fluid_settings_t *)_settings,
        (fluid_synth_t *)_synth);
      if (_audioDriver != NULL)
        {
          return YES;
        }
      [self _setErrorCode: AVMIDIPlayerBackendError
              description: [NSString stringWithFormat:
                @"Unable to create FluidSynth audio driver '%s'.",
                envDriver]];
      return NO;
    }

  for (i = 0; drivers[i] != NULL; i++)
    {
      if (AVMIDIPlayerFluidSynthDriverIsAvailable((fluid_settings_t *)_settings,
        drivers[i]) == NO
        || AVMIDIPlayerShouldSkipFluidSynthDriver(drivers[i], NO) == YES)
        {
          continue;
        }
      if (fluid_settings_setstr((fluid_settings_t *)_settings,
        "audio.driver", drivers[i]) != FLUID_OK)
        {
          continue;
        }
      _audioDriver = new_fluid_audio_driver((fluid_settings_t *)_settings,
        (fluid_synth_t *)_synth);
      if (_audioDriver != NULL)
        {
          return YES;
        }
    }

  [self _setErrorCode: AVMIDIPlayerBackendError
          description: [NSString stringWithFormat:
            @"Unable to create FluidSynth audio driver. Available drivers: %@.",
            AVMIDIPlayerAvailableFluidSynthDrivers(
              (fluid_settings_t *)_settings)]];
  return NO;
#else
  return NO;
#endif
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

- (void) _runPlaybackThread
{
  AVMIDIPlayerCompletionHandler completionHandler;
  BOOL playStarted;
  BOOL stopped;
  void *player;

  completionHandler = nil;
  playStarted = NO;
  stopped = NO;
  player = NULL;

#if defined(AVFOUNDATION_HAVE_FLUIDSYNTH)
  [_playbackCondition lock];
    {
      if (_stopRequested == NO)
        {
          player = _player;
        }
    }
  [_playbackCondition unlock];

  if (player != NULL)
    {
      if (fluid_player_play((fluid_player_t *)player) == FLUID_OK)
        {
          playStarted = YES;
          fluid_player_join((fluid_player_t *)player);
        }
      else
        {
          [self _setErrorCode: AVMIDIPlayerBackendError
                  description: @"Unable to start MIDI playback."];
        }
    }
#endif

  [_playbackCondition lock];
    {
      stopped = _stopRequested;
      completionHandler = RETAIN(_completionHandler);
      _playing = NO;
    }

  _playbackThreadRunning = NO;
  [_playbackCondition broadcast];
  [_playbackCondition unlock];

  (void)playStarted;
  (void)stopped;

  RELEASE(completionHandler);
}

+ (void) _playbackThread: (AVMIDIPlayer *)player
{
  NSAutoreleasePool *pool;

  pool = [NSAutoreleasePool new];
  [player _runPlaybackThread];
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
  if ([self _createFluidSynthAudioDriver] == NO)
    {
      return;
    }

  [_playbackCondition lock];
    {
      if (_playing == YES || _playbackThreadRunning == YES)
        {
          [_playbackCondition unlock];
          return;
        }
      ASSIGNCOPY(_completionHandler, completionHandler);
      _stopRequested = NO;
      _playing = YES;
      _playbackThreadRunning = YES;
    }
  [_playbackCondition unlock];

  [NSThread detachNewThreadSelector: @selector(_playbackThread:)
                           toTarget: [self class]
                         withObject: RETAIN(self)];
#endif
}

- (void) stop
{
  [self _destroyFluidSynthObjects];
}

- (BOOL) isPlaying
{
  return _playing;
}

- (NSError *) error
{
  return _error;
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
