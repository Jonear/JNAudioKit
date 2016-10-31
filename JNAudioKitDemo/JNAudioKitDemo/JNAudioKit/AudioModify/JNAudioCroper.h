//
//  JNAudioCroper.h
//  JNAudioKitDemo
//
//  Created by Jonear on 13-5-20.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>

// object:number(progress)
#define CropProgressNotification @"CropProgressNotification"
#define CropFinishNotification   @"CropFinishNotification"

@interface JNAudioCroper : NSObject

+ (BOOL)cropAudio:(NSURL *)inputUrl output:(NSURL*)outputUrl start:(double)start end:(double)end;

@end
