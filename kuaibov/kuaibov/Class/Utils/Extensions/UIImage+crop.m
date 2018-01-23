//
//  UIImage+crop.m
//  saker
//
//  Created by ZHANGPENG on 14-8-22.
//  Copyright (c) 2014年 kc. All rights reserved.
//

#import "UIImage+crop.h"

@implementation UIImage (crop)

- (UIImage *)crop:(CGRect)rect
{
    if (self.scale > 1.0f)
    {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage    *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return result;
}


@end
