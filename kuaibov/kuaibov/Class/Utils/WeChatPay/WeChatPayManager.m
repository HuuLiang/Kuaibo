//
//  WeChatPayManager.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "WeChatPayManager.h"
#import "WXApi.h"
#import "payRequsestHandler.h"
#import "KbPaymentConfig.h"
#import "KbPaymentInfo.h"

@interface WeChatPayManager ()
@property (nonatomic,copy) WeChatPayCompletionHandler handler;
@end

@implementation WeChatPayManager

+ (instancetype)sharedInstance {
    static WeChatPayManager *_theInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _theInstance = [[WeChatPayManager alloc] init];
    });
    return _theInstance;
}

- (void)startWithPayment:(KbPaymentInfo *)paymentInfo completionHandler:(WeChatPayCompletionHandler)handler {
    if (paymentInfo.orderId.length == 0 || paymentInfo.orderPrice.unsignedIntegerValue == 0 ||
        paymentInfo.appId.length == 0 || paymentInfo.mchId.length == 0 || paymentInfo.signKey.length == 0 || paymentInfo.notifyUrl.length == 0) {
        if (handler) {
            handler(PAYRESULT_FAIL);
        }
        return ;
    }
    
    _handler = handler;
    
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
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPayWithOrderNo:paymentInfo.orderId price:paymentInfo.orderPrice.unsignedIntegerValue];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        //[self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
}

- (void)sendNotificationByResult:(PAYRESULT)result {
    if (_handler) {
        _handler(result);
    }
}
@end
