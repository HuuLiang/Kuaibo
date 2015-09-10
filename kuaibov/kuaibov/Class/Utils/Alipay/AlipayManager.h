//
//  AlipayManager.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, PAYRESULT)
{
    PAYRESULT_SUCCESS   = 0,
    PAYRESULT_ABANDON   = 1,
    PAYRESULT_FAIL      = 2
};

@class Order;
//typedef void (^blockResult)(BOOL success, NSError *error);
typedef void (^AlipayResultBlock)(PAYRESULT result, Order *order);

@interface AlipayManager : NSObject

+ (AlipayManager *)shareInstance;


/*!
 *	@brief 支付宝支付接口
 *  @param orderId  订单的id ，在调用创建订单之后服务器会返回该订单的id
 *  @param price    商品价格
 *  @result
 */
- (void)startAlipay:(NSString *)_orderId price:(NSString*)_price withResult:(AlipayResultBlock)resultBlock;


- (void)sendNotificationByResult:(NSDictionary *)_resultDic;


@end
