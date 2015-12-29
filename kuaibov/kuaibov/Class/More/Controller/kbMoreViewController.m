//
//  kbMoreViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbMoreViewController.h"
#import "KbSystemConfigModel.h"
#import <AFNetworkReachabilityManager.h>

//static const NSUInteger kUIWebViewRetryTimes = 30;

@interface kbMoreViewController () <UIWebViewDelegate>
{
    UIWebView *_webView;
    UIImageView *_topImageView;
}
@property (nonatomic) NSUInteger retryTimes;
@property (nonatomic) BOOL isStandBy;
@property (nonatomic,retain,readonly) NSURLRequest *urlRequest;
@property (nonatomic,retain,readonly) NSURLRequest *standbyUrlRequest;
@end

@import WebKit;

@implementation kbMoreViewController
@synthesize urlRequest = _urlRequest;
@synthesize standbyUrlRequest = _standbyUrlRequest;

- (NSURLRequest *)urlRequest {
    if (_urlRequest) {
        return _urlRequest;
    }
    
    NSString *urlString = [KB_BASE_URL stringByAppendingString:KB_AGREEMENT_URL];
    _urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    return _urlRequest;
}

- (NSURLRequest *)standbyUrlRequest {
    if (_standbyUrlRequest) {
        return _standbyUrlRequest;
    }
    
    NSString *urlString = [KB_STANDBY_BASE_URL stringByAppendingString:KB_STANDBY_AGREEMENT_URL];
    _standbyUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    return _standbyUrlRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"更多";
    
    _topImageView = [[UIImageView alloc] init];
    _topImageView.userInteractionEnabled = YES;
    [_topImageView YPB_addAnimationForImageAppearing];
    [self.view addSubview:_topImageView];
    
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    [_topImageView bk_whenTapped:^{
        NSString *spreadURL = [KbSystemConfigModel sharedModel].spreadURL;
        if (spreadURL) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:spreadURL]];
        }
    }];
    
    [self.navigationController.navigationBar bk_whenTouches:1 tapped:5 handler:^{
        NSString *baseURLString = [KB_BASE_URL stringByReplacingCharactersInRange:NSMakeRange(0, KB_BASE_URL.length-6) withString:@"******"];
        [[KbHudManager manager] showHudWithText:[NSString stringWithFormat:@"Server:%@\nChannelNo:%@\nPackageCertificate:%@", baseURLString, KB_CHANNEL_NO, KB_PACKAGE_CERTIFICATE]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSHTTPURLResponse *response;
        NSError *error;
        [NSURLConnection sendSynchronousRequest:self.urlRequest returningResponse:&response error:&error];
        NSInteger responseCode = response.statusCode;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (responseCode == 502) {
                [_webView loadRequest:self.standbyUrlRequest];
            } else {
                [_webView loadRequest:self.urlRequest];
            }
        });
    });
    
    [self loadTopImage];
}

- (void)loadTopImage {
    @weakify(self);
    [[KbSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (success) {
            NSString *topImage = [KbSystemConfigModel sharedModel].spreadTopImage;
            if (topImage.length == 0) {
                [self.view setNeedsLayout];
                return ;
            }
            
            [self->_topImageView sd_setImageWithURL:[NSURL URLWithString:topImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self.view setNeedsLayout];
            }];
            
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    const CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    const CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    _topImageView.frame = _topImageView.image ? CGRectMake(0, 0, viewWidth, viewWidth/4) : CGRectZero;
    _topImageView.hidden = _topImageView.image == nil;
    
    _webView.frame = CGRectMake(0, CGRectGetMaxY(_topImageView.frame),
                                viewWidth, viewHeight - CGRectGetHeight(_topImageView.frame));
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    if (self.retryTimes++ > kUIWebViewRetryTimes && !self.isStandBy) {
//        [webView stopLoading];
//        self.retryTimes = 0;
//        self.isStandBy = YES;
//        
//        DLog(@"UIWebView exceeds retry times and will try standby url...");
//        [webView loadRequest:self.standbyUrlRequest];
//    }
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    if (!self.isStandBy) {
//        self.retryTimes = 0;
//        self.isStandBy = YES;
//        
//        DLog(@"UIWebView exceeds retry times and will try standby url...");
//        [webView loadRequest:self.standbyUrlRequest];
//    }
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    return YES;
//}
@end
