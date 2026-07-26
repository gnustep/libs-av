/* This file is part of GNUstep */

#import "AVCaptureOutput.h"
#import "AVCaptureSession.h"
#import <Foundation/NSDebug.h>

@implementation AVCaptureOutput

- (AVCaptureSession *)session { return _session; }
- (void)_setSession:(AVCaptureSession *)s { _session = s; }

@end
