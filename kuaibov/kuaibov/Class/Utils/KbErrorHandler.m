//
//  KbErrorHandler.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbErrorHandler.h"
#import "KbURLRequest.h"

NSString *const kNetworkErrorNotification = @"KbNetworkErrorNotification";
NSString *const kNetworkErrorCodeKey = @"KbNetworkErrorCodeKey";
NSString *const kNetworkErrorMessageKey = @"KbNetworkErrorMessageKey";

@implementation KbErrorHandler

+ (instancetype)sharedHandler {
    static KbErrorHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[KbErrorHandler alloc] init];
    });
    return _handler;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkError:) name:kNetworkErrorNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNetworkError:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    KbURLResponseStatus resp = (KbURLResponseStatus)(((NSNumber *)userInfo[kNetworkErrorCodeKey]).unsignedIntegerValue);
    
    if (resp == KbURLResponseFailedByInterface) {
        [[KbHudManager manager] showHudWithText:@"获取影片信息错误"];
    } else if (resp == KbURLResponseFailedByNetwork) {
        [[KbHudManager manager] showHudWithText:@"网络错误，请检查网络连接！"];
    }
    
}
@end
