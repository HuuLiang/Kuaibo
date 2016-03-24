//
//  KbPaymentConfigModel.h
//  kuaibo
//
//  Created by Sean Yue on 16/3/22.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbPaymentConfig.h"

@interface KbPaymentConfigModel : KbEncryptedURLRequest

@property (nonatomic,readonly) BOOL loaded;

+ (instancetype)sharedModel;

- (BOOL)fetchConfigWithCompletionHandler:(KbCompletionHandler)handler;

@end
