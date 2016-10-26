//
//  ViewController.m
//  JNAudioKitDemo
//
//  Created by NetEase on 16/10/24.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "ViewController.h"

#import "KSAVPlayer.h"
#import "CMRecordManager.h"
#import "ALWAVTOACCFile.h"
#import "STKAudioPlayer.h"
#import "JNAudioEffectProcessor.h"

@interface ViewController () <CMRecordDelegate, KSAVPlayerDelegate, STKAudioPlayerDelegate>

@end

@implementation ViewController {
    STKAudioPlayer *audioPlayer;
    KSAVPlayer *avPlayer;
    NSString *_strpath;
    NSString *_aacstrpath;
    UIButton *_demoButton;
    CMRecordManager *record;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"a.wav"];
    _aacstrpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"aac.m4a"];
    record = [[CMRecordManager alloc] init];
    record.delegate = self;
    
    audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){.enableVolumeMixer = YES}];
    audioPlayer.delegate = self;
    
    avPlayer = [[KSAVPlayer alloc] init];
    avPlayer.delegate = self;
    
    _demoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 100, 100)];
    [_demoButton setCenter:CGPointMake(self.view.bounds.size.width/2, _demoButton.center.y)];
    [_demoButton.layer setCornerRadius:50];
    [_demoButton.layer setMasksToBounds:YES];
    [_demoButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_demoButton setBackgroundColor:[UIColor redColor]];
    [_demoButton setTitle:@"record" forState:UIControlStateNormal];
    [self.view addSubview:_demoButton];
}

- (void)buttonClick:(id)sender {
    if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"record"]) {
        [_demoButton setTitle:@"stop" forState:UIControlStateNormal];
        [record startRecordingWithPath:_strpath withDuration:5.];
    } else if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"stop"]) {
        [_demoButton setTitle:@"play" forState:UIControlStateNormal];
        [record stopRecord];
    } else if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"play"]) {
        [_demoButton setTitle:@"playing" forState:UIControlStateNormal];
        [_demoButton setEnabled:NO];
        
        
        //    NSURL *item = [[NSBundle mainBundle] URLForResource:@"asd" withExtension:@"mp3"];
//        STKDataSource *dataSource = [STKAudioPlayer dataSourceFromURL:[NSURL fileURLWithPath:_strpath]];
        [audioPlayer playURL:[NSURL fileURLWithPath:_strpath]];
//        [audioPlayer playDataSource:dataSource];
        [audioPlayer addFrameFilterWithName:@"filter" afterFilterWithName:nil block:^(UInt32 channelsPerFrame, UInt32 bytesPerFrame, UInt32 frameCount, void *frames) {
            [JNAudioEffectProcessor process:JNAudioEffectType_BigRoom samples:frames numsamples:frameCount];
        }];
//        [audioPlayer play];
    } else if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"to aac"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [JNAudioWaveAAC audioWavToAAC:_strpath outputFile:_aacstrpath rate:48000 effectType:JNAudioEffectType_BigRoom];
        });
        [_demoButton setTitle:@"aac ing" forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanged:) name:Noti_SaveProgressChanged object:nil];
    } else if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"play aac"]) {
        [_demoButton setTitle:@"over" forState:UIControlStateNormal];
        [avPlayer initWithURL:[NSURL fileURLWithPath:_aacstrpath]];
        [avPlayer play];
    }
    
}

- (void)saveChanged:(NSNotification *)notification {
    CGFloat progress = [notification.object floatValue];
    NSLog(@"progress:%f", progress);
    if (progress>=1) {
        [_demoButton setTitle:@"play aac" forState:UIControlStateNormal];
    }
}

// MARK: - CMRecordDelegate

- (void)didStartRecord {
    
}

- (void)didFinishRecord {
    [_demoButton setTitle:@"play" forState:UIControlStateNormal];
    [_demoButton setEnabled:YES];
}

- (void)didRecordChanged:(CGFloat)recordTime VoiceLevel:(NSInteger)voiceLevel {
    
}


// MARK: - KSAVPlayerDelegate

- (void)didPlayStateChanged:(KSAVPlayer *)player playing:(BOOL)isPlaying {
    
}
- (void)didPlayFinished:(KSAVPlayer *)player {
    
}
- (void)didPlayError:(KSAVPlayer *)player {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - STKAudioPlayerDelegate

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    
}

/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    
}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    if (stopReason == STKAudioPlayerStopReasonEof) {
        [_demoButton setEnabled:YES];
        [_demoButton setTitle:@"to aac" forState:UIControlStateNormal];
    }
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
    
}


@end
