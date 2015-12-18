//
//  KbPaymentModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbPaymentModel.h"
#import "NSDictionary+KbSign.h"
#import "KbPaymentInfo.h"

static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

typedef void (^KbPaymentCompletionHandler)(BOOL success);

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
                                   @"pV":[KbUtil pV] };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":[KbUtil appId]};
}

- (void)commitUnprocessedOrders {
    NSArray<KbPaymentInfo *> *unprocessedPaymentInfos = [KbUtil paidNotProcessedPaymentInfos];
    [unprocessedPaymentInfos enumerateObjectsUsingBlock:^(KbPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self commitPaymentInfo:obj];
    }];
}

- (BOOL)commitPaymentInfo:(KbPaymentInfo *)paymentInfo {
    @weakify(self);
    return [self commitPaymentInfo:paymentInfo withCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (!success) {
            [self retryToCommitPaymentInfo:paymentInfo withTryTimes:3];
        }
    }];
}

- (void)retryToCommitPaymentInfo:(KbPaymentInfo *)paymentInfo withTryTimes:(NSUInteger)times {
    [self retryToCommitPaymentInfo:paymentInfo withTryTimes:times currentTryTime:0];
}

- (void)retryToCommitPaymentInfo:(KbPaymentInfo *)paymentInfo withTryTimes:(NSUInteger)times currentTryTime:(NSUInteger)currentTime {
    if (currentTime < times) {
        @weakify(self);
        [self commitPaymentInfo:paymentInfo withCompletionHandler:^(BOOL success) {
            @strongify(self);
            if (!success) {
                [self retryToCommitPaymentInfo:paymentInfo withTryTimes:times currentTryTime:currentTime+1];
            }
        }];
        
    }
}

- (BOOL)commitPaymentInfo:(KbPaymentInfo *)paymentInfo withCompletionHandler:(KbPaymentCompletionHandler)handler {
    NSDictionary *statusDic = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(0), @(PAYRESULT_ABANDON):@(2), @(PAYRESULT_UNKNOWN):@(0)};
    
    if (nil == [KbUtil userId] || paymentInfo.orderId.length == 0) {
        return NO;
    }
    
    NSDictionary *params = @{@"uuid":[KbUtil userId],
                             @"orderNo":paymentInfo.orderId,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":paymentInfo.orderPrice.stringValue,
                             @"channelNo":[KbConfig sharedConfig].channelNo,
                             @"contentId":paymentInfo.contentId.stringValue ?: @"0",
                             @"contentType":paymentInfo.contentType.stringValue ?: @"0",
                             @"pluginType":paymentInfo.paymentType,
                             @"payPointType":paymentInfo.payPointType ?: @"1",
                             @"appId":[KbUtil appId],
                             @"versionNo":@([KbUtil appVersion].integerValue),
                             @"status":statusDic[paymentInfo.paymentResult],
                             @"pV":[KbUtil pV],
                             @"payTime":paymentInfo.paymentTime};
    
    BOOL success = [super requestURLPath:[KbConfig sharedConfig].paymentURLPath
                              withParams:params
                         responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        if (respStatus == KbURLResponseSuccess) {
            paymentInfo.paymentStatus = @(KbPaymentStatusProcessed);
            [paymentInfo save];
        }
                        
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
