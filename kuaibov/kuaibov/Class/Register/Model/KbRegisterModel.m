//
//  KbRegisterModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/9.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbRegisterModel.h"

@implementation KbRegisterModel

+ (instancetype)sharedModel {
    static KbRegisterModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[KbRegisterModel alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [NSString class];
}

- (BOOL)requestRegisterWithCompletionHandler:(KbRegisterHandler)handler {
    NSDictionary *params = @{};
    
    BOOL success = [self requestURLPath:[KbConfig sharedConfig].registerURLPath withParams:params responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        if (handler) {
            handler(respStatus == KbURLResponseSuccess);
        }
    }];
    return success;
}

@end
