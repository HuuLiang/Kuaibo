//
//  KbPaymentInfo.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/17.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KbPaymentStatus) {
    KbPaymentStatusUnknown,
    KbPaymentStatusPaying,
    KbPaymentStatusNotProcessed,
    KbPaymentStatusProcessed
};

@interface KbPaymentInfo : NSObject

@property (nonatomic) NSString *paymentId;
@property (nonatomic) NSString *orderId;
@property (nonatomic) NSNumber *orderPrice;
@property (nonatomic) NSNumber *contentId;
@property (nonatomic) NSNumber *contentType;
@property (nonatomic) NSNumber *payPointType;
@property (nonatomic) NSString *paymentTime;
@property (nonatomic) NSNumber *paymentType;
@property (nonatomic) NSNumber *paymentResult;
@property (nonatomic) NSNumber *paymentStatus;
@property (nonatomic) NSString *reservedData;

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *columnType;
@property (nonatomic) NSNumber *contentLocation;

// 商户信息
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment;
- (void)save;

@end
