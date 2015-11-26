//
//  KbUserAccessModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"

typedef void (^KbUserAccessCompletionHandler)(BOOL success);

@interface KbUserAccessModel : KbEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)requestUserAccess;

@end
