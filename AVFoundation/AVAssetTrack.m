#import "AVAssetTrack.h"

@implementation AVAssetTrack

- (id) initWithMediaType: (NSString *)mediaType
                 trackID: (int)trackID
         naturalTimeScale: (CMTimeScale)naturalTimeScale
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_mediaType, mediaType);
      _trackID = trackID;
      _naturalTimeScale = naturalTimeScale;
      _timeRangeStart = kCMTimeZero;
      _timeRangeDuration = kCMTimeIndefinite;
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_mediaType);
  [super dealloc];
}

- (NSString *) mediaType
{
  return _mediaType;
}

- (int) trackID
{
  return _trackID;
}

- (CMTimeScale) naturalTimeScale
{
  return _naturalTimeScale;
}

@end
