//
//  AppDelegate.h
//  kuaibov
//
//  Created by ZHANGPENG on 21/8/15.
//  Copyright (c) 2015 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)paidWithOrderId:(NSString *)orderId
                  price:(NSString *)price
                 result:(NSInteger)result
           forProgramId:(NSString *)programId
            programType:(NSString *)programType
           payPointType:(NSString *)payPointType
            paymentType:(KbPaymentType)paymentType;

@end

