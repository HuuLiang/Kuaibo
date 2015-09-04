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
    return [KbBannerData class];
}

@end

@implementation KbHomeBannerModel

- (BOOL)fetchBannersWithCompletionHandler:(KbFetchBannersCompletionHandler)handler {
    [self registerResponseClass:[KbBannerResponse class]];
    
    @weakify(self);
    BOOL success = [self requestURLPath:[KbConfig sharedConfig].bannerURLPath withParams:nil responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
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
