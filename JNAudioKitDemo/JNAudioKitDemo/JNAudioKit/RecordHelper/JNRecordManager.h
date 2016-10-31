
#import <UIKit/UIKit.h>
//#import "AVFoundation/AVAudioPlayer.h"

@protocol JNRecordDelegate;

@interface JNRecordManager : NSObject 

@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, assign) CGFloat   recordTime;
@property (nonatomic, assign) NSUInteger voiceLevel;

@property (weak, nonatomic) id<JNRecordDelegate> delegate;

//+ (id)defaultManager;

- (void)startRecordingWithPath:(NSString*)path withDuration:(double)duration;
- (void)stopRecord;

@end

@protocol JNRecordDelegate <NSObject>

- (void)didStartRecord;
- (void)didFinishRecord;

- (void)didRecordChanged:(CGFloat)recordTime VoiceLevel:(NSInteger)voiceLevel;

@end

