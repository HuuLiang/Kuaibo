//
//  KbCPCStatsModel.m
//  Kbuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbCPCStatsModel.h"


@implementation KbCPCStatsModel

- (BOOL)statsCPCWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos
             completionHandler:(KbCompletionHandler)completionHandler
{
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler, NO, @"No validated statsInfos to Commit!");
        return NO;
    }

    BOOL ret = [self requestURLPath:Kb_STATS_CPC_URL
                         withParams:params
                    responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
                {
                    SafelyCallBlock(completionHandler, respStatus==KbURLResponseSuccess, errorMessage);
                }];
    return ret;
}

@end
