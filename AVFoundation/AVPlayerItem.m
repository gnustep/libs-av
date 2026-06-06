#import "AVPlayerItem.h"

@implementation AVPlayerItem

+ (id) playerItemWithAsset: (AVAsset *)asset
{
  return AUTORELEASE([[self alloc] initWithAsset: asset]);
}

+ (id) playerItemWithURL: (NSURL *)URL
{
  return [self playerItemWithAsset: [AVAsset assetWithURL: URL]];
}

- (id) initWithAsset: (AVAsset *)asset
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_asset, asset);
      _status = [_asset isPlayable] ? AVPlayerItemStatusReadyToPlay
        : AVPlayerItemStatusFailed;
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_asset);
  RELEASE(_error);
  [super dealloc];
}

- (AVAsset *) asset
{
  return _asset;
}

- (AVPlayerItemStatus) status
{
  return _status;
}

- (NSError *) error
{
  return _error;
}

@end
