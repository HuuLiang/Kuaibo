//
//  KbPaymentConfig.h
//  kuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbURLResponse.h"

typedef NS_ENUM(NSUInteger, KbIAppPayType) {
    KbIAppPayTypeUnknown = 0,
    KbIAppPayTypeWeChat = 1 << 0,
    KbIAppPayTypeAlipay = 1 << 1
};

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
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;
@end

@interface KbVIAPayConfig : NSObject

//@property (nonatomic) NSString *packageId;
@property (nonatomic) NSNumber *supportPayTypes;

@end

@interface KbSPayConfig : NSObject
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end

@interface KbHTPayConfig : NSObject
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *notifyUrl;
@end



@interface KbPaymentConfig : KbURLResponse

@property (nonatomic,retain) KbWeChatPaymentConfig *weixinInfo;
@property (nonatomic,retain) KbAlipayConfig *alipayInfo;
@property (nonatomic,retain) KbIAppPayConfig *iappPayInfo;

@property (nonatomic,retain) KbVIAPayConfig *syskPayInfo;
@property (nonatomic,retain) KbSPayConfig *wftPayInfo;
@property (nonatomic,retain) KbHTPayConfig *haitunPayInfo;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

@end
