//
//  KbHomeSectionHeaderView.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/16.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbHomeSectionHeaderView.h"

@interface KbHomeSectionHeaderView ()
{
    UIImageView *_separatorView;
    UIImageView *_backgroundView;
    UILabel *_titleLabel;
}
@end

@implementation KbHomeSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _separatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_section_separator"]];
        [self addSubview:_separatorView];
        {
            [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.top.equalTo(self).offset(kDefaultItemSpacing);
                make.height.mas_equalTo(4);
            }];
        }
        
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_section_background"]];
        [self insertSubview:_backgroundView belowSubview:_separatorView];
        {
            [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_separatorView);
                make.left.equalTo(self);
                make.bottom.equalTo(self).offset(-kDefaultItemSpacing);
                make.width.equalTo(_backgroundView.mas_height).multipliedBy(4);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.];
        [_backgroundView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_backgroundView);
                make.centerX.equalTo(_backgroundView).offset(-10);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

@end
