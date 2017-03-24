//
//  ChangeVoiceView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/5.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChangeVoiceView.h"
#define footViewH 33.0f

@interface ChangeVoiceView ()
@property (nonatomic, strong) UIView *footView;

@end
@implementation ChangeVoiceView

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ChangeVoiceView *changeVoiceView = nil;
    dispatch_once(&onceToken, ^{
        changeVoiceView = [[[self class] alloc] init];
    });
    return changeVoiceView;
}

- (instancetype)createChangeVoiceView:(ECDeviceVoiceRecordView *)voiceRecordView
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"changeVoice_file"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.frame = voiceRecordView.frame;
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    
    NSArray *imagesArr = @[@"voiceChange_0",@"voiceChange_1",@"voiceChange_2",@"voiceChange_3",@"voiceChange_4",@"voiceChange_5"];
    NSArray *textArr = @[@"原声",@"萝莉",@"大叔",@"惊悚",@"搞怪",@"空灵"];
    NSArray *selectorArr = @[@"sourceVoice",@"petiteVoice",@"uncleVoice",@"thrillerVoice",@"parodyVoice",@"spaciousVoice"];
    CGFloat buttonW = 40;
    CGFloat buttonH = 40;
    CGFloat buttonX;
    CGFloat buttonY;
    CGFloat marginHorizontal = (KscreenW -3*buttonW)/(3+1);
    CGFloat marginVerticality = (voiceRecordView.frame.size.height - buttonH*2-footViewH)/3;
    NSInteger rowIndex;
    NSInteger coloumnIndex;
    for (NSInteger index = 0; index<imagesArr.count; index++) {
        rowIndex = index / 3;
        coloumnIndex = index % 3;

        NSString *imageLight = [NSString stringWithFormat:@"%@_on",imagesArr[index]];
        UIButton *extenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        extenBtn.frame = CGRectMake(50.0f+(50.0+40.0f)*(index%3), 10.0f+ (40.0+20)*(index/3), 40.0f, 40.0f);
        SEL seletor = NSSelectorFromString(selectorArr[index]);
        [extenBtn addTarget:self action:seletor forControlEvents:UIControlEventTouchUpInside];
        [extenBtn setImage:[UIImage imageNamed:imagesArr[index]] forState:UIControlStateNormal];
        [extenBtn setImage:[UIImage imageNamed:imageLight] forState:UIControlStateHighlighted];
        extenBtn.tag = index;
        buttonX = marginHorizontal*(coloumnIndex+1) + buttonW*coloumnIndex;
        buttonY = marginVerticality*(rowIndex+1) + buttonH*rowIndex;
        extenBtn.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [self addSubview:extenBtn];
        
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(extenBtn.frame)-10.0f,CGRectGetMaxY(extenBtn.frame)+5.0f, 60.0f, 15.0f)];
        btnLabel.font = [UIFont systemFontOfSize:14.0f];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        btnLabel.text = textArr[index];
        [self addSubview:btnLabel];
    }
    
    {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, voiceRecordView.bounds.size.height-footViewH, KscreenW, footViewH)];
        footView.backgroundColor = [UIColor whiteColor];
        [self addSubview:footView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0,KscreenW/2-0.5, footViewH);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [cancelBtn addTarget:self action:@selector(cancelChangeVoiceView) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:cancelBtn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(KscreenW/2-0.5, 0, 1.0f, footView.bounds.size.height)];
        label.backgroundColor = [UIColor grayColor];
        [footView addSubview:label];
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(KscreenW/2+0.5, 0,KscreenW/2-0.5,footView.bounds.size.height);
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [sendBtn addTarget:self action:@selector(sendChangeVoice) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:sendBtn];
    }
    return self;
}

+ (void)exitChangeVoiceView {
    [[self sharedInstanced] cancelChangeVoiceView];
}
#pragma mark - 变声
- (void)cancelChangeVoiceView {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"changeVoice_MessageBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    [self removeFromSuperview];
}

- (void)sendChangeVoice {
    
    NSString *displayname = [[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_MessageBody"];
    [self cancelChangeVoiceView];
    ECVoiceMessageBody *voiceBody;
    if (displayname.length>0) {
        
        voiceBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:displayname] displayName:displayname];
        
    } else {
        NSString *srcDisplayname = [[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_file"];
        voiceBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:srcDisplayname] displayName:srcDisplayname];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(sendMediaMessage:messageBody:)]) {
        [self.delegate sendMediaMessage:self messageBody:voiceBody];
    }
}

- (void)sourceVoice {
    
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    NSString *displayname = [[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_file"];
    
    ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:displayname] displayName:displayname];
    
    [[NSUserDefaults standardUserDefaults] setObject:messageBody.displayName forKey:@"changeVoice_MessageBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[ECDevice sharedInstance].messageManager playVoiceMessage:messageBody completion:^(ECError *error) {
    }];
}

- (void)petiteVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.pitch = 8;
    [self changeVoiceAndPlayVoice:config];
}

- (void)uncleVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.pitch = -4;
    config.rate = -10;
    [self changeVoiceAndPlayVoice:config];
}

- (void)thrillerVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.tempoChange = 0;
    config.pitch = 0;
    config.rate = -20;
    [self changeVoiceAndPlayVoice:config];
}

- (void)parodyVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.rate = 100;
    [self changeVoiceAndPlayVoice:config];
}

- (void)spaciousVoice {
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    config.tempoChange = 20;
    config.pitch = 0;
    [self changeVoiceAndPlayVoice:config];
}

- (void)changeVoiceAndPlayVoice:(ECSountTouchConfig*)config {
    
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    NSString *srcFile = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:@"changeVoice_file"]];
    NSString *desFile = [[DeviceChatHelper sharedInstance] createSavePath];
    config.srcVoice = srcFile;
    config.dstVoice = desFile;
    
    [[ECDevice sharedInstance].messageManager changeVoiceWithSoundConfig:config completion:^(ECError *error, ECSountTouchConfig* dstSoundConfig) {
        
        if (error.errorCode == ECErrorType_NoError) {
            
            ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[dstSoundConfig.dstVoice lastPathComponent]] displayName:[dstSoundConfig.dstVoice lastPathComponent]];
            
            [[NSUserDefaults standardUserDefaults] setObject:messageBody.displayName forKey:@"changeVoice_MessageBody"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[ECDevice sharedInstance].messageManager playVoiceMessage:messageBody completion:^(ECError *error) {
                
            }];
        }
    }];
}
@end
