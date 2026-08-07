/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVPlayerItem_h_GNUSTEP_INCLUDE
#define _AVPlayerItem_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>
#import <Foundation/NSURL.h>
#import <AVFoundation/AVAsset.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

typedef enum
{
  AVPlayerItemStatusUnknown,
  AVPlayerItemStatusReadyToPlay,
  AVPlayerItemStatusFailed
} AVPlayerItemStatus;

@interface AVPlayerItem : NSObject
{
  AVAsset *_asset;
  AVPlayerItemStatus _status;
  NSError *_error;
}

+ (id) playerItemWithAsset: (AVAsset *)asset;
+ (id) playerItemWithURL: (NSURL *)URL;
- (id) initWithAsset: (AVAsset *)asset;
- (AVAsset *) asset;
- (AVPlayerItemStatus) status;
- (NSError *) error;

@end

#endif

#endif
