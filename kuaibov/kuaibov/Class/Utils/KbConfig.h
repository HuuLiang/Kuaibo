//
//  KbConfig.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbConfig : NSObject

@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSString *bannerURLPath;
@property (nonatomic) NSString *channelURLPath;

@property (nonatomic) NSString *channelNo;

+ (instancetype)sharedConfig;

@end
