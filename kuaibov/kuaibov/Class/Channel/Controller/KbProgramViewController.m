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
@end

@implementation KbProgramViewController

DefineLazyPropertyInitialization(KbChannelProgramModel, programModel)

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
    
    _programTableView = [[UITableView alloc] init];
    _programTableView.delegate = self;
    _programTableView.dataSource = self;
    _programTableView.rowHeight = 90;
    [_programTableView registerClass:[KbChannelProgramCell class]
              forCellReuseIdentifier:[KbChannelProgramCell reusableIdentifier]];
    [self.view addSubview:_programTableView];
    {
        [_programTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self reloadData];
}

- (void)reloadData {
    @weakify(self);
    [self.programModel fetchProgramsWithColumnId:self.channel.columnId completionHandler:^(BOOL success, KbChannelPrograms *programs) {
        @strongify(self);
        
        if (success) {
            [self->_programTableView reloadData];
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
    return self.programModel.fetchedPrograms.programList[indexPath.row];
}

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.programModel.fetchedPrograms.programList.count;
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
    [self switchToPlayVideo:program];
}
@end
