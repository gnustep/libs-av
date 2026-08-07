/* This file is part of GNUstep */

#ifndef _AVAudioTypes_h_GNUSTEP_INCLUDE
#define _AVAudioTypes_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

typedef unsigned int AVAudioChannelCount;
typedef unsigned int AVAudioFrameCount;
typedef long long AVAudioFramePosition;
typedef int OSStatus;
typedef unsigned int UInt32;
typedef unsigned char UInt8;
typedef double Float64;
typedef float Float32;

#ifndef noErr
#define noErr 0
#endif

typedef struct AudioTimeStamp
{
  Float64 mSampleTime;
  UInt32 mFlags;
} AudioTimeStamp;

typedef struct AudioBuffer
{
  UInt32 mNumberChannels;
  UInt32 mDataByteSize;
  void *mData;
} AudioBuffer;

typedef struct AudioBufferList
{
  UInt32 mNumberBuffers;
  AudioBuffer mBuffers[1];
} AudioBufferList;

extern NSString * const AVLinearPCMIsNonInterleavedKey;
extern NSString * const AVSampleRateKey;
extern NSString * const AVNumberOfChannelsKey;

#endif

#endif
