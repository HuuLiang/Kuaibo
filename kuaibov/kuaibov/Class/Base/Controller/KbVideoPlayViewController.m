//
//  KbVideoPlayViewController.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbVideoPlayViewController.h"
#import "KbVideo.h"
@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

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
    
    @weakify(self);
    [_thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.video.coverImg] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (self.evaluateThumbnail) {
            [self evaluateVideo];
        }
    }];
}

- (void)evaluateVideo {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:self.video.videoUrl] options:nil];
        Float64 duration = CMTimeGetSeconds(urlAsset.duration);
        
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
        
        NSMutableArray *thumbnails = [NSMutableArray array];
        NSUInteger stepSeconds = duration / 6;
        for (NSUInteger i = stepSeconds; i < duration - stepSeconds; i += stepSeconds) {
            CGImageRef imageRef = [generator copyCGImageAtTime:CMTimeMake(i, 1) actualTime:nil error:nil];
            [thumbnails addObject:[UIImage imageWithCGImage:imageRef]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self->_thumbnailImageView.image = [UIImage animatedImageWithImages:thumbnails duration:thumbnails.count];
        });
    });
}

- (void)actionPlayVideo {
    if (NSClassFromString(@"AVPlayerViewController")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.video.videoUrl]];

        [self presentViewController:playerVC animated:YES completion:^{
            [playerVC.player play];
        }];

    } else {
        MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc]
                                                 initWithContentURL:[NSURL URLWithString:self.video.videoUrl]];
        [self presentMoviePlayerViewControllerAnimated:playerVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
