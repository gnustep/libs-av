/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVAudioFormat_h_GNUSTEP_INCLUDE
#define _AVAudioFormat_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import <AVFoundation/AVAudioTypes.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVAudioFormat : NSObject
{
  double _sampleRate;
  AVAudioChannelCount _channelCount;
}

- (id) initStandardFormatWithSampleRate: (double)sampleRate
                               channels: (AVAudioChannelCount)channels;
- (double) sampleRate;
- (AVAudioChannelCount) channelCount;
- (NSDictionary *) settings;

@end

#endif

#endif
