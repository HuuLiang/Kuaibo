//
//  KbChannelProgramModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "KbChannelProgram.h"

@interface KbChannelProgramResponse : KbChannelPrograms

@end

typedef void (^KbFetchChannelProgramCompletionHandler)(BOOL success, KbChannelPrograms *programs);

@interface KbChannelProgramModel : KbEncryptedURLRequest

@property (nonatomic,retain) KbChannelPrograms *fetchedPrograms;

- (BOOL)fetchProgramsWithColumnId:(NSNumber *)columnId
                           pageNo:(NSUInteger)pageNo
                         pageSize:(NSUInteger)pageSize
                completionHandler:(KbFetchChannelProgramCompletionHandler)handler;

@end
