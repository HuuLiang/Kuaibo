//
//  IapppayAlphaKit.h
//  IapppayAlphaDemo
//
//  Created by Shixiong on 16/2/22.
//  Copyright © 2016年 Iapppay.Inc. All rights reserved.
//

////////////////////////////////////////////////////////
///////////version：1.0.1-alpha date：2016.07.27/////////
////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

//透明收银台的支付方式
typedef enum IapppayAlphaKitPayType : NSInteger {
    IapppayAlphaKitAlipayPayType = 401,    //支付宝
    IapppayAlphaKitWeChatPayType = 403,    //微信支付
} IapppayAlphaKitPayType;

//爱贝支付结果Code
typedef enum IapppayAlphaKitPayRetCode : NSInteger {
    IapppayAlphaKitPayRetCancelCode  = 99,    //支付取消
    IapppayAlphaKitPayRetFailedCode  = -1,    //支付失败
    IapppayAlphaKitPayRetSuccessCode = 0      //支付成功
} IapppayAlphaKitPayRetCode;

@protocol IapppayAlphaKitPayRetDelegate <NSObject>

@optional
/**
 * 爱贝支付结果返回
 * @statusCode = "支付结果code"
 * @resultInfo = {RetCode:"错误码",ErrorMsg:"错误信息",Signature:"支付成功的密文，需要验签"}
 **/
- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode
                       resultInfo:(NSDictionary *)resultInfo;

@end


@interface IapppayAlphaKit : NSObject


/**
 * 设置支付宝支付回调
 * @params:appAlipayScheme 支付宝支付SSO回调，该字段必传。
 **/
@property (nonatomic, copy) NSString *appAlipayScheme;


/**
 * 创建SDK接入对象
 **/
+ (IapppayAlphaKit *)sharedInstance;


/**
 * 支付宝App支付结果回调
 **/
- (void)handleOpenUrl:(NSURL *)url;


/**
 * 设置SDK接入的基本信息
 * @params:appID        在爱贝注册的应用ID
 * @params:mACID        渠道号
 **/
- (BOOL)setAppId:(NSString *)appID mACID:(NSString *)mACID;


/**
 * 调起爱贝支付进行支付
 * @params:trandInfo    格式化的订单信息transdata或者transid(参照爱贝SDK服务端接入文档)
 * @params:payDelegate  支付结果处理对象
 **/
- (BOOL)makePayForTrandInfo:(NSString *)trandInfo
              payMethodType:(IapppayAlphaKitPayType)payType
                payDelegate:(id<IapppayAlphaKitPayRetDelegate>)payDelegate;


@end

