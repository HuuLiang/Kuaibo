//
//  KbPaymentPopView.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KbPaymentAction)(KbPaymentType type);
typedef void (^KbBackAction)(void);

@interface KbPaymentPopView : UIView

@property (nonatomic,copy) KbPaymentAction paymentAction;
@property (nonatomic,copy) KbBackAction backAction;

@property (nonatomic) NSNumber *showPrice;
@property (nonatomic,readonly) CGSize contentSize;

+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;
- (void)hide;
@end
