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
#import "NSDate+Utilities.h"
#import "KbPaymentInfo.h"
#import <AFNetworkReachabilityManager.h>
#import "KbHudManager.h"
#import "kbBaseController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

NSString *const kPaymentInfoKeyName = @"kuaibov_paymentinfo_keyname";

static NSString *const kRegisterKeyName = @"kuaibov_register_keyname";
static NSString *const kUserAccessUsername = @"kuaibov_user_access_username";
static NSString *const kUserAccessServicename = @"kuaibov_user_access_service";

static NSString *const kLaunchSeqKeyName = @"kuaibov_launchseq_keyname";


@implementation KbUtil

+ (NSString *)accessId {
    NSString *accessIdInKeyChain = [SFHFKeychainUtils getPasswordForUsername:kUserAccessUsername andServiceName:kUserAccessServicename error:nil];
    if (accessIdInKeyChain) {
        return accessIdInKeyChain;
    }
    
    accessIdInKeyChain = [NSUUID UUID].UUIDString.md5;
    [SFHFKeychainUtils storeUsername:kUserAccessUsername andPassword:accessIdInKeyChain forServiceName:kUserAccessServicename updateExisting:YES error:nil];
    return accessIdInKeyChain;
}

+ (BOOL)isRegistered {
    return [self userId] != nil;
}

+ (void)setRegisteredWithUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray<KbPaymentInfo *> *)allPaymentInfos {
    NSArray<NSDictionary *> *paymentInfoArr = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfos = [NSMutableArray array];
    [paymentInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KbPaymentInfo *paymentInfo = [KbPaymentInfo paymentInfoFromDictionary:obj];
        [paymentInfos addObject:paymentInfo];
    }];
    return paymentInfos;
}

+ (NSArray<KbPaymentInfo *> *)payingPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        KbPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == KbPaymentStatusPaying;
    }];
}

+ (NSArray<KbPaymentInfo *> *)paidNotProcessedPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        KbPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == KbPaymentStatusNotProcessed;
    }];
}

+ (KbPaymentInfo *)successfulPaymentInfo {
    return [self.allPaymentInfos bk_match:^BOOL(id obj) {
        KbPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
            return YES;
        }
        return NO;
    }];
}

+ (BOOL)isPaid {
//    return YES;
    return [self successfulPaymentInfo] != nil;
}

+ (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterKeyName];
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

+ (void)startMonitoringNetwork {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            [[KbHudManager manager] showHudWithText:@"您正在使用数据流量连接网络\n建议您连接到WIFI后观看视频"];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
+ (NSUInteger)launchSeq {
    NSNumber *launchSeq = [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchSeqKeyName];
    return launchSeq.unsignedIntegerValue;
}

+ (void)accumateLaunchSeq {
    NSUInteger launchSeq = [self launchSeq];
    [[NSUserDefaults standardUserDefaults] setObject:@(launchSeq+1) forKey:kLaunchSeqKeyName];
}

+ (NSUInteger)currentTabPageIndex {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        return tabVC.selectedIndex;
    }
    return 0;
}

+ (NSUInteger)currentSubTabPageIndex {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        if ([tabVC.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVC = (UINavigationController *)tabVC.selectedViewController;
            if ([navVC.visibleViewController isKindOfClass:[kbBaseController class]]) {
                kbBaseController *baseVC = (kbBaseController *)navVC.visibleViewController;
                return [baseVC currentIndex];
            }
        }
    }
    return NSNotFound;
}

+ (UIViewController *)currentVisibleViewController {
    UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *selectedVC = tabBarController.selectedViewController;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)selectedVC;
        return navVC.visibleViewController;
    }
    return selectedVC;
}



+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


@end
