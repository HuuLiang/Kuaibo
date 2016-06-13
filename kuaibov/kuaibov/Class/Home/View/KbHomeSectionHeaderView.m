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
//    UIImageView *_separatorView;
    UIView *_backgroundView;
    UILabel *_titleLabel;
}
@end

@implementation KbHomeSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
//        _separatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_section_separator"]];
//        [self addSubview:_separatorView];
//        {
//            [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.equalTo(self);
//                make.top.equalTo(self).offset(kDefaultItemSpacing);
//                make.height.mas_equalTo(4);
//            }];
//        }
//        
//        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_section_background"]];
//        [self insertSubview:_backgroundView belowSubview:_separatorView];
//        {
//            [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(_separatorView);
//                make.left.equalTo(self);
//                make.bottom.equalTo(self).offset(-kDefaultItemSpacing);
//                make.width.equalTo(_backgroundView.mas_height).multipliedBy(4);
//            }];
//        }
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithHexString:@"#ff0066"];
        [self addSubview:_backgroundView];
        {
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.top.mas_equalTo(self).mas_offset(6);
            make.bottom.mas_equalTo(self).mas_offset(-3);
            make.width.mas_equalTo(100);
        }];
        
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.];
        [_backgroundView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_backgroundView);
                make.centerX.equalTo(_backgroundView).mas_offset(-8);
            }];
        }
//        _titleLabel.textAlignment = NSTextAlignmentCenter;
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor colorWithHexString:@"#ff0066"];
        [_backgroundView addSubview:bottomView];
        {
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.bottom.mas_equalTo(_backgroundView);
            make.height.mas_equalTo(1.5);
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
