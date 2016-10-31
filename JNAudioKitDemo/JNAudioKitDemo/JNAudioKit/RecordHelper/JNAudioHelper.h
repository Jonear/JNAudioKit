//
//  JNAudioHelper.h
//  JNAudioKitDemo
//
//  Created by Jonear on 12-8-21.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>

// object(NSNumber:BOOL) //是否插上耳塞
#define CMNotificationHasHeadsetChanged @"CMNotificationHasHeadset"

// object(NSNumber:BOOL) //...
#define CMNotificationMicophoneChanged @"CMNotificationMicophoneChanged"

@interface JNAudioHelper : NSObject

+ (JNAudioHelper*) getInstance;

- (BOOL)hasHeadset;
- (BOOL)hasMicophone;

@end
