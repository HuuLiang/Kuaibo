//
//  UIColor+meltutils.m
//  AiXiu
//
//  Created by ck on 12-03-02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+meltutils.h"

@implementation NSString (meltutils)

- (UIColor *)toUIColor {
    
    unsigned int c;
    
    if ([self characterAtIndex:0] == '#') {
        
        [[NSScanner scannerWithString:[self substringFromIndex:1]] scanHexInt:&c];
        
    } else {
        
        [[NSScanner scannerWithString:self] scanHexInt:&c];
        
    }
    
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:1.0];
    
}

@end