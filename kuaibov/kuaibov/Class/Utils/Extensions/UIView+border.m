//
//  UIView+border.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIView+border.h"
#import <objc/runtime.h>

static const void* kBorderSideAssociatedKey = &kBorderSideAssociatedKey;
static const CGFloat kBorderWidth = 0.5;

@implementation UIView (border)

- (NSString *)kb_stringTagOfBorderOnSide:(KbBorderSide)side {
    if (side == KbBorderNoSide) {
        return nil;
    }
    
    NSDictionary *tagsKeyStrings = @{@(KbBorderLeftSide):@"Left",
                                     @(KbBorderRightSide):@"Right",
                                     @(KbBorderTopSide):@"Top",
                                     @(KbBorderBottomSide):@"Bottom"};
    return [NSString stringWithFormat:@"Kb%@BorderViewStringTag", tagsKeyStrings[@(side)]];
}

- (void)kb_addBorderViewOnSide:(KbBorderSide)side {
    if (side == KbBorderNoSide) {
        return;
    }
    
    
    
    UIView *borderView = [[UIView alloc] init];
    borderView.stringTag = [self kb_stringTagOfBorderOnSide:side];
    borderView.backgroundColor = Color_DefaultBorder;
    [self addSubview:borderView];
    {
        [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (side != KbBorderLeftSide) {
                make.right.equalTo(self);
            }
            
            if (side != KbBorderRightSide) {
                make.left.equalTo(self);
            }
            
            if (side != KbBorderBottomSide) {
                make.top.equalTo(self);
            }
            
            if (side != KbBorderTopSide) {
                make.bottom.equalTo(self);
            }
            
            if (side == KbBorderTopSide || side == KbBorderBottomSide) {
                make.height.mas_equalTo(kBorderWidth);
            }
            
            if (side == KbBorderLeftSide || side == KbBorderRightSide) {
                make.width.mas_equalTo(kBorderWidth);
            }
        }];
    }
}

- (void)kb_removeBorderOnSide:(KbBorderSide)side {
    if (side == KbBorderNoSide) {
        return ;
    }
    
    UIView *borderView = [self viewWithStringTag:[self kb_stringTagOfBorderOnSide:side]];
    [borderView removeFromSuperview];
}

- (void)setKb_borderSide:(KbBorderSide)borderSide {
    KbBorderSide prevBorderSide = self.kb_borderSide;
    objc_setAssociatedObject(self, kBorderSideAssociatedKey, @(borderSide), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    NSUInteger borderSides[] = {KbBorderLeftSide,KbBorderRightSide,KbBorderTopSide,KbBorderBottomSide};
    for (NSUInteger side = 0; side < sizeof(borderSides) / sizeof(borderSides[0]); ++side) {
        if ((borderSide & borderSides[side]) ^ (prevBorderSide & borderSides[side])) {
            if (borderSide & borderSides[side]) {
                [self kb_addBorderViewOnSide:borderSides[side]];
            } else {
                [self kb_removeBorderOnSide:borderSides[side]];
            }
        }
    }
}

- (KbBorderSide)kb_borderSide {
    NSNumber *borderSide = objc_getAssociatedObject(self, kBorderSideAssociatedKey);
    return (KbBorderSide)borderSide.unsignedIntegerValue;
}

@end
