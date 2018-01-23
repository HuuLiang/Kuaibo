//
//  paySender.h
//  WxAndAli
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol stringDelegate<NSObject>
-(void)getResult:(NSDictionary *)sender;
@end

@interface paySender : NSObject
@property (assign,nonatomic)id<stringDelegate> delegate;
+(paySender*)getIntents;

@end
