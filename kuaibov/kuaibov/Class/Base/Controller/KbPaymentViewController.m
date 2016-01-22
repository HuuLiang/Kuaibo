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
#import "WeChatPayManager.h"
#import "KbPaymentInfo.h"
#import "KbWeChatPayConfigModel.h"
#import "KbAlipayConfigModel.h"

@interface KbPaymentViewController ()
@property (nonatomic,retain) KbPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,retain) KbProgram *programToPayFor;
@property (nonatomic,retain) KbPaymentInfo *paymentInfo;

@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
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
    void (^Pay)(KbPaymentType type) = ^(KbPaymentType type) {
        @strongify(self);
        if (!self.payAmount) {
            [[KbHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self payForProgram:self.programToPayFor
                      price:self.payAmount.doubleValue
                paymentType:type];
    };
    
    _popView = [[KbPaymentPopView alloc] init];
    _popView.headerImageURL = [NSURL URLWithString:[KbSystemConfigModel sharedModel].paymentImage];
    _popView.footerImage = [UIImage imageNamed:@"payment_footer"];
    [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
        Pay(KbPaymentTypeAlipay);
    }];
    
    [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
        Pay(KbPaymentTypeWeChatPay);
    }];
    
    _popView.closeAction = ^(id sender){
        @strongify(self);
        [self hidePayment];
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

- (void)popupPaymentInView:(UIView *)view forProgram:(KbProgram *)program {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
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
    }];
}

- (void)payForProgram:(KbProgram *)program
                price:(double)price
          paymentType:(KbPaymentType)paymentType {
    @weakify(self);
    NSString *channelNo = KB_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    void (^SetPayment)(void) = ^{
        @strongify(self);
        KbPaymentInfo *paymentInfo = [[KbPaymentInfo alloc] init];
        paymentInfo.orderId = orderNo;
        paymentInfo.orderPrice = @((NSUInteger)(price * 100));
        paymentInfo.contentId = program.programId;
        paymentInfo.contentType = program.type;
        paymentInfo.payPointType = program.payPointType;
        paymentInfo.paymentType = @(paymentType);
        paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
        paymentInfo.paymentStatus = @(KbPaymentStatusPaying);
        [paymentInfo save];
        self.paymentInfo = paymentInfo;
    };
    
    if (paymentType==KbPaymentTypeWeChatPay) {
        // Payment info
        void (^PayBlock)(void) = ^{
            @strongify(self);
            KbWeChatPayConfig *config = [KbWeChatPayConfig defaultConfig];
            if (!config.isValid) {
                [[KbHudManager manager] showHudWithText:@"无法获取微信支付信息"];
                return ;
            }
            
            SetPayment();
            [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo price:price completionHandler:^(PAYRESULT payResult) {
                [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
            }];
        };
        
        KbWeChatPayConfig *config = [KbWeChatPayConfig defaultConfig];
        if (config.isValid) {
            PayBlock();
        } else {
            [[KbWeChatPayConfigModel sharedModel] fetchWeChatPayConfigWithCompletionHandler:^(BOOL success, id obj) {
                PayBlock();
            }];
        }
    } else {
        [[KbHudManager manager] showHudWithText:@"无法获取支付信息"];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//        
//        IPNPreSignMessageUtil *preSign =[[IPNPreSignMessageUtil alloc] init];
//        preSign.consumerId = KB_CHANNEL_NO;
//        preSign.mhtOrderNo = orderNo;
//        preSign.mhtOrderName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?: @"家庭影院";
//        preSign.mhtOrderType = kPayNowNormalOrderType;
//        preSign.mhtCurrencyType = kPayNowRMBCurrencyType;
//        preSign.mhtOrderAmt = [NSString stringWithFormat:@"%ld", @(price*100).unsignedIntegerValue];
//        preSign.mhtOrderDetail = [preSign.mhtOrderName stringByAppendingString:@"终身会员"];
//        preSign.mhtOrderStartTime = [dateFormatter stringFromDate:[NSDate date]];
//        preSign.mhtCharset = kPayNowDefaultCharset;
//        preSign.payChannelType = ((NSNumber *)self.paymentTypeMap[@(paymentType)]).stringValue;
//        preSign.mhtReserved = KB_PAYMENT_RESERVE_DATA;
//        
//        [[KbPaymentSignModel sharedModel] signWithPreSignMessage:preSign completionHandler:^(BOOL success, NSString *signedData) {
//            @strongify(self);
//            if (success && [KbPaymentSignModel sharedModel].appId.length > 0) {
//                [IpaynowPluginApi pay:signedData AndScheme:KB_PAYNOW_SCHEME viewController:self delegate:self];
//            } else {
//                [[KbHudManager manager] showHudWithText:@"无法获取支付信息"];
//            }
//        }];
    }
}

//- (NSDictionary *)paymentTypeMap {
//    if (_paymentTypeMap) {
//        return _paymentTypeMap;
//    }
//    
//    _paymentTypeMap = @{@(KbPaymentTypeAlipay):@(PayNowChannelTypeAlipay),
//                          @(KbPaymentTypeWeChatPay):@(PayNowChannelTypeWeChatPay),
//                          @(KbPaymentTypeUPPay):@(PayNowChannelTypeUPPay)};
//    return _paymentTypeMap;
//}

//- (KbPaymentType)paymentTypeFromPayNowType:(PayNowChannelType)type {
//    __block KbPaymentType retType = KbPaymentTypeNone;
//    [self.paymentTypeMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        if ([(NSNumber *)obj isEqualToNumber:@(type)]) {
//            retType = ((NSNumber *)key).unsignedIntegerValue;
//            *stop = YES;
//            return ;
//        }
//    }];
//    return retType;
//}
//
//- (PayNowChannelType)payNowTypeFromPaymentType:(KbPaymentType)type {
//    return ((NSNumber *)self.paymentTypeMap[@(type)]).unsignedIntegerValue;
//}
//
//- (PAYRESULT)paymentResultFromPayNowResult:(IPNPayResult)result {
//    NSDictionary *resultMap = @{@(IPNPayResultSuccess):@(PAYRESULT_SUCCESS),
//                                @(IPNPayResultFail):@(PAYRESULT_FAIL),
//                                @(IPNPayResultCancel):@(PAYRESULT_ABANDON),
//                                @(IPNPayResultUnknown):@(PAYRESULT_UNKNOWN)};
//    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
//}
//
//-(IPNPayResult)paymentResultFromPayresult:(PAYRESULT)result{
//    NSDictionary *resultMap = @{@(PAYRESULT_SUCCESS):@(IPNPayResultSuccess),
//                                @(PAYRESULT_FAIL):@(IPNPayResultFail),
//                                @(PAYRESULT_ABANDON):@(IPNPayResultCancel),
//                                @(PAYRESULT_UNKNOWN):@(IPNPayResultUnknown)};
//    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(KbPaymentInfo *)paymentInfo {
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
}

//- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
//    DLog(@"PayNow Result:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
//    PAYRESULT payResult = [self paymentResultFromPayNowResult:result];
//    [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
//}

@end
