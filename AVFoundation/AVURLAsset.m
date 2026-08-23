/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#import "AVURLAsset.h"
#import "AVAssetTrack.h"
#import "AVMetadataItem.h"
#import "AVMediaFormat.h"

#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>

#ifdef AVFOUNDATION_HAVE_FFMPEG
#include <libavformat/avformat.h>
#endif

static BOOL
AVStringInArray(NSString *string, NSArray *array)
{
  unsigned int i;

  for (i = 0; i < [array count]; i++)
    {
      if ([string caseInsensitiveCompare: [array objectAtIndex: i]]
        == NSOrderedSame)
        {
          return YES;
        }
    }
  return NO;
}

static BOOL
AVTracksContainMediaType(NSArray *tracks, NSString *mediaType)
{
  unsigned int i;

  for (i = 0; i < [tracks count]; i++)
    {
      if ([[[tracks objectAtIndex: i] mediaType] isEqualToString: mediaType])
        {
          return YES;
        }
    }
  return NO;
}

// Map FFmpeg metadata keys to AVMetadataCommonKey constants.
// Returns the common key string, or nil if no mapping exists.
static NSString *
_commonKeyForFFmpegKey(const char *key)
{
  if (strcmp(key, "title") == 0)      return AVMetadataCommonKeyTitle;
  if (strcmp(key, "artist") == 0)     return AVMetadataCommonKeyArtist;
  if (strcmp(key, "album") == 0)      return AVMetadataCommonKeyAlbumName;
  if (strcmp(key, "composer") == 0)   return AVMetadataCommonKeyComposer;
  if (strcmp(key, "genre") == 0)      return AVMetadataCommonKeyGenre;
  if (strcmp(key, "track") == 0)      return AVMetadataCommonKeyTrackNumber;
  if (strcmp(key, "date") == 0)       return AVMetadataCommonKeyCreationDate;
  if (strcmp(key, "encoder") == 0)    return AVMetadataCommonKeySoftware;
  return nil;
}

@implementation AVURLAsset

+ (NSArray *) audiovisualTypes
{
  return [NSArray arrayWithObjects: @"aac", @"aif", @"aiff", @"caf", @"m4a",
    @"m4v", @"mov", @"mp3", @"mp4", @"mpeg", @"mpg", @"wav", nil];
}

+ (NSArray *) audiovisualMIMETypes
{
  return [NSArray arrayWithObjects: @"audio/aac", @"audio/aiff",
    @"audio/mpeg", @"audio/mp4", @"audio/wav", @"video/mp4",
    @"video/quicktime", @"video/mpeg", nil];
}

+ (BOOL) isPlayableExtendedMIMEType: (NSString *)extendedMIMEType
{
  NSString *mimeType;
  NSRange range;

  range = [extendedMIMEType rangeOfString: @";"];
  if (range.location == NSNotFound)
    {
      mimeType = extendedMIMEType;
    }
  else
    {
      mimeType = [extendedMIMEType substringToIndex: range.location];
    }
  return AVStringInArray([mimeType stringByTrimmingSpaces],
    [self audiovisualMIMETypes]);
}

- (id) initWithURL: (NSURL *)URL options: (NSDictionary *)options
{
  NSString *path;
  NSString *extension;
  NSMutableArray *tracks;
  NSMutableArray *metadata;
  NSDictionary *attributes;
  BOOL isDirectory;

  self = [super init];
  if (self == nil)
    {
      return nil;
    }

  ASSIGN(_URL, URL);
  path = [_URL isFileURL] ? [_URL path] : [_URL absoluteString];
  extension = [[path pathExtension] lowercaseString];
  tracks = [NSMutableArray array];
  metadata = [NSMutableArray array];
  isDirectory = NO;

  if ([_URL isFileURL]
    && [[NSFileManager defaultManager] fileExistsAtPath: path
                                           isDirectory: &isDirectory]
    && isDirectory == NO)
    {
      attributes = [[NSFileManager defaultManager] fileAttributesAtPath: path
                                                           traverseLink: YES];
      if ([attributes objectForKey: NSFileSize] != nil)
        {
          AVMetadataItem *item;
          item = [[AVMetadataItem alloc] initWithKey: @"fileSize"
                                          keySpace: @"GNUstep"
                                             value: [attributes objectForKey:
                                                        NSFileSize]];
          [metadata addObject: item];
          RELEASE(item);
        }
      _playable = AVStringInArray(extension, [[self class] audiovisualTypes]);
    }
  else
    {
      _playable = ([_URL scheme] != nil);
    }

#ifdef AVFOUNDATION_HAVE_FFMPEG
  if ([_URL isFileURL] && isDirectory == NO)
    {
      AVFormatContext *formatContext;
      int result;

      formatContext = NULL;
      result = avformat_open_input(&formatContext, [path fileSystemRepresentation],
        NULL, NULL);
      if (result == 0)
        {
          result = avformat_find_stream_info(formatContext, NULL);
        }
      if (result >= 0 && formatContext != NULL)
        {
          unsigned int i;

          [tracks removeAllObjects];
          _playable = YES;
          if (formatContext->duration != AV_NOPTS_VALUE)
            {
              _duration = CMTimeMakeWithSeconds(
                ((double)formatContext->duration) / ((double)AV_TIME_BASE),
                600);
            }

          // Read format-level metadata (ID3 tags, etc.)
          {
            AVDictionaryEntry *tag = NULL;
            while ((tag = av_dict_get(formatContext->metadata, "",
              tag, AV_DICT_IGNORE_SUFFIX)) != NULL)
              {
                NSString *key = [NSString stringWithUTF8String: tag->key];
                NSString *value = [NSString stringWithUTF8String: tag->value];
                NSString *commonKey;
                AVMetadataItem *item;

                commonKey = _commonKeyForFFmpegKey(tag->key);
                if (commonKey != nil)
                  {
                    item = [[AVMetadataItem alloc] initWithKey: commonKey
                                                      keySpace: AVMetadataKeySpaceCommon
                                                         value: value];
                  }
                else
                  {
                    item = [[AVMetadataItem alloc] initWithKey: key
                                                      keySpace: AVMetadataKeySpaceID3
                                                         value: value];
                  }
                [metadata addObject: item];
                RELEASE(item);
              }
          }

          for (i = 0; i < formatContext->nb_streams; i++)
            {
              AVStream *stream;
              AVCodecParameters *codecParameters;
              NSString *mediaType;
              CMTimeScale timeScale;

              stream = formatContext->streams[i];
              codecParameters = stream->codecpar;
              mediaType = nil;
              timeScale = 600;

              if (codecParameters->codec_type == AVMEDIA_TYPE_AUDIO)
                {
                  mediaType = AVMediaTypeAudio;
                  timeScale = codecParameters->sample_rate > 0
                    ? codecParameters->sample_rate : 44100;
                }
              else if (codecParameters->codec_type == AVMEDIA_TYPE_VIDEO)
                {
                  mediaType = AVMediaTypeVideo;
                  timeScale = stream->time_base.den > 0
                    ? stream->time_base.den : 600;
                }
              else if (codecParameters->codec_type == AVMEDIA_TYPE_SUBTITLE)
                {
                  mediaType = AVMediaTypeText;
                }

              if (mediaType != nil)
                {
                  AVAssetTrack *track;
                  track = [[AVAssetTrack alloc] initWithMediaType: mediaType
                                                          trackID: (int)(i + 1)
                                                  naturalTimeScale: timeScale];
                  [tracks addObject: track];
                  RELEASE(track);
                }
            }

          // Look for attached pictures (album art) in video streams
          // with AV_DISPOSITION_ATTACHED_PIC disposition.
          for (i = 0; i < formatContext->nb_streams; i++)
            {
              AVStream *stream = formatContext->streams[i];
              if (stream->disposition & AV_DISPOSITION_ATTACHED_PIC)
                {
                  AVPacket *pkt = &stream->attached_pic;
                  if (pkt->size > 0 && pkt->data != NULL)
                    {
                      NSData *imageData;
                      AVMetadataItem *item;

                      imageData = [NSData dataWithBytes: pkt->data
                                                  length: pkt->size];
                      item = [[AVMetadataItem alloc]
                        initWithKey: AVMetadataCommonKeyArtwork
                             keySpace: AVMetadataKeySpaceCommon
                                value: imageData];
                      [metadata addObject: item];
                      RELEASE(item);
                    }
                }
            }
        }
      if (formatContext != NULL)
        {
          avformat_close_input(&formatContext);
        }
    }
#endif

  if (_playable == YES)
    {
      if (AVTracksContainMediaType(tracks, AVMediaTypeVideo) == NO
        && AVStringInArray(extension, [NSArray arrayWithObjects: @"m4v",
          @"mov", @"mp4", @"mpeg", @"mpg", nil]))
        {
          AVAssetTrack *track;
          track = [[AVAssetTrack alloc] initWithMediaType: AVMediaTypeVideo
                                                  trackID: 1
                                          naturalTimeScale: 600];
          [tracks addObject: track];
          RELEASE(track);
        }
      if (AVTracksContainMediaType(tracks, AVMediaTypeAudio) == NO
        && AVStringInArray(extension, [NSArray arrayWithObjects: @"aac",
          @"aif", @"aiff", @"caf", @"m4a", @"mov", @"mp3", @"mp4", @"wav",
          nil]))
        {
          AVAssetTrack *track;
          track = [[AVAssetTrack alloc] initWithMediaType: AVMediaTypeAudio
                                                  trackID: [tracks count] + 1
                                          naturalTimeScale: 44100];
          [tracks addObject: track];
          RELEASE(track);
        }
    }

  ASSIGN(_tracks, tracks);
  ASSIGN(_metadata, metadata);
  _duration = kCMTimeIndefinite;

  return self;
}

- (NSURL *) URL
{
  return _URL;
}

@end
