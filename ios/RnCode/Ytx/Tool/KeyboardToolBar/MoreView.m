//
//  MoreView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "MoreView.h"
#import "ChatViewController.h"

#define preHight 20
#define DefaultMoreViewHight 183.0f

NSString *const MoreView_Btn_Image_Key = @"MoreView_Btn_Image_Key";
NSString *const MoreView_Btn_HightImage_Key = @"MoreView_Btn_HightImage_Key";
NSString *const MoreView_Btn_Title_Key = @"MoreView_Btn_Title_Key";

@interface MoreView ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *moreBtnArray;

@property (nonatomic, strong) UIResponder<UITextInput> *inputView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation MoreView

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static MoreView *moreView = nil;
    dispatch_once(&onceToken, ^{
        moreView = [[[self class] alloc] init];
    });
    return moreView;
}

-(instancetype)init {
    self=[super init];
    if (self) {
        self.moreBtnArray = [NSMutableArray array];
        self.inputView = [[UITextView alloc] init];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)replaceBtnImage:(NSString*)imageNamed hightImage:(NSString*)hightImageNamed title:(NSString*)title forBtnIndex:(NSInteger)index{
    
    [self.moreBtnArray replaceObjectAtIndex:index withObject:@{MoreView_Btn_Image_Key:imageNamed,MoreView_Btn_HightImage_Key:hightImageNamed,MoreView_Btn_Title_Key:title}];
}

- (void)addBtnImage:(NSString*)imageNamed hightImage:(NSString*)hightImageNamed title:(NSString*)title forBtnIndex:(NSInteger)index{
    
    [self.moreBtnArray addObject:@{MoreView_Btn_Image_Key:imageNamed,MoreView_Btn_HightImage_Key:hightImageNamed,MoreView_Btn_Title_Key:title}];
}

- (void)addDisPlayBtn:(NSDictionary*)btnInfo{
    
    [self.moreBtnArray addObject:btnInfo];
}

- (void)setDisPlayBtnArray:(NSArray*)btnArray {
    
    [self.moreBtnArray removeAllObjects];
    [self.moreBtnArray addObjectsFromArray:btnArray];
}

- (void)addDisPlayBtnArray:(NSArray*)btnArray {
    [self.moreBtnArray addObjectsFromArray:btnArray];
}

- (void)setMoreViewHeight:(CGFloat)moreViewHeight {
    _moreViewHeight = moreViewHeight;
}

- (void)setBtnSize:(CGSize)btnSize {
    _btnSize = btnSize;
}

- (void)buildUIWithbtnSize:(CGSize)btnSize {
    _btnSize = btnSize;
    NSInteger btnCount = self.moreBtnArray.count;
    CGFloat height = 0;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    if (btnCount>8) {
        height = preHight;
        _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-height);
        _scrollView.contentSize = CGSizeMake(self.frame.size.width*(btnCount/8), self.frame.size.height-height);
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height)];
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        pageControl.numberOfPages = btnCount/8;
        pageControl.currentPage = 0;
        [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
        _pageControl = pageControl;
        [self addSubview:pageControl];
    }
    [self buildBtnView:btnSize];
}

- (void)buildBtnView:(CGSize)btnSize {
    NSInteger btnCount = self.moreBtnArray.count;
    CGFloat buttonW = btnSize.width;
    CGFloat buttonH = btnSize.height;
    CGFloat buttonX;
    CGFloat buttonY;
    CGFloat marginHorizontal = (KscreenW -4*buttonW)/(4+1);
    CGFloat preMargin = btnCount>8?0:10;
    CGFloat marginVerticality = (_scrollView.frame.size.height - (buttonH+preMargin)*2)/3;
    NSInteger rowIndex;
    NSInteger coloumnIndex;
    for (NSInteger index = 0; index<btnCount; index++) {
        
        NSDictionary *btnInfoDic = self.moreBtnArray[index];
        UIButton *extenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        extenBtn.tag = index;
        [extenBtn addTarget:self action:@selector(onClickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        [extenBtn setImage:[UIImage imageNamed:btnInfoDic[MoreView_Btn_Image_Key]] forState:UIControlStateNormal];
        [extenBtn setImage:[UIImage imageNamed:btnInfoDic[MoreView_Btn_HightImage_Key]] forState:UIControlStateHighlighted];
        [extenBtn setTitle:btnInfoDic[MoreView_Btn_Title_Key] forState:UIControlStateNormal];
        [extenBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:extenBtn.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0],NSForegroundColorAttributeName:[UIColor blackColor]}] forState:UIControlStateNormal];

        rowIndex = index / 4;
        coloumnIndex = index % 4;

        CGFloat preWidth = 0;
        CGFloat imageTop = 0;
        CGFloat titleTop = 10+preHight;
        if (index>=8) {
            preWidth = _scrollView.bounds.size.width*(index/8);
            rowIndex %=2;
        }
        if (btnCount>8) {
            imageTop = -preHight;
            titleTop = 10;
        }
        extenBtn.imageEdgeInsets = UIEdgeInsetsMake(imageTop, 0,-10, extenBtn.bounds.size.width);
        extenBtn.titleEdgeInsets = UIEdgeInsetsMake(_btnSize.height+titleTop, extenBtn.bounds.size.width-btnSize.width,0 , 0);
        extenBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        extenBtn.contentMode = UIViewContentModeScaleAspectFill;
        buttonX = marginHorizontal*(coloumnIndex+1) + buttonW*coloumnIndex+preWidth;
        buttonY = marginVerticality*(rowIndex+1) + buttonH*rowIndex;
        extenBtn.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [_scrollView  addSubview:extenBtn];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
   UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subview in _scrollView.subviews) {
            if ([[subview class] isSubclassOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton*)subview;
                CGPoint touchpoint = [btn convertPoint:point fromView:_scrollView];
                if (CGRectContainsPoint(btn.bounds, touchpoint)) {
                    view = btn;
                }
            }
        }
    }
    return view;
}

- (void)onClickedBtn:(UIButton*)sender {
    if (self.moreViewDelegate && [self.moreViewDelegate respondsToSelector:@selector(onclickedBtn:title:)]) {
        [self.moreViewDelegate onclickedBtn:self title:[sender titleForState:UIControlStateNormal]];
    }
}

- (void)attactMoreViewToToolBar:(UIView *)toolBar WithInputView:(UIResponder<UITextInput> *)inputView{
    CGFloat addHight = DefaultMoreViewHight;
    
    [self platformSource];
    if (self.moreBtnArray.count>8) {
        addHight = DefaultMoreViewHight+preHight;
    }

    _moreViewHeight = _moreViewHeight>0?_moreViewHeight:addHight;
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    self.moreViewDelegate = toolBar;
    _inputView = inputView;
    if (inputView.isFirstResponder) {
        [inputView resignFirstResponder];
    }
    
    CGSize size = CGSizeMake(60, 50);
    _btnSize = (_btnSize.height>0 && _btnSize.width>0)?_btnSize:size;
    CGRect superFrame = toolBar.superview.frame;
    self.frame = CGRectMake(0, superFrame.size.height-_moreViewHeight, superFrame.size.width,_moreViewHeight);
    [self buildUIWithbtnSize:_btnSize];
    
    __weak typeof(self)weakSelf = self;
    CGRect frame = toolBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height-frame.size.height-toolBar.superview.frame.origin.y-_moreViewHeight;
    if (self.moreViewDelegate && [self.moreViewDelegate respondsToSelector:@selector(onclickedMoreView:toolBarWillChangeFame:completion:)]) {
        [self.moreViewDelegate onclickedMoreView:self toolBarWillChangeFame:frame completion:^{
            toolBar.frame = frame;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CGRect moreFrame = weakSelf.frame;
                moreFrame.origin.y = toolBar.superview.bounds.size.height;
                weakSelf.frame = moreFrame;
                [toolBar.superview addSubview:weakSelf];
                [UIView animateWithDuration:0.15 delay:0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    weakSelf.frame = CGRectMake(0, toolBar.frame.origin.y+toolBar.frame.size.height, weakSelf.frame.size.width,_moreViewHeight);
                } completion:^(BOOL finished){
                }];
            });
        }];
    }
}

- (BOOL)platformSource {
    id controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)controller;
        UIViewController *vc = nav.topViewController;
        if ([vc isKindOfClass:[ChatViewController class]]) {
            ChatViewController *chatVC = (ChatViewController *)vc;
            
            //聊天窗口全有的功能
            [self setDisPlayBtnArray:@[
                                       @{MoreView_Btn_Image_Key:@"dialogue_image_icon",MoreView_Btn_HightImage_Key:@"dialogue_image_icon_on",MoreView_Btn_Title_Key:@"图片"},
                                       @{MoreView_Btn_Image_Key:@"dialogue_camera_icon",MoreView_Btn_HightImage_Key:@"dialogue_camera_icon_on",MoreView_Btn_Title_Key:@"拍摄"}
                                       ]];
            
            if ([chatVC.sessionId hasPrefix:@"g"]) {
                //群组聊天的功能
                [self addDisPlayBtn:@{MoreView_Btn_Image_Key:@"chat_location_normal",MoreView_Btn_HightImage_Key:@"chat_location_normal_on",MoreView_Btn_Title_Key:@"位置"}];
                
                [self addDisPlayBtn:@{MoreView_Btn_Image_Key:@"dialogue_redpacket_icon",MoreView_Btn_HightImage_Key:@"dialogue_redpacket_icon_on",MoreView_Btn_Title_Key:@"红包"}];
                
            } else {
                //非群组聊天功能
                if ( ![chatVC.sessionId isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
                    
                    //不是自己的具有的功能
                    if ([DemoGlobalClass sharedInstance].isSDKSupportVoIP) {
                        
                        //是否支持voip功能
                        [self addDisPlayBtnArray: @[
                                                    @{MoreView_Btn_Image_Key:@"dialogue_phone_icon",MoreView_Btn_HightImage_Key:@"dialogue_phone_icon_on",MoreView_Btn_Title_Key:@"音频"},
                                                    @{MoreView_Btn_Image_Key:@"dialogue_video_icon",MoreView_Btn_HightImage_Key:@"dialogue_video_icon_on",MoreView_Btn_Title_Key:@"视频"}]
                         ];
                    }
                    
                    [self addDisPlayBtnArray: @[
                                                @{MoreView_Btn_Image_Key:@"dialogue_snap_icon",MoreView_Btn_HightImage_Key:@"dialogue_snap_icon_on",MoreView_Btn_Title_Key:@"阅后即焚"},
                                                @{MoreView_Btn_Image_Key:@"chat_location_normal",MoreView_Btn_HightImage_Key:@"chat_location_normal_on",MoreView_Btn_Title_Key:@"位置"},
                                                ]];
                    
                    [self addDisPlayBtn:@{MoreView_Btn_Image_Key:@"dialogue_redpacket_icon",MoreView_Btn_HightImage_Key:@"dialogue_redpacket_icon_on",MoreView_Btn_Title_Key:@"红包"}];
                    
                } else {
                    //其他 即自己的聊天窗口的功能
                    [self addDisPlayBtnArray: @[
                                                @{MoreView_Btn_Image_Key:@"dialogue_snap_icon",MoreView_Btn_HightImage_Key:@"dialogue_snap_icon_on",MoreView_Btn_Title_Key:@"阅后即焚"},
                                                @{MoreView_Btn_Image_Key:@"chat_location_normal",MoreView_Btn_HightImage_Key:@"chat_location_normal_on",MoreView_Btn_Title_Key:@"位置"}
                                                ]];
                }
            }
            return YES;
        }
    }
    NSLog(@"请先设置图片数据源");
    return NO;
}

- (void)switchToDefaultKeyboard {
    [_inputView becomeFirstResponder];
    [self removeFromSuperview];
}

- (void)exitMoreView:(UIView*)toolBar {
    if (self.superview && !_inputView.isFirstResponder) {
        CGRect frame = toolBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height-toolBar.frame.size.height-toolBar.superview.frame.origin.y;
        if (self.moreViewDelegate && [self.moreViewDelegate respondsToSelector:@selector(onclickedMoreView:toolBarWillChangeFame:completion:)]) {
            [self.moreViewDelegate onclickedMoreView:self toolBarWillChangeFame:frame completion:^{
                toolBar.frame = frame;
            }];
        }
    }
    [self removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = _pageControl.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [_scrollView scrollRectToVisible:rect animated:YES];
}

@end
