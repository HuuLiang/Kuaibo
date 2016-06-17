//
//  KbStatsManager.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KbStatsPayAction) {
    KbStatsPayActionUnknown,
    KbStatsPayActionClose,
    KbStatsPayActionGoToPay,
    KbStatsPayActionPayBack
};

@class KbStatsInfo;
@class KbChannel;
@interface KbStatsManager : NSObject

+ (instancetype)sharedManager;

- (void)addStats:(KbStatsInfo *)statsInfo;
- (void)removeStats:(NSArray<KbStatsInfo *> *)statsInfos;
- (void)scheduleStatsUploadWithTimeInterval:(NSTimeInterval)timeInterval;

// Helper Methods
- (void)statsCPCWithChannel:(KbChannels *)channel inTabIndex:(NSUInteger)tabIndex;
- (void)statsCPCWithProgram:(KbProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(KbChannels *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex;

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forClickCount:(NSUInteger)clickCount;
- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forSlideCount:(NSUInteger)slideCount;
- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forBanner:(NSNumber *)bannerColumnId withSlideCount:(NSUInteger)slideCount;
- (void)statsStopDurationAtTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex;

- (void)statsPayWithOrderNo:(NSString *)orderNo
                  payAction:(KbStatsPayAction)payAction
                  payResult:(PAYRESULT)payResult
                 forProgram:(KbProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(KbChannels *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex;

- (void)statsPayWithPaymentInfo:(KbPaymentInfo *)paymentInfo
                   forPayAction:(KbStatsPayAction)payAction
                    andTabIndex:(NSUInteger)tabIndex
                    subTabIndex:(NSUInteger)subTabIndex;

@end
