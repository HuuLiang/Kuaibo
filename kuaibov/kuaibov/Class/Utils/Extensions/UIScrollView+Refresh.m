//
//  UIScrollView+Refresh.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <MJRefresh.h>

@implementation UIScrollView (Refresh)

- (void)kb_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        self.header = refreshHeader;
    }
}

- (void)kb_triggerPullToRefresh {
    [self.header beginRefreshing];
}

- (void)kb_endPullToRefresh {
    [self.header endRefreshing];
    [self.footer resetNoMoreData];
}

- (void)kb_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        self.footer = refreshFooter;
    }
}

- (void)kb_pagingRefreshNoMoreData {
    [self.footer noticeNoMoreData];
}
@end
