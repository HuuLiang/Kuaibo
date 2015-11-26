//
//  KbUtil.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KbPendingOrderItem) {
    KbPendingOrderId,
    KbPendingOrderPrice,
    KbPendingOrderProgramId,
    KbPendingOrderProgramType,
    KbPendingOrderPayPointType,
    KbPendingOrderPaymentType,
    KbPendingOrderItemCount
};

@interface KbUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (BOOL)isPaid;
+ (void)setPaid;
+ (void)setPaidPendingWithOrder:(NSArray *)order;

+ (void)setPayingOrder:(NSDictionary<NSString *, id> *)orderInfo;
+ (NSDictionary<NSString *, id> *)payingOrder;

// Methods for convenience
+ (NSString *)payingOrderNo;
+ (KbPaymentType)payingOrderPaymentType;
+ (void)setPayingOrderWithOrderNo:(NSString *)orderNo paymentType:(KbPaymentType)paymentType;

+ (void)setUserAccessed;
+ (BOOL)isUserAccessedToday;

+ (NSArray *)orderForSavePending; // For last time not saved successfully to remote

+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSString *)appVersion;
+ (NSString *)appId;

// For test only
+ (void)removeKeyChainEntries;

@end
