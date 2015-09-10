//
//  KbSystemConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbURLRequest.h"
#import "KbSystemConfig.h"

@interface KbSystemConfigResponse : KbURLResponse
@property (nonatomic,retain) NSArray<KbSystemConfig> *confis;
@end

typedef void (^KbFetchSystemConfigCompletionHandler)(BOOL success);

@interface KbSystemConfigModel : KbURLRequest

@property (nonatomic) CGFloat payAmount;
@property (nonatomic) NSString *channelTopImage;

+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(KbFetchSystemConfigCompletionHandler)handler;

@end