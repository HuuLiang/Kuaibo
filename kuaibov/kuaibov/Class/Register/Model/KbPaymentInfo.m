//
//  KbPaymentInfo.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/17.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbPaymentInfo.h"
#import "NSMutableDictionary+SafeCoding.h"

static NSString *const kPaymentInfoPaymentIdKeyName = @"kuaibov_paymentinfo_paymentid_keyname";
static NSString *const kPaymentInfoOrderIdKeyName = @"kuaibov_paymentinfo_orderid_keyname";
static NSString *const kPaymentInfoOrderPriceKeyName = @"kuaibov_paymentinfo_orderprice_keyname";
static NSString *const kPaymentInfoContentIdKeyName = @"kuaibov_paymentinfo_contentid_keyname";
static NSString *const kPaymentInfoContentTypeKeyName = @"kuaibov_paymentinfo_contenttype_keyname";
static NSString *const kPaymentInfoPayPointTypeKeyName = @"kuaibov_paymentinfo_paypointtype_keyname";
static NSString *const kPaymentInfoPaymentTypeKeyName = @"kuaibov_paymentinfo_paymenttype_keyname";
static NSString *const kPaymentInfoPaymentResultKeyName = @"kuaibov_paymentinfo_paymentresult_keyname";
static NSString *const kPaymentInfoPaymentStatusKeyName = @"kuaibov_paymentinfo_paymentstatus_keyname";
static NSString *const kPaymentInfoPaymentTimeKeyName = @"kuaibov_paymentinfo_paymenttime_keyname";
static NSString *const kPaymentInfoPaymentReservedDataKeyName = @"kuaibov_paymentinfo_paymentreserveddata_keyname";

static NSString *const kPaymentInfoPaymentAppId = @"kuaibov_paymentinfo_paymentappid_keyname";
static NSString *const kPaymentInfoPaymentMchId = @"kuaibov_paymentinfo_paymentmchid_keyname";
static NSString *const kPaymentInfoPaymentSignKey = @"kuaibov_paymentinfo_paymentsignkey_keyname";
static NSString *const kPaymentInfoPaymentNotifyUrl = @"kuaibov_paymentinfo_paymentnotifyurl_keyname";
static NSString *const kPaymentInfoPaymentColumIdKey = @"kuaibov_paymentinfo_paymentcolunidkey_keyname";
static NSString *const kPaymentInfoPaymentColumTypeKey = @"kuaibov_paymentinfo_paymentcoluntypekey_keyname";
static NSString *const kPaymentInfoPaymentContentLocationKey = @"kuaibov_paymentinfo_paymentcontentlocationkey_keyname";


@implementation KbPaymentInfo

- (NSString *)paymentId {
    if (_paymentId) {
        return _paymentId;
    }
    
    _paymentId = [NSUUID UUID].UUIDString.md5;
    return _paymentId;
}

+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment {
    KbPaymentInfo *paymentInfo = [[self alloc] init];
    paymentInfo.paymentId = payment[kPaymentInfoPaymentIdKeyName];
    paymentInfo.orderId = payment[kPaymentInfoOrderIdKeyName];
    paymentInfo.orderPrice = payment[kPaymentInfoOrderPriceKeyName];
    paymentInfo.contentId = payment[kPaymentInfoContentIdKeyName];
    paymentInfo.contentType = payment[kPaymentInfoContentTypeKeyName];
    paymentInfo.payPointType = payment[kPaymentInfoPayPointTypeKeyName];
    paymentInfo.paymentType = payment[kPaymentInfoPaymentTypeKeyName];
    paymentInfo.paymentResult = payment[kPaymentInfoPaymentResultKeyName];
    paymentInfo.paymentStatus = payment[kPaymentInfoPaymentStatusKeyName];
    paymentInfo.paymentTime = payment[kPaymentInfoPaymentTimeKeyName];
    paymentInfo.reservedData = payment[kPaymentInfoPaymentReservedDataKeyName];
    paymentInfo.appId = payment[kPaymentInfoPaymentAppId];
    paymentInfo.mchId = payment[kPaymentInfoPaymentMchId];
    paymentInfo.notifyUrl = payment[kPaymentInfoPaymentNotifyUrl];
    paymentInfo.signKey = payment[kPaymentInfoPaymentSignKey];
    paymentInfo.columnId = payment[kPaymentInfoPaymentColumIdKey];
    paymentInfo.columnType = payment[kPaymentInfoPaymentColumTypeKey];
    paymentInfo.contentLocation = payment[kPaymentInfoPaymentContentLocationKey];
    return paymentInfo;
}

- (NSDictionary *)dictionaryFromCurrentPaymentInfo {
    NSMutableDictionary *payment = [NSMutableDictionary dictionary];
    [payment safelySetObject:self.paymentId forKey:kPaymentInfoPaymentIdKeyName];
    [payment safelySetObject:self.orderId forKey:kPaymentInfoOrderIdKeyName];
    [payment safelySetObject:self.orderPrice forKey:kPaymentInfoOrderPriceKeyName];
    [payment safelySetObject:self.contentId forKey:kPaymentInfoContentIdKeyName];
    [payment safelySetObject:self.contentType forKey:kPaymentInfoContentTypeKeyName];
    [payment safelySetObject:self.payPointType forKey:kPaymentInfoPayPointTypeKeyName];
    [payment safelySetObject:self.paymentType forKey:kPaymentInfoPaymentTypeKeyName];
    [payment safelySetObject:self.paymentResult forKey:kPaymentInfoPaymentResultKeyName];
    [payment safelySetObject:self.paymentStatus forKey:kPaymentInfoPaymentStatusKeyName];
    [payment safelySetObject:self.paymentTime forKey:kPaymentInfoPaymentTimeKeyName];
    [payment safelySetObject:self.reservedData forKey:kPaymentInfoPaymentReservedDataKeyName];
    [payment safelySetObject:self.appId forKey:kPaymentInfoPaymentAppId];
    [payment safelySetObject:self.mchId forKey:kPaymentInfoPaymentMchId];
    [payment safelySetObject:self.notifyUrl forKey:kPaymentInfoPaymentNotifyUrl];
    [payment safelySetObject:self.signKey forKey:kPaymentInfoPaymentSignKey];
    [payment safelySetObject:self.columnId forKey:kPaymentInfoPaymentColumIdKey];
    [payment safelySetObject:self.columnType forKey:kPaymentInfoPaymentColumTypeKey];
    [payment safelySetObject:self.contentLocation forKey:kPaymentInfoPaymentContentLocationKey];
    return payment;
}

- (void)save {
    NSArray *paymentInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfosM = [paymentInfos mutableCopy];
    if (!paymentInfosM) {
        paymentInfosM = [NSMutableArray array];
    }
    
    NSDictionary *payment = [paymentInfos bk_match:^BOOL(id obj) {
        NSString *paymentId = ((NSDictionary *)obj)[kPaymentInfoPaymentIdKeyName];
        if ([paymentId isEqualToString:self.paymentId]) {
            return YES;
        }
        return NO;
    }];
    
    if (payment) {
        [paymentInfosM removeObject:payment];
    }
    
    payment = [self dictionaryFromCurrentPaymentInfo];
    [paymentInfosM addObject:payment];
    
    [[NSUserDefaults standardUserDefaults] setObject:paymentInfosM forKey:kPaymentInfoKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DLog(@"Save payment info: %@", payment);
}

@end
