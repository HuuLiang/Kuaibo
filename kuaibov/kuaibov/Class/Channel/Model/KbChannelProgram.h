//
//  KbChannelProgram.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KbProgram.h"

@protocol KbChannelProgram <NSObject>

@end

@interface KbChannelProgram : KbProgram
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@end

@protocol KbChannelPrograms <NSObject>

@end

@interface KbChannelPrograms : KbChannels
//@property (nonatomic) NSNumber *items;
//@property (nonatomic) NSNumber *page;
//@property (nonatomic) NSNumber *pageSize;
@end