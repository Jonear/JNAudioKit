
#import <UIKit/UIKit.h>
#import "AVFoundation/AVAudioPlayer.h"

@protocol CMRecordDelegate;

@interface CMRecordManager : NSObject 

@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, assign) CGFloat   recordTime;
@property (nonatomic, assign) NSUInteger voiceLevel;

@property (weak, nonatomic) id<CMRecordDelegate> delegate;

//+ (id)defaultManager;

- (void)startRecordingWithPath:(NSString*)path withDuration:(double)duration;
- (void)stopRecord;

@end

@protocol CMRecordDelegate <NSObject>

- (void)didStartRecord;
- (void)didFinishRecord;

- (void)didRecordChanged:(CGFloat)recordTime VoiceLevel:(NSInteger)voiceLevel;

@end

