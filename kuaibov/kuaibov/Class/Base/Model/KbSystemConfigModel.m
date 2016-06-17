//
//  KbSystemConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbSystemConfigModel.h"

@implementation KbSystemConfigResponse

- (Class)confisElementClass {
    return [KbSystemConfig class];
}

@end

@implementation KbSystemConfigModel

+ (instancetype)sharedModel {
    static KbSystemConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[KbSystemConfigModel alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [KbSystemConfigResponse class];
}

- (BOOL)fetchSystemConfigWithCompletionHandler:(KbFetchSystemConfigCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:KB_SYSTEM_CONFIG_URL
                         standbyURLPath:KB_STANDBY_SYSTEM_CONFIG_URL
                             withParams:nil
                        responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (respStatus == KbURLResponseSuccess) {
            KbSystemConfigResponse *resp = self.response;
            
            [resp.confis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                KbSystemConfig *config = obj;
                
                if ([config.name isEqualToString:KB_SYSTEM_CONFIG_PAY_AMOUNT]) {
                    self.payAmount = config.value.doubleValue / 100.;
                } else if ([config.name isEqualToString:KB_SYSTEM_CONFIG_PAY_IMG]) {
                    self.paymentImage = config.value;
                } else if ([config.name isEqualToString:KB_SYSTEM_CONFIG_CHANNEL_TOP_IMAGE]) {
                    self.channelTopImage = config.value;
                } else if ([config.name isEqualToString:KB_SYSTEM_CONFIG_STARTUP_INSTALL]) {
                    self.startupInstall = config.value;
                    self.startupPrompt = config.memo;
                } else if ([config.name isEqualToString:KB_SYSTEM_CONFIG_SPREAD_TOP_IMAGE]) {
                    self.spreadTopImage = config.value;
                } else if ([config.name isEqualToString:KB_SYSTEM_CONFIG_SPREAD_URL]) {
                    self.spreadURL = config.value;
                }else if ([config.name isEqualToString:KB_SYSTEM_CONFIG_STATS_TIME_INTERVAL]){
                    self.statsTimeInterval = config.value.integerValue;
                }
            }];
            _loaded = YES;
        }
        
        if (handler) {
            handler(respStatus==KbURLResponseSuccess);
        }
    }];
    return success;
}

@end
