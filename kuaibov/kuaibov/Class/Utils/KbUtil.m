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
    NSString *registered = [SFHFKeychainUtils getPasswordForUsername:kRegisterKeyChainUsername.md5 andServiceName:kRegisterKeyChainServiceName.md5 error:nil];
    return registered != nil;
}

+ (void)setRegistered {
    [SFHFKeychainUtils storeUsername:kRegisterKeyChainUsername.md5
                         andPassword:kRegisterKeyChainPassword.md5
                      forServiceName:kRegisterKeyChainServiceName.md5
                      updateExisting:NO
                               error:nil];
}
@end
