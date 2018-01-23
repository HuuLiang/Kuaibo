//
//  UIColor+hexColor.m
//  kuaibov
//
//  Created by Sean Yue on 15/3/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIColor+hexColor.h"

@implementation UIColor (hexColor)
+(instancetype)colorWithHexString:(NSString *)hexStr {
    if (hexStr.length < 7)
        return nil;
    
    unsigned int red_, green_, blue_;
    NSRange exceptionRange;
    exceptionRange.length = 2;
    
    //red
    exceptionRange.location = 1;
    [[NSScanner scannerWithString:[hexStr substringWithRange:exceptionRange]]scanHexInt:&red_];
    
    //green
    exceptionRange.location = 3;
    [[NSScanner scannerWithString:[hexStr substringWithRange:exceptionRange]]scanHexInt:&green_];
    
    //blue
    exceptionRange.location = 5;
    [[NSScanner scannerWithString:[hexStr substringWithRange:exceptionRange]]scanHexInt:&blue_];
    
    UIColor *resultColor = [UIColor colorWithRed:red_/255. green:green_/255. blue:blue_/255. alpha:1.];
    return resultColor;
}
@end
