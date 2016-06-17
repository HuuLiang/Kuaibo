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
    return [KbChannels class];
}

@end

@implementation KbChannelModel

+ (Class)responseClass {
    return [KbChannelResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        KbChannelResponse *resp = self.response;
        _fetchedChannels = resp.columnList;
    }
    return self;
}

- (BOOL)fetchChannelsWithCompletionHandler:(KbFetchChannelsCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:KB_CHANNEL_URL
                         standbyURLPath:KB_STANDBY_CHANNEL_URL
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
