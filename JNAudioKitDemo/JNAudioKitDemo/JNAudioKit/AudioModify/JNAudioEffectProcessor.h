//
//  JNAudioEffectProcessor.h
//  JNAudioKitDemo
//
//  Created by NetEase on 16/10/26.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JNAudioEffectType) {
    JNAudioEffectType_Normal,          // regular table view
    JNAudioEffectType_SmallRoom,         // preferences style table view
    JNAudioEffectType_MidRoom,
    JNAudioEffectType_BigRoom,
    JNAudioEffectType_HallRoom
};


@interface JNAudioEffectProcessor : NSObject

+ (void)process:(JNAudioEffectType)type samples:(void *)samples0 numsamples:(unsigned int)numsamples;
@end
