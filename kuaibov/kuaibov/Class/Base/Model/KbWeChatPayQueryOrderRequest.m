//
//  KbWeChatPayQueryOrderRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbWeChatPayQueryOrderRequest.h"
#import "payRequsestHandler.h"
#import "WXUtil.h"

static NSString *const kWeChatPayQueryOrderUrlString = @"https://api.mch.weixin.qq.com/pay/orderquery";
static NSString *const kSuccessString = @"SUCCESS";

@implementation KbWeChatPayQueryOrderRequest

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(KbWeChatPayQueryOrderCompletionHandler)handler {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        srand( (unsigned)time(0) );
        NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
        
        NSMutableDictionary *params = @{@"appid":KB_WECHAT_APP_ID,
                                        @"mch_id":KB_WECHAT_MCH_ID,
                                        @"out_trade_no":orderNo,
                                        @"nonce_str":noncestr}.mutableCopy;
        //创建支付签名对象
        payRequsestHandler *req = [[payRequsestHandler alloc] init];
        //初始化支付签名对象
        [req init:KB_WECHAT_APP_ID mch_id:KB_WECHAT_MCH_ID];
        //设置密钥
        [req setKey:KB_WECHAT_PRIVATE_KEY];
        //设置回调URL
        [req setNotifyUrl:KB_WECHAT_NOTIFY_URL];
        //设置附加数据
        [req setAttach:KB_PAYMENT_RESERVE_DATA];
        
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
