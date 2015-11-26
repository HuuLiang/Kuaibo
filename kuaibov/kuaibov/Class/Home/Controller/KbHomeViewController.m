//
//  KbHomeViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeViewController.h"
#import "KbHomeBannerModel.h"
#import "KbHomeProgramModel.h"
#import "KbHomeSectionHeaderView.h"
#import "KbHomeCollectionViewLayout.h"
#import "KbHomeProgramCell.h"
#import <SDCycleScrollView.h>

@interface KbHomeViewController () <UICollectionViewDataSource,KbHomeCollectionViewLayoutDelegate,SDCycleScrollViewDelegate>
{
    UICollectionView *_collectionView;
    
    UICollectionViewCell *_bannerCell;
    SDCycleScrollView *_bannerView;
}
@property (nonatomic,retain) KbHomeBannerModel *bannerModel;
@property (nonatomic,retain) KbHomeProgramModel *programModel;
@property (nonatomic,retain,readonly) dispatch_group_t dataFetchDispatchGroup;

@property (nonatomic,retain) NSArray *videoPrograms;
@end

static NSString *const kBannerCellReusableIdentifier = @"HomeCollectionViewBannerCellReusableIdentifer";
static NSString *const kProgramCellReusableIdentifier = @"HomeCollectionViewProgramCellReusableIdentifer";
static NSString *const kHeaderViewReusableIdentifier = @"HomeCollectionViewHeaderReusableIdentifier";

@implementation KbHomeViewController
@synthesize dataFetchDispatchGroup = _dataFetchDispatchGroup;

DefineLazyPropertyInitialization(KbHomeBannerModel, bannerModel)
DefineLazyPropertyInitialization(KbHomeProgramModel, programModel)

- (dispatch_group_t)dataFetchDispatchGroup {
    if (_dataFetchDispatchGroup) {
        return _dataFetchDispatchGroup;
    }
    
    _dataFetchDispatchGroup = dispatch_group_create();
    return _dataFetchDispatchGroup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    if (!appName) {
        appName = @"快播";
    }
    
    self.title = appName;
    self.view.backgroundColor = HexColor(#f7f7f7);
    
    KbHomeCollectionViewLayout *layout = [[KbHomeCollectionViewLayout alloc] initWithDelegate:self];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = layout;
    _collectionView.backgroundColor = HexColor(#f7f7f7);
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [_collectionView registerClass:[KbHomeProgramCell class] forCellWithReuseIdentifier:kProgramCellReusableIdentifier];
    [_collectionView registerClass:[KbHomeSectionHeaderView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewReusableIdentifier];
    [self.view addSubview:_collectionView];
    {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-self.adBannerHeight);
        }];
    }
    
    @weakify(self);
    [_collectionView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self reloadData];
    }];
    [_collectionView kb_triggerPullToRefresh];
}

- (void)reloadData {
    dispatch_group_enter(self.dataFetchDispatchGroup);
    [self reloadBanners];
    
    dispatch_group_enter(self.dataFetchDispatchGroup);
    [self reloadPrograms];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        
        dispatch_group_wait(self.dataFetchDispatchGroup, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_collectionView kb_endPullToRefresh];
        });
    });
}

- (void)reloadBanners {
    @weakify(self);
    [self.bannerModel fetchBannersWithCompletionHandler:^(BOOL success, NSArray *banners) {
        @strongify(self);
        dispatch_group_leave(self.dataFetchDispatchGroup);
        
        if (success) {
            NSMutableArray *imageUrlGroup = [NSMutableArray array];
            NSMutableArray *titlesGroup = [NSMutableArray array];
            for (KbProgram *bannerProgram in banners) {
                if (bannerProgram.type.unsignedIntegerValue == KbProgramTypeVideo) {
                    [imageUrlGroup addObject:bannerProgram.coverImg];
                    [titlesGroup addObject:bannerProgram.title];
                }
            }
            self->_bannerView.imageURLStringsGroup = imageUrlGroup;
            self->_bannerView.titlesGroup = titlesGroup;
        }
    }];
}

- (void)reloadPrograms {
    @weakify(self);
    [self.programModel fetchHomeProgramsWithCompletionHandler:^(BOOL success, NSArray *programs) {
        @strongify(self);
        dispatch_group_leave(self.dataFetchDispatchGroup);
        
        if (success) {
            NSMutableArray *videoPrograms = [NSMutableArray array];
            [programs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (((KbPrograms *)obj).type.unsignedIntegerValue == KbProgramTypeVideo) {
                    [videoPrograms addObject:obj];
                }
            }];
            
            self.videoPrograms = videoPrograms;
            [self->_collectionView reloadData];
        }
    }];
}

- (KbProgram *)programOfIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    
    KbPrograms *programs = self.videoPrograms[indexPath.section-1];
    return programs.programList[indexPath.item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.videoPrograms.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        KbPrograms *programs = self.videoPrograms[section-1];
        return programs.programList.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!_bannerCell) {
            _bannerCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellReusableIdentifier forIndexPath:indexPath];
            
            _bannerView = [[SDCycleScrollView alloc] init];
            _bannerView.autoScrollTimeInterval = 3;
            _bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
            _bannerView.delegate = self;
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
        KbHomeProgramCell *programCell = [collectionView dequeueReusableCellWithReuseIdentifier:kProgramCellReusableIdentifier forIndexPath:indexPath];

        KbProgram *program = [self programOfIndexPath:indexPath];
        programCell.imageURL = [NSURL URLWithString:program.coverImg];
        programCell.titleText = program.title;
        programCell.detailText = program.specialDesc;
        return programCell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    
    KbHomeSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewReusableIdentifier forIndexPath:indexPath];
    
    KbPrograms *programs = self.videoPrograms[indexPath.section-1];
    headerView.title = programs.name;
    return headerView;
}

#pragma mark - KbHomeCollectionViewLayoutDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KbProgram *program = [self programOfIndexPath:indexPath];
    [self switchToPlayProgram:program];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    KbProgram *bannerProgram = self.bannerModel.fetchedBanners[index];
    [self switchToPlayProgram:bannerProgram];
}
@end
