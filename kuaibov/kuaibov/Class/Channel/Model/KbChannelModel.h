//
//  KbChannelModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbChannel.h"
@interface KbChannelResponse : KbURLResponse
@property (nonatomic,retain) NSMutableArray<KbChannels *> *columnList;

@end

typedef void (^KbFetchChannelsCompletionHandler)(BOOL success, NSArray<KbChannels *> *channels);

@interface KbChannelModel : KbEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray *fetchedChannels;

- (BOOL)fetchChannelsWithCompletionHandler:(KbFetchChannelsCompletionHandler)handler;

@end
