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
#import "KbSystemConfigModel.h"
#import "KbProgram.h"

static NSString *const kPaymentCellReusableIdentifier = @"PaymentCellReusableIdentifier";
static NSString *const kChannelCellReusableIdentifier = @"ChannelCellReusableIdentifier";

@interface KbChannelViewController () <UITableViewDataSource,UITableViewDelegate>//<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UITableView *_layoutTableView;
    
    UIImageView *_paymentImageView;
    UILabel *_priceLabel;
}
@property (nonatomic,retain) UITableViewCell *paymentCell;
@property (nonatomic,retain) KbChannelModel *channelModel;
@property (nonatomic,retain) NSArray *videoChannels;
@end

@implementation KbChannelViewController

DefineLazyPropertyInitialization(KbChannelModel, channelModel)

- (UITableViewCell *)paymentCell {
    if (_paymentCell) {
        return _paymentCell;
    }
    
    _paymentCell = [[UITableViewCell alloc] init];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _paymentCell.backgroundView = backgroundImageView;
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor redColor];
    _priceLabel.textAlignment = NSTextAlignmentRight;
    _priceLabel.adjustsFontSizeToFitWidth = YES;
    [backgroundImageView addSubview:_priceLabel];
    {
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backgroundImageView).offset(5);
            make.bottom.equalTo(backgroundImageView.mas_centerY).offset(3);
            make.width.equalTo(backgroundImageView).multipliedBy(0.08);
        }];
    }
    return _paymentCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"频道";

    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.backgroundColor = [UIColor whiteColor];
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kChannelCellReusableIdentifier];
    [_layoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPaymentCellReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    self.videoChannels = self.channelModel.fetchedChannels;
    
    @weakify(self);
    [_layoutTableView kb_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadChannels];
    }];
    [_layoutTableView kb_triggerPullToRefresh];
}

- (void)loadChannels {
    @weakify(self);
    [self.channelModel fetchChannelsWithCompletionHandler:^(BOOL success, NSArray<KbChannel *> *channels) {
        @strongify(self);
        [self->_layoutTableView kb_endPullToRefresh];
        
        if (success) {
            NSMutableArray *videoChannels = [NSMutableArray array];
            [channels enumerateObjectsUsingBlock:^(KbChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type.unsignedIntegerValue == KbChannelTypeVideo
                    || obj.type.unsignedIntegerValue == KbChannelTypeBanner) {
                    [videoChannels addObject:obj];
                }
            }];
            
            self.videoChannels = videoChannels;
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self numberOfSectionsInTableView:self->_layoutTableView]-1];
            [self->_layoutTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    if (![KbUtil isPaid]) {
        KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
        [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
            @strongify(self);
            if (self && success) {
                [self->_layoutTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
    
}

- (void)onPaidNotification:(NSNotification *)notification {
    [_layoutTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[KbStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:0 forSlideCount:1];
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

- (BOOL)isPaymentCellInSection:(NSUInteger)section {
    return section < [self numberOfSectionsInTableView:_layoutTableView] - 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([KbUtil isPaid]) {
        return 1;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [self isPaymentCellInSection:indexPath.section] ? kPaymentCellReusableIdentifier : kChannelCellReusableIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!cell.backgroundView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.layer.borderWidth = 0.5;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [imageView YPB_addAnimationForImageAppearing];
        
        cell.backgroundView = imageView;
        [cell.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell).insets(UIEdgeInsetsMake(0, 0, kDefaultItemSpacing, 0));
        }];
        
        if ([self isPaymentCellInSection:indexPath.section]) {
            _paymentImageView = imageView;
            _priceLabel = [[UILabel alloc] init];
            _priceLabel.textColor = [UIColor redColor];
            _priceLabel.textAlignment = NSTextAlignmentRight;
            _priceLabel.adjustsFontSizeToFitWidth = YES;
            [cell.backgroundView addSubview:_priceLabel];
            {
                [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.backgroundView).offset(5);
                    make.bottom.equalTo(cell.backgroundView.mas_centerY).offset(3);
                    make.width.equalTo(cell.backgroundView).multipliedBy(0.08);
                }];
            }
        }
    }
    
    UIImageView *channelImageView = (UIImageView *)cell.backgroundView;
    if (![self isPaymentCellInSection:indexPath.section]) {
        KbChannel *channel = self.videoChannels[indexPath.row];
        [channelImageView sd_setImageWithURL:[NSURL URLWithString:channel.columnImg]];
    } else {
        @weakify(self);
        KbSystemConfigModel *systemConfigModel = [KbSystemConfigModel sharedModel];
        [channelImageView sd_setImageWithURL:[NSURL URLWithString:systemConfigModel.channelTopImage]
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             @strongify(self);
             if (!self) {
                 return ;
             }
             
             if (image) {
                 double showPrice = systemConfigModel.payAmount;
                 BOOL showInteger = (NSUInteger)(showPrice * 100) % 100 == 0;
                 self->_priceLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", (NSUInteger)showPrice] : [NSString stringWithFormat:@"%.2f", showPrice];
             } else {
                 self->_priceLabel.text = nil;
             }
         }];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isPaymentCellInSection:section]) {
        return 1;
    } else {
        return self.videoChannels.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat normalHeight = CGRectGetWidth(tableView.frame) / 3 + kDefaultItemSpacing;
    if ([self isPaymentCellInSection:indexPath.section]) {
        return normalHeight;
    } else {
        KbChannel *channel = self.videoChannels[indexPath.row];
        if (channel.type.unsignedIntegerValue == KbChannelTypeVideo) {
            return normalHeight;
        } else if (channel.type.unsignedIntegerValue == KbChannelTypeBanner){
            return CGRectGetWidth(tableView.frame) / 4.5 + kDefaultItemSpacing;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isPaymentCellInSection:indexPath.section]) {
        if (![KbUtil isPaid]) {
//            [self payForProgram:nil];
            [self payForProgram:nil programLocation:0 inChannel:nil];
        }
    } else {
        KbChannel *selectedChannel = self.videoChannels[indexPath.row];
        if (selectedChannel.type.unsignedIntegerValue == KbChannelTypeVideo) {
            KbProgramViewController *programVC = [[KbProgramViewController alloc] initWithChannel:selectedChannel];
            programVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:programVC animated:YES];
            [[KbStatsManager sharedManager] statsCPCWithProgram:selectedChannel.programList[indexPath.row] programLocation:indexPath.item inChannel:selectedChannel andTabIndex:self.tabBarController.selectedIndex subTabIndex:0];
            
            
        } else if (selectedChannel.type.unsignedIntegerValue == KbChannelTypeBanner) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:selectedChannel.spreadUrl]];
        }
    }
}
@end
