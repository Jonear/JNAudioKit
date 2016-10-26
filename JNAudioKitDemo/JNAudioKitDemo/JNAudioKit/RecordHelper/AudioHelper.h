//
//  AudioHelper.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

// object(NSNumber:BOOL) //是否插上耳塞
#define CMNotificationHasHeadsetChanged @"CMNotificationHasHeadset"

// object(NSNumber:BOOL) //...
#define CMNotificationMicophoneChanged @"CMNotificationMicophoneChanged"

@interface AudioHelper : NSObject

+ (AudioHelper*) getInstance;

- (BOOL)hasHeadset;
- (BOOL)hasMicophone;

@end
