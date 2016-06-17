//
//  NSObject+DictionaryRepresentation.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/5/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "NSObject+DictionaryRepresentation.h"
#import "NSObject+Properties.h"
#import "NSString+crypt.h"

NSString *const kPersistenceTypeKey = @"com.yykuaibo.persistenceTypeKey";

@implementation NSObject (DictionaryRepresentation)

- (NSDictionary *)dictionaryRepresentationWithEncryptBlock:(YYKPlistPersistenceCryptBlock)encryptBlock {
    NSArray *properties = self.allProperties;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [properties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [self valueForKey:obj];
        if (!value) {
            return ;
        }
        
        if ([value isKindOfClass:[NSNumber class]]
            || [value isKindOfClass:[NSDate class]]) {
            [dic setObject:value forKey:obj];
        } else if ([value isKindOfClass:[NSString class]]) {
            NSString *password;
            if (encryptBlock) {
                password = encryptBlock(obj, self);
            }
            
            if (password) {
                [dic setObject:[value encryptedStringWithPassword:password] forKey:obj];
            } else {
                [dic setObject:value forKey:obj];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *valueArr = (NSArray *)value;
            if (valueArr.count == 0) {
                return ;
            }
            
            NSMutableDictionary *typeDic = [dic objectForKey:kPersistenceTypeKey];
            if (!typeDic) {
                typeDic = [NSMutableDictionary dictionary];
            }
            
            [typeDic setObject:NSStringFromClass([valueArr.firstObject class]) forKey:obj];
            [dic setObject:typeDic forKey:kPersistenceTypeKey];
            
            if ([valueArr.firstObject isKindOfClass:[NSString class]]
                || [valueArr.firstObject isKindOfClass:[NSNumber class]]
                || [valueArr.firstObject isKindOfClass:[NSDate class]]) {
                [dic setObject:value forKey:obj];
                return ;
            }
            
            NSMutableArray *arr = [NSMutableArray array];
            [dic setObject:arr forKey:obj];
            
            [valueArr enumerateObjectsUsingBlock:^(id  _Nonnull arrObj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *arrDic = [arrObj dictionaryRepresentationWithEncryptBlock:encryptBlock];
                if (arrDic) {
                    [arr addObject:arrDic];
                }
            }];

        }
    }];
    return dic.count > 0 ? dic : nil;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dic withDecryptBlock:(YYKPlistPersistenceCryptBlock)decryptBlock {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id object = [[self alloc] init];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]
            || [obj isKindOfClass:[NSDate class]]) {
            if ([object respondsToSelector:NSSelectorFromString(key)]) {
                [object setValue:obj forKey:key];
            }
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *password;
            if (decryptBlock) {
                password = decryptBlock(key, object);
            }
            
            if ([object respondsToSelector:NSSelectorFromString(key)]) {
                if (password) {
                    [object setValue:[obj decryptedStringWithPassword:password] forKey:key];
                } else {
                    [object setValue:obj forKey:key];
                }
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *objArr = (NSArray *)obj;
            if (objArr.count == 0) {
                return ;
            }
            
            if ([objArr.firstObject isKindOfClass:[NSString class]]
                || [objArr.firstObject isKindOfClass:[NSNumber class]]
                || [objArr.firstObject isKindOfClass:[NSDate class]]) {
                if ([object respondsToSelector:NSSelectorFromString(key)]) {
                    [object setValue:obj forKey:key];
                }
            } else if ([objArr.firstObject isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *arr = [NSMutableArray array];
                NSDictionary *typeDic = dic[kPersistenceTypeKey];
                NSString *className = typeDic[key];
                Class objClass = NSClassFromString(className);
                if (!objClass) {
                    objClass = [objArr.firstObject class];
                }
                for (id arrObj in objArr) {
                    [arr addObject:[objClass objectFromDictionary:arrObj withDecryptBlock:decryptBlock]];
                }
                if ([object respondsToSelector:NSSelectorFromString(key)]) {
                    [object setValue:arr forKey:key];
                }
            }
        }
    }];
    return object;
}

+ (BOOL)persist:(NSArray *)objects inSpace:(NSString *)spaceName withPrimaryKey:(NSString *)primaryKey clearBeforePersistence:(BOOL)shouldClear encryptBlock:(YYKPlistPersistenceCryptBlock)encryptBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths.firstObject;
    if (!path) {
        return NO;
    }
    
    NSString *file = [NSString stringWithFormat:@"%@/%@", path, spaceName];
    NSMutableArray *arr = shouldClear ? [NSMutableArray array] : [NSArray arrayWithContentsOfFile:file].mutableCopy ?: [NSMutableArray array];
    // Remove all elements that have the same primary key value.
    NSArray *updateObjects = [arr bk_select:^BOOL(id obj) {
        id primaryValue = [arr valueForKey:primaryKey];
        return [objects bk_any:^BOOL(id obj) {
            return [[obj valueForKey:primaryKey] isEqual:primaryValue];
        }];
    }];
    [arr removeObjectsInArray:updateObjects];
    
    [objects enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dicRep = [obj dictionaryRepresentationWithEncryptBlock:encryptBlock];
        if (dicRep) {
            [arr addObject:dicRep];
        }
    }];
    
    if (arr.count == 0) {
        return NO;
    }
    
    return [arr writeToFile:file atomically:YES];
}

+ (NSArray *)allPersistedObjectsInSpace:(NSString *)spaceName withDecryptBlock:(YYKPlistPersistenceCryptBlock)decryptBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths.firstObject;
    if (!path) {
        return nil;
    }
    
    NSString *file = [NSString stringWithFormat:@"%@/%@", path, spaceName];
    NSArray *arr = [NSArray arrayWithContentsOfFile:file];
    NSMutableArray *retArr = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KbChannels *channel = [self objectFromDictionary:obj withDecryptBlock:decryptBlock];
        if (channel) {
            [retArr addObject:channel];
        }
    }];
    return retArr.count > 0 ? retArr : nil;
}
@end
