//
//  KbHudManager.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KbHudManager : NSObject

+(instancetype)manager;
-(void)showHudWithText:(NSString *)text;
-(void)showHudWithTitle:(NSString *)title message:(NSString *)msg;

@end
