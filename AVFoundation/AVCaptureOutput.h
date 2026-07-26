/* This file is part of GNUstep */

#ifndef _AVCaptureOutput_h_GNUSTEP_INCLUDE
#define _AVCaptureOutput_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)

@class AVCaptureSession;

@interface AVCaptureOutput : NSObject
{
  AVCaptureSession *_session;
}
- (AVCaptureSession *)session;
@end

#endif

#endif
