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
#import "IPNPreSignMessageUtil.h"
#import "KbPaymentModel.h"
#import <objc/runtime.h>
#import "KbProgram.h"
#import "WeChatPayManager.h"
#import "KbPaymentInfo.h"
#import "IpaynowPluginApi.h"
#import "KbPaymentSignModel.h"

@interface KbPaymentViewController () <IpaynowPluginDelegate>
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
    _popView = [[KbPaymentPopView alloc] init];
    _popView.paymentAction = ^(KbPaymentType type) {
        @strongify(self);
        if (!self.payAmount) {
            [[KbHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self payForProgram:self.programToPayFor
                      price:self.payAmount.doubleValue
                paymentType:type];
    };
    _popView.backAction = ^{
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
            make.size.mas_equalTo(self.popView.contentSize);
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
            self.payAmount = @(systemConfigModel.payAmount);
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
    NSString *channelNo = [KbConfig sharedConfig].channelNo;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    // Payment info
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
    
    if (paymentType==KbPaymentTypeWeChatPay) {
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo price:price completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
        }];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        
        IPNPreSignMessageUtil *preSign =[[IPNPreSignMessageUtil alloc] init];
        preSign.consumerId = [KbConfig sharedConfig].channelNo;
        preSign.mhtOrderNo = orderNo;
        preSign.mhtOrderName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?: @"家庭影院";
        preSign.mhtOrderType = kPayNowNormalOrderType;
        preSign.mhtCurrencyType = kPayNowRMBCurrencyType;
        preSign.mhtOrderAmt = [NSString stringWithFormat:@"%ld", @(price*100).unsignedIntegerValue];
        preSign.mhtOrderDetail = [preSign.mhtOrderName stringByAppendingString:@"终身会员"];
        preSign.mhtOrderStartTime = [dateFormatter stringFromDate:[NSDate date]];
        preSign.mhtCharset = kPayNowDefaultCharset;
        preSign.payChannelType = ((NSNumber *)self.paymentTypeMap[@(paymentType)]).stringValue;
        
        [[KbPaymentSignModel sharedModel] signWithPreSignMessage:preSign completionHandler:^(BOOL success, NSString *signedData) {
            @strongify(self);
            if (success) {
                [IpaynowPluginApi pay:signedData AndScheme:[KbConfig sharedConfig].payNowScheme viewController:self delegate:self];
            } else {
                [[KbHudManager manager] showHudWithText:@"服务器获取签名失败！"];
            }
        }];
    }
}

- (NSDictionary *)paymentTypeMap {
    if (_paymentTypeMap) {
        return _paymentTypeMap;
    }
    
    _paymentTypeMap = @{@(KbPaymentTypeAlipay):@(PayNowChannelTypeAlipay),
                          @(KbPaymentTypeWeChatPay):@(PayNowChannelTypeWeChatPay),
                          @(KbPaymentTypeUPPay):@(PayNowChannelTypeUPPay)};
    return _paymentTypeMap;
}

- (KbPaymentType)paymentTypeFromPayNowType:(PayNowChannelType)type {
    __block KbPaymentType retType = KbPaymentTypeNone;
    [self.paymentTypeMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([(NSNumber *)obj isEqualToNumber:@(type)]) {
            retType = ((NSNumber *)key).unsignedIntegerValue;
            *stop = YES;
            return ;
        }
    }];
    return retType;
}

- (PayNowChannelType)payNowTypeFromPaymentType:(KbPaymentType)type {
    return ((NSNumber *)self.paymentTypeMap[@(type)]).unsignedIntegerValue;
}

- (PAYRESULT)paymentResultFromPayNowResult:(IPNPayResult)result {
    NSDictionary *resultMap = @{@(IPNPayResultSuccess):@(PAYRESULT_SUCCESS),
                                @(IPNPayResultFail):@(PAYRESULT_FAIL),
                                @(IPNPayResultCancel):@(PAYRESULT_ABANDON),
                                @(IPNPayResultUnknown):@(PAYRESULT_UNKNOWN)};
    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
}

-(IPNPayResult)paymentResultFromPayresult:(PAYRESULT)result{
    NSDictionary *resultMap = @{@(PAYRESULT_SUCCESS):@(IPNPayResultSuccess),
                                @(PAYRESULT_FAIL):@(IPNPayResultFail),
                                @(PAYRESULT_ABANDON):@(IPNPayResultCancel),
                                @(PAYRESULT_UNKNOWN):@(IPNPayResultUnknown)};
    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(KbPaymentInfo *)paymentInfo {
    if (result == PAYRESULT_SUCCESS) {
        [self hidePayment];
        [[KbHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName object:nil];
    } else if (result == PAYRESULT_ABANDON) {
        [[KbHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[KbHudManager manager] showHudWithText:@"支付失败"];
    }
    
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(KbPaymentStatusNotProcessed);
    [paymentInfo save];
    [[KbPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
}

- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
    DLog(@"PayNow Result:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
    PAYRESULT payResult = [self paymentResultFromPayNowResult:result];
    [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
}

@end
