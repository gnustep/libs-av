/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import "AVPlayer.h"

@implementation AVPlayer

+ (id) playerWithURL: (NSURL *)URL
{
  return [self playerWithPlayerItem: [AVPlayerItem playerItemWithURL: URL]];
}

+ (id) playerWithPlayerItem: (AVPlayerItem *)item
{
  return AUTORELEASE([[self alloc] initWithPlayerItem: item]);
}

- (id) initWithPlayerItem: (AVPlayerItem *)item
{
  self = [super init];
  if (self != nil)
    {
      _actionAtItemEnd = AVPlayerActionAtItemEndPause;
      _currentTime = kCMTimeZero;
      [self replaceCurrentItemWithPlayerItem: item];
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_currentItem);
  [super dealloc];
}

- (void) replaceCurrentItemWithPlayerItem: (AVPlayerItem *)item
{
  ASSIGN(_currentItem, item);
  _rate = 0.0;
  if (_currentItem == nil)
    {
      _status = AVPlayerStatusUnknown;
    }
  else if ([_currentItem status] == AVPlayerItemStatusReadyToPlay)
    {
      _status = AVPlayerStatusReadyToPlay;
    }
  else
    {
      _status = AVPlayerStatusFailed;
    }
}

- (AVPlayerItem *) currentItem
{
  return _currentItem;
}

- (AVPlayerStatus) status
{
  return _status;
}

- (float) rate
{
  return _rate;
}

- (void) setRate: (float)rate
{
  _rate = (_status == AVPlayerStatusReadyToPlay) ? rate : 0.0;
}

- (void) play
{
  [self setRate: 1.0];
}

- (void) pause
{
  _rate = 0.0;
}

- (CMTime) currentTime
{
  return _currentTime;
}

- (void) seekToTime: (CMTime)time
{
  _currentTime = time;
}

- (AVPlayerActionAtItemEnd) actionAtItemEnd
{
  return _actionAtItemEnd;
}

- (void) setActionAtItemEnd: (AVPlayerActionAtItemEnd)action
{
  _actionAtItemEnd = action;
}

@end
