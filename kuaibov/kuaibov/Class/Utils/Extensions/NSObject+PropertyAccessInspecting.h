//
//  NSObject+PropertyAccessInspecting.h
//  ShiWanSprite
//
//  Created by Sean Yue on 15/5/4.
//  Copyright (c) 2015年 Kuchuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyAccessInspecting)

-(void)propAccessInspect_init;
-(id)propAccessInspect_preAccessProperty:(NSString *)propertyName;

@end
