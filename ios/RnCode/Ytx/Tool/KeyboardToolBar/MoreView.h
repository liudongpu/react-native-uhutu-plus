//
//  MoreView.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MoreView;

@protocol MoreViewDelegate <NSObject>

@required
- (void)onclickedBtn:(MoreView*)moreView title:(NSString*)title;
- (void)onclickedMoreView:(MoreView*)moreView toolBarWillChangeFame:(CGRect)toolbarFrame completion:(void(^)())completion;

@end

@interface MoreView : UIView

@property (nonatomic, weak) id<MoreViewDelegate> moreViewDelegate;

@property (nonatomic, assign) CGFloat moreViewHeight;
@property (nonatomic, assign) CGSize btnSize;

+ (instancetype)sharedInstanced;

- (void)replaceBtnImage:(NSString*)imageNamed hightImage:(NSString*)hightImageNamed title:(NSString*)title forBtnIndex:(NSInteger)index;

- (void)buildUIWithbtnSize:(CGSize)btnSize;

- (void)attactMoreViewToToolBar:(UIView*)toolBar WithInputView:(UIResponder<UITextInput> *)inputView;
- (void)switchToDefaultKeyboard;
- (void)exitMoreView:(UIView*)toolBar;
@end
