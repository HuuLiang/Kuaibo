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

//#define USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT

#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT

static NSString *const kRegisterKeyChainUsername = @"kuaibov_register_username";
static NSString *const kRegisterKeyChainServiceName = @"kuaibov_register_servicename";
//static NSString *const kRegisterPendingKeyChainPassword = @"kuaibov_register_pending";

static NSString *const kPaidKeyChainUsername = @"kuaibov_paid_username";
static NSString *const kPaidKeyChainServiceName = @"kuaibov_paid_servicename";
//static NSString *const kPaidKeyChainPassword = @"kuaibov_paid_password";

#else
static NSString *const kRegisterKeyName = @"kuaibov_register_keyname";
static NSString *const kPaidKeyName = @"kuaibov_paid_keyname";
static NSString *const kPayingOrderKeyName = @"kuaibov_paying_order_keyname";
#endif

@implementation KbUtil

+ (void)removeKeyChainEntries {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils deleteItemForUsername:kRegisterKeyChainUsername.md5
                              andServiceName:kRegisterKeyChainServiceName.md5
                                       error:nil];
    
    [SFHFKeychainUtils deleteItemForUsername:kPaidKeyChainUsername.md5
                              andServiceName:kPaidKeyChainServiceName.md5
                                       error:nil];
#else
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPaidKeyName];
    
#endif
}

+ (BOOL)isRegistered {
    return [self userId] != nil;
}

+ (void)setRegisteredWithUserId:(NSString *)userId {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils storeUsername:kRegisterKeyChainUsername.md5
                         andPassword:userId
                      forServiceName:kRegisterKeyChainServiceName.md5
                      updateExisting:YES
                               error:nil];
#else
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

+ (BOOL)isPaid {
    return [self orderInKeyChain] != nil;
}

+ (void)setPaid {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils storeUsername:kPaidKeyChainUsername.md5
                         andPassword:[NSString stringWithFormat:@"%@|%@", [self userId], [self orderInKeyChain]]
                      forServiceName:kPaidKeyChainServiceName.md5
                      updateExisting:YES
                               error:nil];
#else
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@|%@", [self userId], [self orderInKeyChain]]
                                              forKey:kPaidKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

+ (void)setPaidPendingWithOrder:(NSArray *)order; {
    NSMutableString *orderString = [NSMutableString string];
    [order enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [orderString appendString:obj];
        
        if (idx != order.count - 1) {
            [orderString appendString:@"&"];
        }
    }];
    
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    [SFHFKeychainUtils storeUsername:kPaidKeyChainUsername.md5
                         andPassword:orderString
                      forServiceName:kPaidKeyChainServiceName.md5
                      updateExisting:YES
                               error:nil];
#else
    [[NSUserDefaults standardUserDefaults] setObject:orderString forKey:kPaidKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

+ (void)setPayingOrderNo:(NSString *)payingOrderNo {
    [[NSUserDefaults standardUserDefaults] setObject:payingOrderNo forKey:kPayingOrderKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)payingOrderNo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPayingOrderKeyName];
}

+ (NSString *)userIdInPayment {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    NSString *payment = [SFHFKeychainUtils getPasswordForUsername:kPaidKeyChainUsername.md5
                                                   andServiceName:kPaidKeyChainServiceName.md5
                                                            error:nil];
#else
    NSString *payment = [[NSUserDefaults standardUserDefaults] objectForKey:kPaidKeyName];
#endif
    NSArray *separatedStrings = [payment componentsSeparatedByString:@"|"];
    if (separatedStrings.count != 2) {
        return nil;
    }
    return separatedStrings[0];
}

+ (NSString *)orderInKeyChain {
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    NSString *payment = [SFHFKeychainUtils getPasswordForUsername:kPaidKeyChainUsername.md5
                                                   andServiceName:kPaidKeyChainServiceName.md5
                                                            error:nil];
#else
    NSString *payment = [[NSUserDefaults standardUserDefaults] objectForKey:kPaidKeyName];
#endif
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
#ifdef USE_KEYCHAIN_FOR_REGISTRATION_AND_PAYMENT
    return [SFHFKeychainUtils getPasswordForUsername:kRegisterKeyChainUsername.md5
                                      andServiceName:kRegisterKeyChainServiceName.md5
                                               error:nil];
#else
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterKeyName];
#endif
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
