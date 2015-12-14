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
#import "KbActivateModel.h"
#import "KbPaymentModel.h"
#import "KbUserAccessModel.h"
#import "MobClick.h"
#import "IpaynowPluginApi.h"
#import "KbSystemConfigModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    _window                              = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor              = [UIColor whiteColor];
    
    KbHomeViewController *homeVC         = [[KbHomeViewController alloc] initWithBottomAdBanner:YES];
    UINavigationController *homeNav      = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem                   = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                                         image:[UIImage imageNamed:@"btm_home"]
                                                                 selectedImage:[UIImage imageNamed:@"btm_home_sel"]];
    
    KbChannelViewController *channelVC   = [[KbChannelViewController alloc] initWithBottomAdBanner:YES];
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
    
    [UITabBarController aspect_hookSelector:@selector(shouldAutorotate)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UITabBarController *thisTabBarVC = [aspectInfo instance];
                                   UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                   
                                   BOOL autoRotate = NO;
                                   if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                       autoRotate = [((UINavigationController *)selectedVC).topViewController shouldAutorotate];
                                   } else {
                                       autoRotate = [selectedVC shouldAutorotate];
                                   }
                                   [[aspectInfo originalInvocation] setReturnValue:&autoRotate];
                               } error:nil];
    
    [UITabBarController aspect_hookSelector:@selector(supportedInterfaceOrientations)
                                withOptions:AspectPositionInstead
                                 usingBlock:^(id<AspectInfo> aspectInfo){
                                     UITabBarController *thisTabBarVC = [aspectInfo instance];
                                     UIViewController *selectedVC = thisTabBarVC.selectedViewController;
                                     
                                     NSUInteger result = 0;
                                     if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                                         result = [((UINavigationController *)selectedVC).topViewController supportedInterfaceOrientations];
                                     } else {
                                         result = [selectedVC supportedInterfaceOrientations];
                                     }
                                     [[aspectInfo originalInvocation] setReturnValue:&result];
                                 } error:nil];
}

- (void)setupMobStatistics {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (bundleVersion) {
        [MobClick setAppVersion:bundleVersion];
    }
    [MobClick startWithAppkey:[KbConfig sharedConfig].umengAppId reportPolicy:BATCH channelId:[KbConfig sharedConfig].channelNo];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[KbErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
    [self.window makeKeyWindow];
    
#ifdef EnableBaiduMobAd
    self.splashAd = [[BaiduMobAdSplash alloc] init];
    self.splashAd.delegate = self;
    self.splashAd.AdUnitTag = [KbConfig sharedConfig].baiduLaunchAdId;
    self.splashAd.canSplashClick = YES;
    [self.splashAd loadAndDisplayUsingKeyWindow:self.window];
#endif
    
    self.window.hidden = NO;
    
    if (![KbUtil isRegistered]) {
        [[KbActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
            if (success) {
                [KbUtil setRegisteredWithUserId:userId];
                [[KbUserAccessModel sharedModel] requestUserAccess];
            }
        }];
    } else {
        [[KbUserAccessModel sharedModel] requestUserAccess];
    }
    
    [[KbPaymentModel sharedModel] processPendingOrder];
    [[KbSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        if (!success) {
            return ;
        }
        
        if ([KbSystemConfigModel sharedModel].startupInstall.length == 0
            || [KbSystemConfigModel sharedModel].startupPrompt.length == 0) {
            return ;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[KbSystemConfigModel sharedModel].startupInstall]];
    }];
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
    [IpaynowPluginApi willEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [IpaynowPluginApi application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}
@end
