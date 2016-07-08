//
//  UIView+Loading.h
//  YuePaoBa
//
//  Created by Sean Yue on 15/12/21.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Loading)

@property (nonatomic,retain,readonly) UIView *ypb_loadingView;
@property (nonatomic,retain,readonly) UIView *ypb_progressingView;
@property (nonatomic,retain,readonly) UIView *ypb_messageView;

- (void)beginLoading;
- (void)endLoading;

- (void)beginProgressingWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
- (void)progressWithPercent:(double)percent;
- (void)endProgressing;

- (void)showMessageWithTitle:(NSString *)title;
- (void)showMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
