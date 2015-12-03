//
//  kbMoreViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbMoreViewController.h"

static const NSUInteger kUIWebViewRetryTimes = 30;

@interface kbMoreViewController () <UIWebViewDelegate,BaiduMobAdWallDelegate>
{
    UIView *_headerView;
    UIWebView *_webView;
}
@property (nonatomic) NSUInteger retryTimes;
@property (nonatomic) BOOL isStandBy;
@property (nonatomic,retain,readonly) NSURLRequest *urlRequest;
@property (nonatomic,retain,readonly) NSURLRequest *standbyUrlRequest;
@property (nonatomic,retain) BaiduMobAdWall *adWall;
@end

@implementation kbMoreViewController
@synthesize urlRequest = _urlRequest;
@synthesize standbyUrlRequest = _standbyUrlRequest;

DefineLazyPropertyInitialization(BaiduMobAdWall, adWall)

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
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_headerView];
    {
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.height.mas_equalTo(20);
        }];
    }
    
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_headerView.mas_bottom);
        }];
    }
    
    self.retryTimes = 0;
    self.isStandBy = NO;
    [_webView loadRequest:self.urlRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#ifdef EnableBaiduMobAd
    self.adWall.delegate = self;
    [self.adWall showOffers];
#endif
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

#pragma mark - BaiduMobAdWallDelegate

- (NSString *)publisherId {
    return [KbConfig sharedConfig].baiduAdAppId;
}

- (NSString *)adUnitTag {
    return [KbConfig sharedConfig].baiduWallAdId;
}
@end
