//
//  KbHomeProgramCell.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/16.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KbHomeProgramItemPosition) {
    KbHomeProgramLeftItem,
    KbHomeProgramRightTopItem,
    KbHomeProgramRightBottomItem
};

@interface KbHomeProgramItem : NSObject
@property (nonatomic) NSString *imageURL;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;

+ (instancetype)itemWithImageURL:(NSString *)imageURL title:(NSString *)title subtitle:(NSString *)subtitle;

@end

typedef void (^KbHomeProgramCellAction)(KbHomeProgramItemPosition position);

@interface KbHomeProgramCell : UITableViewCell

@property (nonatomic,copy) KbHomeProgramCellAction action;

+ (CGFloat)imageScale;
- (void)setItem:(KbHomeProgramItem *)item atPosition:(KbHomeProgramItemPosition)position;

@end
