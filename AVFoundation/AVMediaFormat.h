/* This file is part of GNUstep */

#ifndef _AVMediaFormat_h_GNUSTEP_INCLUDE
#define _AVMediaFormat_h_GNUSTEP_INCLUDE

#import <Foundation/NSString.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

extern NSString * const AVMediaTypeAudio;
extern NSString * const AVMediaTypeVideo;
extern NSString * const AVMediaTypeText;
extern NSString * const AVMetadataCommonKeyTitle;
extern NSString * const AVMetadataCommonKeyArtist;
extern NSString * const AVMetadataCommonKeyAlbumName;
extern NSString * const AVMetadataCommonKeyComposer;
extern NSString * const AVMetadataCommonKeyGenre;
extern NSString * const AVMetadataCommonKeyTrackNumber;
extern NSString * const AVMetadataCommonKeyArtwork;
extern NSString * const AVMetadataCommonKeyCreationDate;
extern NSString * const AVMetadataCommonKeySoftware;
extern NSString * const AVMetadataKeySpaceCommon;
extern NSString * const AVMetadataKeySpaceID3;
extern NSString * const AVPlayerItemDidPlayToEndTimeNotification;

#endif

#endif
