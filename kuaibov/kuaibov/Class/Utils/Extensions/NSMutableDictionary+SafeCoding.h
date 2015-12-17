//
//  NSMutableDictionary+SafeCoding.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/3.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SafeCoding)

- (void)safelySetObject:(id)object forKey:(id <NSCopying>)key;

@end
