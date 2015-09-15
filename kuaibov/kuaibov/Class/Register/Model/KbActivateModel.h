//
//  KbActivateModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"

typedef void (^KbActivateHandler)(BOOL success, NSString *userId);

@interface KbActivateModel : KbEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)activateWithCompletionHandler:(KbActivateHandler)handler;

@end
