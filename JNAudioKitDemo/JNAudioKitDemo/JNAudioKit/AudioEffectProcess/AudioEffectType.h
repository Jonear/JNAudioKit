//
//  AudioEffectType.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-2.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_AudioEffectType_h
#define KwSing_AudioEffectType_h

#ifndef FREEVERB_H
#include "freeverb.h"
#endif

enum EAudioEchoEffect{
    NO_EFFECT = 0,      
    SMALL_ROOM_EFFECT,
    MID_ROOM_EFFECT,
    BIG_ROOM_EFFECT,
    BIG_HALL_EFFECT
};

enum EAudioSoundEffect{
};

/*struct RevSettings {
    int n_room_size;
    int n_damp;
    int n_wet;
    int n_dry;
    int n_width;
    int n_mode;
};*/

// 调整音效的参数 这里需要改动，另外在 freeverb.h中也需要改动。
const RevSettings arry_echo_para[] = {
    {0, 0, 0, 0, 0, 0},
//    {1000, 700, 333, 750, 1000, 0},
    {250, 100, 333, 750, 250, 0},
	{500, 250, 333, 750, 500, 0},
	{700, 250, 333, 750, 700, 0},
	{900, 500, 333, 750, 1000, 0},
};

#endif
