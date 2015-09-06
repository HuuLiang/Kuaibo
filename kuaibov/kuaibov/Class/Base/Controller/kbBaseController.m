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

@interface kbBaseController ()

@end

@implementation kbBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HexColor(#f7f7f7);
}

- (void)switchToPlayVideo:(KbVideo *)video {
    if (video) {
        KbVideoPlayViewController *videoPlayVC = [[KbVideoPlayViewController alloc] initWithVideo:video];
        //videoPlayVC.evaluateThumbnail = YES;
        [self.navigationController pushViewController:videoPlayVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
