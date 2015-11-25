//
//  kbBaseController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"
#import "KbVideo.h"
#import "KbPaymentPopView.h"
#import "AlipayManager.h"
#import "WeChatPayManager.h"
#import "KbSystemConfigModel.h"
#import "AppDelegate.h"
#import "Order.h"
#import "KbProgram.h"
#import "BaiduMobAdView.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

static const CGFloat kDefaultAdBannerHeight = 30;

@interface kbBaseController () <BaiduMobAdViewDelegate>
@property (nonatomic,retain) BaiduMobAdView *adView;

- (UIViewController *)playerVCWithVideo:(KbVideo *)video;
@end

@implementation kbBaseController

- (instancetype)init {
    self = [super init];
    if (self) {
        _adBannerHeight = kDefaultAdBannerHeight;
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
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchToPlayProgram:(KbProgram *)program {
    if (![KbUtil isPaid]) {
        [self payForProgram:program shouldPopView:YES withCompletionHandler:nil];
    } else if (program.type.unsignedIntegerValue == KbProgramTypeVideo) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:program];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        //videoPlayVC.evaluateThumbnail = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(KbProgram *)program
        shouldPopView:(BOOL)popped
withCompletionHandler:(void (^)(BOOL success))handler {
    [self fetchPayPriceWithCompletionHandler:^(NSNumber *payPrice) {
        if (!payPrice) {
            if (handler) {
                handler(NO);
            }
            return ;
        }
        
#ifdef DEBUG
        double price = 0.01;
#else
        double price = payPrice.doubleValue;
#endif
        if (popped) {
            KbPaymentPopView *paymentPopView = [KbPaymentPopView sharedInstance];
            paymentPopView.showPrice = price;
            
            @weakify(paymentPopView);
            paymentPopView.action = ^(KbPaymentType paymentType){
                [self payForProgram:program price:price paymentType:paymentType withCompletionHandler:^(NSUInteger result) {
                    @strongify(paymentPopView);
                    if (result == PAYRESULT_SUCCESS) {
                        [paymentPopView hide];
                        [[KbHudManager manager] showHudWithText:@"支付成功"];
                    }
                    if (handler) {
                        handler(result == PAYRESULT_SUCCESS);
                    }
                }];
            };
            [paymentPopView showInView:self.view.window];
        } else {
            [self payForProgram:program price:price paymentType:KbPaymentTypeAlipay withCompletionHandler:^(NSUInteger result) {
                if (handler) {
                    handler(result == PAYRESULT_SUCCESS);
                }
            }];
        }
    }];
}

- (void)onPaidNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *orderNo = userInfo[kPaidNotificationOrderNoKey];
    NSString *price = userInfo[kPaidNotificationPriceKey];
    
    [KbUtil setPaidPendingWithOrder:@[orderNo,price,@"",@"",@""]];
    [[KbPaymentPopView sharedInstance] hide];
    
    [self onPaymentCallbackWithOrderId:orderNo
                                 price:price
                                result:PAYRESULT_SUCCESS
                          forProgramId:@""
                           programType:@""
                          payPointType:@""];
    
}

- (void)fetchPayPriceWithCompletionHandler:(void (^)(NSNumber *payPrice))handler {
    KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (handler) {
            handler (success ? @(systemConfigModel.payAmount) : nil);
        }
    }];
}

- (void)payForProgram:(KbProgram *)program
                price:(double)price
          paymentType:(KbPaymentType)paymentType
withCompletionHandler:(void (^)(NSUInteger result))handler {
    @weakify(self);
    NSString *channelNo = [KbConfig sharedConfig].channelNo;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    [KbUtil setPayingOrderNo:orderNo];
    
    void (^PayResultBack)(PAYRESULT result) = ^(PAYRESULT result) {
        @strongify(self);
        
        if (result == PAYRESULT_SUCCESS) {
            [KbUtil setPaidPendingWithOrder:@[orderNo,
                                              @(price).stringValue,
                                              program.programId.stringValue ?: @"",
                                              program.type.stringValue ?: @"",
                                              program.payPointType.stringValue ?: @""]];
            
        } else if (result == PAYRESULT_FAIL) {
            [[KbHudManager manager] showHudWithText:@"支付失败"];
        } else if (result == PAYRESULT_ABANDON) {
            [[KbHudManager manager] showHudWithText:@"支付取消"];
        }
        
        if (handler) {
            handler(result);
        }
        
        [self onPaymentCallbackWithOrderId:orderNo
                                     price:@(price).stringValue
                                    result:result
                              forProgramId:program.programId.stringValue ?: @""
                               programType:program.type.stringValue ?: @""
                              payPointType:program.payPointType.stringValue ?: @""];
    };
    
    if (paymentType == KbPaymentTypeAlipay) {
        [[AlipayManager shareInstance] startAlipay:orderNo
                                             price:@(price).stringValue
                                        withResult:^(PAYRESULT result, Order *order) {
                                            PayResultBack(result);
                                        }];
    } else if (paymentType == KbPaymentTypeWeChatPay) {
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo
                                                               price:price
                                                   completionHandler:^(PAYRESULT payResult) {
                                                       PayResultBack(payResult);
                                                   }];
    }

}

- (void)onPaymentCallbackWithOrderId:(NSString *)orderId
                               price:(NSString *)price
                              result:(PAYRESULT)result
                        forProgramId:(NSString *)programId
                         programType:(NSString *)programType
                        payPointType:(NSString *)payPointType {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate paidWithOrderId:orderId
                           price:price
                          result:result
                    forProgramId:programId
                     programType:programType
                    payPointType:payPointType];
}

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

#pragma mark - BaiduMobAdViewDelegate

- (NSString *)publisherId {
    return [KbConfig sharedConfig].baiduAdAppId;
}
@end
