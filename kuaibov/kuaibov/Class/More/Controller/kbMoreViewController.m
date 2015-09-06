//
//  kbMoreViewController.m
//  kuaibov
//
//  Created by ZHANGPENG on 15/9/1.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "kbMoreViewController.h"

@interface kbMoreViewController ()
{
    UIView *_headerView;
    UIWebView *_webView;
}
@end

@implementation kbMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_headerView];
    {
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.height.mas_equalTo(20);
        }];
    }
    
    _webView = [[UIWebView alloc] init];
    [self.view addSubview:_webView];
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(_headerView.mas_bottom);
        }];
    }
    
    NSString *urlString = [[KbConfig sharedConfig].baseURL stringByAppendingString:[KbConfig sharedConfig].moreURLPath];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
