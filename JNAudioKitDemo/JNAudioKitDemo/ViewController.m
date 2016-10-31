//
//  ViewController.m
//  JNAudioKitDemo
//
//  Created by NetEase on 16/10/24.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "ViewController.h"

#import "JNAVPlayer.h"
#import "JNRecordManager.h"
#import "JNAudioWaveAAC.h"
#import "JNAudioEffectProcessor.h"

@interface ViewController () <JNRecordDelegate, JNAVPlayerDelegate>

@end

@implementation ViewController {
    JNAVPlayer *audioPlayer;
    NSString *_strpath;
    NSString *_aacstrpath;
    UIButton *_demoButton;
    JNRecordManager *record;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"a.wav"];
    _aacstrpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"aac.m4a"];
    record = [[JNRecordManager alloc] init];
    record.delegate = self;
    
    audioPlayer = [[JNAVPlayer alloc] init];
    audioPlayer.delegate = self;
    
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

        [audioPlayer initWithURL:[NSURL fileURLWithPath:_strpath]];
        [audioPlayer play];
        
    } else if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"to aac"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [JNAudioWaveAAC audioWavToAAC:_strpath outputFile:_aacstrpath rate:48000 effectType:JNAudioEffectType_BigRoom];
        });
        [_demoButton setTitle:@"aac ing" forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChanged:) name:Noti_SaveProgressChanged object:nil];
    } else if ([[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"play aac"]) {
        [_demoButton setTitle:@"over" forState:UIControlStateNormal];
        [audioPlayer initWithURL:[NSURL fileURLWithPath:_aacstrpath]];
        [audioPlayer play];
    }
}

- (void)saveChanged:(NSNotification *)notification {
    CGFloat progress = [notification.object floatValue];
    NSLog(@"progress:%f", progress);
    if (progress>=1) {
        [_demoButton setTitle:@"play aac" forState:UIControlStateNormal];
    }
}

// MARK: - JNRecordDelegate

- (void)didStartRecord {
    
}

- (void)didFinishRecord {
    [_demoButton setTitle:@"play" forState:UIControlStateNormal];
    [_demoButton setEnabled:YES];
}

- (void)didRecordChanged:(CGFloat)recordTime VoiceLevel:(NSInteger)voiceLevel {
    
}


// MARK: - JNAVPlayerDelegate

- (void)didPlayStateChanged:(JNAVPlayer *)player playing:(BOOL)isPlaying {
    
}
- (void)didPlayFinished:(JNAVPlayer *)player {
    if (![[_demoButton titleForState:UIControlStateNormal] isEqualToString:@"over"]) {
        [_demoButton setEnabled:YES];
        [_demoButton setTitle:@"to aac" forState:UIControlStateNormal];
    }
}

- (void)didPlayError:(JNAVPlayer *)player {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
