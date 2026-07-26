/* This file is part of GNUstep */

#ifndef _AVCompositionTrackSegment_h_GNUSTEP_INCLUDE
#define _AVCompositionTrackSegment_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVAssetTrackSegment.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVCompositionTrackSegment : AVAssetTrackSegment
@end

#endif

#endif
