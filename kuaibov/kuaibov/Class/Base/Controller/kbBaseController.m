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

@interface kbBaseController ()

@end

@implementation kbBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HexColor(#f7f7f7);
}

- (void)switchToPlayVideo:(KbVideo *)video {
    if (![KbUtil isRegistered]) {
        [self showRegisterView];
    } else if (video) {
        KbVideoPlayViewController *videoPlayVC = [[KbVideoPlayViewController alloc] initWithVideo:video];
        //videoPlayVC.evaluateThumbnail = YES;
        [self.navigationController pushViewController:videoPlayVC animated:YES];
    }
}

- (void)showRegisterView {
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
                                                     price:@(systemConfigModel.payAmount).stringValue
                                                withResult:^(PAYRESULT result, Order *order) {
                                                    if (result == PAYRESULT_SUCCESS) {
                                                        [KbUtil setRegistered];
                                                        [registerPopView showRegisteredContent];
                                                    } else {
                                                        [[KbHudManager manager] showHudWithText:@"支付失败"];
                                                    }
                                                }];
                
            };
            registerPopView.showPrice = systemConfigModel.payAmount;
            [registerPopView showInView:self.view.window];
        }
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
