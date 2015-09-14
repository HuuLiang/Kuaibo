//
//  NSDictionary+KbSign.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/13.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KbSign)

- (NSString *)concatenatedValues;
- (NSString *)concatenatedValuesWithKeys:(NSArray *)keys;
- (NSString *)signWithDictionary:(NSDictionary *)dic keyOrders:(NSArray *)keys;

- (NSDictionary *)encryptedDictionarySignedTogetherWithDictionary:(NSDictionary *)dicForSignTogether
                                                        keyOrders:(NSArray *)keys
                                                  passwordKeyName:(NSString *)pwdKeyName;

@end

extern NSString *const kParamKeyName;
extern NSString *const kEncryptionKeyName;
extern NSString *const kEncryptionDataName;