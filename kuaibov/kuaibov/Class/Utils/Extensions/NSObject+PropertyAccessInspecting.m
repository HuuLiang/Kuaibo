//
//  NSObject+PropertyAccessInspecting.m
//  ShiWanSprite
//
//  Created by Sean Yue on 15/5/4.
//  Copyright (c) 2015年 Kuchuan. All rights reserved.
//

#import "NSObject+PropertyAccessInspecting.h"
#import "NSObject+Properties.h"

@implementation NSObject (PropertyAccessInspecting)

-(void)propAccessInspect_init {
    NSArray *propertyNames = [NSObject propertiesOfClass:[self class]];
    for (NSString *propertyName in propertyNames) {
        [self aspect_hookSelector:NSSelectorFromString(propertyName) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
            id preAccessPropertyValue = [self propAccessInspect_preAccessProperty:propertyName];
            if (preAccessPropertyValue) {
                [info.originalInvocation setReturnValue:&preAccessPropertyValue];
            } else {
                [info.originalInvocation invoke];
            }
        } error:nil];
    }
}

-(id)propAccessInspect_preAccessProperty:(NSString *)propertyName {
    return nil;
}

@end
