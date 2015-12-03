//
//  BaiduMobAdWallDelegateProtocol.h
//  BaiduMobAdWallSdkSample
//
//  Created by shao bo on 13-4-9.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

///---------------------------------------------------------------------------------------
/// @name 协议板块
///---------------------------------------------------------------------------------------

@class BaiduMobAdWall;
/**
 *  广告sdk委托协议
 */
@protocol BaiduMobAdWallDelegate<NSObject>

@required
/**
 *  应用的id
 */
- (NSString *)publisherId;

/**
 *  应用的广告位id
 */
- (NSString *)adUnitTag;

@optional


-(NSString *) userName;

/**
 *  启动位置信息
 */
-(BOOL) enableLocation;


@optional
/**
 *  积分墙页面关闭
 */
- (void)offerWallDidClosed;




@end
