//
//  KbNetworkInfo.m
//  Kbuaibo
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbNetworkInfo.h"
#import <AFNetworking.h>

@import SystemConfiguration;
@import CoreTelephony;

@interface KbNetworkInfo ()
@property (nonatomic,retain,readonly) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation KbNetworkInfo
@synthesize networkInfo = _networkInfo;

DefineLazyPropertyInitialization(CTTelephonyNetworkInfo, networkInfo)

+ (instancetype)sharedInfo {
    static KbNetworkInfo *_sharedInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[self alloc] init];
    });
    return _sharedInfo;
}

- (void)startMonitoring {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (KbNetworkStatus)networkStatus {
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable) {
        return KbNetworkStatusNotReachable;
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return KbNetworkStatusWiFi;
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        NSString *radioAccess = self.networkInfo.currentRadioAccessTechnology;
        if ([radioAccess isEqualToString:CTRadioAccessTechnologyGPRS]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyEdge]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return KbNetworkStatus2G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyWCDMA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSDPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSUPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return KbNetworkStatus3G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyLTE]) {
            return KbNetworkStatus4G;
        }
    }
    return KbNetworkStatusUnknown;
}

- (NSString *)carriarName {
    return self.networkInfo.subscriberCellularProvider.carrierName;
}
@end
