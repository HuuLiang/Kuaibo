//
//  HYResponseModel.h
//  WeiXinSourceDemo
//
//  Created by Jiangrx on 1/22/16.
//  Copyright © 2016 HuiYuan.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MergePayResult) {
    
    MergePayResultSuccess           = 1,    //支付成功
    MergePayResultFail              = -1,   //支付失败
    MergePayResultDealing           = 0,    //支付等待中
    MergePayResultCancel            = -2,   //取消支付
    MergePayResultError             = -3,   //一般性错误，商户开始人员可不做逻辑处理，直接将对应的信息显示给用户。
};

@interface HYResponseModel : NSObject

@property (nonatomic,copy) NSString * message; // 回调的具体方法。
@property (nonatomic,assign) MergePayResult payResultCode; //返回码。
@end
