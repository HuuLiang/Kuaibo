//
//  PayNowDef.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/8.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#ifndef PayNowDef_h
#define PayNowDef_h

typedef NS_ENUM(NSUInteger, PayNowChannelType) {
    PayNowChannelTypeUnspecified,
    PayNowChannelTypeUPPay = 11, //银联支付
    PayNowChannelTypeAlipay = 12,
    PayNowChannelTypeWeChatPay = 13
};

#define kPayNowNormalOrderType  @"01"
#define kPayNowRMBCurrencyType  @"156"
#define kPayNowDefaultCharset   @"UTF-8"

#endif /* PayNowDef_h */
