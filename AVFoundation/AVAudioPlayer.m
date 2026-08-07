/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import "AVAudioPlayer.h"

@interface NSObject (AVFoundationNSSoundCompatibility)
- (id) initWithContentsOfFile: (NSString *)path byReference: (BOOL)flag;
- (id) initWithData: (NSData *)data;
- (BOOL) play;
- (void) pause;
- (void) stop;
- (BOOL) isPlaying;
- (void) setVolume: (float)volume;
- (void) setLoops: (BOOL)flag;
@end

@implementation AVAudioPlayer

- (id) initWithContentsOfURL: (NSURL *)url error: (NSError **)outError
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_url, url);
      _volume = 1.0;
      if ([self prepareToPlay] == NO && outError != NULL)
        {
          *outError = _error;
        }
    }
  return self;
}

- (id) initWithData: (NSData *)data error: (NSError **)outError
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_data, data);
      _volume = 1.0;
      if ([self prepareToPlay] == NO && outError != NULL)
        {
          *outError = _error;
        }
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_url);
  RELEASE(_data);
  RELEASE(_error);
  RELEASE(_sound);
  [super dealloc];
}

- (BOOL) prepareToPlay
{
  Class soundClass;

  if (_sound != nil)
    {
      return YES;
    }

  soundClass = NSClassFromString(@"NSSound");
  if (soundClass == Nil)
    {
      return (_url != nil || _data != nil);
    }

  if (_url != nil && [_url isFileURL])
    {
      _sound = [[soundClass alloc] initWithContentsOfFile: [_url path]
                                              byReference: YES];
    }
  else if (_data != nil)
    {
      _sound = [[soundClass alloc] initWithData: _data];
    }

  if ([_sound respondsToSelector: @selector(setVolume:)])
    {
      [_sound setVolume: _volume];
    }
  return (_sound != nil || _url != nil || _data != nil);
}

- (BOOL) play
{
  if ([self prepareToPlay] == NO)
    {
      return NO;
    }
  if ([_sound respondsToSelector: @selector(play)])
    {
      _playing = [_sound play];
    }
  else
    {
      _playing = YES;
    }
  return _playing;
}

- (void) pause
{
  if ([_sound respondsToSelector: @selector(pause)])
    {
      [_sound pause];
    }
  _playing = NO;
}

- (void) stop
{
  if ([_sound respondsToSelector: @selector(stop)])
    {
      [_sound stop];
    }
  _playing = NO;
}

- (BOOL) isPlaying
{
  if ([_sound respondsToSelector: @selector(isPlaying)])
    {
      return [_sound isPlaying];
    }
  return _playing;
}

- (NSURL *) url
{
  return _url;
}

- (NSData *) data
{
  return _data;
}

- (float) volume
{
  return _volume;
}

- (void) setVolume: (float)volume
{
  _volume = volume;
  if ([_sound respondsToSelector: @selector(setVolume:)])
    {
      [_sound setVolume: volume];
    }
}

- (int) numberOfLoops
{
  return _numberOfLoops;
}

- (void) setNumberOfLoops: (int)loops
{
  _numberOfLoops = loops;
  if ([_sound respondsToSelector: @selector(setLoops:)])
    {
      [_sound setLoops: (loops != 0)];
    }
}

@end
