//
//  KbChannelProgramModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbChannelProgramModel.h"

@implementation KbChannelProgramResponse

@end

@implementation KbChannelProgramModel

+ (Class)responseClass {
    return [KbChannelProgramResponse class];
}

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(KbFetchChannelProgramCompletionHandler)handler {
    @weakify(self);
    NSDictionary *params = @{@"columnId":columnId, @"page":@(pageNo), @"pageSize":@(pageSize)};
    BOOL success = [self requestURLPath:[KbConfig sharedConfig].channelProgramURLPath withParams:params responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        @strongify(self);
        
        KbChannelPrograms *programs;
        if (respStatus == KbURLResponseSuccess) {
            programs = (KbChannelProgramResponse *)self.response;
            self.fetchedPrograms = programs;
        }
        
        if (handler) {
            handler(respStatus==KbURLResponseSuccess, programs);
        }
    }];
    return success;
}

@end
