//
//  ALWAVTOACCFile.m
//  WeSing
//
//  Created by 刘长江 on 15/8/3.
//  Copyright (c) 2015年 刘长江. All rights reserved.
//

#import "ALWAVTOACCFile.h"
#import "freeverb.h"
#import "AudioEffectType.h"

@implementation JNAudioWaveAAC

+ (BOOL)audioWavToAAC:(NSString *)inputFilePath outputFile:(NSString *)outputFilePath rate:(UInt32)bitrate {
    return [self audioWavToAAC:inputFilePath outputFile:outputFilePath rate:bitrate effectType:JNAudioEffectType_Normal];
}

+ (BOOL)audioWavToAAC:(NSString *)inputFilePath outputFile:(NSString *)outputFilePath rate:(UInt32)bitrate effectType:(JNAudioEffectType)effectType {
    
    CFURLRef url_input_file = (__bridge CFURLRef)[NSURL fileURLWithPath:inputFilePath isDirectory:NO];
    CFURLRef url_output_file = (__bridge CFURLRef)[NSURL fileURLWithPath:outputFilePath isDirectory:NO];
    
    ExtAudioFileRef file_source = NULL;
    AudioStreamBasicDescription format_source;
    ExtAudioFileOpenURL(url_input_file, &file_source);
    
    freeverb *_pEchoProcessor = nil;
    if (effectType != JNAudioEffectType_Normal) {
        RevSettings EchoPara = arry_echo_para[effectType];
        _pEchoProcessor = new freeverb(&EchoPara);
    }
    
    UInt32 un_size = sizeof(format_source);
    ExtAudioFileGetProperty(file_source, kExtAudioFileProperty_FileDataFormat, &un_size, &format_source);
    
    
    AudioStreamBasicDescription format_dest;
    memset(&format_dest, 0, sizeof(format_dest));
    format_dest.mChannelsPerFrame = format_source.mChannelsPerFrame;
    format_dest.mFormatID = kAudioFormatMPEG4AAC;
    format_dest.mSampleRate = 0.f;
    
    un_size = sizeof(AudioStreamBasicDescription);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &un_size, &format_dest);
    
    ExtAudioFileRef file_dest;
    ExtAudioFileCreateWithURL(url_output_file, kAudioFileM4AType, &format_dest, NULL, kAudioFileFlags_EraseFile, &file_dest);
    
    AudioStreamBasicDescription format_client;
    memset(&format_client, 0, sizeof(format_client));
    
    format_client = format_source;
    un_size = sizeof(format_client);
    OSStatus err_ret = ExtAudioFileSetProperty(file_source, kExtAudioFileProperty_ClientDataFormat, un_size, &format_client);
    if (noErr != err_ret) {
        if (file_source) {
            ExtAudioFileDispose(file_source);
        }
        ExtAudioFileDispose(file_dest);
        return false;
    }
    
    UInt32 un_codec_manu = kAppleSoftwareAudioCodecManufacturer;
    ExtAudioFileSetProperty(file_dest, kExtAudioFileProperty_CodecManufacturer, sizeof(un_codec_manu), &un_codec_manu);
    
    un_size = sizeof(format_client);
    err_ret = ExtAudioFileSetProperty(file_dest, kExtAudioFileProperty_ClientDataFormat, un_size, &format_client);
    if (noErr != err_ret) {
        if (file_source) {
            ExtAudioFileDispose(file_source);
        }
        ExtAudioFileDispose(file_dest);
        return false;
    }
    
    AudioConverterRef audio_converter;
    un_size = sizeof(AudioConverterRef);
    ExtAudioFileGetProperty(file_dest, kExtAudioFileProperty_AudioConverter, &un_size, &audio_converter);
    AudioConverterSetProperty(audio_converter, kAudioConverterEncodeBitRate, sizeof(bitrate), &bitrate);
    
    SInt64 s_n_len_in_frames = 0;
    SInt64 s_n_processed_in_frames = 0;
    if (file_source) {
        un_size = sizeof(SInt64);
        ExtAudioFileGetProperty(file_source, kExtAudioFileProperty_FileLengthFrames, &un_size, &s_n_len_in_frames);
    }
    
    UInt32 un_buf_byte_size = 32768;
    char src_buffer[un_buf_byte_size];


    while (true) {
        AudioBufferList fill_buf_list;
        fill_buf_list.mNumberBuffers = 1;
        fill_buf_list.mBuffers[0].mNumberChannels = format_client.mChannelsPerFrame;
        fill_buf_list.mBuffers[0].mDataByteSize = un_buf_byte_size;
        fill_buf_list.mBuffers[0].mData = src_buffer;
        
        UInt32 un_num_frames = un_buf_byte_size / format_client.mBytesPerFrame;
        if (file_source) {
            if (noErr != ExtAudioFileRead(file_source, &un_num_frames, &fill_buf_list)) {
                ExtAudioFileDispose(file_source);
                ExtAudioFileDispose(file_dest);
                
                return false;
            }
        }
        
        if (0 == un_num_frames) {
            break;
        }
        s_n_processed_in_frames += un_num_frames;
        if (s_n_len_in_frames > s_n_processed_in_frames && 0 == s_n_processed_in_frames % 100) {
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = (0.7 + 0.3 * (s_n_processed_in_frames) / s_n_len_in_frames);
                [[NSNotificationCenter defaultCenter] postNotificationName:Noti_SaveProgressChanged object:@(progress)];
            });
        }
        
        // 魔音
        if (effectType != JNAudioEffectType_Normal && _pEchoProcessor) {
            _pEchoProcessor->process(44100, 1, 2, fill_buf_list.mBuffers[0].mData, fill_buf_list.mBuffers[0].mDataByteSize/2, false);
        }
        ExtAudioFileWrite(file_dest, un_num_frames, &fill_buf_list);
    }
    if (file_source) {
        ExtAudioFileDispose(file_source);
    }
    ExtAudioFileDispose(file_dest);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:Noti_SaveProgressChanged object:@(1)];
    });
    
    return YES;
}

@end

