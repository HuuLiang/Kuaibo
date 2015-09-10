//
//  KbErrorHandler.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbErrorHandler : NSObject

+ (instancetype)sharedHandler;
- (void)initialize;

@end

extern NSString *const kNetworkErrorNotification;
extern NSString *const kNetworkErrorCodeKey;
extern NSString *const kNetworkErrorMessageKey;