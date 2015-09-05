//
//  KbHomeViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeViewController.h"
#import "KbHomeBannerModel.h"
#import "KbBannerView.h"
#import "KbHomeSectionHeaderView.h"
#import "KbHomeCollectionViewLayout.h"

@interface KbHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    UICollectionViewCell *_bannerCell;
    KbBannerView *_bannerView;
}
@property (nonatomic,retain) KbHomeBannerModel *bannerModel;
@end

static NSString *const kBannerCellReusableIdentifier = @"HomeCollectionViewBannerCellReusableIdentifer";
static NSString *const kNormalCellReusableIdentifier = @"HomeCollectionViewNormalCellReusableIdentifer";
static NSString *const kHeaderViewReusableIdentifier = @"HomeCollectionViewHeaderReusableIdentifier";

@implementation KbHomeViewController

DefineLazyPropertyInitialization(KbHomeBannerModel, bannerModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"快播";
    self.view.backgroundColor = HexColor(#f7f7f7);
    
    KbHomeCollectionViewLayout *layout = [[KbHomeCollectionViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = layout;
    _collectionView.backgroundColor = HexColor(#f7f7f7);
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kNormalCellReusableIdentifier];
    [_collectionView registerClass:[KbHomeSectionHeaderView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewReusableIdentifier];
    [self.view addSubview:_collectionView];
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self reloadData];
}

- (void)reloadData {
    @weakify(self);
    [self.bannerModel fetchBannersWithCompletionHandler:^(BOOL success, NSArray *banners) {
        @strongify(self);
        
        if (success) {
            NSMutableArray *bannerItems = [NSMutableArray array];
            for (KbBannerData *bannerData in banners) {
                [bannerItems addObject:[KbBannerItem itemWithImageURLString:bannerData.coverImg title:bannerData.title]];
            }
            self->_bannerView.items = bannerItems;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!_bannerCell) {
            _bannerCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellReusableIdentifier forIndexPath:indexPath];
            
            _bannerView = [[KbBannerView alloc] initWithItems:nil autoPlayTimeInterval:3.0];
            _bannerView.backgroundColor = [UIColor whiteColor];
            [_bannerCell.contentView addSubview:_bannerView];
            {
                [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(_bannerCell.contentView);
                }];
            }
        }
        
        return _bannerCell;
        
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNormalCellReusableIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor redColor];
        return cell;
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        KbHomeSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewReusableIdentifier forIndexPath:indexPath];
        headerView.title = @"今日推荐";
        return headerView;
    }
    return nil;
}



@end
