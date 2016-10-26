//
//  AudioHelper.m
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "AudioHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

@interface AudioHelper()
{
    BOOL _hasMicrophone;
    BOOL _hasHeadset;
}
@end

@implementation AudioHelper

+ (AudioHelper*) getInstance;
{
    static AudioHelper *pInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pInstance = [[AudioHelper alloc] init];
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
