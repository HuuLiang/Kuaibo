//
//  KbPaymentPopView.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KbPaymentType) {
    KbPaymentTypeNone,
    KbPaymentTypeAlipay,
    KbPaymentTypeWeChatPay
};

typedef void (^KbPaymentAction)(KbPaymentType type);

@interface KbPaymentPopView : UIView

@property (nonatomic,copy) KbPaymentAction action;
@property (nonatomic) double showPrice;

+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;
- (void)hide;
@end
