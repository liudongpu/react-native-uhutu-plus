//
//  CustomEmojiView.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "CustomEmojiView.h"

#define EXPRESSION_SCROLL_VIEW_TAG 100
#define pagecontrolW 120.0f
#define pagecontrolH 20.0f
#define emojiViewH 236
#define footViewH 40.0f


@interface CustomEmojiView()<UIScrollViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIScrollView *footView;
@property (nonatomic, strong) NSArray *defaultArray;
@end

@implementation CustomEmojiView
{
    UIPageControl *_pageCtrl;
    UIScrollView  *_pageScroll;
}

+(CustomEmojiView*)shardInstance{
    static dispatch_once_t emojiviewOnce;
    static CustomEmojiView *cutomemojiview;
    dispatch_once(&emojiviewOnce, ^{
        cutomemojiview = [[CustomEmojiView alloc] initWithFrame:CGRectMake(0, 0, KscreenW, emojiViewH)];
    });
    return cutomemojiview;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _textView = [[UITextView alloc] init];
        _textView.inputView = self;
    }
    return self;
}

- (void)setDefaultEmojiArray:(NSArray<NSString *> *)emojiArray {
    _defaultArray = emojiArray;
    [self buildEmojiUi];
}

- (void)buildEmojiUi {
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.backgroundColor = [UIColor clearColor];
    
    NSInteger pageCount = 7;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    scrollView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    scrollView.tag = EXPRESSION_SCROLL_VIEW_TAG;
    _pageScroll = scrollView;
    _pageScroll.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*pageCount, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    
    int row = 4;
    int column = 7;
    int number = 0;
    CGFloat emojiW = 40.0f;
    CGFloat emojiH = 30.0f;
    CGFloat marginH = (KscreenW -column*emojiW)/(column+1);
    CGFloat marginV = (emojiViewH-pagecontrolH-footViewH-row*emojiH)/(row+1);
    for (int p=0; p<pageCount; p++)
    {
        NSInteger page_X = p*scrollView.frame.size.width;
        for (int j=0; j<row; j++)
        {
            NSInteger row_y = marginV*(j+1)+emojiH*j;
            for (int i=0; i<column; i++)
            {
                NSInteger column_x = marginH*(i+1)+emojiW*i;
                if (number > 170)
                {
                    break;
                }
                
                if (j!=row-1 || i!=column-1)
                {
                    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+column_x, row_y, emojiW, emojiH)];
                    btn.tag = number;
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:_defaultArray[number] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(putExpress:) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:btn];
                    number++;
                }
            }
        }
        
        UIButton* delBtn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+marginH*column+(column-1)*emojiW, marginV*row+(row-1)*emojiH, emojiW, emojiH)];
        delBtn.backgroundColor = [UIColor clearColor];
        [delBtn setImage:[UIImage imageNamed:@"emoji_delete_pressed"] forState:UIControlStateHighlighted];
        [delBtn setImage:[UIImage imageNamed:@"emoji_delete"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(backspaceText:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:delBtn];
    }
    
    [self addSubview:scrollView];
    
    UIPageControl *pageView = [[UIPageControl alloc] init];
    pageView.currentPageIndicatorTintColor = [UIColor blackColor];
    pageView.pageIndicatorTintColor = [UIColor grayColor];
    pageView.numberOfPages = pageCount;
    pageView.currentPage = 0;
    [pageView addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    _pageCtrl = pageView;
    [self addSubview:pageView];
    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-pagecontrolmargin-[pageView]-pagecontrolmargin-|" options:0 metrics:@{@"pagecontrolmargin":@((KscreenW-pagecontrolW)/2)} views:NSDictionaryOfVariableBindings(pageView)]];

    
    UIScrollView *footView = [[UIScrollView alloc] init];
    footView.backgroundColor = [UIColor whiteColor];
    footView.showsHorizontalScrollIndicator = NO;
    footView.contentSize = CGSizeMake(KscreenW, footViewH);
    _footView = footView;
    [self addSubview:footView];
    footView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageView(==pagecontrolH@700)][footView(==40)]-|" options:0 metrics:@{@"pagecontrolH":@(pagecontrolH)} views:NSDictionaryOfVariableBindings(pageView,footView)]];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setBackgroundImage:[[UIImage imageNamed:@"common_resizable_blue_N"] stretchableImageWithLeftCapWidth:6 topCapHeight:20] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[[UIImage imageNamed:@"common_resizable_blue_H"] stretchableImageWithLeftCapWidth:6 topCapHeight:20]forState:UIControlStateHighlighted];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:sendBtn.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f],NSForegroundColorAttributeName:[UIColor blackColor]}] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(emojiSendBtn:) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.layer.borderColor = [UIColor grayColor].CGColor;
    sendBtn.layer.borderWidth = 1;
    [self addSubview:sendBtn];
    sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[footView(==footViewW)]-[sendBtn(==60@1000)]|" options:0 metrics:@{@"footViewW":@(KscreenW-60)} views:NSDictionaryOfVariableBindings(footView,sendBtn)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sendBtn(==40@700)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sendBtn)]];
    
}

- (void)switchToDefaultKeyboard {
    _textView.inputView = nil;
    _textView.inputAccessoryView = nil;
    [_textView reloadInputViews];
    _textView = nil;
}

- (void)attachEmotionKeyboardToInput:(UIResponder<UITextInput> *)textView {
    _textView = textView;
    _textView.inputView = self;
    [_textView reloadInputViews];
    [_textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSysKeyBoard)]];
}

-(void)putExpress:(id)sender{
    UIButton *button_tag = (UIButton *)sender;
    [_textView insertText:_defaultArray[button_tag.tag]];
}

- (void)backspaceText:(id)sender{
    [_textView deleteBackward];
}

-(void)emojiSendBtn:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiSendBtn:)]) {
        [self.delegate emojiSendBtn:sender];
    }
}

- (void)tapSysKeyBoard {
    [self switchToDefaultKeyboard];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTextView)]) {
        [self.delegate tapTextView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == EXPRESSION_SCROLL_VIEW_TAG)
    {
        //更新UIPageControl的当前页
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.frame;
        [_pageCtrl setCurrentPage:offset.x / bounds.size.width];
    }
}

- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = _pageScroll.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [_pageScroll scrollRectToVisible:rect animated:YES];
}

@end
