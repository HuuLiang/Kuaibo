//
//  KbBannerView.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/4.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KbBannerItem : NSObject
@property (nonatomic) NSString *imageURLString;
@property (nonatomic) NSString *title;

+ (instancetype)itemWithImageURLString:(NSString *)urlString title:(NSString *)title;

@end

@interface KbBannerView : UIView

@property (nonatomic,retain) NSArray *items;
@property (nonatomic) NSTimeInterval autoPlayTimeInterval;

- (instancetype)initWithItems:(NSArray *)items autoPlayTimeInterval:(NSTimeInterval)timeInterval;

@end
