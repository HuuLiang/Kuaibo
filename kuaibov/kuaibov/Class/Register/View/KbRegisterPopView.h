//
//  KbRegisterPopView.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KbRegisterAction)(void);

@interface KbRegisterPopView : UIView

@property (nonatomic,copy) KbRegisterAction action;
@property (nonatomic) CGFloat showPrice;

+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;
- (void)showRegisteredContent;

@end
