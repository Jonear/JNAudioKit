//
//  ALWAVTOACCFile.h
//  WeSing
//
//  Created by 刘长江 on 15/8/3.
//  Copyright (c) 2015年 刘长江. All rights reserved.
//

#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSInteger, JNAudioEffectType) {
    JNAudioEffectType_Normal,          // regular table view
    JNAudioEffectType_SmallRoom,         // preferences style table view
    JNAudioEffectType_MidRoom,
    JNAudioEffectType_BigRoom,
    JNAudioEffectType_HallRoom
};

#define Noti_SaveProgressChanged @"Noti_SaveProgressChanged"

@interface JNAudioWaveAAC : NSObject

+ (BOOL)audioWavToAAC:(NSString *)inputFilePath
           outputFile:(NSString *)outputFilePath
                 rate:(UInt32)bitrate;


+ (BOOL)audioWavToAAC:(NSString *)inputFilePath
           outputFile:(NSString *)outputFilePath
                 rate:(UInt32)bitrate
           effectType:(JNAudioEffectType)effectType;
@end
