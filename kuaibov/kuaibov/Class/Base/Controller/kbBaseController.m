//
//  kbBaseController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"
#import "KbVideo.h"
#import "KbVideoPlayViewController.h"
#import "KbRegisterPopView.h"
#import "AlipayManager.h"
#import "KbSystemConfigModel.h"
#import "AppDelegate.h"
#import "Order.h"
#import "KbProgram.h"

@interface kbBaseController ()

@end

@implementation kbBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HexColor(#f7f7f7);
}

- (void)switchToPlayProgram:(KbProgram *)program {
    if (![KbUtil isPaid]) {
        [self showRegisterViewForProgram:program];
    } else if (program) {
        KbVideoPlayViewController *videoPlayVC = [[KbVideoPlayViewController alloc] initWithVideo:(KbVideo *)program];
        //videoPlayVC.evaluateThumbnail = YES;
        [self.navigationController pushViewController:videoPlayVC animated:YES];
    }
}

- (void)showRegisterViewForProgram:(KbProgram *)program {
    KbRegisterPopView *registerPopView = [KbRegisterPopView sharedInstance];
    KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (!success) {
            return ;
        }
        
        if (systemConfigModel.payAmount > 0) {
            @weakify(registerPopView);
            registerPopView.action = ^{
                @strongify(registerPopView);
                
                [[AlipayManager shareInstance] startAlipay:[NSUUID UUID].UUIDString
                                                     price:@"0.01"//@(systemConfigModel.payAmount).stringValue
                                                withResult:^(PAYRESULT result, Order *order) {
                                                    if (result == PAYRESULT_SUCCESS) {
                                                        [KbUtil setPaidPendingWithOrder:@[order.tradeNO,
                                                                                          order.amount,
                                                                                          program.programId.stringValue,
                                                                                          program.type.stringValue,
                                                                                          program.payPointType.stringValue]];
                                                        [registerPopView showRegisteredContent];
                                                    } else if (result == PAYRESULT_FAIL) {
                                                        [[KbHudManager manager] showHudWithText:@"支付失败"];
                                                    } else if (result == PAYRESULT_ABANDON) {
                                                        [[KbHudManager manager] showHudWithText:@"支付取消"];
                                                    }
                                                    
                                                    [self onAlipayCallbackWithOrderId:order.tradeNO
                                                                                price:order.amount
                                                                               result:result
                                                                         forProgramId:program.programId.stringValue
                                                                          programType:program.type.stringValue
                                                                         payPointType:program.payPointType.stringValue];
                                                }];
                
            };
            registerPopView.showPrice = systemConfigModel.payAmount;
            [registerPopView showInView:self.view.window];
        }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
