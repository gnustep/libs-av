<!--
Copyright (C) 2022-2026 Free Software Foundation, Inc.

Author: Gregory John Casamento <greg.casamento@gmail.com>

This file is part of GNUstep.
-->

# libs-av

A GNUstep implementation of the AVFoundation library, based on FFmpeg (libavformat/libavcodec/libavutil) for media I/O and FluidSynth for MIDI playback.

## Requirements

- GNUstep (base, gui, and back libraries)
- FFmpeg (libavformat, libavcodec, libavutil)
- FluidSynth (optional, for MIDI playback)

## Building

```bash
. /System/Library/Makefiles/GNUstep.sh
make
```

## Supported Formats

**Audio**: aac, aif, aiff, caf, m4a, mp3, wav  
**Video**: m4v, mov, mp4, mpeg, mpg

## Reading Metadata

The framework can read metadata (ID3 tags, etc.) from media files using `AVAsset`.

### Example: Reading song metadata from an MP3 file

```objc
#import <AVFoundation/AVFoundation.h>

AVURLAsset *asset = [AVURLAsset alloc] initWithURL: [NSURL fileURLWithPath: @"song.mp3"]
                                           options: nil];

for (AVMetadataItem *item in [asset commonMetadata])
{
    NSLog(@"Key: %@  (%@)  Value: %@",
        [item key], [item keySpace], [item stringValue]);
}

// Access specific metadata:
for (AVMetadataItem *item in [asset commonMetadata])
{
    if ([[item key] isEqualToString: AVMetadataCommonKeyTitle])
    {
        NSLog(@"Title: %@", [item stringValue]);
    }
    else if ([[item key] isEqualToString: AVMetadataCommonKeyArtist])
    {
        NSLog(@"Artist: %@", [item stringValue]);
    }
    else if ([[item key] isEqualToString: AVMetadataCommonKeyAlbumName])
    {
        NSLog(@"Album: %@", [item stringValue]);
    }
    else if ([[item key] isEqualToString: AVMetadataCommonKeyComposer])
    {
        NSLog(@"Composer: %@", [item stringValue]);
    }
    else if ([[item key] isEqualToString: AVMetadataCommonKeyGenre])
    {
        NSLog(@"Genre: %@", [item stringValue]);
    }
}
```

### Cover Art

Cover art is returned as `NSData` via `AVMetadataCommonKeyArtwork`:

```objc
for (AVMetadataItem *item in [asset commonMetadata])
{
    if ([[item key] isEqualToString: AVMetadataCommonKeyArtwork])
    {
        NSData *imageData = [item value]; // NSData containing the image
        // Save to file, display in an image view, etc.
        [imageData writeToFile: @"cover.jpg" atomically: NO];
    }
}
```

### Metadata Key Spaces

- **AVMetadataKeySpaceCommon** — Cross-format common metadata keys (title, artist, album, etc.)
- **AVMetadataKeySpaceID3** — Raw ID3/FFmpeg metadata keys (used when no common key mapping exists)

### Available Common Metadata Keys

| Constant                     | FFmpeg key      | Description           |
|------------------------------|-----------------|-----------------------|
| `AVMetadataCommonKeyTitle`   | title           | Song / track title    |
| `AVMetadataCommonKeyArtist`  | artist          | Artist name           |
| `AVMetadataCommonKeyAlbumName` | album         | Album name            |
| `AVMetadataCommonKeyComposer`  | composer      | Composer name         |
| `AVMetadataCommonKeyGenre`   | genre           | Genre                 |
| `AVMetadataCommonKeyTrackNumber` | track       | Track number          |
| `AVMetadataCommonKeyCreationDate` | date       | Creation/recording date |
| `AVMetadataCommonKeySoftware` | encoder        | Encoding software     |
| `AVMetadataCommonKeyArtwork` | (attached pic)  | Cover art (NSData)    |

## Classes

### AVAsset / AVURLAsset

The main class for inspecting media assets. Create with `[AVURLAsset initWithURL:options:]`.

```objc
- (CMTime) duration;
- (BOOL) isPlayable;
- (NSArray *) tracks;
- (NSArray *) tracksWithMediaType: (NSString *)mediaType;
- (NSArray *) commonMetadata;  // Array of AVMetadataItem
```

### AVMetadataItem

Represents a single metadata key-value pair.

```objc
- (id) key;                    // The metadata key (NSString for common/ID3 keys)
- (NSString *) keySpace;       // Namespace: AVMetadataKeySpaceCommon, AVMetadataKeySpaceID3, etc.
- (id) value;                  // The value (NSString or NSData for artwork)
- (NSString *) stringValue;    // Convenience accessor for string display
- (NSNumber *) numberValue;    // Convenience accessor when value is numeric
```

### AVAssetTrack

Represents a single media track (audio, video, or subtitle).

### AVPlayer / AVAudioPlayer / AVMIDIPlayer

Playback classes for audio, video, and MIDI files.
