/* Copyright (C) 2022-2026 Free Software Foundation, Inc.

   Author: Gregory John Casamento <greg.casamento@gmail.com>

   This file is part of GNUstep.
*/

#ifndef _AVTime_h_GNUSTEP_INCLUDE
#define _AVTime_h_GNUSTEP_INCLUDE

#import <Foundation/NSObjCRuntime.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_0, GS_API_LATEST)

#if defined(__cplusplus)
extern "C" {
#endif

typedef int CMTimeValue;
typedef int CMTimeScale;
typedef unsigned int CMTimeFlags;

typedef struct
{
  CMTimeValue value;
  CMTimeScale timescale;
  CMTimeFlags flags;
  long long epoch;
} CMTime;

enum
{
  kCMTimeFlags_Valid = 1UL << 0,
  kCMTimeFlags_HasBeenRounded = 1UL << 1,
  kCMTimeFlags_PositiveInfinity = 1UL << 2,
  kCMTimeFlags_NegativeInfinity = 1UL << 3,
  kCMTimeFlags_Indefinite = 1UL << 4,
  kCMTimeFlags_ImpliedValueFlagsMask = kCMTimeFlags_PositiveInfinity
    | kCMTimeFlags_NegativeInfinity | kCMTimeFlags_Indefinite
};

static const CMTime kCMTimeZero = { 0, 1, kCMTimeFlags_Valid, 0 };
static const CMTime kCMTimeInvalid = { 0, 0, 0, 0 };
static const CMTime kCMTimeIndefinite = { 0, 0,
  kCMTimeFlags_Valid | kCMTimeFlags_Indefinite, 0 };

static inline CMTime
CMTimeMake(CMTimeValue value, CMTimeScale timescale)
{
  CMTime t;
  t.value = value;
  t.timescale = timescale;
  t.flags = kCMTimeFlags_Valid;
  t.epoch = 0;
  return t;
}

static inline CMTime
CMTimeMakeWithSeconds(double seconds, CMTimeScale preferredTimescale)
{
  if (preferredTimescale <= 0)
    {
      return kCMTimeInvalid;
    }
  return CMTimeMake((CMTimeValue)(seconds * preferredTimescale),
    preferredTimescale);
}

static inline double
CMTimeGetSeconds(CMTime time)
{
  if ((time.flags & kCMTimeFlags_Valid) == 0 || time.timescale == 0)
    {
      return 0.0;
    }
  return ((double)time.value) / ((double)time.timescale);
}

#if defined(__cplusplus)
}
#endif

#endif

#endif
