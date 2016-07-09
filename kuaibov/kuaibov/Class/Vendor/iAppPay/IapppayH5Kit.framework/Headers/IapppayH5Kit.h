//
//  IapppayH5Kit.h
//  IapppayH5Demo
//
//  Created by Shixiong on 15/11/18.
//  Copyright © 2015年 爱贝. All rights reserved.
//

////////////////////////////////////////////////////////
///////////version：H5混搭 date：2015.11.19///////////////
////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 爱贝支付结果Code
typedef enum IapppayH5PayRetCodeType : NSInteger {
    IAPPPAY_H5_PAYRETCODE_CANCEL  = 99,    //支付取消
    IAPPPAY_H5_PAYRETCODE_FAILED  = -1,    //支付失败
    IAPPPAY_H5_PAYRETCODE_SUCCESS = 0      //支付成功
} IapppayH5PayRetCodeType;

@protocol IapppayH5KitPayRetDelegate <NSObject>

@optional
/**
 * 爱贝支付结果返回
 * @statusCode = "支付结果code"
 * @resultInfo = {RetCode:"错误码",ErrorMsg:"错误信息",Signature:"支付成功的密文，需要验签"}
 **/
- (void)iapppayH5KitRetPayStatusCode:(IapppayH5PayRetCodeType)statusCode
                          resultInfo:(NSDictionary *)resultInfo;

@end

@interface IapppayH5Kit : NSObject



/**
 * 创建SDK接入对象
 **/
+ (IapppayH5Kit *)sharedInstance;



/**
 * 设置爱贝支付窗口的方向(支持横屏和竖屏)
 * 横屏：UIInterfaceOrientationMaskLandscape
 *      UIInterfaceOrientationMaskLandscapeLeft
 *      UIInterfaceOrientationMaskLandscapeRight
 * 竖屏：UIInterfaceOrientationMaskPortrait
 *
 * 注意：
 *      设置的方向需要在app的info.plist中存在，否则导致设置方向无效，也可能会导致崩溃。
 *      只设置支持横屏的应用，需要在AppDelegate中实现application:supportedInterfaceOrientationsForWindow:方法
 *      可不设置支付方向，会根据app的info.plist自动适应
 **/
- (void)setIapppayH5PayWindowOrientationMask:(UIInterfaceOrientationMask)orientationMask;



/**
 * 调起爱贝支付进行支付
 * @params:trandsId      计费支付平台的交易流水号(参照爱贝SDK服务端接入文档)
 * @params:redirecturl   支付成功后支付回调URL地址(参照爱贝SDK服务端接入文档)
 * @params:cpPrivateKey  应用私钥(参照爱贝SDK服务端接入文档)
 * @params:payDelegate   支付结果处理对象
 *
 * @return:flag  是否成功进入爱贝支付界面
 **/
- (NSInteger)makePayWithTrandsId:(NSString *)trandsId
                     redirecturl:(NSString *)redirecturl
                    cpPrivateKey:(NSString *)cpPrivateKey
                     payDelegate:(id<IapppayH5KitPayRetDelegate>)payDelegate;


@end
