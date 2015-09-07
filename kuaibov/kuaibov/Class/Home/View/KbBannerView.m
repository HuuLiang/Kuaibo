//
//  KbBannerView.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/4.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbBannerView.h"

@implementation KbBannerItem

+ (instancetype)itemWithImageURLString:(NSString *)urlString title:(NSString *)title {
    KbBannerItem *newItem = [[self alloc] init];
    newItem.imageURLString = urlString;
    newItem.title = title;
    return newItem;
}

@end

@interface KbBannerView () <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UILabel *_titleLabel;
    UIView *_indicatorView;
}
@property (nonatomic,retain) NSTimer *autoPlayTimer;
@property (nonatomic,retain) NSMutableArray *imageViews;
@property (nonatomic,readonly) NSUInteger currentPage;
@end

static const CGSize kIndicatorDotNormalSize = {2,2};
static const CGSize kIndicatorDotHighlightSize = {4,4};

@implementation KbBannerView

DefineLazyPropertyInitialization(NSMutableArray, imageViews)

- (instancetype)init {
    self = [super init];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        {
            [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.and.top.equalTo(self);
                make.height.equalTo(self.mas_width).with.dividedBy(2);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).with.offset(22);
                make.top.equalTo(_scrollView.mas_bottom).with.offset(10);
            }];
        }
        
        _indicatorView = [[UIView alloc] init];
        [self addSubview:_indicatorView];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)]];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items
         autoPlayTimeInterval:(NSTimeInterval)timeInterval
                       action:(KbBannerViewSelectAction)action {
    self = [self init];
    if (self) {
        _autoPlayTimeInterval = timeInterval;
        _items = items;
        _action = action;
        
        [self updateImageViews];
        [self updateIndicatorView];
        [self autoPlayImagesFromBeginning];
    }
    return self;
}

- (void)actionTap {
    if (self.action) {
        self.action(self.currentPage);
    }
}

- (NSUInteger)currentPage {
    CGFloat offsetX = _scrollView.contentOffset.x;
    CGFloat scrollWidth = _scrollView.frame.size.width;
    return round(offsetX / scrollWidth);
}

- (void)autoPlayImagesFromBeginning {
    [self stopAutoPlayingImages];
    
    if (self.autoPlayTimeInterval < 1 || self.items.count < 2) {
        return ;
    }
    
    _scrollView.contentOffset = CGPointZero;
    _scrollView.contentSize   = CGSizeMake(CGRectGetWidth(_scrollView.frame) * self.items.count,
                                           CGRectGetHeight(_scrollView.frame));
    
    [self onPageScrolled];
    self.autoPlayTimer        = [NSTimer scheduledTimerWithTimeInterval:self.autoPlayTimeInterval target:self selector:@selector(onTick) userInfo:nil repeats:YES];
}

- (void)autoPlayImages {
    if (self.autoPlayTimeInterval < 1 || self.items.count < 2) {
        return ;
    }
    
    self.autoPlayTimer        = [NSTimer scheduledTimerWithTimeInterval:self.autoPlayTimeInterval target:self selector:@selector(onTick) userInfo:nil repeats:YES];
}

- (void)stopAutoPlayingImages {
    [self.autoPlayTimer invalidate];
    self.autoPlayTimer = nil;
}

- (void)onTick {
    NSUInteger nextPage = self.currentPage + 1;
    if (nextPage == self.imageViews.count) {
        nextPage = 0;
    }
    
    UIImageView *visibleImageView = self.imageViews[nextPage];
    [_scrollView scrollRectToVisible:visibleImageView.frame animated:nextPage!=0];
}

- (void)setItems:(NSArray *)items {
    _items = items;
    
    [self updateImageViews];
    [self updateIndicatorView];
    [self autoPlayImagesFromBeginning];
}

- (void)setAutoPlayTimeInterval:(NSTimeInterval)autoPlayTimeInterval {
    _autoPlayTimeInterval = autoPlayTimeInterval;
    
    [self autoPlayImagesFromBeginning];
}

- (void)updateImageViews {
    [self stopAutoPlayingImages];
    // Clear image views:
    for (UIImageView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
    
    // Reconstruct image views:
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KbBannerItem *item = obj;
        [self addImageViewForScrollingFromURLString:item.imageURLString];
    }];
}

- (void)updateIndicatorView {
    for (UIView *subview in _indicatorView.subviews) {
        [subview removeFromSuperview];
    }
    
    const NSUInteger dotCount = self.imageViews.count;
    if (dotCount == 0) {
        return ;
    }
    
    const CGFloat interspaceBetweenDots = 8;
    for (NSUInteger idx = 0; idx < dotCount; ++idx) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"] highlightedImage:[UIImage imageNamed:@"dot_sel"]];
        imageView.frame = CGRectOffset(CGRectMake(0, 0, kIndicatorDotNormalSize.width, kIndicatorDotNormalSize.height),
                                       (kIndicatorDotNormalSize.width + interspaceBetweenDots) * idx, 0);
        imageView.tag = idx+1;
        [_indicatorView addSubview:imageView];
    }
    
    [_indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleLabel);
        make.right.equalTo(self).with.offset(-5);
        make.size.mas_equalTo(CGSizeMake((kIndicatorDotNormalSize.width + interspaceBetweenDots) * dotCount,
                                         kIndicatorDotNormalSize.height));
    }];
}

- (void)onPageScrolled {
    
    NSUInteger pageIdx = self.currentPage;
    _titleLabel.text = ((KbBannerItem *)self.items[pageIdx]).title;

    [_indicatorView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = obj;
            if (imageView.highlighted) {
                imageView.highlighted = NO;
                imageView.bounds = CGRectMake(0, 0, kIndicatorDotNormalSize.width, kIndicatorDotNormalSize.height);
                *stop = YES;
            }
        }
    }];
    
    NSUInteger highlightImageViewTag = self.currentPage + 1;
    UIImageView *highlightImageView = (UIImageView *)[_indicatorView viewWithTag:highlightImageViewTag];
    highlightImageView.highlighted = YES;
    highlightImageView.bounds = CGRectMake(0, 0, kIndicatorDotHighlightSize.width, kIndicatorDotHighlightSize.height);
}

- (UIImageView *)addImageViewForScrollingFromURLString:(NSString *)urlString {
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    imageView.frame = CGRectOffset(CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height),
                                   self.bounds.size.width * self.imageViews.count, 0);
    [_scrollView addSubview:imageView];
    
    [self.imageViews addObject:imageView];
    return imageView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoPlayingImages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self autoPlayImages];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self onPageScrolled];
}
@end
