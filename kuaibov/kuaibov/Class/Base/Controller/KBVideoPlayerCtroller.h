//
//  KBVideoPlayerCtroller.h
//  kuaibov
//
//  Created by ylz on 16/6/13.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "kbBaseController.h"

@interface KBVideoPlayerCtroller : kbBaseController

@property (nonatomic,retain,readonly) KbProgram *video;
@property (nonatomic) BOOL shouldPopupPaymentIfNotPaid;

- (instancetype)initWithVideo:(KbProgram *)video;

@end