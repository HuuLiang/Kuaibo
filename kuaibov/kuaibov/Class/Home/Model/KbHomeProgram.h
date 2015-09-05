//
//  KbHomeProgram.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KbHomeProgramUrl <NSObject>

@end

@interface KbHomeProgramUrl : NSObject
@property (nonatomic) NSNumber *programUrlId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *url;
@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *height;
@end

@protocol KbHomeProgram <NSObject>

@end

@interface KbHomeProgram : NSObject

@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *specialDesc;
@property (nonatomic) NSString *coverImg;
@property (nonatomic) NSString *videoUrl; // type == 1 有值
@property (nonatomic) NSNumber *payPointType; // 1、会员注册 2、付费
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic,retain) NSArray<KbHomeProgramUrl> *urlList; // type==2有集合，目前为图集url集合

@end

@protocol KbHomePrograms <NSObject>

@end

@interface KbHomePrograms : NSObject
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic,retain) NSArray<KbHomeProgram> *programList;
@end
