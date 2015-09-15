//
//  KbUtil.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbUtil.h"
#import <SFHFKeychainUtils.h>
#import <sys/sysctl.h>

static NSString *const kRegisterKeyChainUsername = @"kuaibov_register_username";
static NSString *const kRegisterKeyChainServiceName = @"kuaibov_register_servicename";
//static NSString *const kRegisterPendingKeyChainPassword = @"kuaibov_register_pending";

static NSString *const kPaidKeyChainUsername = @"kuaibov_paid_username";
static NSString *const kPaidKeyChainServiceName = @"kuaibov_paid_servicename";
//static NSString *const kPaidKeyChainPassword = @"kuaibov_paid_password";

@implementation KbUtil

+ (void)removeKeyChainEntries {
    [SFHFKeychainUtils deleteItemForUsername:kRegisterKeyChainUsername.md5
                              andServiceName:kRegisterKeyChainServiceName.md5
                                       error:nil];
    
    [SFHFKeychainUtils deleteItemForUsername:kPaidKeyChainUsername.md5
                              andServiceName:kPaidKeyChainServiceName.md5
                                       error:nil];
}

+ (BOOL)isRegistered {
    return [self userId] != nil;
}

+ (void)setRegisteredWithUserId:(NSString *)userId {
    [SFHFKeychainUtils storeUsername:kRegisterKeyChainUsername.md5
                         andPassword:userId
                      forServiceName:kRegisterKeyChainServiceName.md5
                      updateExisting:NO
                               error:nil];
}

+ (BOOL)isPaid {
    return [self orderInKeyChain] != nil;
}

+ (void)setPaid {
    [SFHFKeychainUtils storeUsername:kPaidKeyChainUsername.md5
                         andPassword:[NSString stringWithFormat:@"%@|%@", [self userId], [self orderInKeyChain]]
                      forServiceName:kPaidKeyChainServiceName.md5
                      updateExisting:NO
                               error:nil];
}

+ (void)setPaidPendingWithOrder:(NSArray *)order; {
    NSMutableString *orderString = [NSMutableString string];
    [order enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [orderString appendString:obj];
        
        if (idx != order.count - 1) {
            [orderString appendString:@"&"];
        }
    }];
    
    [SFHFKeychainUtils storeUsername:kPaidKeyChainUsername.md5
                         andPassword:orderString
                      forServiceName:kPaidKeyChainServiceName.md5
                      updateExisting:NO
                               error:nil];
}

+ (NSString *)userIdInPayment {
    NSString *payment = [SFHFKeychainUtils getPasswordForUsername:kPaidKeyChainUsername.md5
                                                   andServiceName:kPaidKeyChainServiceName.md5
                                                            error:nil];
    NSArray *separatedStrings = [payment componentsSeparatedByString:@"|"];
    if (separatedStrings.count != 2) {
        return nil;
    }
    return separatedStrings[0];
}

+ (NSString *)orderInKeyChain {
    NSString *payment = [SFHFKeychainUtils getPasswordForUsername:kPaidKeyChainUsername.md5
                                                   andServiceName:kPaidKeyChainServiceName.md5
                                                            error:nil];
    NSArray *separatedStrings = [payment componentsSeparatedByString:@"|"];
    return separatedStrings.lastObject;
}

+ (NSArray *)orderForSavePending {
    if ([self userIdInPayment]) {
        return nil; // already saved
    }
    
    return [[self orderInKeyChain] componentsSeparatedByString:@"&"];
}

+ (NSString *)userId {
    return [SFHFKeychainUtils getPasswordForUsername:kRegisterKeyChainUsername.md5
                                      andServiceName:kRegisterKeyChainServiceName.md5
                                               error:nil];
//    if ([self userIdInKeyChain].length > 0) {
//        return [self userIdInKeyChain];
//    }
//    
//    if ([self userIdInPayment].length > 0) {
//        return [self userIdInPayment];
//    }
//    static NSString *_uuid;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _uuid = [NSUUID UUID].UUIDString;
//    });
//    return _uuid;
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)appId {
    return @"QUBA_2001";
}
@end
