//
//  WebBrowserViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/17.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "WebBrowserBaseViewController.h"
#import <WebKit/WebKit.h>
#import "TFHpple.h"
#import "UIImageView+WebCache.h"
#import "NSString+containsString.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>


#define IPHONE8 [UIDevice currentDevice].systemVersion.integerValue<8.0

@interface WebBrowserBaseViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>
@property (nonatomic,strong) UIWebView *WebView;
@property (nonatomic,strong) WKWebView *wkWebView;
@property (nonatomic, strong) TFHpple *doc;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imgLocalPath;
@property (nonatomic, copy) NSString *imgThumbPath;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation WebBrowserBaseViewController

- (instancetype)initWithBody:(ECPreviewMessageBody *)body andDelegate:(id)delegate {
    self=[super init];
    if (self) {
        _urlStr = body.url;
        self.delegate = delegate;
        _imageStr = body.remotePath;
        _articleTitle = body.title;
        _imgLocalPath = body.localPath;
        _imgThumbPath = body.thumbnailLocalPath;
        _content = body.desc;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"网页";
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClick)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, 2);
    _progressView.tintColor = [UIColor greenColor];
    [self.view addSubview:_progressView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_urlStr.length>0) {
        NSURL *url = [NSURL URLWithString:_urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        if (IPHONE8) {
            _WebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _progressView.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height-_progressView.bounds.size.height)];
            _WebView.delegate = self;
            [self.view addSubview:_WebView];
            [self.WebView loadRequest:request];
        } else {
            _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, _progressView.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height-_progressView.bounds.size.height)];
            [self.view addSubview:_wkWebView];
            _wkWebView.navigationDelegate = self;
            _wkWebView.UIDelegate = self;
            [_wkWebView loadRequest:request];
        }
    }
}

- (void) setRighBarItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(shareAppToYTX)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;

}

- (void)returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAppToYTX {
    
    if (Message_Link == self.view.tag && self.delegate&&[self.delegate respondsToSelector:@selector(onSendPreviewMsgWithUrl:title:imgRemotePath:imgLocalPath:imgThumbPath:description:)]) {
        [self.delegate onSendPreviewMsgWithUrl:_urlStr?:nil title:_articleTitle?:@"网页" imgRemotePath:_imageStr?:nil imgLocalPath:_imgLocalPath?:nil imgThumbPath:_imgThumbPath?:nil description:_content?:_urlStr];
        [self returnClick];
    } else if (self.view.tag == Web_shareToWeixin) {
        [self shareAppToWeixin];
    }
}

- (void)shareAppToWeixin {
    
}
#pragma mark - UIWebViewdelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title =  self.title.length>0?self.title:@"网页";
    if (_articleTitle.length>0 || Web_shareToWeixin == self.view.tag) {
        [self setRighBarItem];
    } else if(Message_Link == self.view.tag) {
        [self parseHtml:[NSURL URLWithString:_urlStr]];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (void)showToast:(NSString*)description {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.margin = 10.0f;
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = description;
    [hud hide:YES afterDelay:2.0f];
}

#pragma mark - navigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    _progressView.progress = webView.estimatedProgress;
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    _progressView.progress = webView.estimatedProgress;

    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
        self.title = title.length>0?title:@"网页";
    }];
    
    if (_articleTitle.length>0 || Web_shareToWeixin == self.view.tag) {
        [self setRighBarItem];
    } else if(Message_Link == self.view.tag){
        [self parseHtml:webView.URL];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential))completionHandler {
    _progressView.progress = webView.estimatedProgress;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        CFDataRef exceptions = SecTrustCopyExceptions(serverTrust);
        SecTrustSetExceptions(serverTrust, exceptions);
        CFRelease(exceptions);
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,
                          [NSURLCredential credentialForTrust:serverTrust]);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    _progressView.progress = webView.estimatedProgress;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_progressView removeFromSuperview];
        _wkWebView.frame = self.view.bounds;
    });
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [_progressView removeFromSuperview];
    _wkWebView.frame = self.view.bounds;
}

- (void)parseHtml:(NSURL*)url {
    self.doc = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:url]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *titleArray = [self.doc searchWithXPathQuery:@"//title"];
        for (TFHppleElement *element in titleArray) {
            _articleTitle = element.text?:@"网页";
            _articleTitle = [[[_articleTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
            _articleTitle = [_articleTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = _articleTitle;
            });
        }
        if (![_urlStr myContainsString:@"taobao.com"]) {
            NSArray *descArray = [self.doc searchWithXPathQuery:@"//meta"];
            for (TFHppleElement *element in descArray) {
                if ([[element objectForKey:@"name"] isEqualToString:@"description"]) {
                    _content = [element.attributes objectForKey:@"content"]?:@"";
                }
            }
        }
        if (_content.length<=0) {
            NSRange range1;
            _urlStr = [_urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([_urlStr hasPrefix:@"http://"]) {
                range1 = [_urlStr rangeOfString:@"http://"];
            } else if ([_urlStr hasPrefix:@"https://"]) {
                range1 = [_urlStr rangeOfString:@"https://"];
            }
            NSRange range2 = [_urlStr rangeOfString:@".com"];
            if (range1.length>0) {
                NSRange range3 = [[_urlStr substringFromIndex:range1.length] rangeOfString:@":"];
                range3.location+=range1.length-1;
                NSRange range4 = [[_urlStr substringFromIndex:range1.length] rangeOfString:@"/"];
                range4.location+=range1.length-1;
                range3 = range3.length==0?range4:range3;
                NSRange range = range2.length==0?range3:range2;
                if (range.length>0) {
                    _content = [_urlStr substringWithRange:NSMakeRange(range1.location+range1.length, range.location+range.length-range1.length)]?:@"";
                }
            }
        }

        NSArray *imgArray = [self.doc searchWithXPathQuery:@"//img"];
        [imgArray enumerateObjectsUsingBlock:^(TFHppleElement *element, NSUInteger idx, BOOL *stop) {
            if ([[element objectForKey:@"class"] isEqualToString:@"firstPreload"]) {
                NSLog(@"img:%@",element.attributes);
                _imageStr = [element.attributes objectForKey:@"src"]?:@"";
            }
        }];
        if (_imageStr.length<=0&&imgArray.count>0) {
            TFHppleElement *element0 = (TFHppleElement *)imgArray[0];
            TFHppleElement *element = [[TFHppleElement alloc] init];
            if (imgArray.count>1) {
                TFHppleElement *element1 = (TFHppleElement *)imgArray[1];
                element = element1==nil?element0:element1;
            }
            _imageStr = [element objectForKey:@"src"];
        }
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_imageStr] options:SDWebImageCacheMemoryOnly progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                
            } else {
                image = [UIImage imageNamed:@"attachment"];
            }
            [self saveImage:image];
        }];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setRighBarItem];
        });
    });
    
}

- (void)saveImage:(UIImage*)image {
    image==nil?[UIImage imageNamed:@"attachment"]:image;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",dateStr]];
    _imgLocalPath = path;
    
    NSData *imageData = [NSData data];
    imageData = UIImageJPEGRepresentation(image, 0.5);
    [imageData writeToFile:path atomically:YES];
    
    CGSize thumsize = CGSizeMake((90.0f/image.size.height) * image.size.width, 90.0f);
    UIImage * thumImage = [CommonTools compressImage:image withSize:thumsize];
    NSData *photo = UIImageJPEGRepresentation(thumImage, 0.5);
    NSString * thumfilePath = [NSString stringWithFormat:@"%@_thum",path];;
    _imgThumbPath = thumfilePath;
    [photo writeToFile:_imgThumbPath atomically:YES];
}
@end
