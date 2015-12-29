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
#import "WXApi.h"
#import "WeChatPayManager.h"
#import "KbWeChatPayQueryOrderRequest.h"
#import "KbPaymentViewController.h"

@interface AppDelegate () <WXApiDelegate>
@property (nonatomic,retain) KbWeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@end

@implementation AppDelegate

DefineLazyPropertyInitialization(KbWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)


- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    _window                              = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor              = [UIColor whiteColor];
    
    KbHomeViewController *homeVC         = [[KbHomeViewController alloc] initWithBottomAdBanner:YES];
    UINavigationController *homeNav      = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem                   = [[UITabBarItem alloc] initWithTitle:nil
                                                                         image:[UIImage imageNamed:@"home_normal"]
                                                                 selectedImage:[UIImage imageNamed:@"home_highlight"]];
    
    KbChannelViewController *channelVC   = [[KbChannelViewController alloc] initWithBottomAdBanner:YES];
    UINavigationController *channelNav   = [[UINavigationController alloc] initWithRootViewController:channelVC];
    channelNav.tabBarItem                = [[UITabBarItem alloc] initWithTitle:nil
                                                                         image:[UIImage imageNamed:@"channel_normal"]
                                                                 selectedImage:[UIImage imageNamed:@"channel_highlight"]];

    kbMoreViewController *moreVC         = [[kbMoreViewController alloc] init];
    UINavigationController *moreNav      = [[UINavigationController alloc] initWithRootViewController:moreVC];
    moreNav.tabBarItem                   = [[UITabBarItem alloc] initWithTitle:nil
                                                                         image:[UIImage imageNamed:@"more_normal"]
                                                                 selectedImage:[UIImage imageNamed:@"more_highlight"]];
    
    UITabBarController *tabBarController    = [[UITabBarController alloc] init];
    tabBarController.viewControllers        = @[homeNav,channelNav,moreNav];
    tabBarController.tabBar.translucent     = NO;
    tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    
    NSUInteger itemCount = tabBarController.viewControllers.count;
    for (NSUInteger i = 0; i < itemCount-1; ++i) {
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_separator"]];
        separator.bounds = CGRectMake(0, 0, 1, CGRectGetHeight(tabBarController.tabBar.bounds));
        separator.center = CGPointMake(mainWidth/itemCount*(i+1), CGRectGetHeight(tabBarController.tabBar.bounds)/2);
        [tabBarController.tabBar addSubview:separator];
    }
    _window.rootViewController              = tabBarController;
    return _window;
}

- (void)setupCommonStyles {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_background"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-6 forBarMetrics:UIBarMetricsDefault];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
                                   thisVC.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.],
                                                                                                     NSForegroundColorAttributeName:[UIColor whiteColor]};
                                   
                                   thisVC.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    [UITabBarItem aspect_hookSelector:@selector(title)
                          withOptions:AspectPositionInstead
                           usingBlock:^(id<AspectInfo> aspectInfo)
    {
        NSString *title;
        [[aspectInfo originalInvocation] setReturnValue:&title];
    } error:nil];
    
    [UITabBarItem aspect_hookSelector:@selector(imageInsets)
                          withOptions:AspectPositionInstead
                           usingBlock:^(id<AspectInfo> aspectInfo)
    {
        UIEdgeInsets imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        [[aspectInfo originalInvocation] setReturnValue:&imageInsets];
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
    [MobClick startWithAppkey:KB_UMENG_APP_ID reportPolicy:BATCH channelId:KB_CHANNEL_NO];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [WXApi registerApp:KB_WECHAT_APP_ID];
    
    [[KbErrorHandler sharedHandler] initialize];
    [self setupMobStatistics];
    [self setupCommonStyles];
    [self.window makeKeyWindow];
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
    
    [[KbPaymentModel sharedModel] startRetryingToCommitUnprocessedOrders];
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
    [self checkPayment];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [IpaynowPluginApi application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

- (void)checkPayment {
    if ([KbUtil isPaid]) {
        return ;
    }
    
    NSArray<KbPaymentInfo *> *payingPaymentInfos = [KbUtil payingPaymentInfos];
    [payingPaymentInfos enumerateObjectsUsingBlock:^(KbPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KbPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
        if (paymentType == KbPaymentTypeWeChatPay) {
            [self.wechatPayOrderQueryRequest queryOrderWithNo:obj.orderId completionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    KbPaymentViewController *paymentVC = [KbPaymentViewController sharedPaymentVC];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }
            }];
        }
    }];
}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}

@end
