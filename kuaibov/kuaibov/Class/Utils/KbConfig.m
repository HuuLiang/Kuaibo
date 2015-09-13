//
//  KbConfig.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbConfig.h"

@implementation KbConfig

+ (instancetype)sharedConfig {
    static KbConfig *_config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
        NSDictionary *configDic = [[NSDictionary alloc] initWithContentsOfFile:configPath];
        _config = [[KbConfig alloc] initWithDictionary:configDic];
    });
    return _config;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self parseConfigWithDictionary:dic];
    }
    return self;
}

- (void)parseConfigWithDictionary:(NSDictionary *)dic {
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *valueDic = (NSDictionary *)obj;
            [self parseConfigWithDictionary:valueDic];
        } else {
            NSString *keyStr = (NSString *)key;
            NSString *camelKeyStr = [[keyStr substringToIndex:1].lowercaseString stringByAppendingString:[keyStr substringFromIndex:1]];
            if ([self respondsToSelector:NSSelectorFromString(camelKeyStr)]) {
                [self setValue:obj forKey:camelKeyStr];
            }
        }
    }];
}

+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)appId {
    return [NSBundle mainBundle].bundleIdentifier;
}
@end
