/* This file is part of GNUstep */

#ifndef _AVCaptureInput_h_GNUSTEP_INCLUDE
#define _AVCaptureInput_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)

@class AVCaptureDevice;
@class AVCaptureSession;

@interface AVCaptureInput : NSObject
{
  AVCaptureSession *_session;
}

- (AVCaptureSession *)session;

@end

@interface AVCaptureDeviceInput : AVCaptureInput
{
  AVCaptureDevice *_device;
  NSError *_error;
}

+ (AVCaptureDeviceInput *)deviceInputWithDevice:(AVCaptureDevice *)device
                                          error:(NSError **)outError;
- (id)initWithDevice:(AVCaptureDevice *)device error:(NSError **)outError;
- (AVCaptureDevice *)device;

@end

#endif

#endif
