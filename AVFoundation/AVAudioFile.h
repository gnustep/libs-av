/* This file is part of GNUstep */

#ifndef _AVAudioFile_h_GNUSTEP_INCLUDE
#define _AVAudioFile_h_GNUSTEP_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileHandle.h>
#import <AVFoundation/AVAudioPCMBuffer.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVAudioFile : NSObject
{
  NSURL *_url;
  NSFileHandle *_fileHandle;
  AVAudioFormat *_processingFormat;
  AVAudioFramePosition _length;
  BOOL _writing;
}

- (id) initForWriting: (NSURL *)url
             settings: (NSDictionary *)settings
                error: (NSError **)outError;
- (id) initForReading: (NSURL *)url
                error: (NSError **)outError;
- (BOOL) writeFromBuffer: (AVAudioPCMBuffer *)buffer
                   error: (NSError **)outError;
- (BOOL) readIntoBuffer: (AVAudioPCMBuffer *)buffer
                  error: (NSError **)outError;
- (AVAudioFormat *) processingFormat;
- (AVAudioFramePosition) length;

@end

#endif

#endif
