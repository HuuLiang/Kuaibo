//
//  KbNetworkInfo.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KbNetworkStatus) {
    KbNetworkStatusUnknown = -1,
    KbNetworkStatusNotReachable = 0,
    KbNetworkStatusWiFi = 1,
    KbNetworkStatus2G = 2,
    KbNetworkStatus3G = 3,
    KbNetworkStatus4G = 4
};

@interface KbNetworkInfo : NSObject

@property (nonatomic,readonly) KbNetworkStatus networkStatus;
@property (nonatomic,readonly) NSString *carriarName;

+ (instancetype)sharedInfo;
- (void)startMonitoring;

@end
