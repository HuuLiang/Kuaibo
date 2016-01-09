//
//  KbWeChatPayConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 16/1/8.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbWeChatPayConfig.h"

@interface KbWeChatPayConfigModel : KbEncryptedURLRequest

+ (instancetype)sharedModel;
- (BOOL)fetchWeChatPayConfigWithCompletionHandler:(KbCompletionHandler)handler;

@end
