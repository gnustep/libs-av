/* This file is part of GNUstep */

#ifndef _AVAudioEngine_h_GNUSTEP_INCLUDE
#define _AVAudioEngine_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSNotification.h>
#import <AVFoundation/AVAudioTypes.h>
#import <AVFoundation/AVAudioFormat.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

extern NSString * const AVAudioEngineConfigurationChangeNotification;

@class AVAudioNode;
typedef OSStatus (^AVAudioSourceNodeRenderBlock)(BOOL *isSilence,
                                                 const AudioTimeStamp *timestamp,
                                                 AVAudioFrameCount frameCount,
                                                 AudioBufferList *outputData);

@interface AVAudioNode : NSObject
@end

@interface AVAudioSourceNode : AVAudioNode
{
  AVAudioFormat *_format;
  AVAudioSourceNodeRenderBlock _renderBlock;
}

- (id) initWithFormat: (AVAudioFormat *)format
          renderBlock: (AVAudioSourceNodeRenderBlock)block;

@end

@interface AVAudioEngine : NSObject
{
  AVAudioNode *_mainMixerNode;
  BOOL _running;
}

- (void) attachNode: (AVAudioNode *)node;
- (void) connect: (AVAudioNode *)node1
              to: (AVAudioNode *)node2
          format: (AVAudioFormat *)format;
- (BOOL) startAndReturnError: (NSError **)outError;
- (void) stop;
- (BOOL) isRunning;
- (AVAudioNode *) mainMixerNode;

@end

#endif

#endif
