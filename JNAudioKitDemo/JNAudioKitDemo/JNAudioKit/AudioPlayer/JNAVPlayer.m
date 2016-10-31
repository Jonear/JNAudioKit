//
//  JNAVPlayer.m
//  CropMusic
//
//  Created by Jonear on 15/1/3.
//  Copyright (c) 2015年 Jonear. All rights reserved.
//

#import "JNAVPlayer.h"
#import "JNAudioHelper.h"
#import "JNAudioEffectProcessor.h"

@implementation JNAVPlayer {
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
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [m_pAudioAVPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    
    m_pAudioAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[m_pAudioAVPlayer currentItem]];
    
    m_bPlaying = NO;
    
    m_pAudioURL = [audio_url copy];
    
    

    return YES;
}

- (BOOL)play {
//    UInt32 audio_route_override = [[JNAudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    AVAudioSessionPortOverride audio_route_override = [[JNAudioHelper getInstance] hasHeadset] ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:audio_route_override error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [m_pAudioAVPlayer play];
    [self setPlaying:YES];
    
    return YES;
}

- (BOOL)continuePlay {
//    sleep(1);
//    UInt32 audio_route_override = [[JNAudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    AVAudioSessionPortOverride audio_route_override = [[JNAudioHelper getInstance] hasHeadset] ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
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

@end
