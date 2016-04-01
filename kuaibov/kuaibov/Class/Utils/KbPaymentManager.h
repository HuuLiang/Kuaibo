//
//  KbPaymentManager.h
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KbProgram;

typedef void (^KbPaymentCompletionHandler)(PAYRESULT payResult, KbPaymentInfo *paymentInfo);

@interface KbPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;
- (BOOL)startPaymentWithType:(KbPaymentType)type
                     subType:(KbPaymentType)subType
                       price:(NSUInteger)price
                  forProgram:(KbProgram *)program
           completionHandler:(KbPaymentCompletionHandler)handler;

- (void)handleOpenURL:(NSURL *)url;
- (void)checkPayment;

@end
