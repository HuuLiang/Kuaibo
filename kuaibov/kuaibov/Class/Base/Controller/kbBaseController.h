//
//  kbBaseController.h
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

@class KbProgram;

@interface kbBaseController : UIViewController

- (void)switchToPlayProgram:(KbProgram *)program;
- (void)showRegisterViewForProgram:(KbProgram *)program;
- (void)alipayPayForProgram:(KbProgram *)program;
- (void)onAlipaySuccessfullyPaid;

@end
