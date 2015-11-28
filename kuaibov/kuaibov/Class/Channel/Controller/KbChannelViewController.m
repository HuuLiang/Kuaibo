//
//  KbChannelViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbChannelViewController.h"
#import "KbChannelModel.h"
#import "KbProgramViewController.h"
#import "KbSystemConfigModel.h"

static NSString *const kChannelCellReusableIdentifier = @"ChannelCollectionViewCellReusableIdentifier";
static const CGFloat kChannelThumbnailScale = 342.0 / 197.0;

@interface KbChannelViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImageView *_headerImageView;
    UICollectionView *_channelsView;
}
@property (nonatomic,retain) KbChannelModel *channelModel;
@property (nonatomic,retain) NSArray *videoChannels;
@end

@implementation KbChannelViewController

DefineLazyPropertyInitialization(KbChannelModel, channelModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"频道";
    
    @weakify(self);
    if (![KbUtil isPaid]) {
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        _headerImageView.userInteractionEnabled = YES;
        [_headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapHeaderImage)]];
        [self.view addSubview:_headerImageView];
        {
            [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.top.equalTo(self.view);
                make.height.equalTo(_headerImageView.mas_width).with.multipliedBy(0.5);
            }];
        }
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.textColor = [UIColor redColor];
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.adjustsFontSizeToFitWidth = YES;
        [_headerImageView addSubview:priceLabel];
        {
            [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_headerImageView).offset(5);
                make.bottom.equalTo(_headerImageView.mas_centerY).offset(2);
                make.width.equalTo(_headerImageView).multipliedBy(0.08);
            }];
        }
        
        KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
        [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
            @strongify(self);
            if (success) {
                [self->_headerImageView sd_setImageWithURL:[NSURL URLWithString:systemConfigModel.channelTopImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        priceLabel.text = [NSString stringWithFormat:@"%.2f", systemConfigModel.payAmount];
                    } else {
                        priceLabel.text = nil;
                    }
                }];
            }
        }];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(6, 6, 6, 6);

    CGSize itemSize = CGSizeZero;
    itemSize.width  = (mainWidth - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / 2;
    itemSize.height = itemSize.width / kChannelThumbnailScale;
    layout.itemSize = itemSize;
    
    _channelsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _channelsView.delegate = self;
    _channelsView.dataSource = self;
    _channelsView.backgroundColor = [UIColor whiteColor];
    [_channelsView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kChannelCellReusableIdentifier];
    [self.view addSubview:_channelsView];
    {
        [_channelsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-self.adBannerHeight);
            make.top.equalTo(_headerImageView?_headerImageView.mas_bottom:self.view);
        }];
    }
    
    self.videoChannels = self.channelModel.fetchedChannels;
    
    [_channelsView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        
        [self loadChannels];
    }];
    [_channelsView kb_triggerPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([KbUtil isPaid]) {
        if (_headerImageView) {
            [_headerImageView removeFromSuperview];
            
            [_channelsView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
            }];
        }
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)loadChannels {
    @weakify(self);
    [self.channelModel fetchChannelsWithCompletionHandler:^(BOOL success, NSArray *channels) {
        @strongify(self);
        [self->_channelsView kb_endPullToRefresh];
        
        if (success) {
            NSMutableArray *videoChannels = [NSMutableArray array];
            [channels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (((KbChannel *)obj).type.unsignedIntegerValue == KbChannelTypeVideo) {
                    [videoChannels addObject:obj];
                }
            }];
            
            self.videoChannels = videoChannels;
            [self->_channelsView reloadData];
        }
    }];
}

- (void)onTapHeaderImage {
    if (![KbUtil isPaid]) {
        @weakify(self);
        [self payForProgram:nil shouldPopView:YES withCompletionHandler:^(BOOL success) {
            @strongify(self);
            if (!success) {
                return ;
            }
            
            [self didPaidSuccessfully];
        }];
    }
}

- (void)didPaidSuccessfully {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (_headerImageView) {
        [_headerImageView removeFromSuperview];
        
        [_channelsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }
}

- (void)onPaidNotification:(NSNotification *)notification {
    [super onPaidNotification:notification];
    [self didPaidSuccessfully];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegateFlowLayout

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoChannels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelCellReusableIdentifier forIndexPath:indexPath];
    
    if (!cell.backgroundView) {
        cell.backgroundView = [[UIImageView alloc] initWithFrame:cell.bounds];
    }
    
    KbChannel *channel = self.videoChannels[indexPath.row];
    UIImageView *channelImageView = (UIImageView *)cell.backgroundView;
    [channelImageView sd_setImageWithURL:[NSURL URLWithString:channel.columnImg]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KbChannel *selectedChannel = self.videoChannels[indexPath.row];
    if (selectedChannel) {
        KbProgramViewController *programVC = [[KbProgramViewController alloc] initWithChannel:selectedChannel];
        programVC.bottomAdBanner = YES;
        programVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:programVC animated:YES];
    }
}

@end
