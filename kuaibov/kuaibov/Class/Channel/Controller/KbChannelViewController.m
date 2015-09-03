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

static NSString *const kChannelCellReusableIdentifier = @"ChannelCollectionViewCellReusableIdentifier";
static const CGFloat kChannelThumbnailScale = 342.0 / 197.0;

@interface KbChannelViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImageView *_headerImageView;
    UICollectionView *_channelsView;
}
@property (nonatomic,retain) KbChannelModel *channelModel;

@end

@implementation KbChannelViewController

DefineLazyPropertyInitialization(KbChannelModel, channelModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.view addSubview:_headerImageView];
    {
        [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.and.right.equalTo(self.view);
            make.height.equalTo(_headerImageView.mas_width).with.multipliedBy(0.5);
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
            make.left.bottom.and.right.equalTo(self.view);
            make.top.equalTo(_headerImageView.mas_bottom);
        }];
    }
    
    [self loadChannels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)loadChannels {
    @weakify(self);
    [self.channelModel fetchChannelsWithCompletionHandler:^(NSArray *channels) {
        @strongify(self);
        if (channels) {
            [self->_channelsView reloadData];
        }
    }];
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
    return self.channelModel.fetchedChannels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelCellReusableIdentifier forIndexPath:indexPath];
    
    if (!cell.backgroundView) {
        cell.backgroundView = [[UIImageView alloc] initWithFrame:cell.bounds];
    }
    
    KbChannel *channel = self.channelModel.fetchedChannels[indexPath.row];
    UIImageView *channelImageView = (UIImageView *)cell.backgroundView;
    [channelImageView sd_setImageWithURL:[NSURL URLWithString:channel.columnImg]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KbChannel *selectedChannel = self.channelModel.fetchedChannels[indexPath.row];
    if (selectedChannel) {
        KbProgramViewController *programVC = [[KbProgramViewController alloc] initWithChannel:selectedChannel];
        [self.navigationController pushViewController:programVC animated:YES];
    }
}

@end
