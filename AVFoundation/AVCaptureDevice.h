/* This file is part of GNUstep */

#ifndef _AVCaptureDevice_h_GNUSTEP_INCLUDE
#define _AVCaptureDevice_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)

typedef NS_ENUM(NSInteger, AVCaptureDevicePosition) {
  AVCaptureDevicePositionUnspecified = 0,
  AVCaptureDevicePositionBuiltInMicrophone,
};

extern NSString *const AVCaptureDeviceWasConnectedNotification;
extern NSString *const AVCaptureDeviceWasDisconnectedNotification;

@interface AVCaptureDevice : NSObject
{
  NSString *_uniqueID;
  NSString *_modelID;
  NSString *_localizedName;
  AVCaptureDevicePosition _position;
  BOOL _connected;
}

+ (NSArray *)devices;
+ (AVCaptureDevice *)defaultDeviceWithMediaType:(NSString *)mediaType;

- (NSString *)uniqueID;
- (NSString *)modelID;
- (NSString *)localizedName;
- (BOOL)isConnected;
- (AVCaptureDevicePosition)position;

@end

#endif

#endif
