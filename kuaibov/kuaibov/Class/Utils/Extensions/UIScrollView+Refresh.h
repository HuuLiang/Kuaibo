//
//  UIScrollView+Refresh.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (Refresh)

- (void)kb_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)kb_triggerPullToRefresh;
- (void)kb_endPullToRefresh;

- (void)kb_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)kb_pagingRefreshNoMoreData;

- (void)kb_addNitoInfoWithHandler:(void (^)(void))handler;


@end
