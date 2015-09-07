//
//  UIScrollView+ODRefresh.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIScrollView+ODRefresh.h"
#import <objc/runtime.h>
#import <ODRefreshControl.h>

static void *kUIScrollViewRefreshControl = &kUIScrollViewRefreshControl;
static void *kODRefreshAction = &kODRefreshAction;

typedef void (^ODRefreshAction)(void);

@interface ODRefreshControl (UIScrollView)
@property (nonatomic,copy) ODRefreshAction od_refreshAction;
@end

@implementation ODRefreshControl (UIScrollView)

- (void)setOd_refreshAction:(ODRefreshAction)od_refreshAction {
    objc_setAssociatedObject(self, kODRefreshAction, od_refreshAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ODRefreshAction)od_refreshAction {
    return objc_getAssociatedObject(self, kODRefreshAction);
}

@end

@interface UIScrollView ()
@property (nonatomic,retain,readonly) ODRefreshControl *odRefreshControl;
@end

@implementation UIScrollView (ODRefresh)

- (ODRefreshControl *)odRefreshControl {
    return objc_getAssociatedObject(self, kUIScrollViewRefreshControl);
}

- (void)setOdRefreshControl:(ODRefreshControl *)odRefreshControl {
    objc_setAssociatedObject(self, kUIScrollViewRefreshControl, odRefreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addODRefreshControlWithActionHandler:(void (^)(void))actionHandler {
    if (!self.odRefreshControl) {
        self.odRefreshControl = [[ODRefreshControl alloc] initInScrollView:self];
        self.odRefreshControl.od_refreshAction = actionHandler;
        [self.odRefreshControl addTarget:self action:@selector(od_refresh) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)od_refresh {
    if (self.odRefreshControl.od_refreshAction) {
        self.odRefreshControl.od_refreshAction();
    }
}

- (void)triggerODRefresh {
    [self.odRefreshControl beginRefreshing];
    [self od_refresh];
}

- (void)endODRefresh {
    [self.odRefreshControl endRefreshing];
}
@end
