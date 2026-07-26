/* This file is part of GNUstep */

#import "AVCaptureDevice.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDebug.h>

#include <libavdevice/avdevice.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>

NSString *const AVCaptureDeviceWasConnectedNotification    = @"AVCaptureDeviceWasConnectedNotification";
NSString *const AVCaptureDeviceWasDisconnectedNotification = @"AVCaptureDeviceWasDisconnectedNotification";

static NSMutableArray *allDevices = nil;
static int avdevice_refcount = 0;

static void ensure_avdevice(void)
{
  if (avdevice_refcount == 0) {
    avdevice_register_all();
  }
  avdevice_refcount++;
}

@implementation AVCaptureDevice

+ (void)initialize
{
  if (self == [AVCaptureDevice class]) {
    allDevices = [[NSMutableArray alloc] init];
  }
}

+ (NSArray *)devices
{
  return [[allDevices copy] autorelease];
}

+ (AVCaptureDevice *)defaultDeviceWithMediaType:(NSString *)mediaType
{
  if (![mediaType isEqualToString:@"AVMediaTypeAudio"]) return nil;
  for (AVCaptureDevice *d in allDevices) {
    if (d->_connected) return d;
  }
  return nil;
}

+ (void)_addDevice:(AVCaptureDevice *)dev
{
  [allDevices addObject:dev];
}

- (id)initWithUniqueID:(NSString *)uid
                modelID:(NSString *)mid
              localizedName:(NSString *)name
{
  self = [super init];
  if (self) {
    _uniqueID = [uid copy];
    _modelID  = [mid copy];
    _localizedName = [name copy];
    _position = AVCaptureDevicePositionUnspecified;
    _connected = YES;
  }
  return self;
}

- (void)dealloc
{
  [_uniqueID release];
  [_modelID release];
  [_localizedName release];
  [super dealloc];
}

- (NSString *)uniqueID { return _uniqueID; }
- (NSString *)modelID { return _modelID; }
- (NSString *)localizedName { return _localizedName; }
- (BOOL)isConnected { return _connected; }
- (AVCaptureDevicePosition)position { return _position; }

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@: %p '%@'>", [self class], self, _localizedName];
}

@end
