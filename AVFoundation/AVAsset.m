/* Implementation of class AVAsset
   Copyright (C) 2022 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: 14-12-2022

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#import "AVAsset.h"
#import "AVURLAsset.h"
#import "AVAssetTrack.h"

@implementation AVAsset

- (id) init
{
  self = [super init];
  if (self != nil)
    {
      _duration = kCMTimeIndefinite;
      _tracks = [[NSArray alloc] init];
      _metadata = [[NSArray alloc] init];
      _playable = NO;
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_URL);
  RELEASE(_tracks);
  RELEASE(_metadata);
  [super dealloc];
}

+ (id) assetWithURL: (NSURL *)URL
{
  return AUTORELEASE([[AVURLAsset alloc] initWithURL: URL options: nil]);
}

- (CMTime) duration
{
  return _duration;
}

- (BOOL) isPlayable
{
  return _playable;
}

- (NSArray *) tracks
{
  return _tracks;
}

- (NSArray *) tracksWithMediaType: (NSString *)mediaType
{
  NSMutableArray *matches;
  unsigned int i;

  matches = [NSMutableArray array];
  for (i = 0; i < [_tracks count]; i++)
    {
      AVAssetTrack *track = [_tracks objectAtIndex: i];
      if ([[track mediaType] isEqualToString: mediaType])
        {
          [matches addObject: track];
        }
    }
  return matches;
}

- (NSArray *) commonMetadata
{
  return _metadata;
}

@end
