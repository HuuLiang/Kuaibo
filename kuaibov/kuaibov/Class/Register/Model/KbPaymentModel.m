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

static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
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

+ (NSString *)signKey {
    return kSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":[KbUtil appId],
                                   @"key":kSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":[KbConfig sharedConfig].channelNo,
                                   @"pV":@(1) };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":[KbUtil appId]};
}

- (BOOL)paidWithOrderId:(NSString *)orderId
                  price:(NSString *)price
                 result:(NSInteger)result
              contentId:(NSString *)contentId
            contentType:(NSString *)contentType
           payPointType:(NSString *)payPointType
            paymentType:(KbPaymentType)paymentType
      completionHandler:(KbPaidCompletionHandler)handler {
    NSDictionary *statusDic = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(0), @(PAYRESULT_ABANDON):@(2)};
    
    if (nil == [KbUtil userId] || orderId.length == 0 || contentId == nil || contentType == nil) {
        return NO;
    }
    
    NSDictionary *params = @{@"uuid":[KbUtil userId],
                             @"orderNo":orderId.md5,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":@((NSUInteger)(price.doubleValue * 100)),
                             @"channelNo":[KbConfig sharedConfig].channelNo,
                             @"contentId":contentId,
                             @"contentType":contentType,
                             @"pluginType":@(paymentType),
                             @"payPointType":@(payPointType.integerValue),
                             @"appId":[KbUtil appId],
                             @"versionNo":@([KbUtil appVersion].integerValue),
                             @"status":statusDic[@(result)],
                             @"pV":@(1) };
    
    BOOL success = [super requestURLPath:[KbConfig sharedConfig].paymentURLPath withParams:params responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        if (handler) {
            handler(respStatus == KbURLResponseSuccess);
        }
    }];
    return success;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(KbURLResponseHandler)responseHandler {
    NSDictionary *decryptedResponse = [self decryptResponse:responseObject];
    DLog(@"Payment response : %@", decryptedResponse);
    NSNumber *respCode = decryptedResponse[@"response_code"];
    KbURLResponseStatus status = (respCode.unsignedIntegerValue == 100) ? KbURLResponseSuccess : KbURLResponseFailedByInterface;
    if (responseHandler) {
        responseHandler(status, nil);
    }
}
@end
