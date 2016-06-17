//
//  KBVideoPlayerCtroller.m
//  kuaibov
//
//  Created by ylz on 16/6/13.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KBVideoPlayerCtroller.h"
#import "KBKVideoPlayer.h"
#import "KbVideo.h"

@interface KBVideoPlayerCtroller ()

{
    KBKVideoPlayer *_videoPlayer;
    UIButton *_closeButton;
}

@end

@implementation KBVideoPlayerCtroller

- (instancetype)initWithVideo:(KbProgram *)video{
    self = [self init];
    if (self) {
        _video = video;
//        _videoLocation = videoLocation;
//        _channel = channel;
        _shouldPopupPaymentIfNotPaid = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    @weakify(self);
    KbVideo *video = (KbVideo *)self.video;
    _videoPlayer = [[KBKVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:video.videoUrl]];
    _videoPlayer.endPlayAction = ^(id sender) {
//        @strongify(self);
//        [self dismissAndPopPayment];
    };
    [self.view addSubview:_videoPlayer];
    {
        [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(30);
        }];
    }
    
    [_closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self->_videoPlayer pause];
        
//        [self payForProgram:self.video];
        [self payForProgram:self.video programLocation:self.videoLocation inChannel:self.channel];
        [self dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     [_videoPlayer startToPlay];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
