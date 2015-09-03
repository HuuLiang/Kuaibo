//
//  KbChannelViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbChannelViewController.h"

static NSString *const kChannelCellReusableIdentifier = @"ChannelCollectionViewCellReusableIdentifier";

@interface KbChannelViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImageView *_headerImageView;
    UICollectionView *_channelsView;
}
@end

@implementation KbChannelViewController

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
    //layout.itemSize = CGSizeMake(mainWidth / 2 - 15, mainWidth / 2 - 15);
    CGSize itemSize = CGSizeZero;
    itemSize.width = itemSize.height = (mainWidth - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / 2;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelCellReusableIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    return cell;
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
