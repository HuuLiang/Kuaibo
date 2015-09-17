//
//  KbChannel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KbChannelType) {
    KbChannelTypeNone = 0,
    KbChannelTypeVideo = 1,
    KbChannelTypePicture = 2
};

@protocol KbChannel <NSObject>

@end

@interface KbChannel : NSObject

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;

@end
