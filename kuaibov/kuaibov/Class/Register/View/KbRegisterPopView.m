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
@property (nonatomic,retain,readonly) UIView *registeredContentView;
@end

static const CGSize kContentViewSize = {283,206};
static const CGFloat kPaymentBannerHeight = 60;

@implementation KbRegisterPopView
@synthesize registeringContentView = _registeringContentView;
@synthesize registeredContentView = _registeredContentView;

+ (instancetype)sharedInstance {
    static KbRegisterPopView *_sharedRegisterPopView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRegisterPopView = [[KbRegisterPopView alloc] init];
    });
    return _sharedRegisterPopView;
}

- (UIView *)contentViewWithRegistered:(BOOL)isRegistered {
    if (isRegistered && _registeredContentView) {
        return _registeredContentView;
    } else if (!isRegistered && _registeringContentView) {
        return _registeringContentView;
    }
    
    UIView *contentView = [[UIView alloc] init];
    if (isRegistered) {
        _registeredContentView = contentView;
    } else {
        _registeringContentView = contentView;
    }
    
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 3;
    [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:isRegistered?@selector(onTapRegisteredContent):@selector(onTapRegisteringContent)]];
    
    UIImageView *payImageView;
    if (!isRegistered) {
        payImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alipay"]];
        [contentView addSubview:payImageView];
        {
            [payImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.and.bottom.equalTo(contentView);
                make.height.mas_equalTo(kPaymentBannerHeight);
            }];
        }
    }
    
    UIImage *topImage = [UIImage imageNamed:@"register_bg"];
    CGSize targetImageSize = CGSizeMake(kContentViewSize.width,
                                        kContentViewSize.height - (isRegistered ? 0 : kPaymentBannerHeight));
    CGRect croppedRect = CGRectMake(MAX(topImage.size.width-targetImageSize.width, 0),
                                    MAX(topImage.size.height-targetImageSize.height, 0),
                                    targetImageSize.width,
                                    targetImageSize.height);
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[topImage crop:croppedRect]];
    topImageView.layer.cornerRadius = contentView.layer.cornerRadius;
    [contentView addSubview:topImageView];
    {
        [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.top.equalTo(contentView).with.insets(UIEdgeInsetsMake(2, 1, 0, 1));
            make.bottom.equalTo(payImageView?payImageView.mas_top:contentView);
        }];
    }
    return contentView;
}

- (UIView *)registeringContentView {
    return [self contentViewWithRegistered:NO];
}

- (UIView *)registeredContentView {
    return [self contentViewWithRegistered:YES];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlank)]];
        
        [self addSubview:self.registeringContentView];
        {
            [self.registeringContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(kContentViewSize);
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

- (void)showRegisteredContent {
    if (_registeredContentView.superview == self) {
        return ;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.registeringContentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.registeringContentView removeFromSuperview];

        [self addSubview:self.registeredContentView];
        self.registeredContentView.frame = self.registeringContentView.frame;
        self.registeredContentView.alpha = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.registeredContentView.alpha = 1;
        }];
    }];
}

- (void)onTapBlank {
    [self hide];
}

- (void)onTapRegisteringContent {
    if (self.action) {
        self.action();
    }
}

- (void)onTapRegisteredContent {
    [self hide];
}
@end
