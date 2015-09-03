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
    KbURLResponseNone
};

typedef void (^KbURLResponseHandler)(KbURLResponseStatus respStatus, NSString *errorMessage);

@interface KbURLRequest : NSObject

@property (nonatomic,retain) KbURLResponse *response;

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler;

@end
