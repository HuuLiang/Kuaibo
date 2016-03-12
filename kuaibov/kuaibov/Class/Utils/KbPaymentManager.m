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

#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import <IapppayAlphaKit/IapppayAlphaKit.h>

static NSString *const kAlipaySchemeUrl = @"comyykuaiboappalipayschemeurl";
static NSString *const kIAppPayAppId = @"3004169606";
static NSString *const kIAppPayPrivateKey = @"MIICXQIBAAKBgQC/bZHYvOsvBKbrtGrvRQUC/IE1nkSdEbpkMw//O/LWApWCK3UthMS9BMwR93qbrflnkDK44yHtqdzMlPrTGtkPVGvEdn3npLXBIHvGjTNjmAjaCZYoDlhSnUiShuHLNnRgxLCj+bzYAItY74NSO5eTqNSwVXknq660qU1LtwRORwIDAQABAoGAbCQa82TuO5aWMauviVHlXeWFnOO3AUCFmptaGycjrRCyo2GnhbpuZhWyryeuhQoITiAg91+gyCFgkdZLyDxviAZYDexPqsmE6wd4SuC/GTibftyKFdqknwGAEa4oXBVnp+LRfFxq0Cx5LBKHEShznaZFlC9qhpLmbfgUi4WGOnkCQQDfz9/Y4Nq5yzDiekQNezTWqVJXccOBPEr6NwVV+NA5NyGlb3cC6+Ct9sIf5xFGV7uBTAHg9Xbjz9HhPd3Yj+v1AkEA2vVoaajsFC2HGvXbMUX0DWFxMgkMtbHtanjMpRwpKOZj16Tq9TQ26E6mnrA+/2GBB+65ajMmLJpSRrY59d6HywJANY7mL10nmlxwd1Hw5RT9wPzF8p0Lvupxuszd3wPquDZkO9WfsjhGDPtG2yGNdbra6QcKUA4NhFigDfmjFAbk3QJBAKvUoS8iILqpC/jtbinZ8u+5Q6L3lSDV1DKVQExmsCpnu3zU8Iqjgl+GsZ2hRJ8X/rGh96JPJ6sjJGRXx16bV0cCQQDY3Dlmt+6xPh4TRzu42g4+Pmh0fku0rCadYPwzSiKTpJ2MsucRNCXWi+wL0F1J/a7NKomTIScOYMEyeq9ZmqBu";
static NSString *const kIAppPayPublicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6UQ1g13TyzURwJqb8qNa/vSuHjcB1iZyqmswiFJjzG+S58BHewYN1K/EXOL9YY+aRVSG4/hZc7BVYnKiu6tSSN0RZiZsknMQI+bK0rYGB3ruoRIfSzwkzvl6eFqkDaCeROdapwgok3ovbwg6yums8YxI+xQ6kJinA86XlpfA+NQIDAQAB";

@interface KbPaymentManager () <IapppayAlphaKitPayRetDelegate>
@property (nonatomic,retain) KbPaymentInfo *paymentInfo;
@property (nonatomic,copy) KbPaymentCompletionHandler completionHandler;
@end

@implementation KbPaymentManager

+ (instancetype)sharedManager {
    static KbPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:kAlipaySchemeUrl];
    [[IapppayAlphaKit sharedInstance] setAppId:kIAppPayAppId mACID:KB_CHANNEL_NO];
}

- (void)handleOpenURL:(NSURL *)url {
    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
}

- (BOOL)startPaymentWithType:(KbPaymentType)type
                       price:(NSUInteger)price
                  forProgram:(KbProgram *)program
           completionHandler:(KbPaymentCompletionHandler)handler
{
    NSDictionary *paymentTypeMapping = @{@(KbPaymentTypeAlipay):@(IapppayAlphaKitAlipayPayType),
                                         @(KbPaymentTypeWeChatPay):@(IapppayAlphaKitWeChatPayType)};
    NSNumber *payType = paymentTypeMapping[@(type)];
    if (!payType) {
        return NO;
    }
    
    NSString *channelNo = KB_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    KbPaymentInfo *paymentInfo = [[KbPaymentInfo alloc] init];
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @((NSUInteger)(price * 100));
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.payPointType = program.payPointType;
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(KbPaymentStatusPaying);
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    
    IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
    order.appId = kIAppPayAppId;
    order.cpPrivateKey = kIAppPayPrivateKey;
    order.cpOrderId = orderNo;
    order.waresId = @"2";
    order.price = [NSString stringWithFormat:@"%.2f", price/100.];
    order.appUserId = [KbUtil userId] ?: @"UnregisterUser";
    order.cpPrivateInfo = KB_PAYMENT_RESERVE_DATA;
    
    NSString *trandData = [order getTrandData];
    BOOL success = [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData
                                                           payMethodType:payType.unsignedIntegerValue
                                                             payDelegate:self];
    return success;
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
@end
