//
//  KbUtil.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegistered;
+ (NSString *)userId;

@end
