//
//  KbURLRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbURLRequest.h"
#import <AFNetworking.h>

@interface KbURLRequest ()
@property (nonatomic,retain) AFHTTPRequestOperationManager *requestOpManager;
@property (nonatomic,retain) AFHTTPRequestOperation *requestOp;

@property (nonatomic,retain) AFHTTPRequestOperationManager *standbyRequestOpManager;
@property (nonatomic,retain) AFHTTPRequestOperation *standbyRequestOp;

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(NSDictionary *)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(KbURLResponseHandler)responseHandler;
@end

@implementation KbURLRequest

+ (Class)responseClass {
    return [KbURLResponse class];
}

- (NSURL *)baseURL {
    return [NSURL URLWithString:[KbConfig sharedConfig].baseURL];
}

- (NSURL *)standbyBaseURL {
    return [NSURL URLWithString:[KbConfig sharedStandbyConfig].baseURL];
}

- (BOOL)shouldPostErrorNotification {
    return YES;
}

- (KbURLRequestMethod)requestMethod {
    return KbURLGetRequest;
}

-(AFHTTPRequestOperationManager *)requestOpManager {
    if (_requestOpManager) {
        return _requestOpManager;
    }
    
    _requestOpManager = [[AFHTTPRequestOperationManager alloc]
                         initWithBaseURL:[self baseURL]];
    return _requestOpManager;
}

- (AFHTTPRequestOperationManager *)standbyRequestOpManager {
    if (_standbyRequestOpManager) {
        return _standbyRequestOpManager;
    }
    
    _standbyRequestOpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[self standbyBaseURL]];
    return _standbyRequestOpManager;
}

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(NSDictionary *)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(KbURLResponseHandler)responseHandler
{
    if (urlPath.length == 0) {
        if (responseHandler) {
            responseHandler(KbURLResponseFailedByParameter, nil);
        }
        return NO;
    }
    
    DLog(@"Requesting %@ !\nwith parameters: %@\n", urlPath, params);
    
    @weakify(self);
    self.response = [[[[self class] responseClass] alloc] init];
    
    void (^success)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        
        DLog(@"Response for %@ : %@\n", urlPath, responseObject);
        [self processResponseObject:responseObject withResponseHandler:responseHandler];
    };
    
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error for %@ : %@\n", urlPath, error.localizedDescription);
        
        if (shouldNotifyError) {
            if ([self shouldPostErrorNotification]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                                    object:self
                                                                  userInfo:@{kNetworkErrorCodeKey:@(KbURLResponseFailedByNetwork),
                                                                             kNetworkErrorMessageKey:error.localizedDescription}];
            }
        }
        
        if (responseHandler) {
            responseHandler(KbURLResponseFailedByNetwork,error.localizedDescription);
        }
    };
    
    AFHTTPRequestOperation *requestOp;
    if (self.requestMethod == KbURLGetRequest) {
        requestOp = [isStandBy?self.standbyRequestOpManager:self.requestOpManager GET:urlPath parameters:params success:success failure:failure];
    } else {
        requestOp = [isStandBy?self.standbyRequestOpManager:self.requestOpManager POST:urlPath parameters:params success:success failure:failure];
    }
    
    if (isStandBy) {
        self.standbyRequestOp = requestOp;
    } else {
        self.requestOp = requestOp;
    }
    return YES;
}

- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler {
    BOOL useStandbyRequest = standbyUrlPath.length > 0;
    BOOL success = [self requestURLPath:urlPath
                             withParams:params
                              isStandby:NO
                      shouldNotifyError:!useStandbyRequest
                        responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        if (useStandbyRequest && respStatus == KbURLResponseFailedByNetwork) {
            [self requestURLPath:standbyUrlPath withParams:params isStandby:YES shouldNotifyError:YES responseHandler:responseHandler];
        } else {
            if (responseHandler) {
                responseHandler(respStatus,errorMessage);
            }
        }
    }];
    return success;
}

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler
{
    return [self requestURLPath:urlPath standbyURLPath:nil withParams:params responseHandler:responseHandler];
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(KbURLResponseHandler)responseHandler {
    KbURLResponseStatus status = KbURLResponseNone;
    NSString *errorMessage;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([self.response isKindOfClass:[KbURLResponse class]]) {
            KbURLResponse *urlResp = self.response;
            [urlResp parseResponseWithDictionary:responseObject];
            
            status = urlResp.success.boolValue ? KbURLResponseSuccess : KbURLResponseFailedByInterface;
            errorMessage = (status == KbURLResponseSuccess) ? nil : [NSString stringWithFormat:@"ResultCode: %@", urlResp.resultCode];
        } else {
            status = KbURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON dictionary.\n";
        }
        
    } else if ([responseObject isKindOfClass:[NSString class]]) {
        if ([self.response isKindOfClass:[NSString class]]) {
            self.response = responseObject;
            status = KbURLResponseSuccess;
        } else {
            status = KbURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON string.\n";
        }
    } else {
        errorMessage = @"Error data structure of response from interface!\n";
        status = KbURLResponseFailedByInterface;
    }
    
    if (status != KbURLResponseSuccess) {
        DLog(@"Error message : %@\n", errorMessage);
        
        if ([self shouldPostErrorNotification]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                                object:self
                                                              userInfo:@{kNetworkErrorCodeKey:@(status),
                                                                         kNetworkErrorMessageKey:errorMessage}];
        }
    }
    
    if (responseHandler) {
        responseHandler(status, errorMessage);
    }

}
@end
