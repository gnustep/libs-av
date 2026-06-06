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
extern NSString * const AVPlayerItemDidPlayToEndTimeNotification;

#endif

#endif
