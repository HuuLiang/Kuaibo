//
//  KbPaymentConfigModel.m
//  kuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbPaymentConfigModel.h"
#import "NSDictionary+KbSign.h"

static NSString *const kSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const kPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@implementation KbPaymentConfigModel

+ (Class)responseClass {
    return [KbPaymentConfig class];
}

+ (instancetype)sharedModel {
    static KbPaymentConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (KbURLRequestMethod)requestMethod {
    return KbURLPostRequest;
}

+ (NSString *)signKey {
    return kSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":KB_REST_APP_ID,
                                   @"key":kSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":KB_CHANNEL_NO,
                                   @"pV":KB_REST_PV };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:kPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":KB_REST_APP_ID};
}

- (BOOL)fetchConfigWithCompletionHandler:(KbCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:KB_PAYMENT_CONFIG_URL
                     standbyURLPath:[NSString stringWithFormat:KB_STANDBY_PAYMENT_CONFIG_URL, KB_REST_APP_ID]
                         withParams:@{@"appId":KB_REST_APP_ID, @"channelNo":KB_CHANNEL_NO}
                    responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        KbPaymentConfig *config;
        if (respStatus == KbURLResponseSuccess) {
            self->_loaded = YES;
            
            config = self.response;
            [config setAsCurrentConfig];
            
            DLog(@"Payment config loaded!");
        }
        
        if (handler) {
            handler(respStatus == KbURLResponseSuccess, config);
        }
    }];
    return ret;
}
@end
