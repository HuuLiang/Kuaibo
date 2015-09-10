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
    return [self userIdInKeyChain] != nil;
}

+ (void)setRegistered {
    [SFHFKeychainUtils storeUsername:kRegisterKeyChainUsername.md5
                         andPassword:[self userId].md5
                      forServiceName:kRegisterKeyChainServiceName.md5
                      updateExisting:NO
                               error:nil];
}

+ (NSString *)userIdInKeyChain {
    return [SFHFKeychainUtils getPasswordForUsername:kRegisterKeyChainUsername.md5
                                      andServiceName:kRegisterKeyChainServiceName.md5
                                               error:nil];
}

+ (NSString *)userId {
    if ([self userIdInKeyChain].length > 0) {
        return [self userIdInKeyChain];
    }
    
    static NSString *_uuid;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _uuid = [NSUUID UUID].UUIDString;
    });
    return _uuid;
}
@end
