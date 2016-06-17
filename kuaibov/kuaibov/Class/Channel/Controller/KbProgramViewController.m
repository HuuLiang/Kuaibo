//
//  KbProgramViewController.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbProgramViewController.h"
#import "KbChannel.h"
#import "KbChannelProgramModel.h"
#import "KbProgramCell.h"

static const NSUInteger kDefaultPageSize = 10;
static NSString *const kProgramCellReusableIdentifier = @"ProgramCellReusableIdentifier";
static const CGFloat kThumbnailScale = 230. / 168.;

@interface KbProgramViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    //UITableView *_programTableView;
    UICollectionView *_layoutCollectionView;
}
@property (nonatomic,retain) KbChannel *channel;
@property (nonatomic,retain) KbChannelProgramModel *programModel;

@property (nonatomic,retain) NSMutableArray *programs;
@property (nonatomic) NSUInteger currentPage;
@end

@implementation KbProgramViewController

DefineLazyPropertyInitialization(KbChannelProgramModel, programModel)
DefineLazyPropertyInitialization(NSMutableArray, programs)

- (instancetype)initWithChannel:(KbChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _channel.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kDefaultItemSpacing;
    layout.minimumLineSpacing = kDefaultItemSpacing;
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.backgroundColor = [UIColor whiteColor];
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[KbProgramCell class] forCellWithReuseIdentifier:kProgramCellReusableIdentifier];
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCollectionView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        
        self.currentPage = 0;
        [self.programs removeAllObjects];
        [self loadPrograms];
    }];
    [_layoutCollectionView kb_triggerPullToRefresh];
    
    [_layoutCollectionView kb_addPagingRefreshWithHandler:^{
        @strongify(self);
        [self loadPrograms];
    }];
}

- (void)loadPrograms {
    @weakify(self);
    [self.programModel fetchProgramsWithColumnId:self.channel.columnId
                                          pageNo:++self.currentPage
                                        pageSize:kDefaultPageSize
                               completionHandler:^(BOOL success, KbChannelPrograms *programs) {
                                   @strongify(self);
                                   
                                   if (success && programs.programList) {
                                       NSUInteger prevCount = self.programs.count;
                                       [self.programs addObjectsFromArray:programs.programList];
                                       
                                       NSMutableArray *indexPaths = [NSMutableArray array];
                                       for (NSUInteger i = 0; i < programs.programList.count; ++i) {
                                           [indexPaths addObject:[NSIndexPath indexPathForRow:i+prevCount inSection:0]];
                                       }
                                       
                                       if (prevCount == 0) {
                                           [self->_layoutCollectionView reloadData];
                                       } else if (indexPaths.count > 0) {
                                           [self->_layoutCollectionView insertItemsAtIndexPaths:indexPaths];
                                       }
                                   }
                                   
                                   [self->_layoutCollectionView kb_endPullToRefresh];
                                   
                                   if (self.programs.count >= programs.items.unsignedIntegerValue) {
                                       [self->_layoutCollectionView kb_pagingRefreshNoMoreData];
                                   }
                               }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (KbChannelProgram *)channelProgramOfIndexPath:(NSIndexPath *)indexPath {
    return self.programs[indexPath.row];
}

#pragma mark - Collection View Delegate & DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KbProgramCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProgramCellReusableIdentifier forIndexPath:indexPath];
    
    KbChannelProgram *program = [self channelProgramOfIndexPath:indexPath];
    cell.titleText = program.title;
    cell.detailText = program.specialDesc;
    cell.imageURL = [NSURL URLWithString:program.coverImg];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.programs.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat itemWidth = (CGRectGetWidth(collectionView.bounds) - kDefaultItemSpacing) / 2;
    const CGFloat itemHeight = itemWidth / kThumbnailScale;
    return CGSizeMake(itemWidth, itemHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KbChannelProgram *program = [self channelProgramOfIndexPath:indexPath];
    //    [self switchToPlayProgram:program];
    [self switchToPlayProgram:program programLocation:indexPath.item inChannel:_programModel.fetchedPrograms];
    [[KbStatsManager sharedManager] statsCPCWithProgram:program programLocation:indexPath.item inChannel:_programModel.fetchedPrograms andTabIndex:1 subTabIndex:[KbUtil currentSubTabPageIndex]];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[KbStatsManager sharedManager] statsTabIndex:1 subTabIndex:[KbUtil currentSubTabPageIndex] forSlideCount:1];
}

@end
