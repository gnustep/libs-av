/* This file is part of GNUstep */

#import <AVFoundation/AVAudioFile.h>
#import <Foundation/NSData.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSValue.h>
#include <string.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

static NSString *AVAudioFileErrorDomain = @"AVAudioFileErrorDomain";

static void
AVWriteUInt16LE(NSMutableData *data, uint16_t value)
{
  uint8_t bytes[2] = { value & 0xff, (value >> 8) & 0xff };
  [data appendBytes: bytes length: sizeof (bytes)];
}

static void
AVWriteUInt32LE(NSMutableData *data, uint32_t value)
{
  uint8_t bytes[4] = {
    value & 0xff,
    (value >> 8) & 0xff,
    (value >> 16) & 0xff,
    (value >> 24) & 0xff
  };
  [data appendBytes: bytes length: sizeof (bytes)];
}

static uint16_t
AVReadUInt16LE(const uint8_t *bytes)
{
  return (uint16_t)bytes[0] | ((uint16_t)bytes[1] << 8);
}

static uint32_t
AVReadUInt32LE(const uint8_t *bytes)
{
  return (uint32_t)bytes[0] | ((uint32_t)bytes[1] << 8)
    | ((uint32_t)bytes[2] << 16) | ((uint32_t)bytes[3] << 24);
}

static NSError *
AVAudioFileError(NSInteger code, NSString *description)
{
  return [NSError errorWithDomain: AVAudioFileErrorDomain
                             code: code
                         userInfo: [NSDictionary dictionaryWithObject: description
                                                                forKey: NSLocalizedDescriptionKey]];
}

@implementation AVAudioFile

- (id) initForWriting: (NSURL *)url
             settings: (NSDictionary *)settings
                error: (NSError **)outError
{
  double sampleRate;
  AVAudioChannelCount channelCount;
  NSMutableData *header;

  if ((self = [super init]))
    {
      _url = [url retain];
      sampleRate = [[settings objectForKey: AVSampleRateKey] doubleValue];
      channelCount = [[settings objectForKey: AVNumberOfChannelsKey] unsignedIntValue];
      if (sampleRate <= 0.0)
        sampleRate = 44100.0;
      if (channelCount == 0)
        channelCount = 2;
      _processingFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate: sampleRate
                                                                         channels: channelCount];
      header = [NSMutableData dataWithCapacity: 44];
      [header appendBytes: "RIFF" length: 4];
      AVWriteUInt32LE(header, 36);
      [header appendBytes: "WAVEfmt " length: 8];
      AVWriteUInt32LE(header, 16);
      AVWriteUInt16LE(header, 3);
      AVWriteUInt16LE(header, (uint16_t)channelCount);
      AVWriteUInt32LE(header, (uint32_t)sampleRate);
      AVWriteUInt32LE(header, (uint32_t)(sampleRate * channelCount * sizeof (float)));
      AVWriteUInt16LE(header, (uint16_t)(channelCount * sizeof (float)));
      AVWriteUInt16LE(header, 32);
      [header appendBytes: "data" length: 4];
      AVWriteUInt32LE(header, 0);
      [[NSFileManager defaultManager] createFileAtPath: [url path]
                                              contents: header
                                            attributes: nil];
      _fileHandle = [[NSFileHandle fileHandleForWritingAtPath: [url path]] retain];
      if (_fileHandle == nil)
        {
          if (outError != NULL)
            *outError = AVAudioFileError(1, @"Could not open audio file for writing.");
          [self release];
          return nil;
        }
      [_fileHandle seekToEndOfFile];
      _writing = YES;
    }
  return self;
}

- (id) initForReading: (NSURL *)url
                error: (NSError **)outError
{
  NSData *data;
  const uint8_t *bytes;
  NSUInteger length;
  uint16_t audioFormat, channelCount, bitsPerSample;
  uint32_t sampleRate, dataSize;

  if ((self = [super init]))
    {
      _url = [url retain];
      data = [NSData dataWithContentsOfFile: [url path]];
      length = [data length];
      if (length < 44)
        {
          if (outError != NULL)
            *outError = AVAudioFileError(2, @"The audio file is too short.");
          [self release];
          return nil;
        }
      bytes = [data bytes];
      if (memcmp (bytes, "RIFF", 4) != 0 || memcmp (bytes + 8, "WAVE", 4) != 0
          || memcmp (bytes + 12, "fmt ", 4) != 0 || memcmp (bytes + 36, "data", 4) != 0)
        {
          if (outError != NULL)
            *outError = AVAudioFileError(3, @"Only simple RIFF/WAVE audio files are supported.");
          [self release];
          return nil;
        }
      audioFormat = AVReadUInt16LE(bytes + 20);
      channelCount = AVReadUInt16LE(bytes + 22);
      sampleRate = AVReadUInt32LE(bytes + 24);
      bitsPerSample = AVReadUInt16LE(bytes + 34);
      dataSize = AVReadUInt32LE(bytes + 40);
      if (audioFormat != 3 || bitsPerSample != 32 || channelCount == 0)
        {
          if (outError != NULL)
            *outError = AVAudioFileError(4, @"Only 32-bit float WAVE audio is supported.");
          [self release];
          return nil;
        }
      _processingFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate: sampleRate
                                                                         channels: channelCount];
      _length = dataSize / (channelCount * sizeof (float));
      _fileHandle = [[NSFileHandle fileHandleForReadingAtPath: [url path]] retain];
      [_fileHandle seekToFileOffset: 44];
    }
  return self;
}

- (BOOL) writeFromBuffer: (AVAudioPCMBuffer *)buffer
                   error: (NSError **)outError
{
  NSMutableData *data;
  AVAudioFrameCount frames, frame;
  AVAudioChannelCount channels, channel;
  float **samples;

  if (!_writing || _fileHandle == nil)
    {
      if (outError != NULL)
        *outError = AVAudioFileError(5, @"The audio file is not open for writing.");
      return NO;
    }
  frames = [buffer frameLength];
  channels = [[buffer format] channelCount];
  samples = [buffer floatChannelData];
  data = [NSMutableData dataWithCapacity: frames * channels * sizeof (float)];
  for (frame = 0; frame < frames; frame++)
    for (channel = 0; channel < channels; channel++)
      [data appendBytes: &samples[channel][frame] length: sizeof (float)];
  [_fileHandle writeData: data];
  _length += frames;
  return YES;
}

- (BOOL) readIntoBuffer: (AVAudioPCMBuffer *)buffer
                  error: (NSError **)outError
{
  NSData *data;
  const float *samples;
  AVAudioFrameCount frames, frame;
  AVAudioChannelCount channels, channel;
  float **destination;

  if (_fileHandle == nil)
    {
      if (outError != NULL)
        *outError = AVAudioFileError(6, @"The audio file is not open for reading.");
      return NO;
    }
  channels = [_processingFormat channelCount];
  frames = MIN ((AVAudioFrameCount)_length, [buffer frameCapacity]);
  data = [_fileHandle readDataOfLength: frames * channels * sizeof (float)];
  if ([data length] < frames * channels * sizeof (float))
    {
      if (outError != NULL)
        *outError = AVAudioFileError(7, @"Could not read the requested audio frames.");
      return NO;
    }
  samples = [data bytes];
  destination = [buffer floatChannelData];
  for (frame = 0; frame < frames; frame++)
    for (channel = 0; channel < channels; channel++)
      destination[channel][frame] = samples[frame * channels + channel];
  [buffer setFrameLength: frames];
  return YES;
}

- (AVAudioFormat *) processingFormat
{
  return _processingFormat;
}

- (AVAudioFramePosition) length
{
  return _length;
}

- (void) dealloc
{
  if (_writing && _fileHandle != nil)
    {
      uint32_t dataSize = (uint32_t)(_length * [_processingFormat channelCount] * sizeof (float));
      NSMutableData *riffSize = [NSMutableData dataWithCapacity: 4];
      NSMutableData *chunkSize = [NSMutableData dataWithCapacity: 4];
      AVWriteUInt32LE(riffSize, dataSize + 36);
      AVWriteUInt32LE(chunkSize, dataSize);
      [_fileHandle seekToFileOffset: 4];
      [_fileHandle writeData: riffSize];
      [_fileHandle seekToFileOffset: 40];
      [_fileHandle writeData: chunkSize];
    }
  [_fileHandle closeFile];
  [_fileHandle release];
  [_processingFormat release];
  [_url release];
  [super dealloc];
}

@end

#endif
