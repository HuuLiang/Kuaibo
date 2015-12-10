//
//  KbSystemConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbSystemConfig.h"

@interface KbSystemConfigResponse : KbURLResponse
@property (nonatomic,retain) NSArray<KbSystemConfig> *confis;
@end

typedef void (^KbFetchSystemConfigCompletionHandler)(BOOL success);

@interface KbSystemConfigModel : KbEncryptedURLRequest

@property (nonatomic) double payAmount;
@property (nonatomic) NSString *channelTopImage;

@property (nonatomic) NSString *startupInstall;
@property (nonatomic) NSString *startupPrompt;

+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(KbFetchSystemConfigCompletionHandler)handler;

@end
