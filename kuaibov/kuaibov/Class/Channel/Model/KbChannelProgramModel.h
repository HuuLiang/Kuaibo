//
//  KbChannelProgramModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbURLRequest.h"
#import "KbChannelProgram.h"

@interface KbChannelProgramResponse : KbChannelPrograms

@end

typedef void (^KbFetchChannelProgramCompletionHandler)(BOOL success, KbChannelPrograms *programs);

@interface KbChannelProgramModel : KbURLRequest

@property (nonatomic,retain) KbChannelPrograms *fetchedPrograms;

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                completionHandler:(KbFetchChannelProgramCompletionHandler)handler;

@end
