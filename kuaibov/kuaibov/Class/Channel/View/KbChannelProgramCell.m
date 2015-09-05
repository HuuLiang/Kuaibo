//
//  KbChannelProgramCell.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbChannelProgramCell.h"

@interface KbChannelProgramCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
}
@end

@implementation KbChannelProgramCell

+ (NSString *)reusableIdentifier {
    return @"ChannelProgramCellReusableIdentifier";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).with.offset(6.5);
                make.size.mas_equalTo(CGSizeMake(93, 71));
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.];
        _titleLabel.textColor = HexColor(#393939);
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imageView.mas_right).with.offset(9.5);
                make.top.equalTo(self).with.offset(12.5);
                make.right.equalTo(self).with.offset(-6.5);
                make.height.mas_equalTo(_titleLabel.font.pointSize);
            }];
        }
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:14.];
        _descLabel.textColor = HexColor(#adadad);
        [self addSubview:_descLabel];
        {
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).with.offset(15.5);
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    [_imageView sd_setImageWithURL:imageURL];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (NSString *)title {
    return _titleLabel.text;
}

- (void)setDetail:(NSString *)detail {
    _descLabel.text = detail;
}

- (NSString *)detail {
    return _descLabel.text;
}

@end
