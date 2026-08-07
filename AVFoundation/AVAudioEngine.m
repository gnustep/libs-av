/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import <AVFoundation/AVAudioEngine.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

NSString * const AVAudioEngineConfigurationChangeNotification =
  @"AVAudioEngineConfigurationChangeNotification";

@implementation AVAudioNode
@end

@implementation AVAudioSourceNode

- (id) initWithFormat: (AVAudioFormat *)format
          renderBlock: (AVAudioSourceNodeRenderBlock)block
{
  if ((self = [super init]))
    {
      _format = [format retain];
      _renderBlock = [block copy];
    }
  return self;
}

- (void) dealloc
{
  [_format release];
  [_renderBlock release];
  [super dealloc];
}

@end

@implementation AVAudioEngine

- (id) init
{
  if ((self = [super init]))
    _mainMixerNode = [[AVAudioNode alloc] init];
  return self;
}

- (void) attachNode: (AVAudioNode *)node
{
  (void)node;
}

- (void) connect: (AVAudioNode *)node1
              to: (AVAudioNode *)node2
          format: (AVAudioFormat *)format
{
  (void)node1;
  (void)node2;
  (void)format;
}

- (BOOL) startAndReturnError: (NSError **)outError
{
  (void)outError;
  _running = YES;
  return YES;
}

- (void) stop
{
  _running = NO;
}

- (BOOL) isRunning
{
  return _running;
}

- (AVAudioNode *) mainMixerNode
{
  return _mainMixerNode;
}

- (void) dealloc
{
  [_mainMixerNode release];
  [super dealloc];
}

@end

#endif
