/* This file is part of GNUstep */

#ifndef _AVCaptureSession_h_GNUSTEP_INCLUDE
#define _AVCaptureSession_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)

@class AVCaptureInput;
@class AVCaptureOutput;
@class AVCaptureConnection;
@class AVCaptureDevice;

extern NSString *const AVCaptureSessionDidStartRunningNotification;
extern NSString *const AVCaptureSessionDidStopRunningNotification;

typedef NS_ENUM(NSInteger, AVCaptureSessionPreset) {
  AVCaptureSessionPresetHigh,
  AVCaptureSessionPresetMedium,
  AVCaptureSessionPresetLow,
  AVCaptureSessionPreset16000,
};

@interface AVCaptureSession : NSObject
{
  NSMutableArray *_inputs;
  NSMutableArray *_outputs;
  NSMutableArray *_connections;
  BOOL _running;
  BOOL _interrupted;
  AVCaptureSessionPreset _sessionPreset;
  int _sampleRate;
  void *_captureHandle;
}

@property (nonatomic, copy) NSArray *inputs;
@property (nonatomic, copy) NSArray *outputs;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, assign) AVCaptureSessionPreset sessionPreset;

- (void)startRunning;
- (void)stopRunning;

- (BOOL)canAddInput:(AVCaptureInput *)input;
- (void)addInput:(AVCaptureInput *)input;
- (void)removeInput:(AVCaptureInput *)input;

- (BOOL)canAddOutput:(AVCaptureOutput *)output;
- (void)addOutput:(AVCaptureOutput *)output;
- (void)removeOutput:(AVCaptureOutput *)output;

@end

#endif

#endif
