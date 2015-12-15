//
//  KbPaymentViewController.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"
#import "IpaynowPluginApi.h"
#import "KbPaymentSignModel.h"

@class KbProgram;

@interface KbPaymentViewController : kbBaseController<IpaynowPluginDelegate>

@property (nonatomic,retain) IPNPreSignMessageUtil *paymentInfo;

+ (instancetype)sharedPaymentVC;

- (void)popupPaymentInView:(UIView *)view forProgram:(KbProgram *)program;
- (void)hidePayment;
- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo ;
@end
