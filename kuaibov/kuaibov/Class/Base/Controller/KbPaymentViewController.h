//
//  KbPaymentViewController.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"

@class KbProgram;
@class KbPaymentInfo;

@interface KbPaymentViewController : kbBaseController

+ (instancetype)sharedPaymentVC;

//- (void)popupPaymentInView:(UIView *)view forProgram:(KbProgram *)program;
- (void)popupPaymentInView:(UIView *)view forProgram:(KbProgram *)program programLocation:(NSUInteger)programLocation inChannel:(KbChannels *)channel;

- (void)hidePayment;

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(KbPaymentInfo *)paymentInfo;

@end
