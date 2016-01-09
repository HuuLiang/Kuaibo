//
//  KbWeChatPayConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 16/1/8.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbWeChatPayConfigModel.h"

@implementation KbWeChatPayConfigModel

+ (instancetype)sharedModel {
    static KbWeChatPayConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [KbWeChatPayConfig class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)fetchWeChatPayConfigWithCompletionHandler:(KbCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:KB_WECHATPAY_CONFIG_URL
                     standbyURLPath:KB_STANDBY_WECHATPAY_CONFIG_URL
                         withParams:nil
                    responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        KbWeChatPayConfig *config;
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
