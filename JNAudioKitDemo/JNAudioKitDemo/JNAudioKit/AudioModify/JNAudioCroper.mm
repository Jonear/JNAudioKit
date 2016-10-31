//
//  JNAudioCroper.m
//  JNAudioKitDemo
//
//  Created by Jonear on 13-5-20.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import "JNAudioCroper.h"
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation JNAudioCroper

+(void) setDefaultAudioFormat : (AudioStreamBasicDescription*)audioForamt sampleRate : (Float64)f_sample_rate numChannels : (int)n_num_channels{
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

+ (BOOL)cropAudio:(NSURL *)inputUrl output:(NSURL*)outputUrl start:(double)start end:(double)end {
    
    if (start<0 || end<0 || start>=end) {
        return NO;
    }
    
    OSStatus ret_status = noErr;
    AudioStreamBasicDescription acomp_audio_format;
    AudioStreamBasicDescription client_format;
    AudioStreamBasicDescription output_audio_format;
    
    UInt32 un_property_size = sizeof(AudioStreamBasicDescription);
    ExtAudioFileRef acom_audio_file = NULL;
    ExtAudioFileRef output_audio_file = NULL;
    
    UInt64 un_processed_frames = 0;
    
    ret_status = ExtAudioFileOpenURL((__bridge CFURLRef)inputUrl, &acom_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
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
        
        return NO;
    }
    
    
    int n_num_channels = acomp_audio_format.mChannelsPerFrame;
    Float64 f_sample_rate = acomp_audio_format.mSampleRate;
    [self setDefaultAudioFormat:&client_format sampleRate:f_sample_rate numChannels:n_num_channels];
    
    ret_status = ExtAudioFileSetProperty(acom_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&output_audio_format, 0, sizeof(output_audio_format));
    [self setDefaultAudioFormat:&output_audio_format sampleRate:f_sample_rate numChannels:n_num_channels];
    
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &un_property_size, &output_audio_format);
    ret_status = ExtAudioFileCreateWithURL((__bridge CFURLRef)outputUrl, kAudioFileWAVEType, &output_audio_format, NULL, kAudioFileFlags_EraseFile, &output_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
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
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return NO;
    }
    
    
    UInt16 un_buf_size = (UInt16)(8192 * 10);
    AudioSampleType* buf_acomp = (AudioSampleType*)malloc(un_buf_size);
    AudioSampleType* buf_output = (AudioSampleType*)malloc(un_buf_size);
    
    AudioBufferList convert_buf_acomp;
    convert_buf_acomp.mNumberBuffers = 1;
    convert_buf_acomp.mBuffers[0].mNumberChannels = acomp_audio_format.mChannelsPerFrame;
    convert_buf_acomp.mBuffers[0].mDataByteSize = un_buf_size;
    convert_buf_acomp.mBuffers[0].mData = buf_acomp;
    
    AudioBufferList output_buf_list;
    output_buf_list.mNumberBuffers = 1;
    output_buf_list.mBuffers[0].mNumberChannels = n_num_channels;
    output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
    output_buf_list.mBuffers[0].mData = buf_output;
    
    UInt32 un_frames_read_per_time = INT_MAX;
    
    // 首先移动到文件起始位置
    UInt32 fileSkip = start * acomp_audio_format.mSampleRate;
    if (start>0){
        ExtAudioFileSeek(acom_audio_file, fileSkip);
    }
    
    UInt32 endOffset = end*acomp_audio_format.mSampleRate;
    while (true) {
        convert_buf_acomp.mBuffers[0].mDataByteSize = un_buf_size;
        output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
        
        UInt32 un_frame_count_acomp = un_frames_read_per_time;
        
        if (acomp_audio_format.mBytesPerFrame) {
            un_frame_count_acomp = un_buf_size / acomp_audio_format.mBytesPerFrame;
        }
        
        ret_status = ExtAudioFileRead(acom_audio_file, &un_frame_count_acomp, &convert_buf_acomp);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        
        if (0 == un_frame_count_acomp) {
            break;
        }
        
        UInt32 un_frame_count = (UInt32)MIN(un_frame_count_acomp, endOffset-fileSkip-un_processed_frames);
        if (un_frame_count <= 0) {
            break;
        }
        un_processed_frames += un_frame_count;
        
        output_buf_list.mBuffers[0].mDataByteSize = un_frame_count * 4;
        output_buf_list.mNumberBuffers = 1;
        output_buf_list.mBuffers[0].mNumberChannels = 2;
        
        UInt32 un_length = un_frame_count * 2;
        for (int n_index = 0; n_index < un_length; ++n_index) {
            
            *(buf_output + n_index)  = *(buf_acomp + n_index);
        }
        
        ret_status = ExtAudioFileWrite(output_audio_file, un_frame_count, &output_buf_list);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        double progress = (un_processed_frames) / ((end-start)*acomp_audio_format.mSampleRate);
        [[NSNotificationCenter defaultCenter] postNotificationName:CropProgressNotification object:[NSNumber numberWithDouble:progress]];

    }

    if (buf_acomp) {
        free(buf_acomp);
        buf_acomp = NULL;
    }
    
    
    if (buf_output) {
        free(buf_output);
        buf_output = NULL;
    }
    
    if (acom_audio_file) {
        ExtAudioFileDispose(acom_audio_file);
        acom_audio_file = nil;
    }
    
    if (output_audio_file) {
        ExtAudioFileDispose(output_audio_file);
        output_audio_file = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CropFinishNotification object:nil];
    return YES;
}

@end
