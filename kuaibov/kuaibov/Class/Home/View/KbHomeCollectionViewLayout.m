//
//  KbHomeCollectionViewLayout.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHomeCollectionViewLayout.h"

static const CGFloat kItemSpacing = 5;
static const CGFloat kProgramThumbnailScale = 230.0 / 168.0;

@interface KbHomeCollectionViewLayout ()
@property (nonatomic,readonly) CGSize bannerSize;
@property (nonatomic,readonly) CGSize halfItemSize;
@property (nonatomic,readonly) CGSize quarterItemSize;


@end

@implementation KbHomeCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = kItemSpacing;
        self.minimumLineSpacing = kItemSpacing;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<KbHomeCollectionViewLayoutDelegate>)delegate {
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
}

//-(CGSize)collectionViewContentSize {
//    CGSize contentSize = [super collectionViewContentSize];
//    
//    CGFloat cutHeight = 0;
//    NSUInteger numberOfSections = self.collectionView.numberOfSections;
//    for (NSUInteger section = 1; section < numberOfSections; ++section) {
//        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
//        if (numberOfItems > 1 && numberOfItems % 2 == 1) {
//            cutHeight += (self.quarterItemSize.height+kItemSpacing);
//        }
//    }
//    return CGSizeMake(contentSize.width, contentSize.height - cutHeight);
//}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *layoutAttrib = [super layoutAttributesForItemAtIndexPath:indexPath];
//    [self customizeLayoutAttributes:layoutAttrib];
//    return layoutAttrib;
//}
//
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray *layoutAttrs = [super layoutAttributesForElementsInRect:rect];
//    for (UICollectionViewLayoutAttributes *layoutAttr in layoutAttrs) {
//        [self customizeLayoutAttributes:layoutAttr];
//    }
//    return layoutAttrs;
//}

- (void)customizeLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttr {
    if (layoutAttr.indexPath.section == 0 || layoutAttr.indexPath.item == 0) {
        return ;
    }
    
    if (layoutAttr.indexPath.item == 1) {
        layoutAttr.center = CGPointMake(layoutAttr.center.x,
                                        layoutAttr.center.y - (layoutAttr.size.height+kItemSpacing)/2);
    } else if (layoutAttr.indexPath.item % 2 == 0) {
        layoutAttr.center = CGPointMake(layoutAttr.center.x + layoutAttr.size.width + kItemSpacing,
                                        layoutAttr.center.y - layoutAttr.size.height - kItemSpacing);
    } else {
        layoutAttr.center = CGPointMake(layoutAttr.center.x - layoutAttr.size.width - kItemSpacing,
                                        layoutAttr.center.y);
    }
}

- (CGSize)bannerSize {
    return CGSizeMake(mainWidth, mainWidth / 2 + 36);
}

- (CGSize)halfItemSize {
    CGSize itemSize = CGSizeZero;
    itemSize.width = (mainWidth - kItemSpacing * 3) / 2;
    itemSize.height = itemSize.width * kProgramThumbnailScale;
    return itemSize;
}

- (CGSize)quarterItemSize {
    return CGSizeMake(self.halfItemSize.width, (self.halfItemSize.height - kItemSpacing) / 2);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(mainWidth, mainWidth / 2);
    } else {
        return /* indexPath.item == 0 ? self.halfItemSize : */self.quarterItemSize;
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(0, 0, 10, 0);
    } else {
        return UIEdgeInsetsMake(0, kItemSpacing, kItemSpacing, kItemSpacing);
    }
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    } else {
        return CGSizeMake(mainWidth, 33);
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        cell.kb_borderSide = KbBorderBottomSide;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}
@end
