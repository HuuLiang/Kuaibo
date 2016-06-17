//
//  KbChannel.h
//  kuaibov
//
//  Created by ylz on 16/6/17.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbURLResponse.h"

@interface KbChannels : KbURLResponse

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *realColumnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnDesc;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSString *spreadUrl;
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@property (nonatomic,retain) NSArray<KbProgram *> *programList;

//+ (NSString *)cryptPasswordForProperty:(NSString *)propertyName withInstance:(id)instance;

//@property (nonatomic) NSNumber *columnId;
//@property (nonatomic) NSString *name;
//@property (nonatomic) NSString *columnImg;
//@property (nonatomic) NSNumber *type; // 1、视频 2、图片
//@property (nonatomic) NSNumber *showNumber;
//@property (nonatomic,retain) NSArray<KbProgram> *programList;

@end
