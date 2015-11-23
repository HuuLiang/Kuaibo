//
//  KbAlipayConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/19.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"

@interface KbAlipayConfig : KbURLResponse

@property (nonatomic,retain) NSString *partner;
@property (nonatomic,retain) NSString *privateKey;
@property (nonatomic,retain) NSString *productInfo;
@property (nonatomic,retain) NSString *seller;
@property (nonatomic,retain) NSString *notifyUrl;

@end

typedef void (^KbFetchAlipayConfigCompletionHandler)(BOOL success, KbAlipayConfig *config);

@interface KbAlipayConfigModel : KbEncryptedURLRequest

- (BOOL)fetchAlipayConfigWithCompletionHandler:(KbFetchAlipayConfigCompletionHandler)handler;

@end
