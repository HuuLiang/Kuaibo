//
//  IappPayMananger.m
//  Kbuaibo
//
//  Created by Sean Yue on 16/6/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "IappPayMananger.h"
#import <IapppayH5Kit/IapppayH5OrderUtils.h>
#import <IapppayH5Kit/IapppayH5Kit.h>
#import "KbPaymentInfo.h"
#import "UIView+Loading.h"

static NSString *const kIappPreOrderURL = @"http://ipay.iapppay.com:9999/payapi/order";

@interface IappPayMananger () <IapppayH5KitPayRetDelegate>
@property (nonatomic,copy) KbPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) KbPaymentInfo *paymentInfo;
@end

@implementation IappPayMananger

+ (instancetype)sharedMananger {
    static IappPayMananger *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)payWithPaymentInfo:(KbPaymentInfo *)paymentInfo completionHandler:(KbPaymentCompletionHandler)completionHandler {
    IapppayH5OrderUtils *order = [[IapppayH5OrderUtils alloc] init];
    order.appId = self.appId;
    order.cpPrivateKey = self.privateKey;
    order.cpOrderId = paymentInfo.orderId;
    order.waresId = self.waresid;
    order.price = [NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice.unsignedIntegerValue/100.];
    order.appUserId = self.appUserId;
    order.cpPrivateInfo = self.privateInfo;
    order.notifyUrl = self.notifyUrl;

    NSString *trandData = [order getTrandData];
    @weakify(self);
    
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [self preOrderWithTrandInfo:trandData completionHandler:^(NSString *trandsId, NSError *error) {
        [[UIApplication sharedApplication].keyWindow endLoading];
        @strongify(self);
        if (trandsId.length > 0) {
            self.completionHandler = completionHandler;
            self.paymentInfo = paymentInfo;
            [[IapppayH5Kit sharedInstance] makePayWithTrandsId:trandsId
                                                   redirecturl:order.notifyUrl
                                                  cpPrivateKey:order.cpPrivateKey
                                                   payDelegate:self];
        } else {
            [[KbHudManager manager] showHudWithText:error.domain];
            SafelyCallBlock(completionHandler, PAYRESULT_FAIL, paymentInfo);
        }
    }];
}

- (void)preOrderWithTrandInfo:(NSString *)trandInfo completionHandler:(void(^)(NSString *trandsId,NSError *error))completionHandler {
    NSData *data = [trandInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:kIappPreOrderURL];
    NSMutableURLRequest *myRequest = [NSMutableURLRequest requestWithURL:url
                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                         timeoutInterval:15];
    [myRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [myRequest setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [myRequest setHTTPMethod:@"POST"];
    [myRequest setHTTPBody:data];
    
    //发送请求
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionTask = nil;
    sessionTask = [session dataTaskWithRequest:myRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //请求结果处理
            if (([data length] > 0) && (connectionError == nil))
            {
                //成功返回数据,执行解析响应体操作
                NSString *transdata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                transdata = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                  (__bridge CFStringRef)transdata,
                                                                                                                  CFSTR(""),
                                                                                                                  CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));;
                
                transdata = [transdata stringByReplacingOccurrencesOfString:@"transdata=" withString:@""];
                DLog(@"爱贝支付预下单返回数据：%@", transdata);
                
                NSDictionary *object = [[self class] OrderUtilsObjectWithJsonString:transdata];
                if ((object != nil) && ([object[@"code"] integerValue] == 1001))
                {
                    //获取transid失败
                    NSString *message = [NSString stringWithFormat:@"%@",object[@"errmsg"]];
                    NSError *otherError = [NSError errorWithDomain:message
                                                              code:1001
                                                          userInfo:nil];
                    if (completionHandler) completionHandler(nil,otherError);
                }
                else
                {
                    NSRange range = [transdata rangeOfString:@"\"transid\":\""];
                    NSRange lastRange = [transdata rangeOfString:@"\"}&sign"];
                    
                    if ((range.location != NSNotFound) && (lastRange.location != NSNotFound))
                    {
                        NSUInteger location = range.location+range.length;
                        NSUInteger length = lastRange.location-location;
                        
                        NSString *transId = [transdata substringWithRange:NSMakeRange(location,length)];
                        
                        if (completionHandler) completionHandler(transId,nil);
                    }
                    else
                    {
                        //获取transid失败
                        NSError *otherError = [NSError errorWithDomain:@"服务器返回数据错误，请重试"
                                                                  code:-1
                                                              userInfo:nil];
                        if (completionHandler) completionHandler(nil,otherError);
                    }
                }
            }
            else if (([data length] == 0) && (connectionError == nil))
            {
                //没有数据
                NSError *otherError = [NSError errorWithDomain:@"没有获取到数据，请稍后再试"
                                                          code:-1
                                                      userInfo:nil];
                if (completionHandler) completionHandler(nil,otherError);
                
            }
            else if (connectionError != nil)
            {
                //超时
                NSString *message = @"网络访问错误,请检查网络";
                if (connectionError.code == NSURLErrorTimedOut)
                {
                    message = @"网络访问超时,请检查网络";
                }
                
                NSError *otherError = [NSError errorWithDomain:message
                                                          code:-1
                                                      userInfo:nil];
                if (completionHandler) completionHandler(nil,otherError);
            }
            else
            {
                //其他错误
                NSError *otherError = [NSError errorWithDomain:@"网络访问错误，请稍后再试"
                                                          code:-1
                                                      userInfo:nil];
                if (completionHandler) completionHandler(nil,otherError);
            }
        });
    }];
    
    //开始请求
    [sessionTask resume];
}

+ (id)OrderUtilsObjectWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error) {
        NSAssert(error != nil, @"json解析失败：%@", error);
        return nil;
    }
    return object;
}
#pragma mark - IapppayH5KitPayRetDelegate

- (void)iapppayH5KitRetPayStatusCode:(IapppayH5PayRetCodeType)statusCode
                          resultInfo:(NSDictionary *)resultInfo {
    NSDictionary *paymentStatusMapping = @{@(IAPPPAY_H5_PAYRETCODE_SUCCESS):@(PAYRESULT_SUCCESS),
                                           @(IAPPPAY_H5_PAYRETCODE_FAILED):@(PAYRESULT_FAIL),
                                           @(IAPPPAY_H5_PAYRETCODE_CANCEL):@(PAYRESULT_ABANDON)};
    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
    if (!paymentResult) {
        paymentResult = @(PAYRESULT_UNKNOWN);
    }
    
    NSString *signature = [resultInfo objectForKey:@"Signature"];
    if (paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
        if (![IapppayH5OrderUtils checkPayResult:signature withAppKey:self.publicKey]) {
            DLog(@"支付成功，但是延签失败！");
            paymentResult = @(PAYRESULT_FAIL);
        }
    }
    SafelyCallBlock(self.completionHandler, paymentResult.unsignedIntegerValue, self.paymentInfo);
    self.completionHandler = nil;
    self.paymentInfo = nil;
}

@end
