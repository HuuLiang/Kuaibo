//
//  NSString+crypt.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/12.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (crypt)

- (NSString *)encryptedStringWithPassword:(NSString *)password;
- (NSString *)decryptedStringWithPassword:(NSString *)password;
- (NSString *)decryptedStringWithKeys:(NSArray *)keys;

@end
