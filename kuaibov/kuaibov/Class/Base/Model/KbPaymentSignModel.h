//
//  KbPaymentSignModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/8.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#ifdef __KB_PAYMENT_SIGN__

#import "KbEncryptedURLRequest.h"

@class IPNPreSignMessageUtil;

typedef void (^KbPaymentSignCompletionHandler)(BOOL success, NSString *signedData);

@interface KbPaymentSignModel : KbEncryptedURLRequest

@property (nonatomic,retain,readonly) NSString *appId;
@property (nonatomic,retain,readonly) NSString *notifyUrl;
@property (nonatomic,retain,readonly) NSString *signature;

+ (instancetype)sharedModel;

- (BOOL)signWithPreSignMessage:(IPNPreSignMessageUtil *)preSign completionHandler:(KbPaymentSignCompletionHandler)handler;

@end
#endif