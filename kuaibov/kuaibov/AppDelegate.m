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
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayManager.h"
#import "WeChatPayManager.h"
#import "KbActivateModel.h"
#import "KbPaymentModel.h"
#import "WXApi.h"
#import "KbAlipayOrderQueryRequest.h"
#import "KbWeChatPayQueryOrderRequest.h"
#import "KbUserAccessModel.h"
#import "MobClick.h"

#ifdef EnableBaiduMobAd
#import "BaiduMobAdSplash.h"
#endif

@interface AppDelegate () <WXApiDelegate
#ifdef EnableBaiduMobAd
,BaiduMobAdSplashDelegate
#endif
>
@property (nonatomic,retain) KbAlipayOrderQueryRequest *alipayOrderQueryRequest;
@property (nonatomic,retain) KbWeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;

#ifdef EnableBaiduMobAd
@property (nonatomic,retain) BaiduMobAdSplash *splashAd;
#endif
@end

@implementation AppDelegate

DefineLazyPropertyInitialization(KbAlipayOrderQueryRequest, alipayOrderQueryRequest)
DefineLazyPropertyInitialization(KbWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

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
    [WXApi registerApp:[KbConfig sharedConfig].weChatPayAppId];
    
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
    
    NSArray *order = [KbUtil orderForSavePending];
    if (order.count == KbPendingOrderItemCount) {
        [self paidWithOrderId:order[KbPendingOrderId] price:order[KbPendingOrderPrice] result:PAYRESULT_SUCCESS forProgramId:order[KbPendingOrderProgramId] programType:order[KbPendingOrderProgramType] payPointType:order[KbPendingOrderPayPointType] paymentType:((NSNumber *)order[KbPendingOrderPaymentType]).unsignedIntegerValue];
    }
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
    [self checkPayment];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        [[AlipayManager shareInstance] sendNotificationByResult:resultDic];
    }];
    [WXApi handleOpenURL:url delegate:self];

    return YES;
}

- (void)checkPayment {
    NSString *payingOrderNo = [KbUtil payingOrderNo];
    KbPaymentType payingType = [KbUtil payingOrderPaymentType];
    if (![KbUtil isPaid] && payingOrderNo && payingType != KbPaymentTypeNone) {
        if (payingType == KbPaymentTypeWeChatPay) {
            [self.wechatPayOrderQueryRequest queryOrderWithNo:payingOrderNo completionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName
                                                                        object:nil
                                                                      userInfo:@{kPaidNotificationOrderNoKey:payingOrderNo,
                                                                                 kPaidNotificationPriceKey:@(total_fee).stringValue,
                                                                                 kPaidNotificationPaymentType:@(KbPaymentTypeWeChatPay)}];
                }
            }];
        }
        
    }
}

- (void)paidWithOrderId:(NSString *)orderId
                  price:(NSString *)price
                 result:(NSInteger)result
           forProgramId:(NSString *)programId
            programType:(NSString *)programType
           payPointType:(NSString *)payPointType
            paymentType:(KbPaymentType)paymentType {
    
    NSString *eventName;
    if (result == PAYRESULT_ABANDON) {
        eventName = [KbConfig sharedConfig].umengCancelledPaymentEventId;
    } else if (result == PAYRESULT_FAIL) {
        eventName = [KbConfig sharedConfig].umengFailedPaymentEventId;
    } else if (result == PAYRESULT_SUCCESS) {
        eventName = [KbConfig sharedConfig].umengSuccessfulPaymentEventId;
    }
    
    NSString *eventLabel;
    if (paymentType == KbPaymentTypeAlipay) {
        eventLabel = @"支付宝";
    } else if (paymentType == KbPaymentTypeWeChatPay) {
        eventLabel = @"微信支付";
    }
    
    if (eventName && eventLabel) {
        [MobClick event:eventName label:eventLabel];
    }
    
    [[KbPaymentModel sharedModel] paidWithOrderId:orderId price:price result:result contentId:programId contentType:programType payPointType:payPointType paymentType:paymentType completionHandler:^(BOOL success){
        if (success && result == PAYRESULT_SUCCESS) {
            [KbUtil setPaid];
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

#ifdef EnableBaiduMobAd
#pragma mark - BaiduMobAdSplashDelegate

- (NSString *)publisherId {
    return [KbConfig sharedConfig].baiduAdAppId;
}
#endif
@end
