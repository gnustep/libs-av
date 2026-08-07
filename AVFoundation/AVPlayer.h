/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVPlayer_h_GNUSTEP_INCLUDE
#define _AVPlayer_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVTime.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

typedef enum
{
  AVPlayerStatusUnknown,
  AVPlayerStatusReadyToPlay,
  AVPlayerStatusFailed
} AVPlayerStatus;

typedef enum
{
  AVPlayerActionAtItemEndAdvance,
  AVPlayerActionAtItemEndPause,
  AVPlayerActionAtItemEndNone
} AVPlayerActionAtItemEnd;

@interface AVPlayer : NSObject
{
  AVPlayerItem *_currentItem;
  float _rate;
  AVPlayerStatus _status;
  AVPlayerActionAtItemEnd _actionAtItemEnd;
  CMTime _currentTime;
}

+ (id) playerWithURL: (NSURL *)URL;
+ (id) playerWithPlayerItem: (AVPlayerItem *)item;
- (id) initWithPlayerItem: (AVPlayerItem *)item;
- (void) replaceCurrentItemWithPlayerItem: (AVPlayerItem *)item;
- (AVPlayerItem *) currentItem;
- (AVPlayerStatus) status;
- (float) rate;
- (void) setRate: (float)rate;
- (void) play;
- (void) pause;
- (CMTime) currentTime;
- (void) seekToTime: (CMTime)time;
- (AVPlayerActionAtItemEnd) actionAtItemEnd;
- (void) setActionAtItemEnd: (AVPlayerActionAtItemEnd)action;

@end

#endif

#endif
