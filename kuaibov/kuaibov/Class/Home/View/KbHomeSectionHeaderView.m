//
//  KbHomeSectionHeaderView.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeSectionHeaderView.h"

@interface KbHomeSectionHeaderView ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
}
@end

@implementation KbHomeSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.kb_borderSide = KbBorderTopSide;
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftdot"]];
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).with.offset(5);
                make.size.mas_equalTo(CGSizeMake(6.5, 16.5));
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imageView.mas_right).with.offset(8.5);
                make.centerY.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (NSString *)title {
    return _titleLabel.text;
}

@end
