//
//  HTPayManager.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/24.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "HTPayManager.h"
#import <AFNetworking.h>
#import "UIView+Loading.h"

static NSString *const kHTOrderUrl = @"http://pay.ylsdk.com/";
static NSString *const kHTCheckUrl = @"http://check.ylsdk.com/";

@interface HTPayManager ()
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSString *channelNo;
@property (nonatomic) NSString *appId;
@end

@implementation HTPayManager

+ (instancetype)sharedManager {
    static HTPayManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)setMchId:(NSString *)mchId
      privateKey:(NSString *)privateKey
       notifyUrl:(NSString *)notifyUrl
       channelNo:(NSString *)channelNo
           appId:(NSString *)appId
{
    _mchId = mchId;
    _privateKey = privateKey;
    _notifyUrl = notifyUrl;
    _channelNo = channelNo;
    _appId = appId;
}

- (void)payWithOrderId:(NSString *)orderId
             orderName:(NSString *)orderName
                 price:(NSUInteger)price
 withCompletionHandler:(KbCompletionHandler)completionHandler
{
    if (self.mchId.length == 0 || self.privateKey.length == 0 || self.notifyUrl.length == 0) {
        SafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    NSMutableDictionary *params = @{@"p0_Cmd":@"Buy", @"p1_MerId":self.mchId, @"p2_Order":orderId, @"p3_Amt":[NSString stringWithFormat:@"%.2f", price / 100.], @"p4_Cur":@"CNY",
                             @"p5_Pid":@"0", @"p6_Pcat":@"0", @"p7_Pdesc":orderName, @"p8_Url":self.notifyUrl, @"p9_SAF":@"0", @"pa_MP":@"0", @"pd_FrpId":@"zsyh",
                             @"pr_NeedResponse":@"1"}.mutableCopy;
    
    NSString *sign = [self signWithParams:params];
    
    [params setObject:sign forKey:@"hmac"];
    [params setObject:@"b" forKey:@"Sjt_Paytype"];
    [params setObject:[NSString stringWithFormat:@"%@$%@", self.channelNo, self.appId] forKey:@"Sjt_UserName"];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    @weakify(self);
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [sessionManager POST:kHTOrderUrl parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        BOOL success = [response[@"error"] isEqual:@9999];
        NSString *urlScheme = response[@"message"];
        
        [[UIApplication sharedApplication].keyWindow endLoading];
        if (!success || urlScheme.length == 0) {
            DLog(@"海豚支付-下单错误：errorCode = %@", response[@"error"]);
            SafelyCallBlock(completionHandler, success, nil);
        } else {
            [UIAlertView bk_showAlertViewWithTitle:@"完成支付后，按[确定]继续。"
                                           message:nil
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex)
            {
                @strongify(self);
                [[UIApplication sharedApplication].keyWindow beginLoading];
                [self checkOrder:orderId withCompletionHandler:^(BOOL success, id obj) {
                    [[UIApplication sharedApplication].keyWindow endLoading];
                    SafelyCallBlock(completionHandler, success, obj);
                }];
            }];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlScheme]];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow endLoading];
        DLog(@"海豚支付-下单错误：%@", error.localizedDescription);
        SafelyCallBlock(completionHandler, NO, error);
    }];
}

- (void)checkOrder:(NSString *)orderId withCompletionHandler:(KbCompletionHandler)completionHandler {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [sessionManager POST:kHTCheckUrl
              parameters:@{@"Sjt_TransID":orderId}
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
    {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        BOOL success = [response[@"status"] isEqual:@"1"];
        SafelyCallBlock(completionHandler, success, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"海豚支付-查询订单错误：%@", error.localizedDescription);
        SafelyCallBlock(completionHandler, NO, error);
    }];
}

- (NSString *)signWithParams:(NSDictionary *)params {
    NSArray *sortedKeys = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableString *paramString = [NSMutableString string];
    [sortedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [paramString appendFormat:@"%@", params[obj]];
    }];
    
    [paramString appendString:self.privateKey];
    return paramString.md5;
}

@end
