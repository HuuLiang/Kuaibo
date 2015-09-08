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
@property (nonatomic) NSString *homeProgramURLPath;
@property (nonatomic) NSString *channelURLPath;
@property (nonatomic) NSString *channelProgramURLPath;
@property (nonatomic) NSString *moreURLPath;
@property (nonatomic) NSString *registerURLPath;

@property (nonatomic) NSString *channelNo;

@property (nonatomic) NSString *alipayPID;
@property (nonatomic) NSString *alipaySellerID;
@property (nonatomic) NSString *alipayScheme;
@property (nonatomic) NSString *alipayPrivateKey;

+ (instancetype)sharedConfig;

@end
