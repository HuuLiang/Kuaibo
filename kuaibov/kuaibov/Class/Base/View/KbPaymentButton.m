//
//  KbPaymentButton.m
//  Kbuaibo
//
//  Created by Sean Yue on 16/5/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbPaymentButton.h"


static const CGFloat kSpaceBetweenImageAndTitle = 3;

@interface KbPaymentButton ()
@property (nonatomic) CGSize titleSize;
@end

@implementation KbPaymentButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.font = kBoldMediumFont;
    }
    return self;
}

- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state {
    [super setAttributedTitle:title forState:state];
    
    self.titleSize = [title size];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    
    self.titleSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    const CGFloat height = CGRectGetHeight(contentRect) * 0.6;
    const CGFloat width = height;
    const CGFloat totalWidth = width + kSpaceBetweenImageAndTitle + self.titleSize.width;
    const CGFloat imageX = (contentRect.size.width-totalWidth)/2;
    return CGRectMake(imageX, (contentRect.size.height - height)/2, height, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [self imageRectForContentRect:contentRect];
    
    const CGFloat x = CGRectGetMaxX(imageRect)+3;
    return CGRectMake(x, 0, contentRect.size.width-x-3, contentRect.size.height);
}
@end
