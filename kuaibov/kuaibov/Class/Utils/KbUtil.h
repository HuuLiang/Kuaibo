//
//  KbUtil.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (BOOL)isPaid;
+ (void)setPaid;
+ (void)setPaidPendingWithOrder:(NSArray *)order;
+ (void)setPayingOrderNo:(NSString *)payingOrderNo;
+ (NSString *)payingOrderNo;

+ (NSArray *)orderForSavePending; // For last time not saved successfully to remote

+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSString *)appVersion;
+ (NSString *)appId;

// For test only
+ (void)removeKeyChainEntries;

@end
