/* This file is part of GNUstep */

#ifndef _AVMutableAudioMix_h_GNUSTEP_INCLUDE
#define _AVMutableAudioMix_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVAudioMix.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVMutableAudioMix : AVAudioMix
@end

#endif

#endif
