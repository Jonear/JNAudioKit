//
//  JNAVPlayer.h
//  CropMusic
//
//  Created by Jonear on 15/1/3.
//  Copyright (c) 2015年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol JNAVPlayerDelegate;

@interface JNAVPlayer : NSObject{
    AVPlayer* m_pAudioAVPlayer;
    BOOL m_bPlaying;
    NSURL* m_pAudioURL;
}

@property (weak, nonatomic) id<JNAVPlayerDelegate> delegate;

- (BOOL)initWithURL:(NSURL*)audio_url;
- (BOOL)play;
- (BOOL)continuePlay;
- (BOOL)pause;
- (BOOL)seek:(float)f_seek_time;
- (BOOL)stop;
- (double)currentTime;
- (double)duration;
- (void)setVolume:(float)f_volume;
- (BOOL)isPlaying;

- (double)loadedData;

@end

@protocol JNAVPlayerDelegate <NSObject>

- (void)didPlayStateChanged:(JNAVPlayer *)player playing:(BOOL)isPlaying;
- (void)didPlayFinished:(JNAVPlayer *)player;
- (void)didPlayError:(JNAVPlayer *)player;

@end
