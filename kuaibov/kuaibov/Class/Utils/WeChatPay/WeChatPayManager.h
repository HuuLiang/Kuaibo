//
//  WeChatPayManager.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WeChatPayCompletionHandler)(PAYRESULT payResult);

@interface WeChatPayManager : NSObject

+ (instancetype)sharedInstance;

- (void)startWeChatPayWithOrderNo:(NSString *)orderNo price:(NSUInteger)price completionHandler:(WeChatPayCompletionHandler)handler;
- (void)sendNotificationByResult:(PAYRESULT)result;
@end
