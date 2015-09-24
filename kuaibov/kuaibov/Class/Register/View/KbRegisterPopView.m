//
//  KbRegisterPopView.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbRegisterPopView.h"
#import "UIImage+crop.h"

@interface KbRegisterPopView ()
@property (nonatomic,retain,readonly) UIView *registeringContentView;

@property (nonatomic,readonly) CGSize contentViewSize;
@property (nonatomic,readonly) CGSize buttonSize;
@property (nonatomic,readonly) CGSize imageSize;
@property (nonatomic,readonly) CGRect priceRect;
@end

@implementation KbRegisterPopView (Size)

- (CGSize)buttonSize {
    const CGFloat buttonHeight = 35;
    return CGSizeMake(buttonHeight*187./70., buttonHeight);
}

- (CGSize)imageSize {
    const CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width * 0.9;
    return CGSizeMake(imageWidth, imageWidth*217.5/322.);
}

- (CGSize)contentViewSize {
    return CGSizeMake(self.imageSize.width,
                      self.imageSize.height+self.buttonSize.height/2);
}

- (CGRect)priceRect {
    return CGRectMake(self.imageSize.width/322.*39.,
                      self.imageSize.height/217.5*126.,
                      self.imageSize.width/322.*38.,
                      self.imageSize.height/217.5*22.);
}
@end

static const NSUInteger kRegisteringDetailLabelTag = 1;

@implementation KbRegisterPopView
@synthesize registeringContentView = _registeringContentView;

+ (instancetype)sharedInstance {
    static KbRegisterPopView *_sharedRegisterPopView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRegisterPopView = [[KbRegisterPopView alloc] init];
    });
    return _sharedRegisterPopView;
}

- (UIView *)registeringContentView {
    if (_registeringContentView) {
        return _registeringContentView;
    }
    
    _registeringContentView = [[UIView alloc] init];
    _registeringContentView.backgroundColor = [UIColor clearColor];
    _registeringContentView.layer.cornerRadius = 3;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg_01" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_registeringContentView addSubview:imageView];
    {
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_registeringContentView);
            make.bottom.equalTo(_registeringContentView).offset(-18);
        }];
    }
    
    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.tag = kRegisteringDetailLabelTag;
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.font = [UIFont boldSystemFontOfSize:18.];
    priceLabel.textColor = [UIColor redColor];
    priceLabel.textAlignment = NSTextAlignmentRight;
    priceLabel.adjustsFontSizeToFitWidth = YES;
    [_registeringContentView addSubview:priceLabel];
    {
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_registeringContentView).offset(self.priceRect.origin.x);
            make.top.equalTo(_registeringContentView).offset(self.priceRect.origin.y);
            make.size.mas_equalTo(self.priceRect.size);
        }];
    }
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *okImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_quedin" ofType:@"png"]];
    [okButton setImage:okImage forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(onRegister) forControlEvents:UIControlEventTouchUpInside];
    [_registeringContentView addSubview:okButton];
    {
        [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_registeringContentView);
            make.centerX.equalTo(_registeringContentView).with.dividedBy(2);
            make.size.mas_equalTo(self.buttonSize);
        }];
    }
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *cancelImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_quxiao" ofType:@"png"]];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [_registeringContentView addSubview:cancelButton];
    {
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.bottom.equalTo(okButton);
            make.centerX.equalTo(_registeringContentView).with.multipliedBy(1.5);
        }];
    }
    return _registeringContentView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        //[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlank)]];
        
        [self addSubview:self.registeringContentView];
        {
            [self.registeringContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(self.contentViewSize);
            }];
        }
        
        
    }
    return self;
}

- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)onRegister {
    if (self.action) {
        self.action();
    }
}

- (void)setShowPrice:(CGFloat)showPrice {
    _showPrice = showPrice;
    
    UILabel *detailLabel = (UILabel *)[_registeringContentView viewWithTag:kRegisteringDetailLabelTag];
    detailLabel.text = [NSString stringWithFormat:@"%.2f", showPrice];
}
@end
