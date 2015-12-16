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
//#import "KbHomeCollectionViewLayout.h"
#import "KbHomeProgramCell.h"
#import <SDCycleScrollView.h>

@interface KbHomeViewController () <UITableViewDataSource,UITableViewDelegate,SDCycleScrollViewDelegate>
{
    UITableView *_layoutTableView;
    
    UITableViewCell *_bannerCell;
    SDCycleScrollView *_bannerView;
}
@property (nonatomic,retain) KbHomeBannerModel *bannerModel;
@property (nonatomic,retain) KbHomeProgramModel *programModel;
@property (nonatomic,retain,readonly) dispatch_group_t dataFetchDispatchGroup;

@property (nonatomic,retain) NSArray *videoPrograms;
@end

static NSString *const kProgramCellReusableIdentifier = @"ProgramCellReusableIdentifier";
static NSString *const kAdBannerCellReusableIdentifier = @"AdBannerCellReusableIdentifier";
static NSString *const kSectionHeaderReusableIdentifier = @"SectionHeaderReusableIdentifier";

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
    // Do any additional setup after loading the view.
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    if (!appName) {
        appName = @"快播";
    }
    
    self.title = appName;
    self.view.backgroundColor = HexColor(#f7f7f7);
    
    _layoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _layoutTableView.backgroundColor = [UIColor whiteColor];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.sectionFooterHeight = 0.1;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[KbHomeProgramCell class] forCellReuseIdentifier:kProgramCellReusableIdentifier];
    [_layoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kAdBannerCellReusableIdentifier];
    [_layoutTableView registerClass:[KbHomeSectionHeaderView class] forHeaderFooterViewReuseIdentifier:kSectionHeaderReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, self.adBannerHeight, 0));
        }];
    }
    
    self.videoPrograms = self.programModel.fetchedProgramList;
    
    @weakify(self);
    [_layoutTableView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self reloadData];
    }];
    [_layoutTableView kb_triggerPullToRefresh];
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
            [self->_layoutTableView kb_endPullToRefresh];
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
                if (((KbPrograms *)obj).type.unsignedIntegerValue == KbProgramTypeVideo
                    || ((KbPrograms *)obj).type.unsignedIntegerValue == KbProgramTypeBanner) {
                    [videoPrograms addObject:obj];
                }
            }];
            
            self.videoPrograms = videoPrograms;
            [self->_layoutTableView reloadData];
        }
    }];
}

- (NSArray<KbProgram *> *)programsForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    
    KbPrograms *programs = self.videoPrograms[indexPath.section-1];
    
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
    
    KbPrograms *programs = self.videoPrograms[indexPath.section-1];
    if (programs.type.unsignedIntegerValue == KbProgramTypeBanner) {
        return programs.programList[indexPath.row];
    }
    return nil;
}

- (BOOL)isAdBannerInSection:(NSUInteger)section {
    if (section == 0) {
        return NO;
    }
    
    KbPrograms *programs = self.videoPrograms[section-1];
    return programs.type.unsignedIntegerValue == KbProgramTypeBanner;
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
                
                NSArray<KbProgram *> *programsForCell = [self programsForCellAtIndexPath:indexPath];
                if (programsForCell.count < position) {
                    return ;
                }
                
                [self switchToPlayProgram:programsForCell[position]];
            };
            return programCell;
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.videoPrograms.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        KbPrograms *programs = self.videoPrograms[section-1];
        if (programs.type.unsignedIntegerValue == KbProgramTypeBanner) {
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
        return CGRectGetHeight(tableView.bounds) * 0.3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    KbPrograms *programs = self.videoPrograms[section-1];
    if (programs.type.unsignedIntegerValue == KbProgramTypeBanner) {
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
    KbProgram *bannerProgram = self.bannerModel.fetchedBanners[index];
    [self switchToPlayProgram:bannerProgram];
}
@end
