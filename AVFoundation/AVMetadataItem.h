/* This file is part of GNUstep */

#ifndef _AVMetadataItem_h_GNUSTEP_INCLUDE
#define _AVMetadataItem_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVMetadataItem : NSObject
{
  id _key;
  NSString *_keySpace;
  id _value;
}

- (id) initWithKey: (id)key keySpace: (NSString *)keySpace value: (id)value;
- (id) key;
- (NSString *) keySpace;
- (id) value;
- (NSString *) stringValue;
- (NSNumber *) numberValue;

@end

#endif

#endif
