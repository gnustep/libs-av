/* This file is part of GNUstep */

#import "AVCaptureInput.h"
#import "AVCaptureSession.h"
#import "AVCaptureDevice.h"
#import <Foundation/NSDictionary.h>

@implementation AVCaptureInput

- (AVCaptureSession *)session { return _session; }
- (void)_setSession:(AVCaptureSession *)s { _session = s; }

@end

@implementation AVCaptureDeviceInput

+ (AVCaptureDeviceInput *)deviceInputWithDevice:(AVCaptureDevice *)device
                                          error:(NSError **)outError
{
  return [[[self alloc] initWithDevice:device error:outError] autorelease];
}

- (id)initWithDevice:(AVCaptureDevice *)device error:(NSError **)outError
{
  if (!device) {
    if (outError) *outError = [NSError errorWithDomain:@"AVFoundation" code:-1
      userInfo:@{NSLocalizedDescriptionKey: @"AVCaptureDevice is nil"}];
    [self release];
    return nil;
  }
  self = [super init];
  if (self) {
    _device = [device retain];
  }
  return self;
}

- (void)dealloc
{
  [_device release];
  [_error release];
  [super dealloc];
}

- (AVCaptureDevice *)device { return _device; }

@end
