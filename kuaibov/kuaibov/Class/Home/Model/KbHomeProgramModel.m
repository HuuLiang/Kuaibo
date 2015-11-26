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

- (BOOL)fetchHomeProgramsWithCompletionHandler:(KbFetchHomeProgramsCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:[KbConfig sharedConfig].homeProgramURLPath standbyURLPath:[KbConfig sharedStandbyConfig].homeProgramURLPath withParams:nil responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        @strongify(self);
        
        NSArray *programs;
        if (respStatus == KbURLResponseSuccess) {
            KbHomeProgramResponse *resp = (KbHomeProgramResponse *)self.response;
            programs = resp.columnList;
            self->_fetchedProgramList = programs;
        }
        
        if (handler) {
            handler(respStatus==KbURLResponseSuccess, programs);
        }
    }];
    return success;
}

@end
