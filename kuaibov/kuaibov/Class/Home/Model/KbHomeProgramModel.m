//
//  KbHomeProgramModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeProgramModel.h"

@implementation KbHomeProgramResponse

- (Class)columnListElementClass {
    return [KbPrograms class];
}

@end

@implementation KbHomeProgramModel

+ (Class)responseClass {
    return [KbHomeProgramResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        KbHomeProgramResponse *resp = (KbHomeProgramResponse *)self.response;
        _fetchedProgramList = resp.columnList;
        
        [self filterProgramTypes];
    }
    return self;
}

- (BOOL)fetchHomeProgramsWithCompletionHandler:(KbFetchHomeProgramsCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:KB_HOME_PAGE_URL
                         standbyURLPath:KB_STANDBY_HOME_PAGE_URL
                             withParams:nil
                        responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (!self) {
            return ;
        }
        
        NSArray *programs;
        if (respStatus == KbURLResponseSuccess) {
            KbHomeProgramResponse *resp = (KbHomeProgramResponse *)self.response;
            programs = resp.columnList;
            self->_fetchedProgramList = programs;
            
            [self filterProgramTypes];
        }
        
        if (handler) {
            handler(respStatus==KbURLResponseSuccess, programs);
        }
    }];
    return success;
}

- (void)filterProgramTypes {
    _fetchedVideoAndAdProgramList = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                           {
                                               KbProgramType type = ((KbPrograms *)obj).type.unsignedIntegerValue;
                                               return type == KbProgramTypeVideo || type == KbProgramTypeAd || type == KbProgramTypeFree;
                                           }];
    
    NSArray<KbPrograms *> *bannerProgramList = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                                {
                                                    KbProgramType type = ((KbPrograms *)obj).type.unsignedIntegerValue;
                                                    return type == KbProgramTypeBanner;
                                                }];
    
    NSMutableArray *bannerPrograms = [NSMutableArray array];
    [bannerProgramList enumerateObjectsUsingBlock:^(KbPrograms * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.programList.count > 0) {
            [bannerPrograms addObjectsFromArray:obj.programList];
        }
    }];
    _fetchedBannerPrograms = bannerPrograms;
}
@end
