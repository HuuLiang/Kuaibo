//
//  kbBaseController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"
#import "KbVideo.h"
#import "KbRegisterPopView.h"
#import "AlipayManager.h"
#import "KbSystemConfigModel.h"
#import "AppDelegate.h"
#import "Order.h"
#import "KbProgram.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface kbBaseController ()
- (UIViewController *)playerVCWithVideo:(KbVideo *)video;
@end

@implementation kbBaseController

- (UIViewController *)playerVCWithVideo:(KbVideo *)video {
    UIViewController *retVC;
    if (NSClassFromString(@"AVPlayerViewController")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo){
                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
                               [thisPlayerVC.player play];
                           } error:nil];
        
        retVC = playerVC;
    } else {
        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
    }
    
    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
        [[aspectInfo originalInvocation] setReturnValue:&mask];
    } error:nil];
    
    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        BOOL rotate = YES;
        [[aspectInfo originalInvocation] setReturnValue:&rotate];
    } error:nil];
    return retVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HexColor(#f7f7f7);
}

- (void)switchToPlayProgram:(KbProgram *)program {
    if (![KbUtil isPaid]) {
        [self payForProgram:program shouldPopView:YES withCompletionHandler:nil];
    } else if (program.type.unsignedIntegerValue == KbProgramTypeVideo) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:program];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        //videoPlayVC.evaluateThumbnail = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(KbProgram *)program
        shouldPopView:(BOOL)popped
withCompletionHandler:(void (^)(BOOL success))handler {
    [self fetchPayPriceWithCompletionHandler:^(NSNumber *payPrice) {
        if (!payPrice) {
            if (handler) {
                handler(NO);
            }
            return ;
        }
        
#ifdef DEBUG
        CGFloat price = 0.01;
#else
        CGFloat price = payPrice.doubleValue;
#endif
        if (popped) {
            KbRegisterPopView *registerPopView = [KbRegisterPopView sharedInstance];
            registerPopView.showPrice = price;
            
            @weakify(registerPopView);
            registerPopView.action = ^{
                [self alipayPayForProgram:program price:price withCompletionHandler:^(NSUInteger result) {
                    @strongify(registerPopView);
                    if (result == PAYRESULT_SUCCESS) {
                        [registerPopView hide];
                        [[KbHudManager manager] showHudWithText:@"支付成功"];
                    }
                    if (handler) {
                        handler(result == PAYRESULT_SUCCESS);
                    }
                }];
            };
            [registerPopView showInView:self.view.window];
        } else {
            [self alipayPayForProgram:program price:price withCompletionHandler:^(NSUInteger result) {
                if (handler) {
                    handler(result == PAYRESULT_SUCCESS);
                }
            }];
        }
    }];
}

- (void)fetchPayPriceWithCompletionHandler:(void (^)(NSNumber *payPrice))handler {
    KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (handler) {
            handler (success ? @(systemConfigModel.payAmount) : nil);
        }
    }];
}

- (void)alipayPayForProgram:(KbProgram *)program
                      price:(CGFloat)price
      withCompletionHandler:(void (^)(NSUInteger result))handler {
    @weakify(self);
    
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", [KbConfig sharedConfig].channelNo, [NSUUID UUID].UUIDString];
    [[AlipayManager shareInstance] startAlipay:orderNo
                                         price:@(price).stringValue
                                    withResult:^(PAYRESULT result, Order *order) {
                                        @strongify(self);
                                        
                                        if (result == PAYRESULT_SUCCESS) {
                                            [KbUtil setPaidPendingWithOrder:@[order.tradeNO,
                                                                              order.amount,
                                                                              program.programId.stringValue ?: @"",
                                                                              program.type.stringValue ?: @"",
                                                                              program.payPointType.stringValue ?: @""]];
                                            
                                        } else if (result == PAYRESULT_FAIL) {
                                            [[KbHudManager manager] showHudWithText:@"支付失败"];
                                        } else if (result == PAYRESULT_ABANDON) {
                                            [[KbHudManager manager] showHudWithText:@"支付取消"];
                                        }
                                        
                                        if (handler) {
                                            handler(result);
                                        }
                                       
                                        [self onAlipayCallbackWithOrderId:order.tradeNO
                                                                    price:order.amount
                                                                   result:result
                                                             forProgramId:program.programId.stringValue ?: @""
                                                              programType:program.type.stringValue ?: @""
                                                             payPointType:program.payPointType.stringValue ?: @""];
                                    }];
}

- (void)onAlipayCallbackWithOrderId:(NSString *)orderId
                              price:(NSString *)price
                             result:(PAYRESULT)result
                       forProgramId:(NSString *)programId
                        programType:(NSString *)programType
                       payPointType:(NSString *)payPointType {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate alipayPaidWithOrderId:orderId
                                 price:price
                                result:result
                          forProgramId:programId
                           programType:programType
                          payPointType:payPointType];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
