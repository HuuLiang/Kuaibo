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
@property (nonatomic,retain) UIViewController *embeddedPlayerVC;
@property (nonatomic,retain) UIViewController *helperVC;
@end

@implementation KbVideoPlayViewController

DefineLazyPropertyInitialization(UIViewController, helperVC)

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
    
    UIView *videoView;
    if (NSClassFromString(@"AVPlayerViewController")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.video.videoUrl]];
        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo){
                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
                               [thisPlayerVC.player play];
                           } error:nil];
        
        [playerVC aspect_hookSelector:@selector(viewWillLayoutSubviews)
                          withOptions:AspectPositionAfter
                           usingBlock:^(id<AspectInfo> aspectInfo){
                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
                               if (CGSizeEqualToSize(thisPlayerVC.contentOverlayView.bounds.size, [UIScreen mainScreen].bounds.size)) {
                                   
                               }
                           } error:nil];
        self.embeddedPlayerVC = playerVC;
        
        [self addChildViewController:self.embeddedPlayerVC];
        [self.view addSubview:self.embeddedPlayerVC.view];
        [self.embeddedPlayerVC didMoveToParentViewController:self];
        
        videoView = self.embeddedPlayerVC.view;
    } else {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.backgroundColor = [UIColor blackColor];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbnailImageView.userInteractionEnabled = YES;
        [_thumbnailImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionPlayVideo)]];
        videoView = _thumbnailImageView;
    }

    [self.view addSubview:videoView];
    {
        [videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.top.equalTo(self.view);
            make.height.equalTo(videoView.mas_width).with.dividedBy(1.6);
        }];
    }
    
    _descLabel = [[UILabel alloc] init];
    _descLabel.text = self.video.specialDesc;
    [self.view addSubview:_descLabel];
    {
        [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 10, 0, 10));
            make.top.equalTo(videoView.mas_bottom).with.offset(10);
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
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
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.video.videoUrl]];
    [playerVC aspect_hookSelector:@selector(shouldAutorotate)
                      withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
                          BOOL rotated = YES;
                          [[aspectInfo originalInvocation] setReturnValue:&rotated];
                      } error:nil];
    
    [playerVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
        NSUInteger ret = UIInterfaceOrientationMaskLandscapeLeft;
        [[aspectInfo originalInvocation] setReturnValue:&ret];
    } error:nil];
    
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

- (BOOL)shouldAutorotate {
    if (self.embeddedPlayerVC) {
        AVPlayerViewController *playerVC = (AVPlayerViewController *)self.embeddedPlayerVC;
        
        if (CGRectEqualToRect(playerVC.contentOverlayView.frame, [UIScreen mainScreen].bounds)) {
            return YES;
        }
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
