//
//  JNAudioEffectProcessor.h
//  JNAudioKitDemo
//
//  Created by NetEase on 16/10/26.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JNAudioEffectType) {
    JNAudioEffectType_Normal = 0,        // regular table view
    JNAudioEffectType_SmallRoom,         // preferences style table view
    JNAudioEffectType_MidRoom,
    JNAudioEffectType_BigRoom,
    JNAudioEffectType_HallRoom
};


@interface JNAudioEffectProcessor : NSObject

+ (void)process:(JNAudioEffectType)type samples:(void *)samples0 numsamples:(unsigned int)numsamples;

+ (void)process:(JNAudioEffectType)type
        samples:(void *)samples0
     numsamples:(unsigned int)numsamples
           samp:(int)samp_freq
             sf:(int)sf
      nchannels:(int)nchannels;

@end
