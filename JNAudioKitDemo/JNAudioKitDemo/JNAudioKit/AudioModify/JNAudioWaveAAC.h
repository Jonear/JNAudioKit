//
//  JNAudioWaveAAC.h
//  JNAudioKitDemo
//
//  Created by Jonear on 15/8/3.
//  Copyright (c) 2015年 Jonear. All rights reserved.
//

#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>
#import "JNAudioEffectProcessor.h"

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
