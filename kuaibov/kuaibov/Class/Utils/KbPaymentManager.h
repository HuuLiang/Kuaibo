//
//  KbPaymentManager.h
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KbChannels;

@class KbProgram;

typedef void (^KbPaymentCompletionHandler)(PAYRESULT payResult, KbPaymentInfo *paymentInfo);

@interface KbPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;
- (KbPaymentInfo *)startPaymentWithType:(KbPaymentType)type
                     subType:(KbSubPayType)subType
                       price:(NSUInteger)price
                  forProgram:(KbProgram *)program
             programLocation:(NSUInteger)programLocation
                   inChannel:(KbChannels *)channel
           completionHandler:(KbPaymentCompletionHandler)handler;

- (void)handleOpenURL:(NSURL *)url;
//- (void)checkPayment;

- (KbPaymentType)wechatPaymentType;
- (KbPaymentType)alipayPaymentType;
- (KbPaymentType)cardPayPaymentType;
- (KbPaymentType)qqPaymentType;

@end
