//
//  NSObject+DictionaryRepresentation.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPersistenceTypeKey;

typedef NSString * (^YYKPlistPersistenceCryptBlock)(NSString *propertyName, id instance);

@interface NSObject (DictionaryRepresentation)

- (NSDictionary *)dictionaryRepresentationWithEncryptBlock:(YYKPlistPersistenceCryptBlock)encryptBlock;
+ (instancetype)objectFromDictionary:(NSDictionary *)dic withDecryptBlock:(YYKPlistPersistenceCryptBlock)decryptBlock;
+ (BOOL)persist:(NSArray *)objects inSpace:(NSString *)spaceName withPrimaryKey:(NSString *)primaryKey clearBeforePersistence:(BOOL)shouldClear encryptBlock:(YYKPlistPersistenceCryptBlock)encryptBlock;
+ (NSArray *)allPersistedObjectsInSpace:(NSString *)spaceName withDecryptBlock:(YYKPlistPersistenceCryptBlock)decryptBlock;

@end
