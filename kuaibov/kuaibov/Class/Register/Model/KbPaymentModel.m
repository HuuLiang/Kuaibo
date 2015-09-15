//
//  KbPaymentModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbPaymentModel.h"
#import "NSDictionary+KbSign.h"
#import "AlipayManager.h"

static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@implementation KbPaymentModel

+ (instancetype)sharedModel {
    static KbPaymentModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[KbPaymentModel alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (KbURLRequestMethod)requestMethod {
    return KbURLPostRequest;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":[KbUtil appId],
                                   @"key":@"qdge^%$#@(sdwHs^&",
                                   @"imsi":@"999999999999999",
                                   @"channelNo":[KbConfig sharedConfig].channelNo,
                                   @"pV":[KbUtil appVersion] };
    
    NSString *encryptedDataString = [params encryptedStringWithSignDictionary:signParams
                                                                    keyOrders:@[@"appId",@"key",@"imsi",@"channelNo",@"pV"]
                                                                     password:kPaymentEncryptionPassword
                                                                  excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":[KbUtil appId]};
}

- (BOOL)paidWithOrderId:(NSString *)orderId
                  price:(NSString *)price
                 result:(NSInteger)result
              contentId:(NSString *)contentId
            contentType:(NSString *)contentType
           payPointType:(NSString *)payPointType
      completionHandler:(KbPaidCompletionHandler)handler {
    NSDictionary *statusDic = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(0), @(PAYRESULT_ABANDON):@(2)};
    
    NSDictionary *params = @{@"uuid":[KbUtil userId],
                             @"orderNo":orderId.md5,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":@(price.floatValue * 100),
                             @"channelNo":[KbConfig sharedConfig].channelNo,
                             @"contentId":contentId,
                             @"contentType":contentType,
                             @"pluginType":@(1001),
                             @"payPointType":@(payPointType.integerValue),
                             @"appId":[KbUtil appId],
                             @"versionNo":@([KbUtil appVersion].floatValue),
                             @"status":statusDic[@(result)],
                             @"pV":@(1) };
    
    BOOL success = [super requestURLPath:[KbConfig sharedConfig].paymentURLPath withParams:params responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        if (handler) {
            handler(respStatus == KbURLResponseSuccess);
        }
    }];
    return success;
}
@end
