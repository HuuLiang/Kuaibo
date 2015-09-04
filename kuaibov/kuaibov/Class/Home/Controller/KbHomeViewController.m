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

@interface KbHomeViewController ()
{
    KbBannerView *_bannerView;
}
@property (nonatomic,retain) KbHomeBannerModel *bannerModel;
@end

@implementation KbHomeViewController

DefineLazyPropertyInitialization(KbHomeBannerModel, bannerModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"快播";
    
    _bannerView = [[KbBannerView alloc] initWithItems:nil autoPlayTimeInterval:3.0];
    [self.view addSubview:_bannerView];
    {
        [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.top.equalTo(self.view);
            make.height.equalTo(_bannerView.mas_width).with.dividedBy(2).and.sizeOffset(CGSizeMake(0, 44));
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

@end
