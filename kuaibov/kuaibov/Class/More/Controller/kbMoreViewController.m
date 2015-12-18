//
//  kbMoreViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbMoreViewController.h"
#import "KbSystemConfigModel.h"

static const NSUInteger kUIWebViewRetryTimes = 30;

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

@implementation kbMoreViewController
@synthesize urlRequest = _urlRequest;
@synthesize standbyUrlRequest = _standbyUrlRequest;

- (NSURLRequest *)urlRequest {
    if (_urlRequest) {
        return _urlRequest;
    }
    
    NSString *urlString = [[KbConfig sharedConfig].baseURL stringByAppendingString:[KbConfig sharedConfig].moreURLPath];
    _urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    return _urlRequest;
}

- (NSURLRequest *)standbyUrlRequest {
    if (_standbyUrlRequest) {
        return _standbyUrlRequest;
    }
    
    NSString *urlString = [[KbConfig sharedStandbyConfig].baseURL stringByAppendingString:[KbConfig sharedStandbyConfig].moreURLPath];
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
        [[KbHudManager manager] showHudWithText:[NSString stringWithFormat:@"Server:%@\nChannelNo:%@\nPackageCertificate:%@", [KbConfig sharedConfig].baseURL, [KbConfig sharedConfig].channelNo, [KbConfig sharedConfig].packageSigningCertificate]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.retryTimes = 0;
    self.isStandBy = NO;
    [_webView loadRequest:self.urlRequest];
    
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

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.retryTimes++ > kUIWebViewRetryTimes && !self.isStandBy) {
        [webView stopLoading];
        self.retryTimes = 0;
        self.isStandBy = YES;
        
        DLog(@"UIWebView exceeds retry times and will try standby url...");
        [webView loadRequest:self.standbyUrlRequest];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!self.isStandBy) {
        self.retryTimes = 0;
        self.isStandBy = YES;
        
        DLog(@"UIWebView exceeds retry times and will try standby url...");
        [webView loadRequest:self.standbyUrlRequest];
    }
}
@end
