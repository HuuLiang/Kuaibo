//
//  KbChannelProgramCell.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KbChannelProgramCell : UITableViewCell

@property (nonatomic,retain) NSURL *imageURL;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *detail;

+ (NSString *)reusableIdentifier;

@end
