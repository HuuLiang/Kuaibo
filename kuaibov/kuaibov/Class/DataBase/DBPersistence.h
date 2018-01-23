//
//  DBPersistence.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBPersistentDelegate <NSObject>

@required
+ (BOOL)DBShouldPersistentSubProperties;
@optional
+ (NSArray *)DBPersistenceExcludedProperties;
+ (NSDictionary *)DBPersistenceCustomObjectMapping;
@end

@interface DBPersistence : NSObject <DBPersistentDelegate>

+ (NSString *)primaryKey;
- (BOOL)save;

@end
