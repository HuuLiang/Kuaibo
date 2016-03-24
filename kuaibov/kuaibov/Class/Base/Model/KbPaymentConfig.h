//
//  KbPaymentConfig.h
//  kuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbURLResponse.h"

@interface KbWeChatPaymentConfig : NSObject
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)defaultConfig;
@end

@interface KbAlipayConfig : NSObject
@property (nonatomic) NSString *partner;
@property (nonatomic) NSString *seller;
@property (nonatomic) NSString *productInfo;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *notifyUrl;
@end

@interface KbIAppPayConfig : NSObject
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;

+ (instancetype)defaultConfig;
@end

@interface KbPaymentConfig : KbURLResponse

@property (nonatomic,retain) KbWeChatPaymentConfig *weixinInfo;
@property (nonatomic,retain) KbAlipayConfig *alipayInfo;
@property (nonatomic,retain) KbIAppPayConfig *iappPayInfo;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

@end
