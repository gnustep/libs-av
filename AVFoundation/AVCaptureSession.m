/* This file is part of GNUstep */

#import "AVCaptureSession.h"
#import "AVCaptureInput.h"
#import "AVCaptureOutput.h"
#import "AVCaptureAudioDataOutput.h"
#import "AVCaptureDevice.h"

#import <Foundation/NSDictionary.h>

@interface AVCaptureInput (Private)
- (void)_setSession:(AVCaptureSession *)s;
@end

@interface AVCaptureOutput (Private)
- (void)_setSession:(AVCaptureSession *)s;
@end
#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSThread.h>

#include <libavdevice/avdevice.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libswresample/swresample.h>
#include <pthread.h>
#include <stdlib.h>

NSString *const AVCaptureSessionDidStartRunningNotification = @"AVCaptureSessionDidStartRunningNotification";
NSString *const AVCaptureSessionDidStopRunningNotification  = @"AVCaptureSessionDidStopRunningNotification";

#define DEFAULT_SAMPLE_RATE 16000

#pragma mark - Audio pipe thread

typedef struct {
  AVFormatContext *fmtCtx;
  AVCodecContext  *decCtx;
  int              streamIdx;
  int              sampleRate;
  AVCaptureAudioDataOutput *output;
  BOOL             running;
} CaptureContext;

static void *capture_thread(void *arg)
{
  CaptureContext *ctx = (CaptureContext *)arg;
  AVPacket *packet = av_packet_alloc();
  AVFrame *frame = av_frame_alloc();
  SwrContext *swr = NULL;
  float *floatBuf = NULL;
  int floatBufCap = 0;

  while (ctx->running && av_read_frame(ctx->fmtCtx, packet) >= 0) {
    if (packet->stream_index == ctx->streamIdx) {
      if (avcodec_send_packet(ctx->decCtx, packet) == 0) {
        while (avcodec_receive_frame(ctx->decCtx, frame) == 0) {
          if (!swr) {
            SwrContext *tmp = NULL;
            AVChannelLayout monoLayout = AV_CHANNEL_LAYOUT_MONO;
            AVChannelLayout srcLayout = frame->ch_layout;
            enum AVSampleFormat srcFmt = (enum AVSampleFormat)frame->format;
            if (swr_alloc_set_opts2(&tmp,
                  &monoLayout, AV_SAMPLE_FMT_FLT, ctx->sampleRate,
                  &srcLayout, srcFmt, frame->sample_rate,
                  0, NULL) >= 0) {
              swr = tmp;
              if (swr_init(swr) < 0) { swr_free(&swr); break; }
            } else {
              break;
            }
          }

          int outSamples = av_rescale_rnd(
            swr_get_delay(swr, frame->sample_rate) + frame->nb_samples,
            ctx->sampleRate, frame->sample_rate, AV_ROUND_UP);
          int bufSize = outSamples * sizeof(float);
          if (bufSize > floatBufCap) {
            floatBuf = realloc(floatBuf, bufSize);
            floatBufCap = bufSize;
          }

          uint8_t *out[] = { (uint8_t *)floatBuf };
          int converted = swr_convert(swr, out, outSamples,
            (const uint8_t **)frame->data, frame->nb_samples);
          if (converted > 0) {
            id delegate = [ctx->output sampleDelegate];
            if (delegate) {
              NSData *data = [NSData dataWithBytesNoCopy:floatBuf
                                                  length:converted * sizeof(float)
                                            freeWhenDone:NO];
              [delegate captureOutput:ctx->output
                   didOutputSampleData:data
                            numSamples:converted
                            sampleRate:ctx->sampleRate];
            }
          }
        }
      }
    }
    av_packet_unref(packet);
  }

  av_frame_free(&frame);
  av_packet_free(&packet);
  avcodec_free_context(&ctx->decCtx);
  avformat_close_input(&ctx->fmtCtx);
  free(floatBuf);
  swr_free(&swr);
  return NULL;
}

#pragma mark - AVCaptureSession

@implementation AVCaptureSession

- (id)init
{
  self = [super init];
  if (self) {
    _inputs = [[NSMutableArray alloc] init];
    _outputs = [[NSMutableArray alloc] init];
    _connections = [[NSMutableArray alloc] init];
    _sessionPreset = AVCaptureSessionPreset16000;
    _sampleRate = DEFAULT_SAMPLE_RATE;
  }
  return self;
}

- (void)dealloc
{
  [self stopRunning];
  [_inputs release];
  [_outputs release];
  [_connections release];
  [super dealloc];
}

- (BOOL)canAddInput:(AVCaptureInput *)input { return input != nil && !_running; }
- (BOOL)canAddOutput:(AVCaptureOutput *)output { return output != nil && !_running; }

- (void)addInput:(AVCaptureInput *)input
{
  if (![self canAddInput:input]) return;
  [_inputs addObject:input];
  [input _setSession:self];
}

- (void)removeInput:(AVCaptureInput *)input
{
  [input _setSession:nil];
  [_inputs removeObjectIdenticalTo:input];
}

- (void)addOutput:(AVCaptureOutput *)output
{
  if (![self canAddOutput:output]) return;
  [_outputs addObject:output];
  [output _setSession:self];
}

- (void)removeOutput:(AVCaptureOutput *)output
{
  [output _setSession:nil];
  [_outputs removeObjectIdenticalTo:output];
}

- (void)startRunning
{
  if (_running) return;

  AVCaptureDevice *device = nil;
  for (AVCaptureInput *input in _inputs) {
    if ([input isKindOfClass:[AVCaptureDeviceInput class]]) {
      device = [(AVCaptureDeviceInput *)input device];
      break;
    }
  }
  if (!device) {
    device = [AVCaptureDevice defaultDeviceWithMediaType:@"AVMediaTypeAudio"];
  }
  if (!device) return;

  NSString *devPath = [device uniqueID];

  avdevice_register_all();

  const AVInputFormat *fmt = av_find_input_format("alsa");
  if (!fmt) fmt = av_find_input_format("oss");
  if (!fmt) fmt = av_find_input_format("pulse");

  AVFormatContext *fmtCtx = NULL;
  AVDictionary *opts = NULL;
  av_dict_set(&opts, "sample_rate",
              [[NSString stringWithFormat:@"%d", _sampleRate] UTF8String], 0);
  av_dict_set(&opts, "channels", "1", 0);

  if (avformat_open_input(&fmtCtx,
                           [devPath UTF8String], fmt, &opts) != 0) {
    NSDebugLLog(@"AVCapture", @"avformat_open_input failed for %@", devPath);
    av_dict_free(&opts);
    return;
  }
  av_dict_free(&opts);

  if (avformat_find_stream_info(fmtCtx, NULL) < 0) {
    avformat_close_input(&fmtCtx);
    return;
  }

  int streamIdx = -1;
  for (unsigned i = 0; i < fmtCtx->nb_streams; i++) {
    if (fmtCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
      streamIdx = i;
      break;
    }
  }
  if (streamIdx < 0) {
    avformat_close_input(&fmtCtx);
    return;
  }

  const AVCodec *codec = avcodec_find_decoder(
    fmtCtx->streams[streamIdx]->codecpar->codec_id);
  if (!codec) { avformat_close_input(&fmtCtx); return; }

  AVCodecContext *decCtx = avcodec_alloc_context3(codec);
  if (!decCtx) { avformat_close_input(&fmtCtx); return; }
  avcodec_parameters_to_context(decCtx,
    fmtCtx->streams[streamIdx]->codecpar);
  if (avcodec_open2(decCtx, codec, NULL) < 0) {
    avcodec_free_context(&decCtx);
    avformat_close_input(&fmtCtx);
    return;
  }

  CaptureContext *capCtx = calloc(1, sizeof(CaptureContext));
  capCtx->fmtCtx = fmtCtx;
  capCtx->decCtx = decCtx;
  capCtx->streamIdx = streamIdx;
  capCtx->sampleRate = _sampleRate;
  capCtx->output = [_outputs lastObject];
  capCtx->running = YES;
  _captureHandle = capCtx;

  pthread_t thread;
  pthread_create(&thread, NULL, capture_thread, capCtx);
  pthread_detach(thread);

  _running = YES;
  [[NSNotificationCenter defaultCenter]
    postNotificationName:AVCaptureSessionDidStartRunningNotification
                  object:self];
}

- (void)stopRunning
{
  if (!_running) return;
  CaptureContext *capCtx = (CaptureContext *)_captureHandle;
  if (capCtx) {
    capCtx->running = NO;
    free(capCtx);
  }
  _captureHandle = NULL;
  _running = NO;
  [[NSNotificationCenter defaultCenter]
    postNotificationName:AVCaptureSessionDidStopRunningNotification
                  object:self];
}

- (BOOL)isRunning { return _running; }
- (NSArray *)inputs { return _inputs; }
- (NSArray *)outputs { return _outputs; }
- (AVCaptureSessionPreset)sessionPreset { return _sessionPreset; }

- (void)setSessionPreset:(AVCaptureSessionPreset)p
{
  _sessionPreset = p;
  switch (p) {
    case AVCaptureSessionPresetHigh:   _sampleRate = 48000; break;
    case AVCaptureSessionPresetMedium: _sampleRate = 44100; break;
    case AVCaptureSessionPresetLow:    _sampleRate = 22050; break;
    case AVCaptureSessionPreset16000:
    default:                           _sampleRate = 16000; break;
  }
}

@end
