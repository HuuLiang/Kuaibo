//
//  KbAlipayConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/19.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbAlipayConfigModel.h"

@implementation KbAlipayConfigModel

+ (instancetype)sharedModel {
    static KbAlipayConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [KbAlipayConfig class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (KbAlipayConfig *)fetchedConfig {
    return self.response;
}

- (BOOL)fetchAlipayConfigWithCompletionHandler:(KbCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:KB_ALIPAY_CONFIG_URL
                     standbyURLPath:KB_STANDBY_ALIPAY_CONFIG_URL
                         withParams:nil
                    responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        KbAlipayConfig *config;
        if (respStatus == KbURLResponseSuccess) {
            config = self.response;
            [config saveAsDefaultConfig];
        }
        
        if (handler) {
            handler(respStatus==KbURLResponseSuccess, config);
        }
    }];
    return ret;
}

@end
