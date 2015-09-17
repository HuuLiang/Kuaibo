//
//  KbHomeBannerModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbProgram.h"

@interface KbBannerResponse : KbURLResponse
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSMutableArray<KbProgram> *bannerList;
@end

typedef void (^KbFetchBannersCompletionHandler)(BOOL success, NSArray *banners);

@interface KbHomeBannerModel : KbEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray *fetchedBanners;

- (BOOL)fetchBannersWithCompletionHandler:(KbFetchBannersCompletionHandler)handler;

@end
