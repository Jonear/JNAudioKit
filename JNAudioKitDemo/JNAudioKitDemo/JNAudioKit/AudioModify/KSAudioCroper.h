//
//  KSAudioCroper.h
//  KwSing
//
//  Created by 单 永杰 on 13-5-20.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

// object:number(progress)
#define CropProgressNotification @"CropProgressNotification"
#define CropFinishNotification   @"CropFinishNotification"

@interface KSAudioCroper : NSObject

+ (BOOL)cropAudio:(NSURL *)inputUrl output:(NSURL*)outputUrl start:(double)start end:(double)end;

@end
