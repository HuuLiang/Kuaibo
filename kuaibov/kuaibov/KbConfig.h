//
//  KbConfig.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/29.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#ifndef KbConfig_h
#define KbConfig_h
#import "KbConfiguration.h"

#define KB_CHANNEL_NO           [KbConfiguration sharedConfig].channelNo
#define KB_PACKAGE_CERTIFICATE  @"iPhone Distribution: Shanghai Yueyang Business Service Co., Ltd."

#define KB_REST_APP_ID          @"QUBA_2001"
#define KB_REST_PV              @200
#define KB_REST_APP_VERSION     ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]))

#define KB_BASE_URL             @"http://iv.ihuiyx.com"
#define KB_HOME_PAGE_URL        @"/iosvideo/homePage.htm"
#define KB_CHANNEL_URL          @"/iosvideo/channelRanking.htm"
#define KB_CHANNEL_PROGRAM_URL  @"/iosvideo/program.htm"
#define KB_AGREEMENT_URL        @"/iosvideo/agreement.html"
#define KB_ACTIVATE_URL         @"/iosvideo/activat.htm"
#define KB_SYSTEM_CONFIG_URL    @"/iosvideo/systemConfig.htm"
#define KB_USER_ACCESS_URL      @"/iosvideo/userAccess.htm"
#define KB_ALIPAY_CONFIG_URL    @"/iosvideo/aliConfig.htm"
#define KB_WECHATPAY_CONFIG_URL @"/iosvideo/weixinConfig.htm"

#define KB_PAYMENT_SIGN_URL     @"http://phas.ihuiyx.com/pd-has/signtureNowdata.json"
#define KB_PAYMENT_COMMIT_URL   @"http://pay.iqu8.net/paycenter/qubaPr.json"
#define KB_PAYMENT_RESERVE_DATA [NSString stringWithFormat:@"%@$%@", KB_REST_APP_ID, KB_CHANNEL_NO]

#define KB_STANDBY_BASE_URL             @"http://7xomw1.com2.z0.glb.qiniucdn.com"
#define KB_STANDBY_HOME_PAGE_URL        @"/iosvideo/homePage.json"
#define KB_STANDBY_CHANNEL_URL          @"/iosvideo/channelRanking.json"
#define KB_STANDBY_CHANNEL_PROGRAM_URL  @"/iosvideo/program_%@_%@.json"
#define KB_STANDBY_AGREEMENT_URL        @"/iosvideo/agreement1.html"
#define KB_STANDBY_SYSTEM_CONFIG_URL    @"/iosvideo/systemConfig.json"
#define KB_STANDBY_ALIPAY_CONFIG_URL    @"/iosvideo/weixinConfig.json"
#define KB_STANDBY_WECHATPAY_CONFIG_URL @"/iosvideo/aliConfig.json"

//#define KB_PAYNOW_SCHEME        @"comyeyekuaiboapppaynowurlscheme"

#define KB_WECHAT_APP_ID        @"wx4af04eb5b3dbfb56"
#define KB_WECHAT_MCH_ID        @"1281148901"
#define KB_WECHAT_PRIVATE_KEY   @"hangzhouquba20151112qwertyuiopas"
#define KB_WECHAT_NOTIFY_URL    @"http://phas.ihuiyx.com/pd-has/notifyWx.json"

#define KB_SYSTEM_CONFIG_PAY_AMOUNT         @"PAY_AMOUNT"
#define KB_SYSTEM_CONFIG_PAY_IMG            @"PAY_IMG"
#define KB_SYSTEM_CONFIG_CHANNEL_TOP_IMAGE  @"CHANNEL_TOP_IMG"
#define KB_SYSTEM_CONFIG_STARTUP_INSTALL    @"START_INSTALL"
#define KB_SYSTEM_CONFIG_SPREAD_TOP_IMAGE   @"SPREAD_TOP_IMG"
#define KB_SYSTEM_CONFIG_SPREAD_URL         @"SPREAD_URL"

//#define KB_BAIDU_AD_APP_ID      @"a39921a8"
//#define KB_BAIDU_BANNER_AD_ID   @"2340965"
#define KB_UMENG_APP_ID         @"565bc5bee0f55a13a60011b1"

#endif /* KbConfig_h */
