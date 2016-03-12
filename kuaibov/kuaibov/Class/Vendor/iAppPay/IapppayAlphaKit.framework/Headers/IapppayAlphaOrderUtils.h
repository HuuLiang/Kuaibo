//
//  IapppayAlphaOrderUtils.h
//  IapppayAlphaDemo
//
//  Created by Shixiong on 16/2/24.
//  Copyright © 2016年 Iapppay.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IapppayAlphaOrderUtils : NSObject

@property (nonatomic, copy) NSString *appId;            //应用ID（必须）String(20)

@property (nonatomic, copy) NSString *cpPrivateKey;     //应用私钥（必须）

@property (nonatomic, copy) NSString *notifyUrl;        //回调地址（条件）String(128)

@property (nonatomic, copy) NSString *cpOrderId;        //商户订单ID（必须）String(64)

@property (nonatomic, copy) NSString *waresId;          //商品ID（必须）

@property (nonatomic, copy) NSString *price;            //商品价格<单位：元>（必须）

@property (nonatomic, copy) NSString *appUserId;        //用户在商户应用的唯一标识（必须）String(32)

@property (nonatomic, copy) NSString *waresName;        //商品名称,只对开放价格有效（条件）String(32)

@property (nonatomic, copy) NSString *cpPrivateInfo;    //商品私有信息（条件）String(64)


/**
 * 客户端下单：获取调起SDK支付参数的方法
 *
 * @return:data  返回支付参数
 *
 * 注意：使用此方法生成支付参数，要求传入所有《必须》的字段
 **/
- (NSString *)getTrandData;



/**
 * 服务端下单：获取调起SDK支付参数的方法
 * @params:transId    在爱贝服务端的获取的此次订单的流水号
 *
 * @return:data  返回支付参数
 *
 * 注意：使用此方法生成支付参数，只需传入appId和transId即可
 **/
- (NSString *)getTrandIdDataWith:(NSString *)transId;


/**
 * 支付结果验签方法
 * @params:signature    爱贝SDK返回此次订单的支付签名结果
 * @params:appKey       在爱贝后台获取的平台公钥
 *
 * @return:flag  返回验签结果
 *
 **/
+ (BOOL)checkPayResult:(NSString *)signature withAppKey:(NSString *)appKey;

@end
