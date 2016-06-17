//
//  KbPaymentManager.m
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbPaymentManager.h"
#import "KbPaymentInfo.h"
#import "KbPaymentViewController.h"
#import "KbProgram.h"
#import "KbPaymentConfigModel.h"

#import "WXApi.h"
#import "WeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import <IapppayAlphaKit/IapppayAlphaKit.h>

static NSString *const kAlipaySchemeUrl = @"comyykuaiboappalipayschemeurl";

@interface KbPaymentManager () <IapppayAlphaKitPayRetDelegate,WXApiDelegate>
@property (nonatomic,retain) KbPaymentInfo *paymentInfo;
@property (nonatomic,copy) KbPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) WeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@property (nonatomic,retain) KbChannels *payChannel;

@end

@implementation KbPaymentManager

DefineLazyPropertyInitialization(WeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

+ (instancetype)sharedManager {
    static KbPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    [[KbPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:kAlipaySchemeUrl];
        [[IapppayAlphaKit sharedInstance] setAppId:[KbPaymentConfig sharedConfig].iappPayInfo.appid mACID:KB_CHANNEL_NO];
        [WXApi registerApp:[KbPaymentConfig sharedConfig].weixinInfo.appId];
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
    //    [WXApi handleOpenURL:url delegate:self];
}

- (KbPaymentInfo *)startPaymentWithType:(KbPaymentType)type
                                subType:(KbPaymentType)subType
                                  price:(NSUInteger)price
                             forProgram:(KbProgram *)program
                        programLocation:(NSUInteger)programLocation
                              inChannel:(KbChannels *)channel
                      completionHandler:(KbPaymentCompletionHandler)handler
{
    if (type == KbPaymentTypeNone || (type == KbPaymentTypeIAppPay && subType == KbPaymentTypeNone)) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, nil);
        }
        return nil;
    }
    price = 1;
    NSString *channelNo = KB_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    KbPaymentInfo *paymentInfo = [[KbPaymentInfo alloc] init];
    paymentInfo.contentLocation = @(programLocation+1);
    paymentInfo.columnId = channel.realColumnId;
    paymentInfo.columnType = channel.type;
    
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.payPointType = program.payPointType;
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(KbPaymentStatusPaying);
    paymentInfo.reservedData = KB_PAYMENT_RESERVE_DATA;
    if (type == KbPaymentTypeWeChatPay) {
        paymentInfo.appId = [KbPaymentConfig sharedConfig].weixinInfo.appId;
        paymentInfo.mchId = [KbPaymentConfig sharedConfig].weixinInfo.mchId;
        paymentInfo.signKey = [KbPaymentConfig sharedConfig].weixinInfo.signKey;
        paymentInfo.notifyUrl = [KbPaymentConfig sharedConfig].weixinInfo.notifyUrl;
    }
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    self.payChannel = channel;
    
    BOOL success = YES;
    if (type == KbPaymentTypeWeChatPay) {
        @weakify(self);
        [[WeChatPayManager sharedInstance] startWithPayment:paymentInfo completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else if (type == KbPaymentTypeIAppPay) {
        NSDictionary *paymentTypeMapping = @{@(KbPaymentTypeAlipay):@(IapppayAlphaKitAlipayPayType),
                                             @(KbPaymentTypeWeChatPay):@(IapppayAlphaKitWeChatPayType)};
        NSNumber *payType = paymentTypeMapping[@(subType)];
        if (!payType) {
            return nil;
        }
        
        
        IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
        order.appId = [KbPaymentConfig sharedConfig].iappPayInfo.appid;
        order.cpPrivateKey = [KbPaymentConfig sharedConfig].iappPayInfo.privateKey;
        order.cpOrderId = orderNo;
#ifdef DEBUG
        order.waresId = @"2";
#else
        order.waresId = [KbPaymentConfig sharedConfig].iappPayInfo.waresid;
#endif
        order.price = [NSString stringWithFormat:@"%.2f", price/100.];
        order.appUserId = [KbUtil userId] ?: @"UnregisterUser";
        order.cpPrivateInfo = KB_PAYMENT_RESERVE_DATA;
        
        NSString *trandData = [order getTrandData];
        success = [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData
                                                          payMethodType:payType.unsignedIntegerValue
                                                            payDelegate:self];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    
    
    return success ? paymentInfo : nil;
}

- (void)checkPayment {
    NSArray<KbPaymentInfo *> *payingPaymentInfos = [KbUtil payingPaymentInfos];
    [payingPaymentInfos enumerateObjectsUsingBlock:^(KbPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KbPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
        if (paymentType == KbPaymentTypeWeChatPay) {
            if (obj.appId.length == 0 || obj.mchId.length == 0 || obj.signKey.length == 0 || obj.notifyUrl.length == 0) {
                obj.appId = [KbPaymentConfig sharedConfig].weixinInfo.appId;
                obj.mchId = [KbPaymentConfig sharedConfig].weixinInfo.mchId;
                obj.signKey = [KbPaymentConfig sharedConfig].weixinInfo.signKey;
                obj.notifyUrl = [KbPaymentConfig sharedConfig].weixinInfo.notifyUrl;
            }
            
            [self.wechatPayOrderQueryRequest queryPayment:obj withCompletionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    KbPaymentViewController *paymentVC = [KbPaymentViewController sharedPaymentVC];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }
            }];
        }
    }];
}

#pragma mark - IapppayAlphaKitPayRetDelegate

- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
    if (!paymentResult) {
        paymentResult = @(PAYRESULT_UNKNOWN);
    }
    
    if (self.completionHandler) {
        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
    }
}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}
@end
