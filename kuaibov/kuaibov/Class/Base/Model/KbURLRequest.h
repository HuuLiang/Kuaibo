//
//  KbURLRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KbURLResponse.h"

typedef NS_ENUM(NSUInteger, KbURLResponseStatus) {
    KbURLResponseSuccess,
    KbURLResponseFailedByInterface,
    KbURLResponseFailedByNetwork,
    KbURLResponseFailedByParsing,
    KbURLResponseNone
};

typedef NS_ENUM(NSUInteger, KbURLRequestMethod) {
    KbURLGetRequest,
    KbURLPostRequest
};
typedef void (^KbURLResponseHandler)(KbURLResponseStatus respStatus, NSString *errorMessage);

@interface KbURLRequest : NSObject

@property (nonatomic,retain) id response;

+ (Class)responseClass;  // override this method to provide a custom class to be used when instantiating instances of KbURLResponse
- (NSURL *)baseURL; // override this method to provide a custom base URL to be used
- (BOOL)shouldPostErrorNotification;
- (KbURLRequestMethod)requestMethod;

- (BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler;

// For subclass pre/post processing response object
- (void)processResponseObject:(id)responseObject withResponseHandler:(KbURLResponseHandler)responseHandler;

@end
