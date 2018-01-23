//
//  WeChatPayQueryOrderRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "WeChatPayQueryOrderRequest.h"
#import "payRequsestHandler.h"
#import "WXUtil.h"
#import "KbPaymentConfig.h"
#import "KbPaymentInfo.h"

static NSString *const kWeChatPayQueryOrderUrlString = @"https://api.mch.weixin.qq.com/pay/orderquery";
static NSString *const kSuccessString = @"SUCCESS";

@implementation WeChatPayQueryOrderRequest

- (BOOL)queryPayment:(KbPaymentInfo *)paymentInfo withCompletionHandler:(WeChatPayQueryOrderCompletionHandler)handler {
    if (paymentInfo.orderId.length == 0
        || paymentInfo.appId.length == 0
        || paymentInfo.mchId.length == 0
        || paymentInfo.signKey.length == 0
        || paymentInfo.notifyUrl.length == 0)
    {
        if (handler) {
            handler(NO, nil, 0);
        }
        return NO;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        srand( (unsigned)time(0) );
        NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
        
        NSMutableDictionary *params = @{@"appid":paymentInfo.appId,
                                        @"mch_id":paymentInfo.mchId,
                                        @"out_trade_no":paymentInfo.orderId,
                                        @"nonce_str":noncestr}.mutableCopy;
        //创建支付签名对象
        payRequsestHandler *req = [[payRequsestHandler alloc] init];
        //初始化支付签名对象
        [req init:paymentInfo.appId mch_id:paymentInfo.mchId];
        //设置密钥
        [req setKey:paymentInfo.signKey];
        //设置回调URL
        [req setNotifyUrl:paymentInfo.notifyUrl];
        //设置附加数据
        [req setAttach:paymentInfo.reservedData];
        
        NSString *package = [req genPackage:params];
        NSData *data =[WXUtil httpSend:kWeChatPayQueryOrderUrlString method:@"POST" data:package];
        
        XMLHelper *xml  = [[XMLHelper alloc] init];
        
        //开始解析
        [xml startParse:data];
        
        NSMutableDictionary *resParams = [xml getDict];
        self.return_code = resParams[@"return_code"];
        self.result_code = resParams[@"result_code"];
        self.trade_state = resParams[@"trade_state"];
        self.total_fee = ((NSString *)resParams[@"total_fee"]).integerValue / 100;
        
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler([self.return_code isEqualToString:kSuccessString] && [self.result_code isEqualToString:kSuccessString], self.trade_state, self.total_fee);
            });
        }
    });
    
    return YES;
}
@end
