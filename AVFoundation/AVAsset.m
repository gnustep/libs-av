/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
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
