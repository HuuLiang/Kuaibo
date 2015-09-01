//
//  NSString+FilterHTML.m
//  saker
//
//  Created by kc on 15/5/15.
//  Copyright (c) 2015年 kc. All rights reserved.
//

#import "NSString+FilterHTML.h"

@implementation NSString(filterHTML)

- (NSString *)filterHTML{
    NSString * html = self;
    
    NSScanner * styleScanner = [NSScanner scannerWithString:self];
    NSString * text = nil;
    while([styleScanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [styleScanner scanUpToString:@"<style" intoString:nil];
        
        //找到标签的结束位置
        [styleScanner scanUpToString:@"/style>" intoString:&text];
        
        //替换字符
        html = [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/style>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    NSScanner * scanner = [NSScanner scannerWithString:html];
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:&text];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    
    return html;
}

- (BOOL)hasKeyWord{
    if([self rangeOfString:@"app" options:NSCaseInsensitiveSearch].location != NSNotFound || [self rangeOfString:@"安卓" options:NSCaseInsensitiveSearch].location != NSNotFound || [self rangeOfString:@"android" options:NSCaseInsensitiveSearch].location != NSNotFound || [self rangeOfString:@"应用" options:NSCaseInsensitiveSearch].location != NSNotFound){
        return YES;
    }
    return NO;
}

@end
