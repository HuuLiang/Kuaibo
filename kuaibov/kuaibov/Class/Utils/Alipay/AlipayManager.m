//
//  AlipayManager.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "AlipayManager.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>


static AlipayManager *alipayManager;

@interface AlipayManager ()
@property (nonatomic,copy) AlipayResultBlock resultBlock;
@property (nonatomic,retain) Order *payOrder;
@end

@implementation AlipayManager
{
}



#pragma mark - shareInstance
+ (AlipayManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        alipayManager = [[AlipayManager alloc] init];
    });
    return alipayManager;
}



#pragma mark -  function
/*!
 *	@brief 支付宝支付接口
 *  @param orderId  订单的id ，在调用创建订单之后服务器会返回该订单的id
 *  @param price    商品价格
 *  @result
 */
- (void)startAlipay:(NSString *)_orderId price:(NSString*)_price withResult:(AlipayResultBlock)resultBlock
{
    self.resultBlock = resultBlock;
    
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    if (!appName) {
        appName = @"家庭影院";
    }
    
    Order *order = [[Order alloc] init];
    order.partner       = [KbConfig sharedConfig].alipayPID;
    order.seller        = [KbConfig sharedConfig].alipaySellerID;
    
    order.tradeNO       = _orderId;         //订单ID（由商家自行制定）
    order.productName   = appName; //商品标题
    order.productDescription = [NSString stringWithFormat:@"%@终身会员", appName]; //商品描述
    order.amount        = _price;           //商品价格
    order.notifyURL     =  [KbConfig sharedConfig].alipayNotifyURL; //回调URL
    
    order.service       = @"mobile.securitypay.pay";
    order.paymentType   = @"1";
    order.inputCharset  = @"utf-8";
    order.itBPay        = @"30m";
    order.showUrl       = @"m.alipay.com";
    
    
    
    
    NSString *orderInfo = [order description];
    NSString *appScheme = [KbConfig sharedConfig].alipayScheme;
//
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer   = CreateRSADataSigner([KbConfig sharedConfig].alipayPrivateKey);
    NSString *signedString  = [signer signString:orderInfo];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil)
    {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderInfo, signedString, @"RSA"];
        
        self.payOrder = order;
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic)
        {
            [self sendNotificationByResult:resultDic];
        }];
    }
    
}


- (void)sendNotificationByResult:(NSDictionary *)_resultDic
{
    DLog(@"支付宝返回的result : %@" , _resultDic);
    PAYRESULT payResult = PAYRESULT_FAIL;
    //用户放弃付款的情况  6001
    if([[_resultDic allKeys] containsObject:@"resultStatus"])
    {
        NSString * resultStatues  = _resultDic[@"resultStatus"];
        if(resultStatues && [resultStatues isEqualToString:@"6001"]) {
            payResult = PAYRESULT_ABANDON;
        } else if (resultStatues && [resultStatues isEqualToString:@"9000"]) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
    }
    
    if (self.resultBlock) {
        self.resultBlock(payResult, self.payOrder);
    }
//    NSLog(@"reslut = %@",_resultDic);
//    NSString * strResult    = _resultDic[@"success"];
//    NSRange range = [strResult rangeOfString:@"true"];//判断字符串是否包含
//    if (range.length >0)
//    {
//        [NOTIFICENTER postNotificationName:NOTIFY_ALIPAY_PAY_STATE object:[NSNumber numberWithInt:PAYRESULT_SUCCESS]];
//    }
//    else
//    {
//        [NOTIFICENTER postNotificationName:NOTIFY_ALIPAY_PAY_STATE object:[NSNumber numberWithInt:PAYRESULT_FAIL]];
//    }
}

@end
