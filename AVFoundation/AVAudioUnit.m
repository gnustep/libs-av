/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import <AVFoundation/AVAudioUnit.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@implementation AUParameter
- (uint64_t) address
{
  return 0;
}

- (NSString *) displayName
{
  return nil;
}

- (NSString *) identifier
{
  return nil;
}

- (AUValue) value
{
  return 0.0f;
}

- (AUValue) minValue
{
  return 0.0f;
}

- (AUValue) maxValue
{
  return 0.0f;
}

- (NSString *) unitName
{
  return nil;
}

- (void) setValue: (AUValue)value
       originator: (id)originator
{
  (void)value;
  (void)originator;
}
@end

@implementation AUParameterTree
- (NSArray *) allParameters
{
  return [NSArray array];
}

- (AUParameter *) parameterWithAddress: (uint64_t)address
{
  (void)address;
  return nil;
}
@end

@implementation AUAudioUnit
- (NSDictionary *) fullState
{
  return [NSDictionary dictionary];
}

- (void) setFullState: (NSDictionary *)state
{
  (void)state;
}

- (AUParameterTree *) parameterTree
{
  return [[[AUParameterTree alloc] init] autorelease];
}

- (AUScheduleMIDIEventBlock) scheduleMIDIEventBlock
{
  return nil;
}

- (void) requestViewControllerWithCompletionHandler: (id)completionHandler
{
  (void)completionHandler;
}
@end

@implementation AVAudioUnit
+ (void) instantiateWithComponentDescription: (AudioComponentDescription)audioComponentDescription
                                     options: (NSUInteger)options
                           completionHandler: (id)completionHandler
{
  (void)audioComponentDescription;
  (void)options;
  (void)completionHandler;
}

- (AUAudioUnit *) AUAudioUnit
{
  return [[[AUAudioUnit alloc] init] autorelease];
}
@end

@implementation AVAudioUnitMIDIInstrument
- (void) sendMIDIEvent: (UInt8)midiStatus
                 data1: (UInt8)data1
                 data2: (UInt8)data2
{
  (void)midiStatus;
  (void)data1;
  (void)data2;
}

- (void *) audioUnit
{
  return NULL;
}
@end

@implementation AVAudioUnitEffect
@end

@implementation AVAudioUnitEQFilterParameters
- (void) setFilterType: (AVAudioUnitEQFilterType)filterType
{
  (void)filterType;
}

- (void) setFrequency: (float)frequency
{
  (void)frequency;
}

- (void) setBypass: (BOOL)bypass
{
  (void)bypass;
}
@end

@implementation AVAudioUnitEQ
- (id) initWithNumberOfBands: (NSUInteger)numberOfBands
{
  NSUInteger index;

  if ((self = [super init]))
    {
      _bands = [[NSMutableArray alloc] initWithCapacity: numberOfBands];
      for (index = 0; index < numberOfBands; index++)
        {
          [_bands addObject:
            [[[AVAudioUnitEQFilterParameters alloc] init] autorelease]];
        }
    }
  return self;
}

- (NSArray *) bands
{
  return _bands;
}

- (void) setGlobalGain: (float)globalGain
{
  _globalGain = globalGain;
}

- (void) dealloc
{
  [_bands release];
  [super dealloc];
}
@end

@implementation AVAudioUnitDelay
- (void) setDelayTime: (NSTimeInterval)delayTime
{
  (void)delayTime;
}

- (void) setFeedback: (float)feedback
{
  (void)feedback;
}

- (void) setWetDryMix: (float)wetDryMix
{
  (void)wetDryMix;
}
@end

@implementation AVAudioUnitReverb
- (void) loadFactoryPreset: (AVAudioUnitReverbPreset)preset
{
  (void)preset;
}

- (void) setWetDryMix: (float)wetDryMix
{
  (void)wetDryMix;
}
@end

@implementation AVAudioUnitComponent
- (AudioComponentDescription) audioComponentDescription
{
  AudioComponentDescription description = { 0, 0, 0, 0, 0 };
  return description;
}

- (NSString *) name
{
  return nil;
}

- (NSString *) manufacturerName
{
  return nil;
}

- (NSDictionary *) configurationDictionary
{
  return [NSDictionary dictionary];
}

- (BOOL) hasCustomView
{
  return NO;
}

- (BOOL) isSandboxSafe
{
  return YES;
}

- (BOOL) passesAUVal
{
  return YES;
}

- (NSString *) versionString
{
  return nil;
}
@end

@implementation AVAudioUnitComponentManager
+ (AVAudioUnitComponentManager *) sharedAudioUnitComponentManager
{
  static AVAudioUnitComponentManager *manager = nil;
  if (manager == nil)
    manager = [[self alloc] init];
  return manager;
}

- (NSArray *) componentsPassingTest: (id)testHandler
{
  (void)testHandler;
  return [NSArray array];
}
@end

#endif
