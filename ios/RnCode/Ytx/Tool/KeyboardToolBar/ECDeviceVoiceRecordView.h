//
//  ECDeviceScrollView.h
//  ECSDKDemo_OC
//
//  Created by admin on 15/11/25.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECDeviceVoiceRecordView;

@protocol ECDeviceVoiceRecordViewDelegate <NSObject>

@required
- (void)onclickedVoiceRecordView:(ECDeviceVoiceRecordView*)voiceRecordView toolBarWillChangeFame:(CGRect)toolbarFrame completion:(void(^)())completion;

- (void)recordButtonTouchDown:(ECDeviceVoiceRecordView*)voiceRecordView;
- (void)recordButtonTouchUpInside:(ECDeviceVoiceRecordView*)voiceRecordView;
- (void)recordButtonTouchUpOutside:(ECDeviceVoiceRecordView*)voiceRecordView;
- (void)recordDragOutside:(ECDeviceVoiceRecordView*)voiceRecordView;
- (void)recordDragInside:(ECDeviceVoiceRecordView*)voiceRecordView;
@end

typedef void (^block)(NSArray* items);

@interface ECDeviceVoiceRecordView : UIView<UIScrollViewDelegate>

+ (instancetype)sharedInstanced;

- (instancetype)initWithFrame:(CGRect)frame imageItems:(NSArray*)imageItems HightImageItems:(NSArray*)HightImageItems titleLabel:(NSArray*)titleArray;

@property (nonatomic, strong) UIImage* defaultPageIndicatorImage;   //默认page图
@property (nonatomic, strong) UIImage* currentPageIndicatorImage;   //当前page图
@property (nonatomic, assign) NSInteger pages;  //页数,如果赋值将有最高优先级
@property (nonatomic, assign) BOOL pagingEnabled;   //默认是YES

@property (nonatomic, assign) BOOL hiddenPageControl;   //隐藏页数标识
@property (nonatomic, weak) id<ECDeviceVoiceRecordViewDelegate> delegate;
@property (nonatomic, assign) BOOL isChangeVoice;

- (void)attachVoiceRecordViewToToobar:(UIView*)toolBar WithInputView:(UIResponder<UITextInput> *)inputView;
- (void)switchToDefaultKeyboard;
- (void)exitVoiceRecordView:(UIView*)toolBar;
@end
