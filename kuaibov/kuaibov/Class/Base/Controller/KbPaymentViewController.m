//
//  KbPaymentViewController.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbPaymentViewController.h"
#import "KbPaymentPopView.h"
#import "KbSystemConfigModel.h"
#import "KbPaymentModel.h"
#import <objc/runtime.h>
#import "KbProgram.h"
#import "KbPaymentInfo.h"
#import "KbPaymentConfig.h"

@interface KbPaymentViewController ()
@property (nonatomic,retain) KbPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,retain) KbProgram *programToPayFor;
@property (nonatomic,retain) KbPaymentInfo *paymentInfo;
@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;

@property (nonatomic) NSUInteger programLocationToPayFor;
@property (nonatomic,retain) KbChannels *channelToPayFor;

@end

@implementation KbPaymentViewController
@synthesize paymentTypeMap = _paymentTypeMap;

+ (instancetype)sharedPaymentVC {
    static KbPaymentViewController *_sharedPaymentVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentVC = [[KbPaymentViewController alloc] init];
    });
    return _sharedPaymentVC;
}

- (KbPaymentPopView *)popView {
    if (_popView) {
        return _popView;
    }
    
    @weakify(self);
    void (^Pay)(KbPaymentType type, KbPaymentType subType) = ^(KbPaymentType type, KbPaymentType subType)
    {
        @strongify(self);
        if (!self.payAmount) {
            [[KbHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self payForProgram:self.programToPayFor
                      price:self.payAmount.doubleValue
                paymentType:type
             paymentSubType:subType];
        
        [self hidePayment];
    };
    
    _popView = [[KbPaymentPopView alloc] init];
    _popView.headerImageURL = [NSURL URLWithString:[KbSystemConfigModel sharedModel].paymentImage];
    _popView.footerImage = [UIImage imageNamed:@"payment_footer"];
    
    
    //微信支付 首游时空
    [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
        Pay(KbPaymentTypeVIAPay, KbPaymentTypeWeChatPay);
    }];
    //支付宝支付  首游时空
    [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
        Pay(KbPaymentTypeVIAPay, KbPaymentTypeAlipay);
    }];
//    if (([KbPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & KbIAppPayTypeWeChat)
//        || [KbPaymentConfig sharedConfig].weixinInfo) {
//        BOOL useBuildInWeChatPay = [KbPaymentConfig sharedConfig].weixinInfo != nil;
//        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
//            Pay(useBuildInWeChatPay?KbPaymentTypeWeChatPay:KbPaymentTypeIAppPay, useBuildInWeChatPay?KbPaymentTypeNone:KbPaymentTypeWeChatPay);
//        }];
//    }
//    
//    if (([KbPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & KbIAppPayTypeAlipay)
//        || [KbPaymentConfig sharedConfig].alipayInfo) {
//        BOOL useBuildInAlipay = [KbPaymentConfig sharedConfig].alipayInfo != nil;
//        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
//            Pay(useBuildInAlipay?KbPaymentTypeAlipay:KbPaymentTypeIAppPay, useBuildInAlipay?KbPaymentTypeNone:KbPaymentTypeAlipay);
//        }];
//    }
    
    //    [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
    //        Pay(KbPaymentTypeWeChatPay);
    //    }];
    //    
    //    if ([KbPaymentConfig sharedConfig].iappPayInfo) {
    //        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
    //            Pay(KbPaymentTypeAlipay);
    //        }];
    //    }
    
    _popView.closeAction = ^(id sender){
        @strongify(self);
        [self hidePayment];
        
        [[KbStatsManager sharedManager] statsPayWithOrderNo:nil
                                                  payAction:KbStatsPayActionClose
                                                  payResult:PAYRESULT_UNKNOWN
                                                 forProgram:self.programToPayFor
                                            programLocation:self.programLocationToPayFor
                                                  inChannel:self.channelToPayFor
                                                andTabIndex:[KbUtil currentTabPageIndex]
                                                subTabIndex:[KbUtil currentSubTabPageIndex]];
        
    };
    return _popView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.popView];
    {
        [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            
            const CGFloat width = mainWidth * 0.95;
            make.size.mas_equalTo(CGSizeMake(width, [self.popView viewHeightRelativeToWidth:width]));
        }];
    }
}

- (void)popupPaymentInView:(UIView *)view forProgram:(KbProgram *)program programLocation:(NSUInteger)programLocation inChannel:(KbChannels *)channel{
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.programLocationToPayFor = programLocation;
    self.channelToPayFor = channel;
    self.payAmount = nil;
    self.programToPayFor = program;
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    
    if (view == [UIApplication sharedApplication].keyWindow) {
        [view insertSubview:self.view belowSubview:[KbHudManager manager].hudView];
    } else {
        [view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
    }];
    
    [self fetchPayAmount];
}

- (void)fetchPayAmount {
    @weakify(self);
    KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (success) {
#ifdef DEBUG
            self.payAmount = @(0.01);
#else
            self.payAmount = @(systemConfigModel.payAmount);
#endif
        }
    }];
}

- (void)setPayAmount:(NSNumber *)payAmount {
    //#ifdef DEBUG
    //    payAmount = @(0.1);
    //#endif
    _payAmount = payAmount;
    self.popView.showPrice = payAmount;
}

- (void)hidePayment {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        self.programToPayFor = nil;
        self.programLocationToPayFor = 0;
        self.channelToPayFor = nil;
    }];
}

- (void)payForProgram:(KbProgram *)program
                price:(double)price
          paymentType:(KbPaymentType)paymentType
       paymentSubType:(KbPaymentType)paymentSubType
{
    @weakify(self);
    KbPaymentInfo *paymentInfo = [[KbPaymentManager sharedManager] startPaymentWithType:paymentType
                                                                                subType:paymentSubType
                                                                                  price:price*100
                                                                             forProgram:program
                                                                        programLocation:self.programLocationToPayFor
                                                                              inChannel:self.channelToPayFor
                                                                      completionHandler:^(PAYRESULT payResult, KbPaymentInfo *paymentInfo)
                                  {
                                      @strongify(self);
                                      [self notifyPaymentResult:payResult withPaymentInfo:paymentInfo];
                                  }];
    
    if (paymentInfo) {
        [[KbStatsManager sharedManager] statsPayWithPaymentInfo:paymentInfo
                                                   forPayAction:KbStatsPayActionGoToPay
                                                    andTabIndex:[KbUtil currentTabPageIndex]
                                                    subTabIndex:[KbUtil currentSubTabPageIndex]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(KbPaymentInfo *)paymentInfo {
    if (result == PAYRESULT_SUCCESS && [KbUtil successfulPaymentInfo]) {
        return ;
    }
    
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(KbPaymentStatusNotProcessed);
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    if (result == PAYRESULT_SUCCESS) {
        [self hidePayment];
        [[KbHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName object:nil];
    } else if (result == PAYRESULT_ABANDON) {
        [[KbHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[KbHudManager manager] showHudWithText:@"支付失败"];
    }
    
    [[KbPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
    
    [[KbStatsManager sharedManager] statsPayWithPaymentInfo:paymentInfo
                                               forPayAction:KbStatsPayActionPayBack
                                                andTabIndex:[KbUtil currentTabPageIndex]
                                                subTabIndex:[KbUtil currentSubTabPageIndex]];
    
}

@end
