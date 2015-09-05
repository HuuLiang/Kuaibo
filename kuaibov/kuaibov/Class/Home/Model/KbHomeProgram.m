//
//  KbHomeProgram.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeProgram.h"

@implementation KbHomeProgramUrl

@end

@implementation KbHomeProgram

- (Class)urlListElementClass {
    return [KbHomeProgramUrl class];
}

@end

@implementation KbHomePrograms

- (Class)programListElementClass {
    return [KbHomeProgram class];
}

@end