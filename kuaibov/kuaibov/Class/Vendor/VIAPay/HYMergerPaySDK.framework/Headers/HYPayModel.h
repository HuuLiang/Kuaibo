//
//  HYPayModel.h
//  WeiXinSourceDemo
//
//  Created by Jiangrx on 12/29/15.
//  Copyright © 2015 HuiYuan.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MergePayChannelType) {
    
    MergePayChannelTypeWeiXin             = 30,  //聚合支付--- 微信
    MergePayChannelTypeAliPay             = 22,  //聚合支付--- 支付宝
};

@interface HYPayModel : NSObject


@property (nonatomic,copy) NSString * token_id;
@property (nonatomic,copy) NSString * agent_id;
@property (nonatomic,copy) NSString * agent_bill_id;

@property (nonatomic,copy) NSString * schemeStr; //走支付宝无线支付时必传; WAP时，忽略此参数。
@property (nonatomic,strong) UIViewController * currViewController; //预留属性。
@end
