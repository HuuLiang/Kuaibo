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

- (void)startWeChatPayWithOrderNo:(NSString *)orderNo price:(double)price completionHandler:(WeChatPayCompletionHandler)handler {
    _handler = handler;
    
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    //初始化支付签名对象
    [req init:[KbConfig sharedConfig].weChatPayAppId mch_id:[KbConfig sharedConfig].weChatPayMchId];
    //设置密钥
    [req setKey:[KbConfig sharedConfig].weChatPayPrivateKey];
    //设置回调URL
    [req setNotifyUrl:[KbConfig sharedConfig].weChatPayNotifyURL];
    //设置附加数据
    [req setAttach:[KbConfig sharedConfig].paymentReservedData];
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPayWithOrderNo:orderNo price:@(price*100).unsignedIntegerValue];
    
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
