//
//  KbAlipayOrderQueryRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbURLRequest.h"

@interface KbAlipayOrderQueryResponse : KbURLResponse

@property (nonatomic) NSString *trade_no;
@property (nonatomic) NSString *out_trade_no;

@end

typedef void (^KbAlipayOrderQueryCompletionHandler)(BOOL success, NSString *trade_status);

@interface KbAlipayOrderQueryRequest : KbURLRequest

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(KbAlipayOrderQueryCompletionHandler)handler;

@end
