//
//  NSDictionary+KbSign.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/13.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "NSDictionary+KbSign.h"
#import "NSString+crypt.h"

NSString *const kParamKeyName       = @"params";
NSString *const kEncryptionKeyName  = @"key";
NSString *const kEncryptionDataName = @"data";

@implementation NSDictionary (KbSign)

- (NSString *)concatenatedValues {
    return [self concatenatedValuesWithKeys:self.allKeys];
}

- (NSString *)concatenatedValuesWithKeys:(NSArray *)keys {
    NSMutableString *concatenatedValues = [NSMutableString string];
    for (NSString *key in keys) {
        NSObject *value = [self valueForKey:key];
        [concatenatedValues appendString:value.description];
    }
    return concatenatedValues;
}

- (NSString *)signWithDictionary:(NSDictionary *)dic keyOrders:(NSArray *)keys {
    NSArray *sortedKeys = [self.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];
    
    NSMutableString *signedString = [self concatenatedValuesWithKeys:sortedKeys].mutableCopy;
    [signedString appendString:[dic concatenatedValuesWithKeys:keys]];
    [signedString appendString:@"null"];
    return signedString.md5;
}

- (NSDictionary *)encryptedDictionarySignedTogetherWithDictionary:(NSDictionary *)dicForSignTogether
                                                        keyOrders:(NSArray *)keys
                                                  passwordKeyName:(NSString *)pwdKeyName {
    NSString *password = [self objectForKey:pwdKeyName];
    if (password.length == 0) {
        password = [dicForSignTogether objectForKey:pwdKeyName];
        NSAssert(password.length > 0, @"No password for encryption found!");
    }
    
    NSString *sign = [self signWithDictionary:dicForSignTogether keyOrders:keys];
    NSAssert(sign.length > 0, @"The sign of url params must NOT be nil!");
    
    __block NSMutableString *params = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && ![pwdKeyName isEqualToString:key]) {
            NSString *keyValueString = [NSString stringWithFormat:@"&%@=%@", key, obj];
            [params appendString:keyValueString];
        }
    }];
    
    NSString *signParam = [NSString stringWithFormat:@"sign=%@", sign];
    if (params.length > 0) {
        signParam = [signParam stringByAppendingString:params];
    }
    
    NSString *encryptedParam = [signParam encryptedStringWithPassword:password.md5];
    return [NSDictionary dictionaryWithObject:encryptedParam forKey:kParamKeyName];
}

@end
