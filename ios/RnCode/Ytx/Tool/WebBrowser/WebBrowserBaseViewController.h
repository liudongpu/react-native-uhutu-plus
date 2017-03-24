//
//  WebBrowserViewController.h
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/17.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECDeviceHeaders.h"

#define Web_Base 00000
#define Message_Link 10000
#define Message_Vote 10001
#define Web_shareToWeixin 10002

@class WebBrowserBaseViewController;
@protocol WebBrowserBaseViewControllerDelegate <NSObject>

- (void)onSendPreviewMsgWithUrl:(NSString *)url title:(NSString*)title imgRemotePath:(NSString*)imgRemotePath imgLocalPath:(NSString*)imgLocalPath imgThumbPath:(NSString*)imgThumbPath description:(NSString*)description;

@end

@interface WebBrowserBaseViewController : UIViewController
@property (nonatomic, copy) NSString *urlStr;//网页地址
@property (nonatomic, weak) id<WebBrowserBaseViewControllerDelegate> delegate;
-(instancetype)initWithBody:(ECPreviewMessageBody *)body andDelegate:(id)delegate;
@end
