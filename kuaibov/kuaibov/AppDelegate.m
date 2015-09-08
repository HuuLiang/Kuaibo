//
//  AppDelegate.m
//  kuaibov
//
//  Created by ZHANGPENG on 21/8/15.
//  Copyright (c) 2015 kuaibov. All rights reserved.
//

#import "AppDelegate.h"
#import "kbMoreViewController.h"
#import "KbChannelViewController.h"
#import "KbHomeViewController.h"
#import "KbURLRequest.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    _window                              = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor              = [UIColor whiteColor];

    KbHomeViewController *homeVC         = [[KbHomeViewController alloc] init];
    UINavigationController *homeNav      = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem                   = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                                         image:[UIImage imageNamed:@"btm_home"]
                                                                 selectedImage:[UIImage imageNamed:@"btm_home_sel"]];

    KbChannelViewController *channelVC   = [[KbChannelViewController alloc] init];
    UINavigationController *channelNav   = [[UINavigationController alloc] initWithRootViewController:channelVC];
    channelNav.tabBarItem                = [[UITabBarItem alloc] initWithTitle:@"频道"
                                                                         image:[UIImage imageNamed:@"btm_c"]
                                                                 selectedImage:[UIImage imageNamed:@"btm_c_sel"]];

    kbMoreViewController *moreVC         = [[kbMoreViewController alloc] init];
    moreVC.tabBarItem                    = [[UITabBarItem alloc] initWithTitle:@"更多"
                                                                         image:[UIImage imageNamed:@"btm_more"]
                                                                 selectedImage:[UIImage imageNamed:@"btm_more_sel"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers     = @[homeNav,channelNav,moreVC];
    tabBarController.tabBar.translucent  = NO;
    _window.rootViewController           = tabBarController;
    return _window;
}

- (void)setupCommonStyles {
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    } error:nil];
    
    [UINavigationController aspect_hookSelector:@selector(preferredStatusBarStyle)
                                    withOptions:AspectPositionInstead
                                     usingBlock:^(id<AspectInfo> aspectInfo){
                                         UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                         [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
    } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                   [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
    } error:nil];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupCommonStyles];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        [[AlipayManager shareInstance] sendNotificationByResult:resultDic];
    }];
    return YES;
}

@end
