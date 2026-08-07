/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import <AVFoundation/AVAudioFormat.h>
#import <Foundation/NSValue.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

NSString * const AVLinearPCMIsNonInterleavedKey = @"AVLinearPCMIsNonInterleaved";
NSString * const AVSampleRateKey = @"AVSampleRateKey";
NSString * const AVNumberOfChannelsKey = @"AVNumberOfChannelsKey";

@implementation AVAudioFormat

- (id) initStandardFormatWithSampleRate: (double)sampleRate
                               channels: (AVAudioChannelCount)channels
{
  if ((self = [super init]))
    {
      _sampleRate = sampleRate;
      _channelCount = channels;
    }
  return self;
}

- (double) sampleRate
{
  return _sampleRate;
}

- (AVAudioChannelCount) channelCount
{
  return _channelCount;
}

- (NSDictionary *) settings
{
  return [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithDouble: _sampleRate], AVSampleRateKey,
    [NSNumber numberWithUnsignedInt: _channelCount], AVNumberOfChannelsKey,
    [NSNumber numberWithBool: YES], AVLinearPCMIsNonInterleavedKey,
    nil];
}

@end

#endif
