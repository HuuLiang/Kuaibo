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
@property (nonatomic,retain) NSArray<KbPrograms> *columnList;
@end

typedef void (^KbFetchHomeProgramsCompletionHandler)(BOOL success, NSArray *programs);

@interface KbHomeProgramModel : KbEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<KbPrograms *> *fetchedProgramList;
@property (nonatomic,retain,readonly) NSArray<KbPrograms *> *fetchedVideoAndAdProgramList;

@property (nonatomic,retain,readonly) NSArray<KbProgram *> *fetchedBannerPrograms;

- (BOOL)fetchHomeProgramsWithCompletionHandler:(KbFetchHomeProgramsCompletionHandler)handler;

@end
