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
    [self createBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
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
    
    self.videoPrograms = self.programModel.fetchedProgramList;
    
    @weakify(self);
    [_collectionView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self reloadData];
    }];
    [_collectionView kb_triggerPullToRefresh];
}

//添加点击多次的手势
-(void)createBtn{
    UIView *view=[[UIView alloc]init];
    view.frame=CGRectMake(0, 0, 30, 30);
    view.backgroundColor=[UIColor clearColor];
    view.layer.cornerRadius=10;
    view.layer.masksToBounds=YES;
    UIBarButtonItem *btnItem=[[UIBarButtonItem alloc]initWithCustomView:view];
    self.navigationItem.rightBarButtonItem=btnItem;
    //添加手势
    UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)];
    tap2.numberOfTapsRequired=5;
    [view addGestureRecognizer:tap2];
}

//添加点击多次的手势点击方法
-(void)tap2:(UITapGestureRecognizer *)tap{
    
    //    NSLog(@"被三击了");
    UIView *view=[[UIView alloc]init];
    view.frame=CGRectMake(self.view.frame.size.width/2-75, self.view.frame.size.height/2-100, 150, 200);
    view.backgroundColor=[UIColor blackColor];
    view.layer.cornerRadius=20;
    view.layer.masksToBounds=YES;
    [self.view addSubview:view];
    
    NSString *channelNo=[KbConfig sharedConfig].channelNo;//渠道号
//    NSString *appId=[KbUtil appId];//appid
    NSString *versionStr=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];//版本号
    
    UILabel *label1=[[UILabel alloc]init];
    label1.numberOfLines=0;
    label1.text=[NSString stringWithFormat:@"channelNo:%@",channelNo];
    label1.textColor=[UIColor whiteColor];
    label1.adjustsFontSizeToFitWidth=YES;
    [view addSubview:label1];
    {
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.center.equalTo(view);
            make.top.equalTo(view.mas_top).with.offset(30);
            make.left.equalTo(view.mas_left).with.offset(0);
            make.width.equalTo(@150);
            make.height.equalTo(@40);
        }];
    }
    UILabel *label2=[[UILabel alloc]init];
    label2.numberOfLines=0;
    label2.text=@"2015 11.28 16:00";
    label2.textColor=[UIColor whiteColor];
    label2.adjustsFontSizeToFitWidth=YES;
    [view addSubview:label2];
    {
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
            make.width.equalTo(@150);
            make.height.equalTo(@40);
        }];
    }
    UILabel *label3=[[UILabel alloc]init];
    label3.numberOfLines=0;
    label3.text=[NSString stringWithFormat:@"Version:%@",versionStr];
    label3.textColor=[UIColor whiteColor];
    label3.adjustsFontSizeToFitWidth=YES;
    [view addSubview:label3];
    {
        [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(view.mas_bottom).with.offset(-30);
            make.left.equalTo(view.mas_left).with.offset(0);
            make.width.equalTo(@150);
            make.height.equalTo(@40);
        }];
    }
    
    [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        view.alpha=0;
    } completion:^(BOOL finished) {
        //
        [view removeFromSuperview];
    }];
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
            
            NSMutableArray *imageUrlGroup = [NSMutableArray array];
            NSMutableArray *titlesGroup = [NSMutableArray array];
            for (KbProgram *bannerProgram in self.bannerModel.fetchedBanners) {
                if (bannerProgram.type.unsignedIntegerValue == KbProgramTypeVideo) {
                    [imageUrlGroup addObject:bannerProgram.coverImg];
                    [titlesGroup addObject:bannerProgram.title];
                }
            }
            _bannerView.imageURLStringsGroup = imageUrlGroup;
            _bannerView.titlesGroup = titlesGroup;
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
