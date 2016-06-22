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
#import "KbSystemConfigModel.h"
#import "KBKLaunchView.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

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
                                                                         image:[UIImage imageNamed:@"home_normal"]
                                                                 selectedImage:[UIImage imageNamed:@"home_highlight"]];
    homeNav.navigationItem.title = @"首页";
    
    KbChannelViewController *channelVC   = [[KbChannelViewController alloc] init];
    UINavigationController *channelNav   = [[UINavigationController alloc] initWithRootViewController:channelVC];
    
    channelNav.tabBarItem                = [[UITabBarItem alloc] initWithTitle:@"频道"
                                                                         image:[UIImage imageNamed:@"channel_normal"]
                                                                 selectedImage:[UIImage imageNamed:@"channel_highlight"]];
    
    kbMoreViewController *moreVC         = [[kbMoreViewController alloc] init];
    UINavigationController *moreNav      = [[UINavigationController alloc] initWithRootViewController:moreVC];
    moreNav.tabBarItem                   = [[UITabBarItem alloc] initWithTitle:@"更多"
                                                                         image:[UIImage imageNamed:@"more_normal"]
                                                                 selectedImage:[UIImage imageNamed:@"more_highlight"]];
    
    UITabBarController *tabBarController    = [[UITabBarController alloc] init];
    tabBarController.viewControllers        = @[homeNav,channelNav,moreNav];
    tabBarController.tabBar.translucent     = NO;
    tabBarController.delegate = self;
    //    tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    
    //    NSUInteger itemCount = tabBarController.viewControllers.count;
    //    for (NSUInteger i = 0; i < itemCount-1; ++i) {
    //        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_separator"]];
    //        separator.bounds = CGRectMake(0, 0, 1, CGRectGetHeight(tabBarController.tabBar.bounds));
    //        separator.center = CGPointMake(mainWidth/itemCount*(i+1), CGRectGetHeight(tabBarController.tabBar.bounds)/2);
    //        [tabBarController.tabBar addSubview:separator];
    //    }
    _window.rootViewController              = tabBarController;
    return _window;
}

- (void)setupCommonStyles {
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#efefef"]];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_background"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#ff0066"]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-3 forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:@"#ff0066"]];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   //                                   thisVC.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
                                   thisVC.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.],
                                                                                                     NSForegroundColorAttributeName:[UIColor whiteColor]};
                                   
                                   //                                                                      thisVC.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#ff0066"];
                                   thisVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:nil];
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
    
    // No title in tabbar item
    //    [UITabBarItem aspect_hookSelector:@selector(title)
    //                          withOptions:AspectPositionInstead
    //                           usingBlock:^(id<AspectInfo> aspectInfo)
    //    {
    //        NSString *title;
    //        [[aspectInfo originalInvocation] setReturnValue:&title];
    //    } error:nil];
    //    
    //    [UITabBarItem aspect_hookSelector:@selector(imageInsets)
    //                          withOptions:AspectPositionInstead
    //                           usingBlock:^(id<AspectInfo> aspectInfo)
    //    {
    //        UIEdgeInsets imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    //        [[aspectInfo originalInvocation] setReturnValue:&imageInsets];
    //    } error:nil];
}

- (void)setupMobStatistics {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (bundleVersion) {
        [MobClick setAppVersion:bundleVersion];
    }
    [MobClick startWithAppkey:KB_UMENG_APP_ID reportPolicy:BATCH channelId:KB_CHANNEL_NO];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [KbUtil accumateLaunchSeq];
    [[KbPaymentManager sharedManager] setup];
    [KbUtil startMonitoringNetwork];
    [[KbErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
    [[KbNetworkInfo sharedInfo] startMonitoring];
    [self.window makeKeyWindow];
    self.window.hidden = NO;
    //启动图
    KBKLaunchView *launchView = [[KBKLaunchView alloc] init];
    [launchView show];
    
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
    
    [[KbPaymentModel sharedModel] startRetryingToCommitUnprocessedOrders];
    [[KbSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        NSInteger statsTimeInterval = 20;//上传时间间隔
        if ([KbSystemConfigModel sharedModel].loaded && [KbSystemConfigModel sharedModel].statsTimeInterval >0) {
            statsTimeInterval = [KbSystemConfigModel sharedModel].statsTimeInterval;
        }
        
        [[KbStatsManager sharedManager] scheduleStatsUploadWithTimeInterval:statsTimeInterval];
        
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
    if (![KbUtil isPaid]) {
        [[KbPaymentManager sharedManager] checkPayment];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[KbPaymentManager sharedManager] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [[KbPaymentManager sharedManager] handleOpenURL:url];
    return YES;
}


#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [[KbStatsManager sharedManager] statsTabIndex:tabBarController.selectedIndex subTabIndex:[KbUtil currentSubTabPageIndex] forClickCount:1];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [[KbStatsManager sharedManager] statsStopDurationAtTabIndex:tabBarController.selectedIndex subTabIndex:[KbUtil currentSubTabPageIndex]];
    return YES;
}
@end
