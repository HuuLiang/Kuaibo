//
//  KbHomeBannerModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeBannerModel.h"

@implementation KbBannerResponse

- (Class)bannerListElementClass {
    return [KbProgram class];
}

@end

@implementation KbHomeBannerModel
@synthesize fetchedBanners = _fetchedBanners;

DefineLazyPropertyInitialization(NSArray, fetchedBanners)

+ (Class)responseClass {
    return [KbBannerResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        KbBannerResponse *resp = (KbBannerResponse *)self.response;
        _fetchedBanners = resp.bannerList;
    }
    return self;
}

- (BOOL)fetchBannersWithCompletionHandler:(KbFetchBannersCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:[KbConfig sharedConfig].bannerURLPath standbyURLPath:[KbConfig sharedStandbyConfig].bannerURLPath withParams:nil responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        @strongify(self);
        
        if (respStatus == KbURLResponseSuccess) {
            KbBannerResponse *resp = (KbBannerResponse *)self.response;
            self->_fetchedBanners = resp.bannerList;
            
            if (handler) {
                handler(YES, self->_fetchedBanners);
            }
        } else {
            if (handler) {
                handler(NO, nil);
            }
        }
    }];
    return success;
}

@end
