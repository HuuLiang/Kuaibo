//
//  KbHomeChannelCell.m
//  kuaibov
//
//  Created by ylz on 16/7/21.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "KbHomeChannelCell.h"

@implementation KbHomeChannelCell
{
    UILabel *_titleLabel;
    UIImageView *_coverImage;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame]) {
        
        UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover"]];
//        coverImageView.alpha = 0.2;
//        [self addSubview:backImageView];
//        {
//            [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.mas_equalTo(self);
//            }];
//            
//        }
        self.backgroundView = backImageView;
        _coverImage = [[UIImageView alloc] init];
         [_coverImage YPB_addAnimationForImageAppearing];
        [backImageView addSubview:_coverImage];
        {
            [_coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(backImageView);
                make.left.mas_equalTo(backImageView).mas_offset(1.5);
                make.right.bottom.mas_equalTo(backImageView).mas_offset(-1.5);
            }];
        }
        
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self addSubview:coverView];
        {
            [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(_coverImage);
            }];
            
        }
  
        UIImageView *channelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"channelBtn"]];
        [coverView addSubview:channelImageView];
        {
            [channelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(_coverImage);
                make.bottom.mas_equalTo(_coverImage).mas_offset(-11);
                make.width.mas_equalTo(88./375.*kScWidth);
                make.height.mas_equalTo(23/667.*kScHeight);
            }];
            
        }
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC" size:17./375.*kScWidth];

        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [coverView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(channelImageView.mas_top).mas_offset(-10);
                make.centerX.mas_equalTo(channelImageView);
            }];
            
        }
        
        UIImageView *leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftArrow"]];
        [coverView addSubview:leftArrow];
        {
            [leftArrow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(_titleLabel.mas_left).mas_offset(-3);
                make.centerY.mas_equalTo(_titleLabel.mas_centerY);
//                make.left.mas_equalTo(_coverImage).mas_offset(10);
                make.width.mas_equalTo(41/375.*kScWidth);
                make.height.mas_equalTo(3);
            }];
        }
        UIImageView *rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow"]];
        [coverView addSubview:rightArrow];
        {
            [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_titleLabel.mas_right).mas_offset(3);
                make.centerY.mas_equalTo(_titleLabel.mas_centerY);
                //                make.left.mas_equalTo(_coverImage).mas_offset(10);
                make.width.mas_equalTo(41/375.*kScWidth);
                make.height.mas_equalTo(3);
            }];
        }
    }
 
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    [_coverImage sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"cover"]];
}

@end
