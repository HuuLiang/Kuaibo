//
//  KbUtil.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbUtil.h"
#import <SFHFKeychainUtils.h>

static NSString *const kRegisterKeyChainUsername = @"kuaibov_register_username";
static NSString *const kRegisterKeyChainServiceName = @"kuaibov_register_servicename";
static NSString *const kRegisterKeyChainPassword = @"kuaibov_register_password";

@implementation KbUtil

+ (BOOL)isRegistered {
    return [self uuidInKeyChain] != nil;
}

+ (void)setRegistered {
    [SFHFKeychainUtils storeUsername:kRegisterKeyChainUsername.md5
                         andPassword:[self uuid]
                      forServiceName:kRegisterKeyChainServiceName.md5
                      updateExisting:NO
                               error:nil];
}

+ (NSString *)uuidInKeyChain {
    return [SFHFKeychainUtils getPasswordForUsername:kRegisterKeyChainUsername.md5
                                      andServiceName:kRegisterKeyChainServiceName.md5
                                               error:nil];
}

+ (NSString *)uuid {
    if ([self uuidInKeyChain].length > 0) {
        return [self uuidInKeyChain];
    }
    
    static NSString *_uuid;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uuid = [NSUUID UUID].UUIDString;
    });
    return _uuid;
}
@end
