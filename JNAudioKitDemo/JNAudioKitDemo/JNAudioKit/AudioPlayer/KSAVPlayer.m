//
//  KSAVPlayer.m
//  CropMusic
//
//  Created by Jonear on 15/1/3.
//  Copyright (c) 2015年 Jonear. All rights reserved.
//

#import "KSAVPlayer.h"
#import "AudioHelper.h"
#import "JNAudioEffectProcessor.h"

@implementation KSAVPlayer {
    AVPlayerItem *_playerItem;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        m_pAudioAVPlayer = [[AVPlayer alloc] init];
        
    }
    return self;
}

- (BOOL)initWithURL:(NSURL*)audio_url {
    
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }

    _playerItem = [AVPlayerItem playerItemWithURL:audio_url];
    [self initCallBack:audio_url];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [m_pAudioAVPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    
    m_pAudioAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[m_pAudioAVPlayer currentItem]];
    
    m_bPlaying = NO;
    
    m_pAudioURL = [audio_url copy];
    
    

    return YES;
}

- (void)initCallBack:(NSURL*)audio_url {
    // Continuing on from where we created the AVAsset...
    AVAsset *asset = [AVAsset assetWithURL:audio_url];
    AVAssetTrack *audioTrack = [[asset tracks] objectAtIndex:0];
    AVMutableAudioMixInputParameters *inputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    
    // Create a processing tap for the input parameters
    MTAudioProcessingTapCallbacks callbacks;
    callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
    callbacks.clientInfo = (__bridge void *)(self);
    callbacks.init = init;
    callbacks.prepare = prepare;
    callbacks.process = process;
    callbacks.unprepare = unprepare;
    callbacks.finalize = finalize;
    
    MTAudioProcessingTapRef tap;
    // The create function makes a copy of our callbacks struct
    OSStatus err = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks,
                                              kMTAudioProcessingTapCreationFlag_PostEffects, &tap);
    if (err || !tap) {
        NSLog(@"Unable to create the Audio Processing Tap");
        return;
    }
    assert(tap);
    
    // Assign the tap to the input parameters
    inputParams.audioTapProcessor = tap;
    
    // Create a new AVAudioMix and assign it to our AVPlayerItem
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[inputParams];
    _playerItem.audioMix = audioMix;
    
    // And then we create the AVPlayer with the playerItem, and send it the play message...
}

- (BOOL)play {
//    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    AVAudioSessionPortOverride audio_route_override = [[AudioHelper getInstance] hasHeadset] ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:audio_route_override error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [m_pAudioAVPlayer play];
    [self setPlaying:YES];
    
    return YES;
}

- (BOOL)continuePlay {
//    sleep(1);
//    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    AVAudioSessionPortOverride audio_route_override = [[AudioHelper getInstance] hasHeadset] ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:audio_route_override error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [m_pAudioAVPlayer play];
    [self setPlaying:YES];
    //    NSLog(@"%f", m_pAVPlayer.rate);
    return YES;
}

- (BOOL)pause {
    [m_pAudioAVPlayer pause];
    [self setPlaying:NO];
    
    return YES;
}

- (BOOL)stop {
    [m_pAudioAVPlayer pause];
    [m_pAudioAVPlayer seekToTime:kCMTimeZero];
    [self setPlaying:NO];
    
    return YES;
}

- (BOOL)seek:(float)f_seek_time {
    if (f_seek_time >= [self loadedData] || f_seek_time >= [self duration]) {
        return NO;
    }
    
    CMTime new_time = CMTimeMakeWithSeconds(f_seek_time, NSEC_PER_SEC);
    
    [m_pAudioAVPlayer seekToTime:new_time];
    
    return YES;
}

- (void)setVolume:(float)f_volume {
    AVURLAsset* p_audio_asset = [AVURLAsset assetWithURL:m_pAudioURL];
    NSArray* audio_tracks = [p_audio_asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray* audio_paras = [NSMutableArray array];
    for (AVAssetTrack* track in audio_tracks) {
        AVMutableAudioMixInputParameters* audio_input_paras = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audio_input_paras setVolume:f_volume atTime:kCMTimeZero];
        [audio_input_paras setTrackID:[track trackID]];
        [audio_paras addObject:audio_input_paras];
    }
    AVMutableAudioMix* audio_accompany_zero_mix = [AVMutableAudioMix audioMix];
    [audio_accompany_zero_mix setInputParameters:audio_paras];
    [m_pAudioAVPlayer.currentItem setAudioMix:audio_accompany_zero_mix];
}

- (double)currentTime {
    return CMTimeGetSeconds([m_pAudioAVPlayer currentTime]);
}

- (double)duration {
    return CMTimeGetSeconds(m_pAudioAVPlayer.currentItem.asset.duration);
}

- (double)loadedData {
    if (0 == [m_pAudioAVPlayer.currentItem.loadedTimeRanges count]) {
        return 0;
    }
    return CMTimeGetSeconds([[m_pAudioAVPlayer.currentItem.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue].duration);
}

- (BOOL)isPlaying {
    return m_bPlaying;
}

- (void)setPlaying:(BOOL)isPlaying {
    m_bPlaying = isPlaying;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didPlayStateChanged:playing:)]) {
        [_delegate didPlayStateChanged:self playing:m_bPlaying];
    }
}

- (void) playFinished:(NSNotification*)notification {
    [m_pAudioAVPlayer pause];
    [m_pAudioAVPlayer seekToTime:kCMTimeZero];
    //
    if (_delegate && [_delegate respondsToSelector:@selector(didPlayFinished:)]) {
        [_delegate didPlayFinished:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItemStatus status = [[change objectForKey:@"new"] integerValue];
    if (status == AVPlayerItemStatusFailed) {
        if (_delegate && [_delegate respondsToSelector:@selector(didPlayError:)]) {
            [_delegate didPlayError:self];
        }
    }
}


void init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    NSLog(@"Initialising the Audio Tap Processor");
    *tapStorageOut = clientInfo;
}

void finalize(MTAudioProcessingTapRef tap)
{
    NSLog(@"Finalizing the Audio Tap Processor");
}

void prepare(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{
    NSLog(@"Preparing the Audio Tap Processor");
}

void unprepare(MTAudioProcessingTapRef tap)
{
    NSLog(@"Unpreparing the Audio Tap Processor");
}

void process(MTAudioProcessingTapRef tap, CMItemCount numberFrames,
             MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut,
             CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut)
{
    OSStatus err = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut,
                                                      flagsOut, NULL, numberFramesOut);
    if (err) NSLog(@"Error from GetSourceAudio: %zd", err);

//    LAKEViewController *self = (__bridge LAKEViewController *) MTAudioProcessingTapGetStorage(tap);
//    
//    float scalar = self.slider.value;
    
//    vDSP_vsmul(bufferListInOut->mBuffers[LAKE_RIGHT_CHANNEL].mData, 1, &scalar, bufferListInOut->mBuffers[LAKE_RIGHT_CHANNEL].mData, 1, bufferListInOut->mBuffers[LAKE_RIGHT_CHANNEL].mDataByteSize / sizeof(float));
//    vDSP_vsmul(bufferListInOut->mBuffers[LAKE_LEFT_CHANNEL].mData, 1, &scalar, bufferListInOut->mBuffers[LAKE_LEFT_CHANNEL].mData, 1, bufferListInOut->mBuffers[LAKE_LEFT_CHANNEL].mDataByteSize / sizeof(float));
    
//    [JNAudioEffectProcessor process:JNAudioEffectType_BigRoom samples:bufferListInOut->mBuffers[0].mData numsamples:bufferListInOut->mBuffers[0].mDataByteSize/2];
    
}
@end
