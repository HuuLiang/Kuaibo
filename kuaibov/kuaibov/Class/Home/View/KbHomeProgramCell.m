//
//  KbHomeProgramCell.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/16.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbHomeProgramCell.h"
#import "KbHomeProgramItemView.h"

@implementation KbHomeProgramItem

+ (instancetype)itemWithImageURL:(NSString *)imageURL title:(NSString *)title subtitle:(NSString *)subtitle {
    if (imageURL.length == 0) {
        return nil;
    }
    
    KbHomeProgramItem *item = [[self alloc] init];
    item.imageURL = imageURL;
    item.title = title;
    item.subtitle = subtitle;
    return item;
}

@end

@interface KbHomeProgramCell ()
@property (nonatomic,retain) NSMutableDictionary<NSNumber *, KbHomeProgramItemView *> *imageViews;
@end

@implementation KbHomeProgramCell

DefineLazyPropertyInitialization(NSMutableDictionary, imageViews)

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setItem:(KbHomeProgramItem *)item atPosition:(KbHomeProgramItemPosition)position {
    KbHomeProgramItemView *itemView = self.imageViews[@(position)];
    if (!itemView) {
        itemView = [[KbHomeProgramItemView alloc] init];
        [self.imageViews setObject:itemView forKey:@(position)];
        [self addSubview:itemView];
        [self setConstraintsOfItemView:itemView atPosition:position];
        
        @weakify(self);
        [itemView bk_whenTapped:^{
            @strongify(self);
            if (self.action) {
                self.action(position,itemView.tag);
            }
        }];
    }
    
    itemView.imageURL = [NSURL URLWithString:item.imageURL];
    itemView.titleText = item.title;
    itemView.detailText = item.subtitle;
}

- (void)setConstraintsOfItemView:(KbHomeProgramItemView *)itemView atPosition:(KbHomeProgramItemPosition)position {
    switch (position) {
        case KbHomeProgramLeftItem:
        {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(self);
                make.bottom.equalTo(self).offset(-kDefaultItemSpacing);
                make.width.equalTo(itemView.mas_height).multipliedBy([[self class] imageScale]);
//                make.width.equalTo(self).offset(-kDefaultItemSpacing/2).multipliedBy(2./3.);
            }];
            itemView.tag = 0;
            break;
        }
        case KbHomeProgramRightTopItem:
        {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.top.equalTo(self);
                //make.width.equalTo(self).offset(-kDefaultItemSpacing/2).multipliedBy(1./3.);
                make.height.equalTo(self).offset(-kDefaultItemSpacing).multipliedBy(0.5);
                make.width.equalTo(itemView.mas_height).multipliedBy([[self class] imageScale]);
            }];
            itemView.tag = 1;
            break;
        }
        case KbHomeProgramRightBottomItem:
        {
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-kDefaultItemSpacing);
                //make.width.equalTo(self).offset(-kDefaultItemSpacing/2).multipliedBy(1./3.);
                make.height.equalTo(self).offset(-kDefaultItemSpacing).multipliedBy(0.5);
                make.width.equalTo(itemView.mas_height).multipliedBy([[self class] imageScale]);
            }];
            itemView.tag = 2;
            break;
        }
        default:
            break;
    }
}

+ (CGFloat)imageScale {
    return 230./168.;
}

@end
