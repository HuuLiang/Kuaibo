//
//  KbProgram.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KbURLResponse.h"
#import "KbVideo.h"

typedef NS_ENUM(NSUInteger, KbProgramType) {
    KbProgramTypeNone = 0,
    KbProgramTypeVideo = 1,
    KbProgramTypePicture = 2,
    KbProgramTypeAd = 3,
    KbProgramTypeBanner = 4,
    KBprogramTypeFreeVideo = 5
};

@protocol KbProgramUrl <NSObject>

@end

@interface KbProgramUrl : NSObject
@property (nonatomic) NSNumber *programUrlId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *url;
@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *height;
@end

@protocol KbProgram <NSObject>

@end

@interface KbProgram : KbVideo

@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSNumber *payPointType; // 1、会员注册 2、付费
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic,retain) NSArray<KbProgramUrl> *urlList; // type==2有集合，目前为图集url集合

@end

@protocol KbPrograms <NSObject>

@end

@interface KbPrograms : KbURLResponse
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic,retain) NSArray<KbProgram> *programList;
@end

