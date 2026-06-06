/* This file is part of GNUstep */

#ifndef _AVAssetTrack_h_GNUSTEP_INCLUDE
#define _AVAssetTrack_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <AVFoundation/AVTime.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVAssetTrack : NSObject
{
  NSString *_mediaType;
  int _trackID;
  CMTimeScale _naturalTimeScale;
  CMTime _timeRangeStart;
  CMTime _timeRangeDuration;
}

- (id) initWithMediaType: (NSString *)mediaType
                 trackID: (int)trackID
         naturalTimeScale: (CMTimeScale)naturalTimeScale;
- (NSString *) mediaType;
- (int) trackID;
- (CMTimeScale) naturalTimeScale;

@end

#endif

#endif
