//
//  KbWeChatPayConfig.m
//  kuaibov
//
//  Created by Sean Yue on 16/1/9.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbWeChatPayConfig.h"
#import "NSMutableDictionary+SafeCoding.h"

static NSString *kWeChatPayConfigKeyName = @"kuaibov_wechatpay_config_keyname";

@implementation KbWeChatPayConfig

- (BOOL)isValid {
    return self.appId.length > 0 && self.mchId.length > 0 && self.signKey.length > 0 && self.notifyUrl.length > 0;
}

+ (instancetype)defaultConfig {
    static KbWeChatPayConfig *_defaultConfig;
    static dispatch_once_t configToken;
    dispatch_once(&configToken, ^{
        NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:kWeChatPayConfigKeyName];
        _defaultConfig = [[self alloc] initWithDictionary:configDic];
    });
    return _defaultConfig;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [self init];
    if (self) {
        self.appId = dic[@"appId"];
        self.mchId = dic[@"mchId"];
        self.signKey = dic[@"signKey"];
        self.notifyUrl = dic[@"notifyUrl"];
        
        if (!self.isValid) {
            self.appId = KB_WECHAT_APP_ID;
            self.mchId = KB_WECHAT_MCH_ID;
            self.signKey = KB_WECHAT_PRIVATE_KEY;
            self.notifyUrl = KB_WECHAT_NOTIFY_URL;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safelySetObject:self.appId forKey:@"appId"];
    [dic safelySetObject:self.mchId forKey:@"mchId"];
    [dic safelySetObject:self.signKey forKey:@"signKey"];
    [dic safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dic.count > 0 ? dic : nil;
}

- (void)saveAsDefaultConfig {
    NSDictionary *dicRep = [self dictionaryRepresentation];
    if (dicRep) {
        [[NSUserDefaults standardUserDefaults] setObject:dicRep forKey:kWeChatPayConfigKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
