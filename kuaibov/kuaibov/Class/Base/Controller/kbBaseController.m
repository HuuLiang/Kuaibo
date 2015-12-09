//
//  kbBaseController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"
#import "KbVideo.h"
#import "AppDelegate.h"
#import "KbProgram.h"
#import "MobClick.h"
#import "KbPaymentViewController.h"

#ifdef EnableBaiduMobAd
#import "BaiduMobAdView.h"
#endif

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

#ifdef EnableBaiduMobAd
static const CGFloat kDefaultAdBannerHeight = 30;
#endif

@interface kbBaseController ()
#ifdef EnableBaiduMobAd
<BaiduMobAdViewDelegate>

@property (nonatomic,retain) BaiduMobAdView *adView;
#endif
- (UIViewController *)playerVCWithVideo:(KbVideo *)video;
@end

@implementation kbBaseController

- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef EnableBaiduMobAd
        _adBannerHeight = kDefaultAdBannerHeight;
#endif
    }
    return self;
}

- (instancetype)initWithBottomAdBanner:(BOOL)hasBanner {
    self = [self init];
    if (self) {
        _bottomAdBanner = hasBanner;
    }
    return self;
}

#ifdef EnableBaiduMobAd
- (BaiduMobAdView *)adView {
    if (_adView) {
        return _adView;
    }
    
    _adView = [[BaiduMobAdView alloc] init];
    _adView.frame = CGRectMake(0, self.view.bounds.size.height-self.adBannerHeight, self.view.bounds.size.width, self.adBannerHeight);
    _adView.AdUnitTag = [KbConfig sharedConfig].baiduBannerAdId;
    _adView.AdType = BaiduMobAdViewTypeBanner;
    _adView.delegate = self;
    [_adView start];
    return _adView;
}
#endif

- (UIViewController *)playerVCWithVideo:(KbVideo *)video {
    UIViewController *retVC;
    if (NSClassFromString(@"AVPlayerViewController")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo){
                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
                               [thisPlayerVC.player play];
                           } error:nil];
        
        retVC = playerVC;
    } else {
        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
    }
    
    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
        [[aspectInfo originalInvocation] setReturnValue:&mask];
    } error:nil];
    
    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        BOOL rotate = YES;
        [[aspectInfo originalInvocation] setReturnValue:&rotate];
    } error:nil];
    return retVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HexColor(#f7f7f7);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
#ifdef EnableBaiduMobAd
    if (_bottomAdBanner) {
        CGRect newFrame = CGRectMake(0, self.view.bounds.size.height-self.adBannerHeight, self.view.bounds.size.width, self.adBannerHeight);
        if (!CGRectEqualToRect(newFrame, self.adView.frame)) {
            if ([self.view.subviews containsObject:self.adView]) {
                [self.adView removeFromSuperview];
                self.adView = nil;
            }
        }
        
        if (![self.view.subviews containsObject:self.adView]) {
            [self.view addSubview:self.adView];
        }
    }
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchToPlayProgram:(KbProgram *)program {
    if (![KbUtil isPaid]) {
        [self payForProgram:program];
    } else if (program.type.unsignedIntegerValue == KbProgramTypeVideo) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:program];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        //videoPlayVC.evaluateThumbnail = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(KbProgram *)program {
    [[KbPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:program];
}

- (void)onPaidNotification:(NSNotification *)notification {}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef EnableBaiduMobAd
#pragma mark - BaiduMobAdViewDelegate

- (NSString *)publisherId {
    return [KbConfig sharedConfig].baiduAdAppId;
}
#endif
@end
