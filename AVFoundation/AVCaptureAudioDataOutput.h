/* This file is part of GNUstep */

#ifndef _AVCaptureAudioDataOutput_h_GNUSTEP_INCLUDE
#define _AVCaptureAudioDataOutput_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSData.h>
#import <AVFoundation/AVCaptureOutput.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)

@protocol AVCaptureAudioDataOutputSampleDelegate <NSObject>
- (void)captureOutput:(id)output
  didOutputSampleData:(NSData *)sampleData
           numSamples:(NSUInteger)numSamples
           sampleRate:(double)sampleRate;
@end

@interface AVCaptureAudioDataOutput : AVCaptureOutput
{
  id <AVCaptureAudioDataOutputSampleDelegate> _delegate;
}
@property (nonatomic, assign) id <AVCaptureAudioDataOutputSampleDelegate> sampleDelegate;
- (void)setSampleDelegate:(id <AVCaptureAudioDataOutputSampleDelegate>)delegate;
@end

#endif

#endif
