//
//  JNAudioHelper.m
//  JNAudioKitDemo
//
//  Created by Jonear on 12-8-21.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import "JNAudioHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

@interface JNAudioHelper()
{
    BOOL _hasMicrophone;
    BOOL _hasHeadset;
}
@end

@implementation JNAudioHelper

+ (JNAudioHelper*) getInstance;
{
    static JNAudioHelper *pInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pInstance = [[JNAudioHelper alloc] init];
        [pInstance initSession];
    });
    return pInstance;
}

- (BOOL)hasMicophone
{
    return [[AVAudioSession sharedInstance] isInputAvailable];
}

- (BOOL)hasHeadset
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    return NO;
}

- (void)audioRouteChangeListenerCallback:(id)sender {
    BOOL hasMicrophone = [self hasMicophone];
    BOOL hasHeadset = [self hasHeadset];
    
    if (_hasMicrophone != hasMicrophone) {
        _hasMicrophone = hasMicrophone;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CMNotificationMicophoneChanged object:@(_hasMicrophone)];
    }
    
    if (_hasHeadset != hasHeadset) {
        _hasHeadset = hasHeadset;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CMNotificationHasHeadsetChanged object:@(_hasHeadset)];
    }
}

- (void)initSession {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _hasMicrophone = [self hasMicophone];
    _hasHeadset = [self hasHeadset];
}


@end
