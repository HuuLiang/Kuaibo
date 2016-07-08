//
//  HTPayManager.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/24.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTPayManager : NSObject

+ (instancetype)sharedManager;

- (void)setMchId:(NSString *)mchId
      privateKey:(NSString *)privateKey
       notifyUrl:(NSString *)notifyUrl
       channelNo:(NSString *)channelNo
           appId:(NSString *)appId;
- (void)payWithOrderId:(NSString *)orderId orderName:(NSString *)orderName price:(NSUInteger)price withCompletionHandler:(KbCompletionHandler)completionHandler;

@end
