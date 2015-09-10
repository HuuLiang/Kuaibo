//
//  KbHomeProgramCell.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeProgramCell.h"

@interface KbHomeProgramCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
}
@end

@implementation KbHomeProgramCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        self.backgroundView = _imageView;
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont boldSystemFontOfSize:10.];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.adjustsFontSizeToFitWidth = YES;
        [_imageView addSubview:_detailLabel];
        {
            [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imageView).with.offset(10);
                make.right.equalTo(_imageView).with.offset(-10);
                make.bottom.equalTo(_imageView).with.offset(-10);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.];
        _titleLabel.textColor = [UIColor whiteColor];
        [_imageView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(_detailLabel);
                make.bottom.equalTo(_detailLabel.mas_top).with.offset(-1);
            }];
        }
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    
    [_imageView sd_setImageWithURL:imageURL];
}

- (void)setTitleText:(NSString *)titleText {
    _titleLabel.text = titleText;
}

- (NSString *)titleText {
    return _titleLabel.text;
}

- (void)setDetailText:(NSString *)detailText {
    _detailLabel.text = detailText;
}

- (NSString *)detailText {
    return _detailLabel.text;
}
@end
