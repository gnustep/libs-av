/* This file is part of GNUstep */

#import <AVFoundation/AVAudioPCMBuffer.h>
#include <stdlib.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@implementation AVAudioPCMBuffer

- (id) initWithPCMFormat: (AVAudioFormat *)format
           frameCapacity: (AVAudioFrameCount)frameCapacity
{
  AVAudioChannelCount channelCount;
  NSUInteger channel;

  if ((self = [super init]))
    {
      _format = [format retain];
      _frameCapacity = frameCapacity;
      channelCount = [_format channelCount];
      _floatChannelData = calloc (MAX ((AVAudioChannelCount)1, channelCount), sizeof (float *));
      if (_floatChannelData == NULL)
        {
          [self release];
          return nil;
        }
      for (channel = 0; channel < channelCount; channel++)
        {
          _floatChannelData[channel] = calloc (MAX ((AVAudioFrameCount)1, frameCapacity),
                                              sizeof (float));
          if (_floatChannelData[channel] == NULL)
            {
              [self release];
              return nil;
            }
        }
    }
  return self;
}

- (AVAudioFormat *) format
{
  return _format;
}

- (AVAudioFrameCount) frameCapacity
{
  return _frameCapacity;
}

- (AVAudioFrameCount) frameLength
{
  return _frameLength;
}

- (void) setFrameLength: (AVAudioFrameCount)frameLength
{
  _frameLength = MIN (frameLength, _frameCapacity);
}

- (float **) floatChannelData
{
  return _floatChannelData;
}

- (void) dealloc
{
  AVAudioChannelCount channelCount = [_format channelCount];
  NSUInteger channel;

  if (_floatChannelData != NULL)
    {
      for (channel = 0; channel < channelCount; channel++)
        free (_floatChannelData[channel]);
      free (_floatChannelData);
    }
  [_format release];
  [super dealloc];
}

@end

#endif
