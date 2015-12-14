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
#import "KbChannelProgramCell.h"

@interface KbProgramViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_programTableView;
}
@property (nonatomic,retain) KbChannel *channel;
@property (nonatomic,retain) KbChannelProgramModel *programModel;

@property (nonatomic,retain) NSMutableArray *programs;
@property (nonatomic) NSUInteger currentPage;
@end

static const NSUInteger kDefaultPageSize = 10;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
    // Do any additional setup after loading the view.
    self.title = _channel.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _programTableView = [[UITableView alloc] init];
    _programTableView.delegate = self;
    _programTableView.dataSource = self;
    _programTableView.rowHeight = 90;
    _programTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_programTableView registerClass:[KbChannelProgramCell class]
              forCellReuseIdentifier:[KbChannelProgramCell reusableIdentifier]];
    [self.view addSubview:_programTableView];
    {
        [_programTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-self.adBannerHeight);
        }];
    }
    

    @weakify(self);
    [_programTableView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        
        self.currentPage = 0;
        [self.programs removeAllObjects];
        [self loadPrograms];
    }];
    [_programTableView kb_triggerPullToRefresh];
    
    [_programTableView kb_addPagingRefreshWithHandler:^{
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
                                       [self.programs addObjectsFromArray:programs.programList];
                                       [self->_programTableView reloadData];
                                   }
                                   
                                   [self->_programTableView kb_endPullToRefresh];
                                   
                                   if (self.programs.count >= programs.items.unsignedIntegerValue) {
                                       [self->_programTableView kb_pagingRefreshNoMoreData];
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

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.programs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KbChannelProgramCell *cell = [tableView dequeueReusableCellWithIdentifier:[KbChannelProgramCell reusableIdentifier] forIndexPath:indexPath];
    
    KbChannelProgram *program = [self channelProgramOfIndexPath:indexPath];
    cell.title = program.title;
    cell.detail = program.specialDesc;
    cell.imageURL = [NSURL URLWithString:program.coverImg];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    KbChannelProgram *program = [self channelProgramOfIndexPath:indexPath];
    [self switchToPlayProgram:program];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.kb_borderSide = KbBorderTopSide | KbBorderBottomSide;
    } else {
        cell.kb_borderSide = KbBorderBottomSide;
    }
}
@end
