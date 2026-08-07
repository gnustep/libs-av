/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVAudioPCMBuffer_h_GNUSTEP_INCLUDE
#define _AVAudioPCMBuffer_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <AVFoundation/AVAudioFormat.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVAudioPCMBuffer : NSObject
{
  AVAudioFormat *_format;
  AVAudioFrameCount _frameCapacity;
  AVAudioFrameCount _frameLength;
  float **_floatChannelData;
}

- (id) initWithPCMFormat: (AVAudioFormat *)format
           frameCapacity: (AVAudioFrameCount)frameCapacity;
- (AVAudioFormat *) format;
- (AVAudioFrameCount) frameCapacity;
- (AVAudioFrameCount) frameLength;
- (void) setFrameLength: (AVAudioFrameCount)frameLength;
- (float **) floatChannelData;

@end

#endif

#endif
