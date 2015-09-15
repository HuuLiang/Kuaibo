//
//  KbPaymentModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "Order.h"

typedef void (^KbPaidCompletionHandler)(BOOL success);

@interface KbPaymentModel : KbEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)paidWithOrderId:(NSString *)orderId
                  price:(NSString *)price
                 result:(NSInteger)result
              contentId:(NSString *)contentId
            contentType:(NSString *)contentType
           payPointType:(NSString *)payPointType
      completionHandler:(KbPaidCompletionHandler)handler;

@end
