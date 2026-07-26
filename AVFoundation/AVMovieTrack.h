/* This file is part of GNUstep */

#ifndef _AVMovieTrack_h_GNUSTEP_INCLUDE
#define _AVMovieTrack_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVAssetTrack.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVMovieTrack : AVAssetTrack
@end

#endif

#endif
