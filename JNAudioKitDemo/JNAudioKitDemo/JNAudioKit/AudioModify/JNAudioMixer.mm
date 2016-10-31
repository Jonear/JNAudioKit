//
//  KSAudioMixer.m
//  JNAudioKitDemo
//
//  Created by Jonear on 13-5-20.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import "JNAudioMixer.h"


@implementation JNMixAudioInfo

- (double)getStartOffsetSizeWithRate:(double)rate {
    return (self.audioOffset+self.audioStartTime)*rate;
}

- (double)getEndOffsetSizeWithRate:(double)rate {
    return (self.audioOffset+self.audioEndTime)*rate;
}

- (double)getStartOffsetSize {
    return [self getStartOffsetSizeWithRate:self.mixAudioDesc.audioFormat.mSampleRate];
}

- (double)getEndOffsetSize {
    return [self getEndOffsetSizeWithRate:self.mixAudioDesc.audioFormat.mSampleRate];
}

@end

@implementation JNAudioMixer

+(void) setDefaultAudioFormat:(AudioStreamBasicDescription*)audioForamt sampleRate:(Float64)f_sample_rate numChannels:(int)n_num_channels{
    memset(audioForamt, 0, sizeof(AudioStreamBasicDescription));
    audioForamt->mFormatID = kAudioFormatLinearPCM;
    audioForamt->mSampleRate = f_sample_rate;
    audioForamt->mChannelsPerFrame = n_num_channels;
    audioForamt->mBytesPerPacket = 2 * n_num_channels;
    audioForamt->mFramesPerPacket = 1;
    audioForamt->mBytesPerFrame = 2 * n_num_channels;
    audioForamt->mBitsPerChannel = 16;
    audioForamt->mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
}

+ (BOOL)mixAudio:(NSString*)str_acomp_path
        andAudio:(NSString*)str_sing_path
          output:(NSString*)str_output_path
     acompVolume:(float)f_acom_volume
      singVolume:(float)f_sing_volume {
    
    OSStatus ret_status = noErr;
    AudioStreamBasicDescription acomp_audio_format;
    AudioStreamBasicDescription sing_audio_format;
    AudioStreamBasicDescription client_format;
    AudioStreamBasicDescription output_audio_format;
    
    UInt32 un_property_size = sizeof(AudioStreamBasicDescription);
    ExtAudioFileRef acom_audio_file = NULL;
    ExtAudioFileRef sing_audio_file = NULL;
    ExtAudioFileRef output_audio_file = NULL;
    
    UInt64 un_sing_frames = 0;
    UInt64 un_processed_frames = 0;
    
    NSURL* acomp_url = [NSURL fileURLWithPath:str_acomp_path];
    NSURL* sing_url = [NSURL fileURLWithPath:str_sing_path];
    NSURL* output_url = [NSURL fileURLWithPath:str_output_path];
    
    ret_status = ExtAudioFileOpenURL((__bridge CFURLRef)acomp_url, &acom_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        return NO;
    }
    
    ret_status = ExtAudioFileOpenURL((__bridge CFURLRef)sing_url, &sing_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&acomp_audio_format, 0, sizeof(AudioStreamBasicDescription));
    ret_status = ExtAudioFileGetProperty(acom_audio_file, kExtAudioFileProperty_FileDataFormat, &un_property_size, &acomp_audio_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&sing_audio_format, 0, sizeof(AudioStreamBasicDescription));
    ret_status = ExtAudioFileGetProperty(sing_audio_file, kExtAudioFileProperty_FileDataFormat, &un_property_size, &sing_audio_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    int n_num_channels = MAX(acomp_audio_format.mChannelsPerFrame, sing_audio_format.mChannelsPerFrame);
    Float64 f_sample_rate = MAX(acomp_audio_format.mSampleRate, sing_audio_format.mSampleRate);
    [self setDefaultAudioFormat:&client_format sampleRate:f_sample_rate numChannels:n_num_channels];
    
    ret_status = ExtAudioFileSetProperty(acom_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    ret_status = ExtAudioFileSetProperty(sing_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&output_audio_format, 0, sizeof(output_audio_format));
    [self setDefaultAudioFormat:&output_audio_format sampleRate:f_sample_rate numChannels:n_num_channels];
    
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &un_property_size, &output_audio_format);
    ret_status = ExtAudioFileCreateWithURL((__bridge CFURLRef)output_url, kAudioFileWAVEType, &output_audio_format, NULL, kAudioFileFlags_EraseFile, &output_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return NO;
    }
    
//    ExtAudioFileSetProperty(output_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    
    ret_status = ExtAudioFileSetProperty(output_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return NO;
    }
    
    UInt32 un_size = sizeof(un_sing_frames);
    ExtAudioFileGetProperty(sing_audio_file, kExtAudioFileProperty_FileLengthFrames, &un_size, &un_sing_frames);
    if (0 == un_sing_frames) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return YES;
    }
    
    UInt16 un_buf_size = (UInt16)(8192 * 10);
    AudioSampleType* buf_acomp = (AudioSampleType*)malloc(un_buf_size);
    AudioSampleType* buf_sing = (AudioSampleType*)malloc(un_buf_size);
    AudioSampleType* buf_output = (AudioSampleType*)malloc(un_buf_size);
    
    AudioBufferList convert_buf_acomp;
    convert_buf_acomp.mNumberBuffers = 1;
    convert_buf_acomp.mBuffers[0].mNumberChannels = acomp_audio_format.mChannelsPerFrame;
    convert_buf_acomp.mBuffers[0].mDataByteSize = un_buf_size;
    convert_buf_acomp.mBuffers[0].mData = buf_acomp;
    
    AudioBufferList convert_buf_sing;
    convert_buf_sing.mNumberBuffers = 1;
    convert_buf_sing.mBuffers[0].mNumberChannels = sing_audio_format.mChannelsPerFrame;
    convert_buf_sing.mBuffers[0].mDataByteSize = un_buf_size;
    convert_buf_sing.mBuffers[0].mData = buf_sing;
    
    AudioBufferList output_buf_list;
    output_buf_list.mNumberBuffers = 1;
    output_buf_list.mBuffers[0].mNumberChannels = n_num_channels;
    output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
    output_buf_list.mBuffers[0].mData = buf_output;
    
    UInt32 un_frames_read_per_time = INT_MAX;
    UInt8 un_bit_offset = 8 * sizeof(AudioSampleType);
    UInt64 un_bit_max = (UInt64)(pow(2, un_bit_offset));
    UInt64 un_bit_mid = un_bit_max / 2;
    
    while (true) {
        convert_buf_acomp.mBuffers[0].mDataByteSize = un_buf_size;
        convert_buf_sing.mBuffers[0].mDataByteSize = un_buf_size;
        output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
        
        UInt32 un_frame_count_acomp = un_frames_read_per_time;
        UInt32 un_frame_count_sing = un_frames_read_per_time;
        
        if (acomp_audio_format.mBytesPerFrame) {
            un_frame_count_acomp = un_buf_size / acomp_audio_format.mBytesPerFrame;
        }
        if (sing_audio_format.mBytesPerFrame) {
            un_frame_count_sing = un_buf_size / sing_audio_format.mBytesPerFrame;
        }
        
        ret_status = ExtAudioFileRead(acom_audio_file, &un_frame_count_acomp, &convert_buf_acomp);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_sing) {
                free(buf_sing);
                buf_sing = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            if (sing_audio_file) {
                ExtAudioFileDispose(sing_audio_file);
                sing_audio_file = nil;
            }
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        ret_status = ExtAudioFileRead(sing_audio_file, &un_frame_count_sing, &convert_buf_sing);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_sing) {
                free(buf_sing);
                buf_sing = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            if (sing_audio_file) {
                ExtAudioFileDispose(sing_audio_file);
                sing_audio_file = nil;
            }
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        if (0 == un_frame_count_acomp || 0 == un_frame_count_sing) {
            break;
        }
        
        UInt32 un_frame_count = MIN(un_frame_count_acomp, un_frame_count_sing);
        un_processed_frames += un_frame_count;
        
        output_buf_list.mBuffers[0].mDataByteSize = un_frame_count * 4;
        output_buf_list.mNumberBuffers = 1;
        output_buf_list.mBuffers[0].mNumberChannels = 2;
        
        UInt32 un_length = un_frame_count * 2;
        for (int n_index = 0; n_index < un_length; ++n_index) {
            SInt32 sn_value = 0;
            SInt16 sn_value_acomp = (SInt16)(*(buf_acomp + n_index));
            SInt16 sn_value_sing = (SInt16)(*(buf_sing + n_index));
            
            SInt8 sn_sign_acomp = (0 == sn_value_acomp) ? 0 : (abs(sn_value_acomp) / sn_value_acomp);
            SInt8 sn_sign_sing = (0 == sn_value_sing) ? 0 : (abs(sn_value_sing) / sn_value_sing);
            
            sn_value_acomp *= f_acom_volume;
            sn_value_sing *= f_sing_volume;
            
            if (sn_sign_acomp == sn_sign_sing) {
                UInt32 un_temp = ((sn_value_acomp * sn_value_sing) >> (un_bit_offset - 1));
                sn_value = sn_value_acomp + sn_value_sing - sn_sign_sing * un_temp;
                if (un_bit_mid <= abs(sn_value)) {
                    sn_value = (SInt32)(sn_sign_sing * (un_bit_mid - 1));
                }
            }else {
                SInt32 sn_temp_acomp = (SInt32)(sn_value_acomp + un_bit_mid);
                SInt32 sn_temp_sing = (SInt32)(sn_value_sing + un_bit_mid);
                UInt32 un_temp = ((sn_temp_acomp * sn_temp_sing) >> (un_bit_offset - 1));
                if (sn_temp_acomp < un_bit_mid && sn_temp_sing < un_bit_mid) {
                    sn_value = un_temp;
                }else {
                    sn_value = (SInt32)(2 * (sn_temp_acomp + sn_temp_sing) - un_temp - un_bit_max);
                }
                
                sn_value -= un_bit_mid;
            }
            
            if (0 != sn_value && un_bit_mid <= abs(sn_value)) {
                SInt8 sn_sign_value = abs(sn_value) / sn_value;
                sn_value = (SInt32)(sn_sign_value * (un_bit_mid - 1));
            }
            
            *(buf_output + n_index) = sn_value;
        }
        
        ret_status = ExtAudioFileWrite(output_audio_file, un_frame_count, &output_buf_list);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_sing) {
                free(buf_sing);
                buf_sing = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            if (sing_audio_file) {
                ExtAudioFileDispose(sing_audio_file);
                sing_audio_file = nil;
            }
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
//         NSLog(@"*************合成：%f, %llu", un_processed_frames*1. / un_sing_frames, un_sing_frames);
//        double progress = un_processed_frames*1. / un_sing_frames;
//        [[NSNotificationCenter defaultCenter] postNotificationName:MixProgressNotification object:[NSNumber numberWithDouble:progress]];
//        SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, (0.7 * un_processed_frames) / un_sing_frames);
    }

    if (buf_acomp) {
        free(buf_acomp);
        buf_acomp = NULL;
    }
    
    if (buf_sing) {
        free(buf_sing);
        buf_sing = NULL;
    }
    
    if (buf_output) {
        free(buf_output);
        buf_output = NULL;
    }
    
    if (acom_audio_file) {
        ExtAudioFileDispose(acom_audio_file);
        acom_audio_file = nil;
    }
    
    if (sing_audio_file) {
        ExtAudioFileDispose(sing_audio_file);
        sing_audio_file = nil;
    }
    
    if (output_audio_file) {
        ExtAudioFileDispose(output_audio_file);
        output_audio_file = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MixFinishNotification object:nil];
    
    return YES;
}


//*****************************************************

+ (BOOL)mixAudioWithArray:(NSArray *)audioArray
                   output:(NSString *)str_output_path {
    
    NSLog(@"输出文件地址%@", str_output_path);
    
    OSStatus ret_status = noErr;
    
    AudioStreamBasicDescription client_format;
    AudioStreamBasicDescription output_audio_format;
    
    UInt32 un_property_size = sizeof(AudioStreamBasicDescription);
    ExtAudioFileRef output_audio_file = NULL;

    UInt64 un_processed_frames = 0;
    
    int n_max_channels = 0;
    Float64 f_sample_rate = 0;
    
    NSURL* output_url = [NSURL fileURLWithPath:str_output_path];
    
    double duration = 0;
    for (JNMixAudioInfo *audioInfo in audioArray) {
        NSURL* audioURL = [NSURL fileURLWithPath:audioInfo.audioPath];
        
        MixAudioInfoDescription tempDesc = audioInfo.mixAudioDesc;
        ret_status = ExtAudioFileOpenURL((__bridge CFURLRef)audioURL, &tempDesc.audioFile);
        if (noErr != ret_status) {
            return NO;
        }
        
        memset(&tempDesc.audioFormat, 0, sizeof(AudioStreamBasicDescription));
        
        ret_status = ExtAudioFileGetProperty(tempDesc.audioFile, kExtAudioFileProperty_FileDataFormat, &un_property_size, &tempDesc.audioFormat);
        if (noErr != ret_status) {
            
            return NO;
        }
        
        if (tempDesc.audioFormat.mChannelsPerFrame > n_max_channels) {
            n_max_channels = tempDesc.audioFormat.mChannelsPerFrame;
        }
        if (tempDesc.audioFormat.mSampleRate > f_sample_rate) {
            f_sample_rate = tempDesc.audioFormat.mSampleRate;
        }
        
        int time = audioInfo.audioOffset + audioInfo.audioEndTime;
        if (time > duration) {
            duration = time;
        }
        
        audioInfo.mixAudioDesc = tempDesc;
        
//        NSLog(@"!!!开启音乐成功");
    }
    
//    NSLog(@"!!!最大时长%f", duration);
    
    [self setDefaultAudioFormat:&client_format sampleRate:f_sample_rate numChannels:n_max_channels];
    
    for (JNMixAudioInfo *audioInfo in audioArray) {
        MixAudioInfoDescription tempDesc = audioInfo.mixAudioDesc;
        ret_status = ExtAudioFileSetProperty(tempDesc.audioFile, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
        if (noErr != ret_status) {
            
            return NO;
        }
        audioInfo.mixAudioDesc = tempDesc;
    }
    
    memset(&output_audio_format, 0, sizeof(output_audio_format));
    [self setDefaultAudioFormat:&output_audio_format sampleRate:f_sample_rate numChannels:n_max_channels];
    
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &un_property_size, &output_audio_format);
    ret_status = ExtAudioFileCreateWithURL((__bridge CFURLRef)output_url, kAudioFileWAVEType, &output_audio_format, NULL, kAudioFileFlags_EraseFile, &output_audio_file);
    if (noErr != ret_status) {
        return NO;
    }
    
    ret_status = ExtAudioFileSetProperty(output_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        return NO;
    }
    
    //**************************
    //--------------------------
    
    UInt16 un_buf_size = (UInt16)(8192 * 10);
    UInt16 un_buf_framesize = un_buf_size/4;
    SInt16* buf_output = (SInt16*)malloc(un_buf_size);
    
    for (JNMixAudioInfo *audioInfo in audioArray) {
        MixAudioInfoDescription tempDesc = audioInfo.mixAudioDesc;
        
        tempDesc.audioBuf = (SInt16*)malloc(un_buf_size);
        tempDesc.audioBufList.mNumberBuffers = 1;
        tempDesc.audioBufList.mBuffers[0].mNumberChannels = tempDesc.audioFormat.mChannelsPerFrame;
        tempDesc.audioBufList.mBuffers[0].mDataByteSize = un_buf_size;
        tempDesc.audioBufList.mBuffers[0].mData = tempDesc.audioBuf;
        
        // 首先移动到文件起始位置,跳过文件平移量
        UInt32 fileSkip = audioInfo.audioStartTime * tempDesc.audioFormat.mSampleRate;
        if (fileSkip>0){
            ExtAudioFileSeek(tempDesc.audioFile, fileSkip);
        }
        
        audioInfo.mixAudioDesc = tempDesc;
    }
    
    AudioBufferList output_buf_list;
    output_buf_list.mNumberBuffers = 1;
    output_buf_list.mBuffers[0].mNumberChannels = n_max_channels;
    output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
    output_buf_list.mBuffers[0].mData = buf_output;
    
    while (true) {
//        NSLog(@"!!!开启合成");
        UInt32 maxFrameCount = 0;

        for (JNMixAudioInfo *audioInfo in audioArray) {
            
            MixAudioInfoDescription tempDesc = audioInfo.mixAudioDesc;
            
            tempDesc.audioBufList.mBuffers[0].mDataByteSize = un_buf_size;
            
            tempDesc.audioBufFrameCount = 0;
            
            if ((un_processed_frames>=[audioInfo getStartOffsetSizeWithRate:f_sample_rate] && un_processed_frames<=[audioInfo getEndOffsetSizeWithRate:f_sample_rate])
                ||
                (un_processed_frames < [audioInfo getStartOffsetSizeWithRate:f_sample_rate] && un_processed_frames+un_buf_framesize>=[audioInfo getEndOffsetSizeWithRate:f_sample_rate])) {
                
                UInt16 size = un_buf_framesize;
//                if (un_processed_frames<[audioInfo getStartOffsetSize] && (un_processed_frames+un_buf_framesize)<=[audioInfo getStartOffsetSize]) {
//    
//                    size = [audioInfo getStartOffsetSize] - un_processed_frames;
//                }
                
                if (tempDesc.audioFormat.mBytesPerFrame) {
                    tempDesc.audioBufFrameCount = size / tempDesc.audioFormat.mBytesPerFrame;
                } else {
                    tempDesc.audioBufFrameCount = size;
                }
            }
            
            if (tempDesc.audioBufFrameCount != 0) {
//                NSLog(@"!!!读取数据，读取量：%d,", (unsigned int)tempDesc.audioBufFrameCount);
                ret_status = ExtAudioFileRead(tempDesc.audioFile, &tempDesc.audioBufFrameCount, &tempDesc.audioBufList);
                if (noErr != ret_status) {
                    return NO;
                }
                
                if (tempDesc.audioBufFrameCount > maxFrameCount) {
                    maxFrameCount = tempDesc.audioBufFrameCount;
                }
                
//                NSLog(@"!!!读取数据成功，读取量：%d", (unsigned int)tempDesc.audioBufFrameCount);
            }
            
            audioInfo.mixAudioDesc = tempDesc;
        }
        
        if (un_processed_frames >= (duration*f_sample_rate)) {
            break;
        }
        
        if (maxFrameCount == 0) {
            maxFrameCount = un_buf_framesize;
        }
        un_processed_frames += maxFrameCount;
        
        output_buf_list.mBuffers[0].mDataByteSize = maxFrameCount * 4;
        output_buf_list.mNumberBuffers = 1;
        output_buf_list.mBuffers[0].mNumberChannels = 2;
        
        UInt32 un_length = maxFrameCount * 2;
        for (int n_index = 0; n_index < un_length; ++n_index) {
            
            SInt32 value_buf = 0;
            for (JNMixAudioInfo *audioInfo in audioArray) {
                MixAudioInfoDescription tempDesc = audioInfo.mixAudioDesc;
                
                if (tempDesc.audioBufFrameCount != 0) {
                    if (value_buf != 0) {
                        value_buf = [JNAudioMixer mixbuf:value_buf buf2:(SInt16)(*(tempDesc.audioBuf+n_index)) index:n_index];
                    } else {
                        value_buf = (SInt16)(*(tempDesc.audioBuf+n_index));
                    }
                }
            }
        
            *(buf_output + n_index) = value_buf;
        }
        
//        NSLog(@"!!!已合成%f,总时长%f", un_processed_frames/f_sample_rate, duration);
        
        ret_status = ExtAudioFileWrite(output_audio_file, maxFrameCount, &output_buf_list);
        if (noErr != ret_status) {
            return NO;
        }
        
            [[NSNotificationCenter defaultCenter] postNotificationName:MixProgressNotification object:[NSNumber numberWithDouble:(un_processed_frames/f_sample_rate)/duration]];

   
    }
    
    for (JNMixAudioInfo *audioInfo in audioArray) {
        MixAudioInfoDescription tempDesc = audioInfo.mixAudioDesc;
        ExtAudioFileDispose(tempDesc.audioFile);
    }
    
    if (output_audio_file) {
        ExtAudioFileDispose(output_audio_file);
        output_audio_file = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MixFinishNotification object:nil];
    
    return YES;
}

+ (SInt32)mixbuf:(SInt16)buf1 buf2:(SInt16)buf2 index:(int)index {
    UInt8 un_bit_offset = 8 * sizeof(SInt16);
    UInt64 un_bit_max = (UInt64)(pow(2, un_bit_offset));
    UInt64 un_bit_mid = un_bit_max / 2;
    
    SInt32 sn_value = 0;
    SInt16 sn_value_acomp = buf1; //(SInt16)(*(buf1 + n_index));
    SInt16 sn_value_sing = buf2;  //(SInt16)(*(buf2 + n_index));
    
    SInt8 sn_sign_acomp = (0 == sn_value_acomp) ? 0 : (abs(sn_value_acomp) / sn_value_acomp);
    SInt8 sn_sign_sing = (0 == sn_value_sing) ? 0 : (abs(sn_value_sing) / sn_value_sing);
    
    if (sn_sign_acomp == sn_sign_sing) {
        UInt32 un_temp = ((sn_value_acomp * sn_value_sing) >> (un_bit_offset - 1));
        sn_value = sn_value_acomp + sn_value_sing - sn_sign_sing * un_temp;
        if (un_bit_mid <= abs(sn_value)) {
            sn_value = (SInt32)(sn_sign_sing * (un_bit_mid - 1));
        }
    }else {
        SInt32 sn_temp_acomp = (SInt32)(sn_value_acomp + un_bit_mid);
        SInt32 sn_temp_sing = (SInt32)(sn_value_sing + un_bit_mid);
        UInt32 un_temp = ((sn_temp_acomp * sn_temp_sing) >> (un_bit_offset - 1));
        if (sn_temp_acomp < un_bit_mid && sn_temp_sing < un_bit_mid) {
            sn_value = un_temp;
        }else {
            sn_value = (SInt32)(2 * (sn_temp_acomp + sn_temp_sing) - un_temp - un_bit_max);
        }
        
        sn_value -= un_bit_mid;
    }
    
    if (0 != sn_value && un_bit_mid <= abs(sn_value)) {
        SInt8 sn_sign_value = abs(sn_value) / sn_value;
        sn_value = (SInt32)(sn_sign_value * (un_bit_mid - 1));
    }
    
    return sn_value;
}

@end
