//
//  IpaynowPluginDelegate.h
//  TestIpaynow
//
//  Created by dby on 14-8-17.
//  Copyright (c) 2014年 Ipaynow. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IPNPayResult) {
    IPNPayResultFail           ,  //失败
    IPNPayResultSuccess   ,  //成功
    IPNPayResultCancel      ,  //取消
    IPNPayResultUnknown     //未知
};

@protocol IpaynowPluginDelegate <NSObject>
- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo;
@end
