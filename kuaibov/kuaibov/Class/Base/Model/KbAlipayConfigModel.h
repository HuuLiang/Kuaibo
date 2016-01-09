//
//  KbAlipayConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/19.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbAlipayConfig.h"

@interface KbAlipayConfigModel : KbEncryptedURLRequest

@property (nonatomic,readonly,retain) KbAlipayConfig *fetchedConfig;

+ (instancetype)sharedModel;
- (BOOL)fetchAlipayConfigWithCompletionHandler:(KbCompletionHandler)handler;

@end
