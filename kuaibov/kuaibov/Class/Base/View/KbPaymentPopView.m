//
//  KbPaymentPopView.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/13.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "KbPaymentPopView.h"

static const NSUInteger kRegisteringDetailLabelTag = 1;
static const CGFloat kBackButtonInsets = 10;

@interface KbPaymentPopView ()
@property (nonatomic,retain,readonly) UIView *paymentContentView;

@property (nonatomic,readonly) CGSize contentViewSize;
@property (nonatomic,readonly) CGSize imageSize;
@property (nonatomic,readonly) CGRect priceRect;

@property (nonatomic,readonly) CGSize payButtonSize;
@property (nonatomic,readonly) CGSize backButtonSize;
@property (nonatomic,readonly) CGPoint alipayButtonOrigin;
@property (nonatomic,readonly) CGPoint wechatPayButtonOrigin;
@end

@implementation KbPaymentPopView (Size)

- (CGSize)payButtonSize {
    return CGSizeMake(self.imageSize.width * 252. / 695., self.imageSize.height * 156. / 861.);
}

- (CGSize)backButtonSize {
    return CGSizeMake(self.imageSize.width * 81. / 695. + kBackButtonInsets * 2,
                      self.imageSize.height * 80. / 861. + kBackButtonInsets * 2);
}

- (CGSize)imageSize {
    const CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width * 0.9;
    return CGSizeMake(imageWidth, imageWidth*861./695.);
}

- (CGSize)contentViewSize {
    return self.imageSize;
}

- (CGRect)priceRect {
    return CGRectMake(self.imageSize.width * 0.7,
                      self.imageSize.height * 0.365,
                      self.imageSize.width * 0.2,
                      self.imageSize.height * 0.08);
}

- (CGPoint)alipayButtonOrigin {
    return CGPointMake(self.imageSize.width * 0.65, self.imageSize.height * 0.56);
}

- (CGPoint)wechatPayButtonOrigin {
    return CGPointMake(self.alipayButtonOrigin.x, self.imageSize.height * 0.72);
}
@end

@implementation KbPaymentPopView
@synthesize paymentContentView = _paymentContentView;

+ (instancetype)sharedInstance {
    static KbPaymentPopView *_sharedPaymentPopView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentPopView = [[KbPaymentPopView alloc] init];
    });
    return _sharedPaymentPopView;
}

- (UIView *)paymentContentView {
    if (_paymentContentView) {
        return _paymentContentView;
    }
    
    _paymentContentView = [[UIView alloc] init];
    _paymentContentView.backgroundColor = [UIColor clearColor];
    _paymentContentView.layer.cornerRadius = 3;
    
    UIImage *image = [UIImage imageNamed:@"payment"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_paymentContentView addSubview:imageView];
    {
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_paymentContentView);
            make.bottom.equalTo(_paymentContentView).offset(-18);
        }];
    }
    
    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.tag = kRegisteringDetailLabelTag;
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.font = [UIFont boldSystemFontOfSize:20.];
    priceLabel.textColor = [UIColor redColor];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.adjustsFontSizeToFitWidth = YES;
    [_paymentContentView addSubview:priceLabel];
    {
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_paymentContentView).offset(self.priceRect.origin.x);
            make.top.equalTo(_paymentContentView).offset(self.priceRect.origin.y);
            make.size.mas_equalTo(self.priceRect.size);
        }];
    }
    
    UIButton *alipayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [alipayButton setImage:[UIImage imageNamed:@"payment_go_normal"] forState:UIControlStateNormal];
    [alipayButton setImage:[UIImage imageNamed:@"payment_go_highlight"] forState:UIControlStateHighlighted];
    [alipayButton addTarget:self action:@selector(onAlipay) forControlEvents:UIControlEventTouchUpInside];
    [_paymentContentView addSubview:alipayButton];
    {
        [alipayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_paymentContentView).offset(self.alipayButtonOrigin.x);
            make.top.equalTo(_paymentContentView).offset(self.alipayButtonOrigin.y);
            make.size.mas_equalTo(self.payButtonSize);
        }];
    }
    
    UIButton *wechatPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [wechatPayButton setImage:[UIImage imageNamed:@"payment_go_normal"] forState:UIControlStateNormal];
    [wechatPayButton setImage:[UIImage imageNamed:@"payment_go_highlight"] forState:UIControlStateHighlighted];
    [wechatPayButton addTarget:self action:@selector(onWeChatPay) forControlEvents:UIControlEventTouchUpInside];
    [_paymentContentView addSubview:wechatPayButton];
    {
        [wechatPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_paymentContentView).offset(self.wechatPayButtonOrigin.x);
            make.top.equalTo(_paymentContentView).offset(self.wechatPayButtonOrigin.y);
            make.size.mas_equalTo(self.payButtonSize);
        }];
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"payment_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(kBackButtonInsets, kBackButtonInsets, kBackButtonInsets, kBackButtonInsets);
    [_paymentContentView addSubview:backButton];
    {
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(_paymentContentView).offset(5);
            make.size.mas_equalTo(self.backButtonSize);
        }];
    }
    return _paymentContentView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        //[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlank)]];
        
        [self addSubview:self.paymentContentView];
        {
            [self.paymentContentView mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)setShowPrice:(double)showPrice {
    _showPrice = showPrice;
    
    UILabel *detailLabel = (UILabel *)[_paymentContentView viewWithTag:kRegisteringDetailLabelTag];
    detailLabel.text = [NSString stringWithFormat:@"%.2f", showPrice];
}

- (void)onAlipay {
    if (self.action) {
        self.action(KbPaymentTypeAlipay);
    }
}

- (void)onWeChatPay {
    if (self.action) {
        self.action(KbPaymentTypeWeChatPay);
    }
}
@end
