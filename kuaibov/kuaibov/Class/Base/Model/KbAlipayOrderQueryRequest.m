//
//  KbAlipayOrderQueryRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbAlipayOrderQueryRequest.h"

static NSString *const kAlipayOrderQueryUrlString = @"https://openapi.alipay.com/gateway.do";

@implementation KbAlipayOrderQueryResponse

@end

@implementation KbAlipayOrderQueryRequest

+ (Class)responseClass {
    return [KbAlipayOrderQueryResponse class];
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(KbAlipayOrderQueryCompletionHandler)handler {
    NSDateFormatter *dateFormmatter = [[NSDateFormatter alloc] init];
    NSDictionary *params = @{@"app_id":[KbConfig sharedConfig].alipayPID,
                             @"method":@"alipay.trade.pay",
                             @"charset":@"utf-8",
                             @"sign_type":@"RSA",
                             @"sign":[KbConfig sharedConfig].alipayPrivateKey,
                             @"timestamp":[dateFormmatter stringFromDate:[NSDate date]],
                             @"version":@"1.0",
                             @"biz_content":@""};
    BOOL success = [self requestURLPath:kAlipayOrderQueryUrlString
                             withParams:params
                        responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        
    }];
    return success;
}

@end
