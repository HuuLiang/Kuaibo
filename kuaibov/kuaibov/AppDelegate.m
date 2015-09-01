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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
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

#pragma mark - Setup TabBarController

- (UITabBarController *)setupRootViewController{
    
    KbHomeViewController *homeVC = [[KbHomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UIImage *unselectedImage = [UIImage imageNamed:@"btm_home"];
    UIImage *selectedImage = [UIImage imageNamed:@"btm_home_sel"];
    if (IS_IOS7_LATER) {
        homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                          image:[unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        homeVC.tabBarItem.tag = 0;
    }else{
        homeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:unselectedImage tag:0];
        [homeVC.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
    }
    
    KbChannelViewController *gShareVC = [[KbChannelViewController alloc] init];
    UINavigationController *missionNav = [[UINavigationController alloc] initWithRootViewController:gShareVC];
    unselectedImage = [UIImage imageNamed:@"btm_c"];
    selectedImage = [UIImage imageNamed:@"btm_c_sel"];
    if (IS_IOS7_LATER) {
        gShareVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"频道"
                                                            image:[unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        gShareVC.tabBarItem.tag = 1;
    }else{
        gShareVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"频道" image:unselectedImage tag:2];
        [gShareVC.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
    }
    

    
    kbMoreViewController * setVC = [[kbMoreViewController alloc] init];
    UINavigationController *setNav = [[UINavigationController alloc] initWithRootViewController:setVC];
    unselectedImage = [UIImage imageNamed:@"btm_more"];
    selectedImage = [UIImage imageNamed:@"btm_more_sel"];
    if (IS_IOS7_LATER) {
        setVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"更多"
                                                         image:[unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                 selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        setVC.tabBarItem.tag = 2;
    }else{
        setVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"更多" image:unselectedImage tag:1];
        [setVC.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
    }
    
    
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNav,missionNav, setNav];
    tabBarController.delegate = self;
    
    for (int i = 1; i <= tabBarController.tabBar.items.count; i++) {
        UIView *borderV = [[UIView alloc] initWithFrame:CGRectMake((mainWidth * i / tabBarController.tabBar.items.count), 0, 0.5,  tabBarController.tabBar.height)];
        borderV.backgroundColor = [@"#E8E8E8" toUIColor];
        [tabBarController.tabBar addSubview:borderV];
    }
    
    // customsie UINavigationBar UI Effect
    //UIImage *backgroundImage = [UIImage imageWithRenderColor:NAVBAR_COLOR renderSize:CGSizeMake(10., 10.)];
    UIImage *backgroundImage = [UIImage imageNamed:@"top.jpg"];
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    // customise TabBar UI Effect
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    //[[UITabBar appearance] setSelectedImageTintColor:NAVBAR_COLOR];
    
    if (IS_IOS7_LATER) {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:TABBAR_TEXT_NOR_COLOR} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:TABBAR_TEXT_HLT_COLOR} forState:UIControlStateSelected];
    }else{
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:TABBAR_TEXT_NOR_COLOR} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:TABBAR_TEXT_HLT_COLOR} forState:UIControlStateSelected];
    }
    
    UITabBar *tabBar = tabBarController.tabBar;
    tabBar.backgroundColor = [UIColor whiteColor];
    
    if ([tabBar respondsToSelector:@selector(setBarTintColor:)]){
        [tabBar setBarTintColor:[UIColor whiteColor]];
    }else{
        for (UIView *view in tabBar.subviews) {
            if ([NSStringFromClass([view class]) hasSuffix:@"TabBarBackgroundView"]) {
                [view removeFromSuperview];
                break;
            }
        }
    }
    
    return tabBarController;
}

@end
