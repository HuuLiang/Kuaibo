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
@end

@implementation KbURLRequest

+ (Class)responseClass {
    return [KbURLResponse class];
}

-(AFHTTPRequestOperationManager *)requestOpManager {
    if (_requestOpManager) {
        return _requestOpManager;
    }
    
    _requestOpManager = [[AFHTTPRequestOperationManager alloc]
                         initWithBaseURL:[NSURL URLWithString:[KbConfig sharedConfig].baseURL]];
    return _requestOpManager;
}

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler {
    if (urlPath.length == 0) {
        return NO;
    }
    
    DLog(@"Requesting %@ !\n", urlPath);
    
    @weakify(self);
    self.response = [[[[self class] responseClass] alloc] init];
    self.requestOp = [self.requestOpManager GET:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        
        DLog(@"Response for %@ : %@\n", urlPath, responseObject);
        [self processResponseObject:responseObject withResponseHandler:responseHandler];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error for %@ : %@\n", urlPath, error.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                            object:self
                                                          userInfo:@{kNetworkErrorCodeKey:@(KbURLResponseFailedByNetwork),
                                                                     kNetworkErrorMessageKey:error.localizedDescription}];
        
        if (responseHandler) {
            responseHandler(KbURLResponseFailedByNetwork,error.localizedDescription);
        }
    }];
    return YES;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                            object:self
                                                          userInfo:@{kNetworkErrorCodeKey:@(status),
                                                                     kNetworkErrorMessageKey:errorMessage}];
    }
    
    if (responseHandler) {
        responseHandler(status, errorMessage);
    }

}
@end
