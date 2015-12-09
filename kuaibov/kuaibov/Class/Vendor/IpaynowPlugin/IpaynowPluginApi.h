//
//  IpaynowPluginApi.h
//  TestPlugin
//
//  Created by dby on 14-8-19.
//  Copyright (c) 2014年 Ipaynow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IpaynowPluginDelegate.h"

@interface IpaynowPluginApi : NSObject

+ (void) setProductIdentifier:(NSString *)productID andQuantity:(NSInteger)quantity orderNo:(NSString *)orderNo;
+ (BOOL)pay:(NSString*)data AndScheme:(NSString*)scheme viewController:(UIViewController*)viewController delegate:(id<IpaynowPluginDelegate>)delegate;
+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
+ (void)willEnterForeground;
@end
