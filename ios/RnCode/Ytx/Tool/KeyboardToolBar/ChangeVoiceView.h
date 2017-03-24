//
//  ChangeVoiceView.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/5.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECDeviceVoiceRecordView.h"
#import <AVFoundation/AVFoundation.h>

@class ChangeVoiceView;

@protocol ChangeVoiceViewDelegate <NSObject>

@required
- (void)sendMediaMessage:(ChangeVoiceView*)changeVoiceView messageBody:(ECFileMessageBody *)mediaBody;

@end

@interface ChangeVoiceView : UIView
@property (nonatomic, weak) id<ChangeVoiceViewDelegate> delegate;

+ (instancetype)sharedInstanced ;
- (instancetype)createChangeVoiceView:(ECDeviceVoiceRecordView *)voiceRecordView;
+ (void)exitChangeVoiceView;
@end
