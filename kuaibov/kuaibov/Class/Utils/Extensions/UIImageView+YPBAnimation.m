//
//  UIImageView+YPBAnimation.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/16.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "UIImageView+YPBAnimation.h"
#import <objc/runtime.h>

static const void *kImageAppearingAnimationAssociatedKey = &kImageAppearingAnimationAssociatedKey;

@interface UIImageView ()
@property (nonatomic,retain) id<AspectToken> ypb_appearingAnimation;
@end
@implementation UIImageView (YPBAnimation)

- (void)setYpb_appearingAnimation:(id<AspectToken>)ypb_appearingAnimation {
    objc_setAssociatedObject(self, kImageAppearingAnimationAssociatedKey, ypb_appearingAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<AspectToken>)ypb_appearingAnimation {
    return objc_getAssociatedObject(self, kImageAppearingAnimationAssociatedKey);
}

- (void)YPB_addAnimationForImageAppearing {
    if ([self ypb_appearingAnimation]) {
        return ;
    }
    
    NSError *error;
    id<AspectToken> aspectToken = [self aspect_hookSelector:@selector(setImage:)
                                                withOptions:AspectPositionAfter
                                                 usingBlock:^(id<AspectInfo> aspectInfo, UIImage *image)
    {
        if (!image) {
            return ;
        }
        
        UIImageView *thisImageView = [aspectInfo instance];
        thisImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        thisImageView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            thisImageView.transform = CGAffineTransformIdentity;
            thisImageView.alpha = 1;
        }];
    } error:&error];
    
    if (!error) {
        self.ypb_appearingAnimation = aspectToken;
    }
}

- (void)YPB_removeAnimationForImageAppearing {
    id<AspectToken> aspectToken = self.ypb_appearingAnimation;
    if (aspectToken) {
        [aspectToken remove];
    }
}
@end
