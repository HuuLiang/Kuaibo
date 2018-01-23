//
//  KbPaymentTypeCell.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/7/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KbPaymentButton;

@interface KbPaymentTypeCell : UICollectionViewCell

@property (nonatomic,retain,readonly) KbPaymentButton *paymentButton;
@property (nonatomic,copy) KBKAction paymentAction;

@end
