/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVAsset_h_GNUSTEP_BASE_INCLUDE
#define _AVAsset_h_GNUSTEP_BASE_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSURL.h>
#import <AVFoundation/AVTime.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

#if	defined(__cplusplus)
extern "C" {
#endif

@interface AVAsset : NSObject
{
  NSURL *_URL;
  CMTime _duration;
  NSArray *_tracks;
  NSArray *_metadata;
  BOOL _playable;
}

+ (id) assetWithURL: (NSURL *)URL;

- (CMTime) duration;
- (BOOL) isPlayable;
- (NSArray *) tracks;
- (NSArray *) tracksWithMediaType: (NSString *)mediaType;
- (NSArray *) commonMetadata;

@end

#if	defined(__cplusplus)
}
#endif

#endif	/* GS_API_MACOSX */

#endif	/* _AVAsset_h_GNUSTEP_BASE_INCLUDE */
