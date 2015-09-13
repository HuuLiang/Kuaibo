//
//  KbRegisterModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/9.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"

typedef void (^KbRegisterHandler)(BOOL success);

@interface KbRegisterModel : KbEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)requestRegisterWithCompletionHandler:(KbRegisterHandler)handler;

@end
