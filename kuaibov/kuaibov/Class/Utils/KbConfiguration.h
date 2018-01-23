//
//  KbConfiguration.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbConfiguration : NSObject

@property (nonatomic,readonly) NSString *channelNo;

+ (instancetype)sharedConfig;
+ (instancetype)sharedStandbyConfig;

@end
