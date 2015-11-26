//
//  KbChannelModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbChannelModel.h"

@implementation KbChannelResponse

- (Class)columnListElementClass {
    return [KbChannel class];
}

@end

@implementation KbChannelModel

+ (Class)responseClass {
    return [KbChannelResponse class];
}
- (BOOL)fetchChannelsWithCompletionHandler:(KbFetchChannelsCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:[KbConfig sharedConfig].channelURLPath
                         standbyURLPath:[KbConfig sharedStandbyConfig].channelURLPath
                             withParams:nil
                        responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        if (respStatus == KbURLResponseSuccess) {
            KbChannelResponse *channelResp = (KbChannelResponse *)self.response;
            self->_fetchedChannels = channelResp.columnList;
            
            if (handler) {
                handler(YES, self->_fetchedChannels);
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
