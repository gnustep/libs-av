/* This file is part of GNUstep */

#ifndef _AVAudioUnit_h_GNUSTEP_INCLUDE
#define _AVAudioUnit_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDate.h>
#import <AVFoundation/AVAudioEngine.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

typedef struct AudioComponentDescription
{
  UInt32 componentType;
  UInt32 componentSubType;
  UInt32 componentManufacturer;
  UInt32 componentFlags;
  UInt32 componentFlagsMask;
} AudioComponentDescription;

enum
{
  kAudioUnitType_MusicDevice = 0x61756d75,
  kAudioComponentInstantiation_LoadOutOfProcess = 1
};

typedef long long AUEventSampleTime;
typedef float AUValue;
typedef void (^AUScheduleMIDIEventBlock)(AUEventSampleTime eventSampleTime,
                                         UInt8 cable,
                                         NSInteger length,
                                         const UInt8 *midiBytes);

@interface AUParameter : NSObject
- (uint64_t) address;
- (NSString *) displayName;
- (NSString *) identifier;
- (AUValue) value;
- (AUValue) minValue;
- (AUValue) maxValue;
- (NSString *) unitName;
- (void) setValue: (AUValue)value
       originator: (id)originator;
@end

@interface AUParameterTree : NSObject
- (NSArray *) allParameters;
- (AUParameter *) parameterWithAddress: (uint64_t)address;
@end

@interface AUAudioUnit : NSObject
- (NSDictionary *) fullState;
- (void) setFullState: (NSDictionary *)state;
- (AUParameterTree *) parameterTree;
- (AUScheduleMIDIEventBlock) scheduleMIDIEventBlock;
- (void) requestViewControllerWithCompletionHandler: (void (^)(id controller))completionHandler;
@end

@interface AVAudioUnit : AVAudioNode
+ (void) instantiateWithComponentDescription: (AudioComponentDescription)audioComponentDescription
                                     options: (NSUInteger)options
                           completionHandler: (void (^)(AVAudioUnit *audioUnit,
                                                        NSError *error))completionHandler;
- (AUAudioUnit *) AUAudioUnit;
@end

@interface AVAudioUnitMIDIInstrument : AVAudioUnit
- (void) sendMIDIEvent: (UInt8)midiStatus
                 data1: (UInt8)data1
                 data2: (UInt8)data2;
- (void *) audioUnit;
@end

@interface AVAudioUnitEffect : AVAudioUnit
@end

typedef enum
{
  AVAudioUnitEQFilterTypeLowPass = 1
} AVAudioUnitEQFilterType;

@interface AVAudioUnitEQFilterParameters : NSObject
- (void) setFilterType: (AVAudioUnitEQFilterType)filterType;
- (void) setFrequency: (float)frequency;
- (void) setBypass: (BOOL)bypass;
@end

@interface AVAudioUnitEQ : AVAudioUnitEffect
{
  NSMutableArray *_bands;
  float _globalGain;
}
- (id) initWithNumberOfBands: (NSUInteger)numberOfBands;
- (NSArray *) bands;
- (void) setGlobalGain: (float)globalGain;
@end

@interface AVAudioUnitDelay : AVAudioUnitEffect
- (void) setDelayTime: (NSTimeInterval)delayTime;
- (void) setFeedback: (float)feedback;
- (void) setWetDryMix: (float)wetDryMix;
@end

typedef enum
{
  AVAudioUnitReverbPresetMediumHall = 5
} AVAudioUnitReverbPreset;

@interface AVAudioUnitReverb : AVAudioUnitEffect
- (void) loadFactoryPreset: (AVAudioUnitReverbPreset)preset;
- (void) setWetDryMix: (float)wetDryMix;
@end

@interface AVAudioUnitComponent : NSObject
- (AudioComponentDescription) audioComponentDescription;
- (NSString *) name;
- (NSString *) manufacturerName;
- (NSDictionary *) configurationDictionary;
- (BOOL) hasCustomView;
- (BOOL) isSandboxSafe;
- (BOOL) passesAUVal;
- (NSString *) versionString;
@end

@interface AVAudioUnitComponentManager : NSObject
+ (AVAudioUnitComponentManager *) sharedAudioUnitComponentManager;
- (NSArray *) componentsPassingTest: (BOOL (^)(AVAudioUnitComponent *component,
                                               BOOL *stop))testHandler;
@end

#endif

#endif
