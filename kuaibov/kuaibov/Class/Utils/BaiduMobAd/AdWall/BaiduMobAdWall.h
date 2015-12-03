//
//  BaiduMobAdWall.h
//  BaiduMobAdWallSdk
//
//  Created by shao bo on 13-4-9.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMobAdWallDelegateProtocol.h"

@interface BaiduMobAdWall : NSObject{
    @private
    id<BaiduMobAdWallDelegate> _delegate;
    

}

/**
 *  积分请求失败 error code
 */
typedef enum _BaiduMobWallFailCode
{
    BaiduMobWallFailCode_NOT_ENOUGH = -1,
    //积分不足
    BaiduMobWallFailCode_EXCEPTION = -2
    //网络或其它异常
} BaiduMobWallFailCode;


typedef void (^BaiduMobAdWallCompletionBlock)(NSInteger result, NSError *error);
///---------------------------------------------------------------------------------------
/// @name 属性
///---------------------------------------------------------------------------------------

/**
 *  委托对象
 */
@property (nonatomic ,assign) id<BaiduMobAdWallDelegate>  delegate;

/**
 *  SDK版本
 */
@property (nonatomic, readonly) NSString* Version;

/**
 * 打开积分墙
 */
- (void)showOffers;

/**
 * 查询积分
 */
- (void)getPointsWithCompletion:(BaiduMobAdWallCompletionBlock)block;
/**
 * 赚取积分
 */
- (void)earnPoints:(NSInteger)point withCompletion:(BaiduMobAdWallCompletionBlock)block;
/**
 * 消费积分
 */
- (void)spendPoints:(NSInteger)point withCompletion:(BaiduMobAdWallCompletionBlock)block;

@end
