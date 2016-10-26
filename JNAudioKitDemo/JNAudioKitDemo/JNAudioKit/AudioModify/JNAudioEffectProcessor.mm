//
//  JNAudioEffectProcessor.m
//  JNAudioKitDemo
//
//  Created by NetEase on 16/10/26.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "JNAudioEffectProcessor.h"
#import "freeverb.h"
#import "AudioEffectType.h"

@implementation JNAudioEffectProcessor

+ (void)process:(JNAudioEffectType)type samples:(inout void *)samples0 numsamples:(unsigned int)numsamples {
    [self process:type samples:samples0 numsamples:numsamples samp:44100 sf:1 nchannels:2];
}

+ (void)process:(JNAudioEffectType)type
        samples:(inout void *)samples0
     numsamples:(unsigned int)numsamples
           samp:(int)samp_freq
             sf:(int)sf
      nchannels:(int)nchannels {
    
    RevSettings EchoPara = arry_echo_para[type];
    freeverb *pEchoProcessor = new freeverb(&EchoPara);
    pEchoProcessor->process(samp_freq, sf, nchannels, samples0, numsamples, false);
}
@end
