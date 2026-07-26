/* This file is part of GNUstep */

#ifndef _AVQueuePlayer_h_GNUSTEP_INCLUDE
#define _AVQueuePlayer_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVPlayer.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVQueuePlayer : AVPlayer
@end

#endif

#endif
