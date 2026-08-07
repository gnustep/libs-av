/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVAudioPlayer_h_GNUSTEP_INCLUDE
#define _AVAudioPlayer_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVAudioPlayer : NSObject
{
  NSURL *_url;
  NSData *_data;
  NSError *_error;
  id _sound;
  float _volume;
  int _numberOfLoops;
  BOOL _playing;
}

- (id) initWithContentsOfURL: (NSURL *)url error: (NSError **)outError;
- (id) initWithData: (NSData *)data error: (NSError **)outError;
- (BOOL) prepareToPlay;
- (BOOL) play;
- (void) pause;
- (void) stop;
- (BOOL) isPlaying;
- (NSURL *) url;
- (NSData *) data;
- (float) volume;
- (void) setVolume: (float)volume;
- (int) numberOfLoops;
- (void) setNumberOfLoops: (int)loops;

@end

#endif

#endif
