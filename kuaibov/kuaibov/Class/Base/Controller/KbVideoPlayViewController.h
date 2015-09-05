//
//  KbVideoPlayViewController.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kbBaseController.h"

@class KbVideo;

@interface KbVideoPlayViewController : kbBaseController

- (instancetype)initWithVideo:(KbVideo *)video;

@end
