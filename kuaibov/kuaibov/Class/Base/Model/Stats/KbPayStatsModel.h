//
//  KbPayStatsModel.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbStatsBaseModel.h"

@interface KbPayStatsModel : KbStatsBaseModel

- (BOOL)statsPayWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos completionHandler:(KbCompletionHandler)completionHandler;

@end
