//
//  KbPaymentManager.m
//  kuaibov
//
//  Created by Sean Yue on 16/3/11.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbPaymentManager.h"
#import "KbPaymentInfo.h"
#import "KbPaymentViewController.h"
#import "KbProgram.h"
#import "KbPaymentConfigModel.h"
#import "KbSystemConfigModel.h"

#import "WXApi.h"
#import "WeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import "IappPayMananger.h"
#import <PayUtil/PayUtil.h>


typedef NS_ENUM(NSUInteger, KbVIAPayType) {
    KbVIAPayTypeNone,
    KbVIAPayTypeWeChat = 2,
    KbVIAPayTypeQQ = 3,
    KbVIAPayTypeUPPay = 4,
    KbVIAPayTypeShenZhou = 5
};

static NSString *const kAlipaySchemeUrl = @"comKbuaiboappalipayschemeurl";
static NSString *const kIappPaySchemeUrl  = @"comKbuaiboappiaapayschemeurl";

@interface KbPaymentManager () <WXApiDelegate,stringDelegate>
@property (nonatomic,retain) KbPaymentInfo *paymentInfo;
@property (nonatomic,copy) KbPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) WeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@property (nonatomic,retain) KbChannels *payChannel;

@end

@implementation KbPaymentManager

DefineLazyPropertyInitialization(WeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

+ (instancetype)sharedManager {
    static KbPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setup {
    //    [[KbPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
    //        [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:kAlipaySchemeUrl];
    //        [[IapppayAlphaKit sharedInstance] setAppId:[KbPaymentConfig sharedConfig].iappPayInfo.appid mACID:KB_CHANNEL_NO];
    //        [WXApi registerApp:[KbPaymentConfig sharedConfig].weixinInfo.appId];
    //    }];
    
    [[PayUitls getIntents] initSdk];
    [paySender getIntents].delegate = self;
    [IappPayMananger sharedMananger].alipayURLScheme = kIappPaySchemeUrl;
    [[KbPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        
    }];
    
    Class class = NSClassFromString(@"VIASZFViewController");
    if (class) {
        [class aspect_hookSelector:NSSelectorFromString(@"viewWillAppear:")
                       withOptions:AspectPositionAfter
                        usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated)
         {
             UIViewController *thisVC = [aspectInfo instance];
             if ([thisVC respondsToSelector:NSSelectorFromString(@"buy")]) {
                 UIViewController *buyVC = [thisVC valueForKey:@"buy"];
                 [buyVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([obj isKindOfClass:[UIButton class]]) {
                         UIButton *buyButton = (UIButton *)obj;
                         if ([[buyButton titleForState:UIControlStateNormal] isEqualToString:@"购卡支付"]) {
                             [buyButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                         }
                     }
                 }];
             }
         } error:nil];
    }
    
}

- (KbPaymentType)wechatPaymentType {
    if ([KbPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & KbSubtypePayTypeWeChat) {
        return KbPaymentTypeVIAPay;
    }
    //else if ([KbPaymentConfig sharedConfig].wftPayInfo) {
    //        return KbPaymentTypeSPay;
    //    } else if ([KbPaymentConfig sharedConfig].iappPayInfo) {
    //        return KbPaymentTypeIAppPay;
    //    } else if ([KbPaymentConfig sharedConfig].haitunPayInfo) {
    //        return KbPaymentTypeHTPay;
    //    }
    return KbPaymentTypeNone;
}

- (KbPaymentType)alipayPaymentType {
    if ([KbPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & KbSubtypeAlipay) {
        return KbPaymentTypeVIAPay;
    }
    return KbPaymentTypeNone;
}

- (KbPaymentType)cardPayPaymentType {
    if ([KbPaymentConfig sharedConfig].iappPayInfo) {
        return KbPaymentTypeIAppPay;
    }
    return KbPaymentTypeNone;
}

- (KbPaymentType)qqPaymentType {
    if ([KbPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.unsignedIntegerValue & KbSubPayTypeQQ) {
        return KbPaymentTypeVIAPay;
    }
    return KbPaymentTypeNone;
}

- (void)handleOpenURL:(NSURL *)url {
    [[PayUitls getIntents] paytoAli:url];
}

- (KbPaymentInfo *)startPaymentWithType:(KbPaymentType)type
                                subType:(KbSubPayType)subType
                                  price:(NSUInteger)price
                             forProgram:(KbProgram *)program
                        programLocation:(NSUInteger)programLocation
                              inChannel:(KbChannels *)channel
                      completionHandler:(KbPaymentCompletionHandler)handler
{
    if (type == KbPaymentTypeNone) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, nil);
        }
        return nil;
    }
    //        price = 1;
#if DEBUG
    price = 1;
#endif
    NSString *channelNo = KB_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    KbPaymentInfo *paymentInfo = [[KbPaymentInfo alloc] init];
    paymentInfo.contentLocation = @(programLocation+1);
    paymentInfo.columnId = channel.realColumnId;
    paymentInfo.columnType = channel.type;
    
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.payPointType = program.payPointType;
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(KbPaymentStatusPaying);
    paymentInfo.reservedData = KB_PAYMENT_RESERVE_DATA;
    //    if (type == KbPaymentTypeWeChatPay) {
    //        paymentInfo.appId = [KbPaymentConfig sharedConfig].weixinInfo.appId;
    //        paymentInfo.mchId = [KbPaymentConfig sharedConfig].weixinInfo.mchId;
    //        paymentInfo.signKey = [KbPaymentConfig sharedConfig].weixinInfo.signKey;
    //        paymentInfo.notifyUrl = [KbPaymentConfig sharedConfig].weixinInfo.notifyUrl;
    //    }
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    self.payChannel = channel;
    
    BOOL success = YES;
    if (type == KbPaymentTypeVIAPay &&(subType == KbSubPayTypeWeChat || subType == KbSubPayTypeAlipay || subType == KbSubPayTypeQQ)) {
        NSDictionary *viaPayTypeMapping = @{@(KbSubPayTypeAlipay):@(KbVIAPayTypeShenZhou),
                                            @(KbSubPayTypeWeChat):@(KbVIAPayTypeWeChat),
                                            @(KbSubPayTypeQQ):@(KbVIAPayTypeQQ)};
        
        NSString *tradName = @"VIP会员";
        [[PayUitls getIntents ] gotoPayByFee:@(price).stringValue andTradeName:tradName andGoodsDetails:tradName andScheme:kAlipaySchemeUrl andchannelOrderId:[orderNo stringByAppendingFormat:@"$%@", KB_REST_APP_ID] andType:[viaPayTypeMapping[@(subType)] stringValue]
                            andViewControler:[KbUtil currentVisibleViewController]];
    }else if (type == KbPaymentTypeIAppPay){
        @weakify(self);
        IappPayMananger *iAppMgr = [IappPayMananger sharedMananger];
        iAppMgr.appId = [KbPaymentConfig sharedConfig].iappPayInfo.appid;
        iAppMgr.privateKey = [KbPaymentConfig sharedConfig].iappPayInfo.privateKey;
        iAppMgr.waresid = [KbPaymentConfig sharedConfig].iappPayInfo.waresid.stringValue;
        iAppMgr.appUserId = [KbUtil userId].md5 ?: @"UnregisterUser";
        iAppMgr.privateInfo = KB_PAYMENT_RESERVE_DATA;
        iAppMgr.notifyUrl = [KbPaymentConfig sharedConfig].iappPayInfo.notifyUrl;
        iAppMgr.publicKey = [KbPaymentConfig sharedConfig].iappPayInfo.publicKey;
        
        [iAppMgr payWithPaymentInfo:paymentInfo completionHandler:^(PAYRESULT payResult, KbPaymentInfo *paymentInfo) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
        
        
    } else {
        success = NO;
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL,self.paymentInfo);
        }
        
    }
    
    
    return success ? paymentInfo : nil;
}

//- (void)checkPayment {
//    NSArray<KbPaymentInfo *> *payingPaymentInfos = [KbUtil payingPaymentInfos];
//    [payingPaymentInfos enumerateObjectsUsingBlock:^(KbPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        KbPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
//        if (paymentType == KbPaymentTypeWeChatPay) {
//            if (obj.appId.length == 0 || obj.mchId.length == 0 || obj.signKey.length == 0 || obj.notifyUrl.length == 0) {
//                obj.appId = [KbPaymentConfig sharedConfig].weixinInfo.appId;
//                obj.mchId = [KbPaymentConfig sharedConfig].weixinInfo.mchId;
//                obj.signKey = [KbPaymentConfig sharedConfig].weixinInfo.signKey;
//                obj.notifyUrl = [KbPaymentConfig sharedConfig].weixinInfo.notifyUrl;
//            }
//            
//            [self.wechatPayOrderQueryRequest queryPayment:obj withCompletionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
//                if ([trade_state isEqualToString:@"SUCCESS"]) {
//                    KbPaymentViewController *paymentVC = [KbPaymentViewController sharedPaymentVC];
//                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
//                }
//            }];
//        }
//    }];
//}

#pragma mark - IapppayAlphaKitPayRetDelegate
//
//- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
//    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
//                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
//                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
//    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
//    if (!paymentResult) {
//        paymentResult = @(PAYRESULT_UNKNOWN);
//    }
//    
//    if (self.completionHandler) {
//        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
//    }
//}

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

#pragma mark - stringDelegate

- (void)getResult:(NSDictionary *)sender {
    PAYRESULT paymentResult = [sender[@"result"] integerValue] == 0 ? PAYRESULT_SUCCESS : PAYRESULT_FAIL;
    if (paymentResult == PAYRESULT_FAIL) {
        DLog(@"首游时空支付失败：%@", sender[@"info"]);
        //    } else if (paymentResult == PAYRESULT_SUCCESS) {
        //        UIViewController *currentController = [KbUtil currentVisibleViewController];
        //        if ([currentController isKindOfClass:NSClassFromString(@"SZFViewController")]) {
        //            [currentController dismissViewControllerAnimated:YES completion:nil];
        //        }
    }
    
    //    [self onPaymentResult:paymentResult withPaymentInfo:self.paymentInfo];
    
    if (self.completionHandler) {
        if ([NSThread currentThread].isMainThread) {
            self.completionHandler(paymentResult, self.paymentInfo);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionHandler(paymentResult, self.paymentInfo);
            });
        }
    }
}
@end
