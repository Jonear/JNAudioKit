//
//  KSAudioMixer.h
//  KwSing
//
//  Created by 单 永杰 on 13-5-20.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>

// object:number(progress)
#define MixProgressNotification @"MixProgressNotification"
#define MixFinishNotification @"MixFinishNotification"

struct MixAudioInfoDescription
{
    AudioStreamBasicDescription audioFormat;
    ExtAudioFileRef             audioFile;
    AudioBufferList             audioBufList;
    UInt32                      audioBufFrameCount;
    SInt16                     *audioBuf;
};

@interface CMMixAudioInfo : NSObject

@property (strong, nonatomic) NSString *audioPath;        //音频路径
@property (assign, nonatomic) double    audioOffset;      //起始偏移量
@property (assign, nonatomic) double    audioStartTime;   //开始合成的位置
@property (assign, nonatomic) double    audioEndTime;     //结束合成的位置

@property (assign, nonatomic) struct MixAudioInfoDescription mixAudioDesc;

- (double)getStartOffsetSize;
- (double)getEndOffsetSize;

@end


@interface KSAudioMixer : NSObject

/**
 *  两个音频合成
 *
 *  @param str_acomp_path  伴奏音乐路径
 *  @param str_sing_path   人声音乐路径
 *  @param str_output_path 合成后输出的路径
 *  @param f_acom_volume   伴奏音量
 *  @param f_sing_volume   人声音量
 *
 *  @return 是否开始正常合成
 */
+ (BOOL)mixAudio:(NSString*)str_acomp_path
        andAudio:(NSString*)str_sing_path
          output:(NSString*)str_output_path
     acompVolume:(float)f_acom_volume
      singVolume:(float)f_sing_volume;

/**
 *  多个音频合成
 *
 *  @param audioArray      音频数组（CMMixAudioInfo类型）
 *  @param str_output_path 合成后输出的路径
 *
 *  @return 是否开始正常合成
 */
+ (BOOL)mixAudioWithArray:(NSArray *)audioArray
                   output:(NSString *)str_output_path;

@end
