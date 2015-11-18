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

@property (nonatomic,readonly) NSString *alipayPID;
@property (nonatomic,readonly) NSString *alipaySellerID;
@property (nonatomic,readonly) NSString *alipayScheme;
@property (nonatomic,readonly) NSString *alipayPrivateKey;
@property (nonatomic,readonly) NSString *alipayNotifyURL;

@property (nonatomic,readonly) NSString *weChatPayAppId;
@property (nonatomic,readonly) NSString *weChatPayMchId;
@property (nonatomic,readonly) NSString *weChatPayPrivateKey;
@property (nonatomic,readonly) NSString *weChatPayNotifyURL;

@property (nonatomic,readonly) NSString *systemConfigPayAmount;
@property (nonatomic,readonly) NSString *systemConfigChannelTopImage;

@property (nonatomic,readonly) NSString *paymentURLPath;

+ (instancetype)sharedConfig;

@end
