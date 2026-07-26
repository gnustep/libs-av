/* This file is part of GNUstep */

#ifndef _AVFragmentedAssetTrack_h_GNUSTEP_INCLUDE
#define _AVFragmentedAssetTrack_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVAssetTrack.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVFragmentedAssetTrack : AVAssetTrack
@end

#endif

#endif
