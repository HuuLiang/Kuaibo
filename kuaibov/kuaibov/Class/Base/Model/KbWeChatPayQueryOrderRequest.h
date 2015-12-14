//
//  KbWeChatPayQueryOrderRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KbWeChatPayQueryOrderCompletionHandler)(BOOL success, NSString *trade_state, double total_fee);

@interface KbWeChatPayQueryOrderRequest : NSObject

@property (nonatomic) NSString *return_code;
@property (nonatomic) NSString *result_code;
@property (nonatomic) NSString *trade_state;
@property (nonatomic) double total_fee;

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(KbWeChatPayQueryOrderCompletionHandler)handler;

@end
