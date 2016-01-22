//
//  KbPaymentPopView.h
//  JQKuaibo
//
//  Created by Sean Yue on 15/12/26.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JQKPaymentAction)(id sender);

@interface KbPaymentPopView : UITableView

@property (nonatomic) NSURL *headerImageURL;

//@property (nonatomic,retain) UIImage *headerImage;
@property (nonatomic,retain) UIImage *footerImage;
//@property (nonatomic,copy) JQKPaymentAction paymentAction;
@property (nonatomic,copy) JQKPaymentAction closeAction;
@property (nonatomic) NSNumber *showPrice;

- (void)addPaymentWithImage:(UIImage *)image title:(NSString *)title available:(BOOL)available action:(JQKPaymentAction)action;
- (CGFloat)viewHeightRelativeToWidth:(CGFloat)width;

@end
