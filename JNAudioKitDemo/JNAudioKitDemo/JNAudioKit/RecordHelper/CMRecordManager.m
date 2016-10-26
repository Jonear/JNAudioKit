
#import "CMRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioHelper.h"

#define WAVE_UPDATE_FREQUENCY   0.05

@interface CMRecordManager () <AVAudioRecorderDelegate>

@end

@implementation CMRecordManager {
	NSTimer         *_timer;
	AVAudioRecorder *_recorder;
    AVAudioPlayer   *_audioPlayer;
    AVAudioSession  *_audioSession;
    double           _maxRecordTime;
}

//+ (id)defaultManager
//{
//    static id instance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[[self class] alloc] init];
//    });
//    return instance;
//}

- (id)init
{
    self = [super init];
    if (self) {

        
        //音量0~7, 共8个等级
        _voiceLevel = 0;
        
    }
    return self;
}


- (void)startRecordingWithPath:(NSString*)path withDuration:(double)duration
{
    _maxRecordTime = duration;
    _recordTime = 0.0;
    
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
    }

	NSError *err = nil;
	[_audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
	if(err){
        NSLog(@"audioSession: %@ %zd %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
    
    err = nil;
	[_audioSession setActive:YES error:&err];
	if(err){
        NSLog(@"audioSession: %@ %zd %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
	
	NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
	[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
	[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    /*
     [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
     [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
     [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
     */
	
	err = nil;
    self.recordFilePath = path;
	NSData *audioData = [NSData dataWithContentsOfFile:self.recordFilePath options: 0 error:&err];
	if(audioData)
	{
		[[NSFileManager defaultManager] removeItemAtPath:self.recordFilePath error:&err];
	}
	
	err = nil;
	if(_recorder!=nil){
		[_recorder stop];
		_recorder = nil;
	}
	_recorder = [[ AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordFilePath] settings:recordSetting error:&err];
	if(!_recorder){
        NSLog(@"recorder: %@ %zd %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}

	[_recorder setDelegate:self];
	[_recorder prepareToRecord];
	_recorder.meteringEnabled = YES;
	
	BOOL res = [_recorder recordForDuration:(NSTimeInterval)_maxRecordTime];
    if (!_timer && res) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    }
    
	AudioSessionInitialize(NULL, NULL,nil,(__bridge  void *)(self));
	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
							sizeof(sessionCategory),
							&sessionCategory
							);
	AudioSessionSetActive(true);
    
    AVAudioSessionPortOverride audio_route_override = [[AudioHelper getInstance] hasHeadset] ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:audio_route_override error:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecord)]) {
        [_delegate didStartRecord];
    }
}

- (void)stopRecord{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
	
	if (_recorder) {
		[_recorder stop];
		_recorder = nil;
	}
    
    [_audioSession setActive:NO error:nil];
}


- (void)updateMeters {
    [_recorder updateMeters];
    
    CGFloat voice = [_recorder averagePowerForChannel:0];
    //NSLog(@"meter:%5f", voice);
    
    //-56   0
    //-48   1
    //...
    //0     7
    voice *= -1;
    if (voice > 56.0) {
        voice = 56.0;
    }
    _voiceLevel = 7 - voice/8;
    //NSLog(@"voiceProgress = %d", voiceProgress);
    
    _recordTime += WAVE_UPDATE_FREQUENCY;

    if (_recordTime > _maxRecordTime) {
        _recordTime = _maxRecordTime;
        [self stopRecord];
    } else  {
        if (_delegate && [_delegate respondsToSelector:@selector(didRecordChanged:VoiceLevel:)]) {
            [_delegate didRecordChanged:_recordTime VoiceLevel:_voiceLevel];
        }
    }
    
}


#pragma mark - AVAudioPlayerDelegate Delegate

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:NNKEY_RECORDER_INTERRUPTION object:nil];
    // 开始录制
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    // 结束录制
	[_recorder stop];
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording");
    if (_delegate && [_delegate respondsToSelector:@selector(didFinishRecord)]) {
        [_delegate didFinishRecord];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur:%@", error.description);
}


@end
