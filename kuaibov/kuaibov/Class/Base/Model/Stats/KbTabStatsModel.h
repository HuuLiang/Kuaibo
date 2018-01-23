//
//  KbTabStatsModel.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbStatsBaseModel.h"

@interface KbTabStatsModel : KbStatsBaseModel

- (BOOL)statsTabWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos completionHandler:(KbCompletionHandler)completionHandler;

@end
