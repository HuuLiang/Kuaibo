//
//  KbChannel.m
//  kuaibov
//
//  Created by ylz on 16/6/17.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbChannel.h"

@implementation KbChannels
//
//- (BOOL)isEqual:(id)object{
//
//    if (![object isKindOfClass:[KbChannel class]]) {
//        return NO;
//    }
//    return [_columnId isEqualToNumber:[object columnId]];
//}
//
//- (NSUInteger)hash {
//    return self.columnId.hash;
//}

- (Class)programListElementClass {
    return [KbProgram class];
}
//+ (NSString *)cryptPasswordForProperty:(NSString *)propertyName withInstance:(id)instance {
//    if ([instance class] == [KbChannel class]) {
//        NSArray *cryptProperties = @[@"columnDesc",@"name",@"columnImg",@"spreadUrl"];
//        if ([cryptProperties containsObject:propertyName]) {
//            return kPersistenceCryptPassword;
//        }
//    } else if ([instance class] == [KbProgram class]) {
//        NSArray *cryptProperties = @[@"videoUrl",@"coverImg",@"offUrl",@"title",@"specialDesc"];
//        if ([cryptProperties containsObject:propertyName]) {
//            return kPersistenceCryptPassword;
//        }
//    }
//    return nil;
//}


@end
