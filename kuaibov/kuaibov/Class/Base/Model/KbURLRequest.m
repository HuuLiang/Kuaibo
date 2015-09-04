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
@property (nonatomic,retain) Class responseClass;
@end

@implementation KbURLRequest

DefineLazyPropertyInitialization(KbURLResponse, response)

-(AFHTTPRequestOperationManager *)requestOpManager {
    if (_requestOpManager) {
        return _requestOpManager;
    }
    
    _requestOpManager = [[AFHTTPRequestOperationManager alloc]
                         initWithBaseURL:[NSURL URLWithString:[KbConfig sharedConfig].baseURL]];
    return _requestOpManager;
}

- (void)registerResponseClass:(Class)respClass {
    _responseClass = respClass;
}

- (Class)responseClass {
    if (_responseClass) {
        return _responseClass;
    }
    return [KbURLResponse class];
}

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler {
    if (urlPath.length == 0) {
        return NO;
    }
    
    DLog(@"Requesting %@ !\n", urlPath);
    
    NSMutableDictionary *finalParams = params ? params.mutableCopy : [NSMutableDictionary dictionary];
    [finalParams setObject:[KbConfig sharedConfig].channelNo forKey:@"channelNo"];
    
    @weakify(self);
    self.response = [[self.responseClass alloc] init];
    self.requestOp = [self.requestOpManager GET:urlPath parameters:finalParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        
        DLog(@"Response for %@ : %@\n", urlPath, responseObject);
        
        KbURLResponseStatus status = KbURLResponseNone;
        NSString *errorMessage;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self.response parseResponseWithDictionary:responseObject];
            
            status = self.response.success.boolValue ? KbURLResponseSuccess : KbURLResponseFailedByInterface;
            errorMessage = (status == KbURLResponseSuccess) ? nil : [NSString stringWithFormat:@"ResultCode: %@", self.response.resultCode];
        } else {
            errorMessage = @"Error data structure of response from interface!\n";
            status = KbURLResponseFailedByInterface;
        }
        
        if (status != KbURLResponseSuccess) {
            DLog(@"Error for %@ : %@\n", urlPath, errorMessage);
        }
        if (responseHandler) {
            responseHandler(status, errorMessage);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error for %@ : %@\n", urlPath, error.localizedDescription);
        
        if (responseHandler) {
            responseHandler(KbURLResponseFailedByNetwork,error.localizedDescription);
        }
    }];
    return YES;
}

@end
