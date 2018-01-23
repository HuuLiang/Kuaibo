//
//  UIColor+FeaturedColor.m
//  Pods
//
//  Created by Sean Yue on 16/6/27.
//
//

#import "UIColor+FeaturedColor.h"
#import "UIColor+hexColor.h"

@implementation UIColor (FeaturedColor)

+ (instancetype)featuredColorWithIndex:(NSUInteger)index {
    NSArray *colors = @[@"#fe5135",@"#ff4c8d",@"#5faaea",@"#37f890",@"#998dfd",@"#e3d548",@"#009193",@"#941751",@"#531b93",@"#7a81ff"];
    return [UIColor colorWithHexString:colors[index % colors.count]];
}

+ (instancetype)darkPink {
    return [self colorWithHexString:@"#ff206f"];
}

@end
