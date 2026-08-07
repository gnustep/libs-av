/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import "AVMetadataItem.h"

@implementation AVMetadataItem

- (id) initWithKey: (id)key keySpace: (NSString *)keySpace value: (id)value
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_key, key);
      ASSIGN(_keySpace, keySpace);
      ASSIGN(_value, value);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_key);
  RELEASE(_keySpace);
  RELEASE(_value);
  [super dealloc];
}

- (id) key
{
  return _key;
}

- (NSString *) keySpace
{
  return _keySpace;
}

- (id) value
{
  return _value;
}

- (NSString *) stringValue
{
  if ([_value respondsToSelector: @selector(stringValue)])
    {
      return [_value stringValue];
    }
  return [_value description];
}

- (NSNumber *) numberValue
{
  if ([_value isKindOfClass: [NSNumber class]])
    {
      return _value;
    }
  return nil;
}

@end
