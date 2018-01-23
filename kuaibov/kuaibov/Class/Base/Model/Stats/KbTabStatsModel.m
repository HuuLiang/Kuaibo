//
//  KbTabStatsModel.m
//  Kbuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbTabStatsModel.h"

@implementation KbTabStatsModel

- (BOOL)statsTabWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos
             completionHandler:(KbCompletionHandler)completionHandler
{
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler,NO,@"No validated statsInfos to Commit!");
        return NO;
    }
    
    BOOL ret = [self requestURLPath:Kb_STATS_TAB_URL
                         withParams:params
                    responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage)
    {
        SafelyCallBlock(completionHandler, respStatus == KbURLResponseSuccess, errorMessage);
    }];
    return ret;
}

@end
