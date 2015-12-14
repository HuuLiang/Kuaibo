//
//  KbConfig.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbConfig : NSObject

@property (nonatomic,readonly) NSString *channelNo;

@property (nonatomic,readonly) NSString *baseURL;
@property (nonatomic,readonly) NSString *bannerURLPath;
@property (nonatomic,readonly) NSString *homeProgramURLPath;
@property (nonatomic,readonly) NSString *channelURLPath;
@property (nonatomic,readonly) NSString *channelProgramURLPath;
@property (nonatomic,readonly) NSString *moreURLPath;
@property (nonatomic,readonly) NSString *registerURLPath;
@property (nonatomic,readonly) NSString *systemConfigURLPath;
@property (nonatomic,readonly) NSString *userAccessURLPath;

@property (nonatomic,readonly) NSString *systemConfigPayAmount;
@property (nonatomic,readonly) NSString *systemConfigChannelTopImage;
@property (nonatomic,readonly) NSString *systemConfigStartupInstall;

@property (nonatomic,readonly) NSString *payNowScheme;
@property (nonatomic,readonly) NSString *paymentSignURLPath;
@property (nonatomic,readonly) NSString *paymentURLPath;

@property (nonatomic,readonly) NSString *baiduAdAppId;
@property (nonatomic,readonly) NSString *baiduBannerAdId;
@property (nonatomic,readonly) NSString *baiduLaunchAdId;
@property (nonatomic,readonly) NSString *baiduWallAdId;

@property (nonatomic,readonly) NSString *umengAppId;
@property (nonatomic,readonly) NSString *umengTriggerPaymentEventId;
@property (nonatomic,readonly) NSString *umengSuccessfulPaymentEventId;
@property (nonatomic,readonly) NSString *umengFailedPaymentEventId;
@property (nonatomic,readonly) NSString *umengCancelledPaymentEventId;

+ (instancetype)sharedConfig;
+ (instancetype)sharedStandbyConfig;
+ (instancetype)configWithName:(NSString *)configName;

@end
