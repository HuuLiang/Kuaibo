//
//  UIScrollView+ODRefresh.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (ODRefresh)

- (void)addODRefreshControlWithActionHandler:(void (^)(void))actionHandler;
- (void)triggerODRefresh;
- (void)endODRefresh;

@end
