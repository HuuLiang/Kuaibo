//
//  kbBaseController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"
#import "KbVideo.h"
#import "AppDelegate.h"
#import "KbProgram.h"
#import "MobClick.h"
#import "KbPaymentViewController.h"
#import "KBVideoPlayerCtroller.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface kbBaseController ()

- (UIViewController *)playerVCWithVideo:(KbVideo *)video;
@end

@implementation kbBaseController
- (NSUInteger)currentIndex {
    return NSNotFound;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)switchToPlayProgram:(KbProgram *)program programLocation:(NSInteger)programLocation inChannel:(KbChannels *)channel{
    if (![KbUtil isPaid]) {
//        [self payForProgram:program];
        [self payForProgram:program programLocation:programLocation inChannel:channel];
    } else if (program.type.unsignedIntegerValue == KbProgramTypeVideo) {
        UIViewController *videoPlayVC = [self playerVCWithVideo:program];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    } 
}

/**
 *  免费试播
 */

- (void)switchToPlayFreeVideoProgram:(KbProgram*)program channel:(KbChannels *)channel programLocation:(NSInteger)programLocation {
 
    KBVideoPlayerCtroller *videoPlayer = [[KBVideoPlayerCtroller alloc] initWithVideo:program];
    videoPlayer.hidesBottomBarWhenPushed = YES;
    videoPlayer.shouldPopupPaymentIfNotPaid = YES;
    videoPlayer.channel = channel;
    videoPlayer.videoLocation = programLocation;
    [self presentViewController:videoPlayer animated:YES completion:nil];
}



- (void)payForProgram:(KbProgram *)program programLocation:(NSInteger)programLocation inChannel:(KbChannels *)channel{
//    [[KbPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:program];
    [[KbPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:program programLocation:programLocation inChannel:channel];
}


- (void)onPaidNotification:(NSNotification *)notification {}

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
