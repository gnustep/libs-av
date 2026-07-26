/* This file is part of GNUstep */

#ifndef _AVPersistableContentKeyRequest_h_GNUSTEP_INCLUDE
#define _AVPersistableContentKeyRequest_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVContentKeyRequest.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVPersistableContentKeyRequest : AVContentKeyRequest
@end

#endif

#endif
