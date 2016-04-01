//
//  KbPaymentConfig.m
//  kuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbPaymentConfig.h"

@implementation KbWeChatPaymentConfig

+ (instancetype)defaultConfig {
    KbWeChatPaymentConfig *config = [[self alloc] init];
    config.appId = @"wx4af04eb5b3dbfb56";
    config.mchId = @"1281148901";
    config.signKey = @"hangzhouquba20151112qwertyuiopas";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWx.json";
    return config;
}
@end

@implementation KbAlipayConfig

@end

@implementation KbIAppPayConfig

+ (instancetype)defaultConfig {
    KbIAppPayConfig *config = [[self alloc] init];
    config.appid = @"3004262770";
    config.privateKey = @"MIICXQIBAAKBgQCAlkSlxfOCLY/6NPA5VaLvlJjKByjUk2HRGxXDMCZhxucckfvY2yJ0eInTKoqVmkof3+Sp22TNlAdfsMFbsw/9qyHalRclfjhXlKzjurXtGGZ+7uDZGIHM3BV492n1gSbWMAFZE7l5tNPiANkxFjfid7771S3vYB7lthaEcvgRmwIDAQABAoGAMG/qdgOmIcBl/ttYLlDK6rKwB1JBGCpYa3tnbDpECwrw3ftDwkFxriwFxuy8fXQ8PduJ+E3zn9kGGg6sF43RFLVNlEwJMZXWXj0tA1rtbk56vbISXzK+/McDqfhk89abdvdS1HngXRXsYZSFSwt67IwsLRPNCz5vYkS+56kLckkCQQC8IF5zbr+9zLRoUP5H7URNvvYceUHB500skyVfB/kE2KqfP9NCwt7OlTaZG0iFOqSGtG1bqXawiGuTzk+bxvd/AkEArvq/p0dBv00OVFeo7j/OZ2d/usAYSTGCWcGib7vb8xlXHvWkwKSR2priG2vTTNlx7K2r35YheyQcfjV0G4HT5QJBALEF8HrEmw7ZomWK2UwLezuBVwuCGpuAsMEiEYdz9CJYU22Y3I20234fMIov/zTG8uyCuWkIdNQ2+qvR9l1Kg7cCQQCEKAp8cwsrSy2ZciO63iIsYzVLfS5aibQjymW+8inrb6YnUew/O4yViQlhII0Uq96pnXoEgsWC1gFXKVQqOmIpAkBtljLpXAoLNGku5cvGpZycAck9Mbwz4tNzixf4Q/eCuLH6rmUcoNI9q5zQjp8GSITN/7PyzZ+Mw3TahCysC5fl";
    config.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9NgdzqMPgAySHtV02jw8alHb/es/4NOBfjmNwi2uO50No1DM85S/THpNbBLPS7etLunb8XBqGDOQ3cILxCcWOggdcqjaHvmJ/OliWNofDu2QImMrM3t129wSjhfbvUA1btqnDuNcKz0yawZWt9YIIk/jQxutEmxYMq1eN1uvWHQIDAQAB";
    config.waresid = @(1);
    return config;
}

@end

@interface KbPaymentConfigRespCode : NSObject
@property (nonatomic) NSNumber *value;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *message;
@end

@implementation KbPaymentConfigRespCode

@end

static KbPaymentConfig *_shardConfig;

@interface KbPaymentConfig ()
@property (nonatomic) KbPaymentConfigRespCode *code;
@end

@implementation KbPaymentConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shardConfig = [[self alloc] init];
        [_shardConfig loadDefaultConfig];
    });
    return _shardConfig;
}

- (NSNumber *)success {
    return self.code.value.unsignedIntegerValue == 100 ? @(1) : (0);
}

- (NSString *)resultCode {
    return self.code.value.stringValue;
}

- (Class)codeClass {
    return [KbPaymentConfigRespCode class];
}

- (Class)weixinInfoClass {
    return [KbWeChatPaymentConfig class];
}

- (Class)alipayInfoClass {
    return [KbAlipayConfig class];
}

- (Class)iappPayInfoClass {
    return [KbIAppPayConfig class];
}

- (void)loadDefaultConfig {
    self.weixinInfo = [KbWeChatPaymentConfig defaultConfig];
}

- (void)setAsCurrentConfig {
    KbPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.weixinInfo = self.weixinInfo;
    currentConfig.iappPayInfo = self.iappPayInfo;
    currentConfig.alipayInfo = self.alipayInfo;
}
@end
