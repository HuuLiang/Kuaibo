//
//  KbBannerData.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/4.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KbVideo.h"

@protocol KbBannerData <NSObject>

@end

@interface KbBannerData : KbVideo

@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSNumber *payPointType; // 1、会员注册  2、付费
@property (nonatomic) NSNumber *type; // 1、视频 2、图片 4、wap 5、app下载

@end
