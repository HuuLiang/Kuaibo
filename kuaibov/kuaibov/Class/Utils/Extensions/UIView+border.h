//
//  UIView+border.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, KbBorderSide) {
    KbBorderNoSide = 0,
    KbBorderLeftSide = 1 << 0,
    KbBorderRightSide = 1 << 1,
    KbBorderTopSide = 1 << 2,
    KbBorderBottomSide = 1 << 3
};

@interface UIView (border)

@property (nonatomic) KbBorderSide kb_borderSide;

@end
