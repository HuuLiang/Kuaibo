//
//  KbHomeCollectionViewLayout.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KbHomeCollectionViewLayoutDelegate <NSObject>

@optional
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface KbHomeCollectionViewLayout : UICollectionViewFlowLayout <UICollectionViewDelegateFlowLayout>

@property (nonatomic,assign) id<KbHomeCollectionViewLayoutDelegate> delegate;

- (instancetype)initWithDelegate:(id<KbHomeCollectionViewLayoutDelegate>)delegate;

@end
