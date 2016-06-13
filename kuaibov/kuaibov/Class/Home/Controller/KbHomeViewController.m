//
//  KbHomeViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeViewController.h"
#import "KbHomeProgramModel.h"
#import "KbHomeSectionHeaderView.h"
#import "KbHomeProgramCell.h"
#import <SDCycleScrollView.h>

@interface KbHomeViewController () <UITableViewDataSource,UITableViewDelegate,SDCycleScrollViewDelegate>
{
    UITableView *_layoutTableView;
    
    UITableViewCell *_bannerCell;
    SDCycleScrollView *_bannerView;
}
@property (nonatomic,retain) KbHomeProgramModel *programModel;
@property (nonatomic,retain,readonly) dispatch_group_t dataFetchDispatchGroup;
@end

static NSString *const kProgramCellReusableIdentifier = @"ProgramCellReusableIdentifier";
static NSString *const kAdBannerCellReusableIdentifier = @"AdBannerCellReusableIdentifier";
static NSString *const kSectionHeaderReusableIdentifier = @"SectionHeaderReusableIdentifier";

@implementation KbHomeViewController
@synthesize dataFetchDispatchGroup = _dataFetchDispatchGroup;

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
//    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
//    if (!appName) {
//        appName = @"快播";
//    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"首页";
    self.view.backgroundColor = HexColor(#f7f7f7);
    
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _layoutTableView.backgroundColor = [UIColor whiteColor];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.sectionFooterHeight = 0.01;
    _layoutTableView.showsVerticalScrollIndicator = NO;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[KbHomeProgramCell class] forCellReuseIdentifier:kProgramCellReusableIdentifier];
    [_layoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kAdBannerCellReusableIdentifier];
    [_layoutTableView registerClass:[KbHomeSectionHeaderView class] forHeaderFooterViewReuseIdentifier:kSectionHeaderReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    @weakify(self);
    [_layoutTableView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self reloadPrograms];
    }];
    [_layoutTableView kb_triggerPullToRefresh];
 _layoutTableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
}

- (void)reloadPrograms {
    @weakify(self);
    [self.programModel fetchHomeProgramsWithCompletionHandler:^(BOOL success, NSArray *programs) {
        @strongify(self);
        
        if (success) {
            [self->_layoutTableView reloadData];
        }
        [self->_layoutTableView kb_endPullToRefresh];
    }];
}

- (NSArray<KbProgram *> *)programsForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.programModel.fetchedBannerPrograms;
    }
    
    KbPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[indexPath.section-1];
    
    NSMutableArray *programsForCell = [NSMutableArray array];
    for (NSUInteger i = 0; i < 3; ++i) {
        NSUInteger index = indexPath.row * 3 + i;
        if (index < programs.programList.count) {
            [programsForCell addObject:programs.programList[index]];
        }
    }
    return programsForCell.count > 0 ? programsForCell : nil;
}

- (KbProgram *)adProgramAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    
    KbPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[indexPath.section-1];
    if (programs.type.unsignedIntegerValue == KbProgramTypeAd) {
        return programs.programList[indexPath.row];
    }
    return nil;
}

- (BOOL)isAdBannerInSection:(NSUInteger)section {
    if (section == 0) {
        return NO;
    }
    
    KbPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[section-1];
    return programs.type.unsignedIntegerValue == KbProgramTypeAd;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate & DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!_bannerCell) {
            _bannerCell = [[UITableViewCell alloc] init];;
            
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
        
        NSMutableArray *imageUrlGroup = [NSMutableArray array];
        NSMutableArray *titlesGroup = [NSMutableArray array];
        for (KbProgram *bannerProgram in self.programModel.fetchedBannerPrograms) {
            [imageUrlGroup addObject:bannerProgram.coverImg];
            [titlesGroup addObject:bannerProgram.title];
        }
        _bannerView.imageURLStringsGroup = imageUrlGroup;
        _bannerView.titlesGroup = titlesGroup;
        return _bannerCell;
        
    } else {
        KbProgram *adProgram = [self adProgramAtIndexPath:indexPath];
        if (adProgram) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAdBannerCellReusableIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (!cell.backgroundView) {
                UIImageView *backgroundView = [[UIImageView alloc] init];
                [backgroundView YPB_addAnimationForImageAppearing];
                cell.backgroundView = backgroundView;
            }
            
            UIImageView *backgroundView = (UIImageView *)cell.backgroundView;
            [backgroundView sd_setImageWithURL:[NSURL URLWithString:adProgram.coverImg]];
            
            [cell bk_whenTapped:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adProgram.videoUrl]];
            }];
            return cell;
        } else {
            KbHomeProgramCell *programCell = [tableView dequeueReusableCellWithIdentifier:kProgramCellReusableIdentifier forIndexPath:indexPath];
            programCell.backgroundColor = [UIColor whiteColor];
            
            NSArray<KbProgram *> *programsForCell = [self programsForCellAtIndexPath:indexPath];
            KbProgram *leftProgram = programsForCell.count > 0 ? programsForCell[0] : nil;
            KbProgram *rightTopProgram = programsForCell.count > 1 ? programsForCell[1] : nil;
            KbProgram *rightBottomProgram = programsForCell.count > 2 ? programsForCell[2] : nil;
            
            [programCell setItem:[KbHomeProgramItem itemWithImageURL:leftProgram.coverImg
                                                               title:leftProgram.title
                                                            subtitle:leftProgram.specialDesc]
                      atPosition:KbHomeProgramLeftItem];
            
            [programCell setItem:[KbHomeProgramItem itemWithImageURL:rightTopProgram.coverImg
                                                               title:rightTopProgram.title
                                                            subtitle:rightTopProgram.specialDesc]
                      atPosition:KbHomeProgramRightTopItem];
            
            [programCell setItem:[KbHomeProgramItem itemWithImageURL:rightBottomProgram.coverImg
                                                               title:rightBottomProgram.title
                                                            subtitle:rightBottomProgram.specialDesc]
                      atPosition:KbHomeProgramRightBottomItem];
            
            @weakify(self);
            programCell.action = ^(KbHomeProgramItemPosition position) {
                @strongify(self);
                
                KbPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[indexPath.section-1];
 
                NSArray<KbProgram *> *programsForCell = [self programsForCellAtIndexPath:indexPath];
                if (programsForCell.count < position) {
                    return ;
                }
                if (programs.type.unsignedIntegerValue == KBprogramTypeFreeVideo) {
                    [self switchToPlayFreeVideoProgram:programsForCell[position]];
                }else{
                    [self switchToPlayProgram:programsForCell[position]];}
            };
            return programCell;
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.programModel.fetchedVideoAndAdProgramList.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        KbPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[section-1];
        if (programs.type.unsignedIntegerValue == KbProgramTypeAd) {
            return programs.programList.count;
        } else {
            return (programs.programList.count + 2) / 3;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGRectGetWidth(tableView.bounds) / 2;
    } else if ([self isAdBannerInSection:indexPath.section]) {
        return CGRectGetWidth(tableView.bounds) / 4;
    } else {
        const CGFloat imageScale = [KbHomeProgramCell imageScale];
        return (CGRectGetWidth(tableView.bounds)-kDefaultItemSpacing+imageScale*kDefaultItemSpacing/2)/(imageScale*1.5)+kDefaultItemSpacing;//CGRectGetHeight(tableView.bounds) * 0.3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    KbPrograms *programs = self.programModel.fetchedVideoAndAdProgramList[section-1];
    if (programs.type.unsignedIntegerValue == KbProgramTypeAd) {
        return nil;
    }
    
    KbHomeSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSectionHeaderReusableIdentifier];
    headerView.title = programs.name;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || [self isAdBannerInSection:section]) {
        return 0.1;
    } else {
        return MIN(CGRectGetHeight(tableView.frame) * 0.1, 40);
    }
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    KbProgram *bannerProgram = self.programModel.fetchedBannerPrograms[index];
    if (bannerProgram.type.unsignedIntegerValue == KbProgramTypeVideo) {
        [self switchToPlayProgram:bannerProgram];
    } else if (bannerProgram.type.unsignedIntegerValue == KbProgramTypeAd) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:bannerProgram.videoUrl]];
    }
    
}
@end
