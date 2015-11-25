//
//  kbBaseController.h
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

@class KbProgram;

@interface kbBaseController : UIViewController

@property (nonatomic) BOOL bottomAdBanner;
@property (nonatomic) CGFloat adBannerHeight;

- (instancetype)initWithBottomAdBanner:(BOOL)hasBanner;

- (void)switchToPlayProgram:(KbProgram *)program;
- (void)payForProgram:(KbProgram *)program
        shouldPopView:(BOOL)popped
withCompletionHandler:(void (^)(BOOL success))handler;
- (void)onPaidNotification:(NSNotification *)notification;

@end
