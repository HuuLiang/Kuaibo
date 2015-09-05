//
//  KbVideoPlayViewController.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbVideoPlayViewController.h"
#import "KbVideo.h"
#import <MediaPlayer/MediaPlayer.h>

@interface KbVideoPlayViewController ()
{
    UIImageView *_thumbnailImageView;
    UILabel *_descLabel;
}
@property (nonatomic,retain) KbVideo *video;
@end

@implementation KbVideoPlayViewController

- (instancetype)initWithVideo:(KbVideo *)video {
    self = [super init];
    if (self) {
        _video = video;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.video.title;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _thumbnailImageView = [[UIImageView alloc] init];
    _thumbnailImageView.backgroundColor = [UIColor blackColor];
    [_thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.video.coverImg]];
    _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    _thumbnailImageView.userInteractionEnabled = YES;
    [_thumbnailImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionPlayVideo)]];
    [self.view addSubview:_thumbnailImageView];
    {
        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.top.equalTo(self.view);
            make.height.equalTo(_thumbnailImageView.mas_width).with.dividedBy(1.6);
        }];
    }
    
    _descLabel = [[UILabel alloc] init];
    _descLabel.text = self.video.specialDesc;
    [self.view addSubview:_descLabel];
    {
        [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 10, 0, 10));
            make.top.equalTo(_thumbnailImageView.mas_bottom).with.offset(10);
        }];
    }
}

- (void)actionPlayVideo {
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc]
                                             initWithContentURL:[NSURL URLWithString:self.video.videoUrl]];
    playerVC.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:nil];
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
