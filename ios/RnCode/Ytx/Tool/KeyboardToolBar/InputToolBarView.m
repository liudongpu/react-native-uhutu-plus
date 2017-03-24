//
//  InputToolBarView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "InputToolBarView.h"
#import "AppDelegate.h"

@interface InputToolBarView ()

@end

@implementation InputToolBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
        [self registNotification];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
        [self registNotification];
    }
    return self;
}

- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)unRegistNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)buildUI {
    _btnType = ToolbarDisplay_None;
    CGFloat btnWH = self.frame.size.height-5*2;
    CGFloat margin = 5.0f;
    CGFloat inputTextViiewW = self.frame.size.width - 3*btnWH -5*margin;
    CGFloat inputTextViiewH = btnWH;
    
    //聊天的基础功能
    _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceButton.tag = ToolbarDisplay_Record;
    [_voiceButton addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_voiceButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
    [_voiceButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
    _voiceButton.frame = CGRectMake(margin, 5.0f, btnWH, btnWH);
    _voiceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_voiceButton];
    
    _inputTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(2*margin+btnWH, 5.0f, inputTextViiewW, inputTextViiewH)];
    _inputTextView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _inputTextView.layer.cornerRadius = 5.0f;
    _inputTextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    _inputTextView.minNumberOfLines = 1;
    _inputTextView.maxNumberOfLines = 4;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:15.0f];
    _inputTextView.delegate = self;
    _inputTextView.placeholder = @"添加文本";
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_inputTextView];
    
    _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _emojiButton.tag = ToolbarDisplay_Emoji;
    [_emojiButton addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    _emojiButton.frame = CGRectMake(CGRectGetMaxX(_inputTextView.frame)+margin, 5.0f, btnWH, btnWH);
    _emojiButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_emojiButton];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton setImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"add_icon_on"] forState:UIControlStateHighlighted];
    _moreButton.frame = CGRectMake(CGRectGetMaxX(_emojiButton.frame)+margin, 5.0f, btnWH, btnWH);
    _moreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _moreButton.tag = ToolbarDisplay_More;
    [self addSubview:_moreButton];
}

/**
 *@brief 根据按钮改变工具栏的显示布局
 */
-(void)switchToolbarDisplay:(UIButton*)sender {
    ToolbarDisplay type = (ToolbarDisplay)sender.tag;
    sender.selected = (!sender.selected || _btnType!=type);
    _btnType = type;
    switch (type) {
        case ToolbarDisplay_None: {
            [self setBtnImageSource];
        }
            break;
        case ToolbarDisplay_Record: {
            [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
            [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
            if (sender.selected) {
                [_voiceButton setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
                [_voiceButton setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
                [[MoreView sharedInstanced] removeFromSuperview];
                [ChangeVoiceView exitChangeVoiceView];
                [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
                [[ECDeviceVoiceRecordView sharedInstanced] attachVoiceRecordViewToToobar:self WithInputView:_inputTextView.internalTextView];
                
            } else {
                _btnType = ToolbarDisplay_None;
                [_voiceButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
                [_voiceButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
                [[ECDeviceVoiceRecordView sharedInstanced] switchToDefaultKeyboard];
            }
        }
            break;
        case ToolbarDisplay_Emoji: {
            [_voiceButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
            if (sender.selected) {
                [_emojiButton setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
                [_emojiButton setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
                if (!_inputTextView.isFirstResponder) {
                    [_inputTextView becomeFirstResponder];
                }
                //attatch 表情mm键盘
//                NSString *version = [MMEmotionCentre defaultCentre].version;
                [[MoreView sharedInstanced] switchToDefaultKeyboard];
                [[ECDeviceVoiceRecordView sharedInstanced] switchToDefaultKeyboard];
                [ChangeVoiceView exitChangeVoiceView];
                [MMEmotionCentre defaultCentre].delegate = self; //设置BQMM键盘delegate
                [[MMEmotionCentre defaultCentre] shouldShowShotcutPopoverAboveView:_emojiButton withInput:_inputTextView.internalTextView];
                [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView.internalTextView];
            }else{
                _btnType = ToolbarDisplay_None;
                [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
                [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
                [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
            }
        }
            break;
        case ToolbarDisplay_More: {
            [_voiceButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
            [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
            [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
            if (sender.selected) {
                //弹出“更多”键盘
                [[ECDeviceVoiceRecordView sharedInstanced] removeFromSuperview];
                [ChangeVoiceView exitChangeVoiceView];
                [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
                [[MoreView sharedInstanced] attactMoreViewToToolBar:self WithInputView:_inputTextView.internalTextView];
            }else{
                _btnType = ToolbarDisplay_None;
                [[MoreView sharedInstanced] switchToDefaultKeyboard];
            }
        }
            break;
        default:
            _btnType = ToolbarDisplay_None;
            break;
    }
}

- (void)keyBoardWillChangeFame:(NSNotification*)noti {
    if (_btnType == ToolbarDisplay_More || _btnType == ToolbarDisplay_Record) {
        return;
    }

    NSDictionary *userInfo = noti.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.frame;
    frame.origin.y = endFrame.origin.y-frame.size.height-64;
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarWillChangeFame:completion:)]) {
        [self.delegate toolBarWillChangeFame:frame completion:^{
            self.frame = frame;
        }];
    }
}

- (void)resetToolBarToBottom {
    [self setBtnImageSource];
    [[MoreView sharedInstanced] exitMoreView:self];
    [[ECDeviceVoiceRecordView sharedInstanced] exitVoiceRecordView:self];
    [ChangeVoiceView exitChangeVoiceView];
    [_inputTextView.internalTextView resignFirstResponder];
    _btnType = ToolbarDisplay_None;
}

- (void)setBtnImageSource {
    _btnType = ToolbarDisplay_None;
    [_voiceButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
    [_voiceButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
    [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
    [_emojiButton setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
}

- (void)dealloc {
    [self unRegistNotification];
}

#pragma mark - MMEmotionCentreDelegate
// 弹出系统键盘的代理（表情云提供）
- (void)tapOverlay {
    [self setBtnImageSource];
}

- (void)didSendWithInput:(UIResponder<UITextInput> *)input {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTooBarView:growingTextView:shouldChangeTextInRange:replacementText:)]) {
        NSRange range = NSMakeRange(0, 0);
        [self.delegate inputTooBarView:self growingTextView:_inputTextView shouldChangeTextInRange:range replacementText:@"\n"];
    }
}

- (void)didSelectEmoji:(MMEmoji *)emoji {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendFace:)]) {
        [self.delegate didSendFace:emoji];
    }
}

- (void)didSelectTipEmoji:(MMEmoji *)emoji {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendFace:)]) {
        [self.delegate didSendFace:emoji];
        _inputTextView.text = @"";
    }
}
#pragma mark - MoreViewDelegate
- (void)onclickedMoreView:(MoreView *)moreView toolBarWillChangeFame:(CGRect)toolbarFrame completion:(void (^)())completion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarWillChangeFame:completion:)]) {
        [self.delegate toolBarWillChangeFame:toolbarFrame completion:completion];
    }
}

- (void)onclickedBtn:(MoreView *)moreView title:(NSString *)title {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onclickedMoreView:moreview:btnTitle:)]) {
        [self.delegate onclickedMoreView:self moreview:moreView btnTitle:title];
    }
}

#pragma mark - ECDeviceVoiceRecordViewDelegate
- (void)onclickedVoiceRecordView:(ECDeviceVoiceRecordView*)voiceRecordView toolBarWillChangeFame:(CGRect)toolbarFrame completion:(void(^)())completion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarWillChangeFame:completion:)]) {
        [self.delegate toolBarWillChangeFame:toolbarFrame completion:completion];
    }
}

- (void)recordButtonTouchDown:(ECDeviceVoiceRecordView*)voiceRecordView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchDown:)]) {
        [self.delegate recordButtonTouchDown:voiceRecordView];
    }
}

- (void)recordButtonTouchUpInside:(ECDeviceVoiceRecordView*)voiceRecordView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchUpInside:)]) {
        [self.delegate recordButtonTouchUpInside:voiceRecordView];
    }
}

- (void)recordButtonTouchUpOutside:(ECDeviceVoiceRecordView*)voiceRecordView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchUpOutside:)]) {
        [self.delegate recordButtonTouchUpOutside:voiceRecordView];
    }
}

- (void)recordDragOutside:(ECDeviceVoiceRecordView*)voiceRecordView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDragOutside:)]) {
        [self.delegate recordDragOutside:voiceRecordView];
    }
}

- (void)recordDragInside:(ECDeviceVoiceRecordView*)voiceRecordView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDragInside:)]) {
        [self.delegate recordDragInside:voiceRecordView];
    }
}

#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTooBarView:growingTextView:willChangeHeight:)]) {
        [self.delegate inputTooBarView:self growingTextView:growingTextView willChangeHeight:height];
    }
}

//获取焦点
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    [[MoreView sharedInstanced] exitMoreView:self];
    [[ECDeviceVoiceRecordView sharedInstanced] exitVoiceRecordView:self];
    [ChangeVoiceView exitChangeVoiceView];

    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTooBarView:growingTextViewDidBeginEditing:)]) {
        [self.delegate inputTooBarView:self growingTextViewDidBeginEditing:growingTextView];
    }
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTooBarView:growingTextViewDidEndEditing:)]) {
        [self.delegate inputTooBarView:self growingTextViewDidEndEditing:growingTextView];
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    _btnType = (_btnType==ToolbarDisplay_More | _btnType==ToolbarDisplay_Record)?ToolbarDisplay_None:_btnType;
    [_voiceButton setImage:[UIImage imageNamed:@"voice_icon"] forState:UIControlStateNormal];
    [_voiceButton setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTooBarView:growingTextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputTooBarView:self growingTextView:growingTextView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTooBarView:growingTextViewDidChangeSelection:)]) {
        [self.delegate inputTooBarView:self growingTextViewDidChangeSelection:growingTextView];
    }
}
@end
