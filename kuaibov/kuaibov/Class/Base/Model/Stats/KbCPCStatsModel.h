//
//  KbCPCStatsModel.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbStatsBaseModel.h"

@interface KbCPCStatsModel : KbStatsBaseModel

- (BOOL)statsCPCWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos
             completionHandler:(KbCompletionHandler)completionHandler;

@end
