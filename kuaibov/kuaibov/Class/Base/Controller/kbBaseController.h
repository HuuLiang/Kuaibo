//
//  kbBaseController.h
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

@class KbProgram;

@interface kbBaseController : UIViewController

//- (void)switchToPlayProgram:(KbProgram *)program;
- (void)switchToPlayProgram:(KbProgram *)program programLocation:(NSInteger)programLocation inChannel:(KbChannels *)channel;

//- (void)payForProgram:(KbProgram *)program;
- (void)payForProgram:(KbProgram *)program programLocation:(NSInteger)programLocation inChannel:(KbChannels *)channel;
- (void)onPaidNotification:(NSNotification *)notification;

- (void)switchToPlayFreeVideoProgram:(KbProgram*)program;

- (NSUInteger)currentIndex;
@end
