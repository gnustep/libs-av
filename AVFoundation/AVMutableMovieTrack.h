/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVMutableMovieTrack_h_GNUSTEP_INCLUDE
#define _AVMutableMovieTrack_h_GNUSTEP_INCLUDE

#import <AVFoundation/AVMovieTrack.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

@interface AVMutableMovieTrack : AVMovieTrack
@end

#endif

#endif
