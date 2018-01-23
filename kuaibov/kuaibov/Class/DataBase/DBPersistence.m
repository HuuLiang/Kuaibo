//
//  DBPersistence.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "DBPersistence.h"
#import "DBHandler.h"

@implementation DBPersistence

+ (NSString *)primaryKey {
    return nil;
}

- (BOOL)save {
    return [[DBHandler sharedInstance] insertOrUpdateWithModelArr:@[self] byPrimaryKey:[[self class] primaryKey]];
}

+ (BOOL)DBShouldPersistentSubProperties {
    return NO;
}

+ (NSArray *)DBPersistenceExcludedProperties {
    return @[@"description",@"debugDescription",@"hash",@"superclass"];
}
@end
