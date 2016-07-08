//
//  HYMergePayManager.h
//  WeiXinSourceDemo
//
//  Created by Jiangrx on 12/25/15.
//  Copyright © 2015 HuiYuan.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYPayModel.h"
#import "HYResponseModel.h"

@protocol HYMergePayDelegate <NSObject>

@optional

- (void)thirdAppWillOpened;
- (void)thirdAppOpenSuccess;
- (void)thirdAppOpenFailure;

@end

typedef void(^PayResultBlock)(HYResponseModel * respModel);
@interface HYMergePayManager : NSObject

//启动SDK方法，需要传入启动SDK时的支付类型
+ (void)sendPayRequest:(HYPayModel *)payModel delegate:(id <HYMergePayDelegate>)delegate payResultBlock:(PayResultBlock)resultBlock;

//需要在AppDelegate 的applicationWillEnterForeground:方法中调用.
+(void)mergePaySDKWillEnterForeground; // 获取支付结果使用。

//获取当前聚合支付SDK版本号。
+(NSString *)getApiVersion;

//支付宝专用。应用之间接收同步通知结果。
+(BOOL)application:(UIApplication *)application openURL:(NSURL *)url;
@end
