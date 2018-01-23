//
//  WeChatPayQueryOrderRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WeChatPayQueryOrderCompletionHandler)(BOOL success, NSString *trade_state, double total_fee);

@class KbPaymentInfo;
@interface WeChatPayQueryOrderRequest : NSObject

@property (nonatomic) NSString *return_code;
@property (nonatomic) NSString *result_code;
@property (nonatomic) NSString *trade_state;
@property (nonatomic) double total_fee;

- (BOOL)queryPayment:(KbPaymentInfo *)paymentInfo withCompletionHandler:(WeChatPayQueryOrderCompletionHandler)handler;

@end
