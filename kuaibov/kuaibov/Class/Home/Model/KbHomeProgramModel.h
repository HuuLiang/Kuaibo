//
//  KbHomeProgramModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbProgram.h"

@interface KbHomeProgramResponse : KbURLResponse
@property (nonatomic,retain) NSArray<KbChannels *> *columnList;
@end

typedef void (^KbFetchHomeProgramsCompletionHandler)(BOOL success, NSArray *programs);

@interface KbHomeProgramModel : KbEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<KbChannels *> *fetchedProgramList;
@property (nonatomic,retain,readonly) NSArray<KbChannels *> *fetchedVideoAndAdProgramList;

@property (nonatomic,retain,readonly) NSArray<KbChannels *> *fetchedBannerPrograms;

- (BOOL)fetchHomeProgramsWithCompletionHandler:(KbFetchHomeProgramsCompletionHandler)handler;

@end
