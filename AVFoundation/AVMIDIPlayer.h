/* This file is part of GNUstep */

#ifndef _AVMIDIPlayer_h_GNUSTEP_INCLUDE
#define _AVMIDIPlayer_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSError.h>

@class NSCondition;

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

typedef id AVMIDIPlayerCompletionHandler;

@interface AVMIDIPlayer : NSObject
{
  NSURL *_url;
  NSData *_data;
  NSURL *_soundBankURL;
  NSError *_error;
  void *_settings;
  void *_synth;
  void *_audioDriver;
  void *_player;
  AVMIDIPlayerCompletionHandler _completionHandler;
  NSTimeInterval _duration;
  NSTimeInterval _currentPosition;
  NSCondition *_playbackCondition;
  float _rate;
  BOOL _prepared;
  BOOL _playing;
  BOOL _playbackThreadRunning;
  BOOL _stopRequested;
}

- (id) initWithContentsOfURL: (NSURL *)inURL
                soundBankURL: (NSURL *)bankURL
                       error: (NSError **)outError;
- (id) initWithData: (NSData *)data
       soundBankURL: (NSURL *)bankURL
              error: (NSError **)outError;
- (BOOL) prepareToPlay;
- (void) play: (AVMIDIPlayerCompletionHandler)completionHandler;
- (void) stop;
- (BOOL) isPlaying;
- (NSError *) error;
- (NSTimeInterval) duration;
- (NSTimeInterval) currentPosition;
- (void) setCurrentPosition: (NSTimeInterval)position;
- (float) rate;
- (void) setRate: (float)rate;

@end

#endif

#endif
