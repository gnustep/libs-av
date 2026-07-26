/* This file is part of GNUstep */

#import "AVCaptureAudioDataOutput.h"
#import "AVCaptureSession.h"
#import <Foundation/NSDebug.h>

@implementation AVCaptureAudioDataOutput

- (id)init
{
  self = [super init];
  if (self) {
    _delegate = nil;
  }
  return self;
}

- (id <AVCaptureAudioDataOutputSampleDelegate>)sampleDelegate
{
  return _delegate;
}

- (void)setSampleDelegate:(id <AVCaptureAudioDataOutputSampleDelegate>)delegate
{
  _delegate = delegate;
}

@end
