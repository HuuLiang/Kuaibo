//
//  KbStatsManager.m
//  Kbuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbStatsManager.h"
#import "KbCPCStatsModel.h"
#import "KbTabStatsModel.h"
#import "KbPayStatsModel.h"
#import "KbPaymentInfo.h"
#import "MobClick.h"

static NSString *const kUmengCPCChannelEvent = @"CPC_CHANNEL";
static NSString *const kUmengCPCProgramEvent = @"CPC_PROGRAM";
static NSString *const kUmengTabEvent = @"TAB_STATS";
static NSString *const kUmengPayEvent = @"PAY_STATS";

@interface KbStatsManager ()
@property (nonatomic,retain) dispatch_queue_t queue;
@property (nonatomic,retain,readonly) KbCPCStatsModel *cpcStats;
@property (nonatomic,retain,readonly) KbTabStatsModel *tabStats;
@property (nonatomic,retain,readonly) KbPayStatsModel *payStats;
@property (nonatomic,retain,readonly) NSDate *statsDate;
@end

@implementation KbStatsManager
@synthesize cpcStats = _cpcStats;
@synthesize tabStats = _tabStats;
@synthesize payStats = _payStats;

DefineLazyPropertyInitialization(KbCPCStatsModel, cpcStats)
DefineLazyPropertyInitialization(KbTabStatsModel, tabStats)
DefineLazyPropertyInitialization(KbPayStatsModel, payStats)

- (dispatch_queue_t)queue {
    if (_queue) {
        return _queue;
    }
    
    _queue = dispatch_queue_create("com.Kbuaibo.app.statsq", nil);
    return _queue;
}

+ (instancetype)sharedManager {
    static KbStatsManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _statsDate = [NSDate date];
    }
    return self;
}

- (void)addStats:(KbStatsInfo *)statsInfo {
    dispatch_async(self.queue, ^{
        [statsInfo save];
    });
}

- (void)removeStats:(NSArray<KbStatsInfo *> *)statsInfos {
    dispatch_async(self.queue, ^{
        [KbStatsInfo removeStatsInfos:statsInfos];
    });
}

- (void)scheduleStatsUploadWithTimeInterval:(NSTimeInterval)timeInterval {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (1) {
            dispatch_async(self.queue, ^{
                [self uploadStatsInfos:[KbStatsInfo allStatsInfos]];
            });
            sleep(timeInterval);
        }
    });
}

- (void)uploadStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos {
    if (statsInfos.count == 0) {
        return ;
    }
    
    NSArray<KbStatsInfo *> *cpcStats = [statsInfos bk_select:^BOOL(KbStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == KbStatsTypeColumnCPC
        || statsInfo.statsType.unsignedIntegerValue == KbStatsTypeProgramCPC;
    }];
    
    NSArray<KbStatsInfo *> *tabStats = [statsInfos bk_select:^BOOL(KbStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == KbStatsTypeTabCPC
        || statsInfo.statsType.unsignedIntegerValue == KbStatsTypeTabPanning
        || statsInfo.statsType.unsignedIntegerValue == KbStatsTypeTabStay
        || statsInfo.statsType.unsignedIntegerValue == KbStatsTypeBannerPanning;
    }];
    
    NSArray<KbStatsInfo *> *payStats = [statsInfos bk_select:^BOOL(KbStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == KbStatsTypePay;
    }];
    
    if (cpcStats.count > 0) {
        DLog(@"Commit CPC stats...");
        [self.cpcStats statsCPCWithStatsInfos:cpcStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [KbStatsInfo removeStatsInfos:cpcStats];
                DLog(@"Commit CPC stats successfully!");
            } else {
                DLog(@"Commit CPC stats with failure: %@", obj);
            }
        }];
    }
    
    if (tabStats.count > 0) {
        DLog(@"Commit TAB stats...");
        [self.tabStats statsTabWithStatsInfos:tabStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [KbStatsInfo removeStatsInfos:tabStats];
                DLog(@"Commit TAB stats successfully");
            } else {
                DLog(@"Commint TAB stats with failure: %@", obj);
            }
        }];
    }
    
    if (payStats.count > 0) {
        DLog(@"Commit PAY stats...");
        [self.payStats statsPayWithStatsInfos:payStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [KbStatsInfo removeStatsInfos:payStats];
                DLog(@"Commit PAY stats successfully!");
            } else {
                DLog(@"Commit PAY stats with failure: %@", obj);
            }
        }];
    }
}

- (void)statsCPCWithChannel:(KbChannels *)channel inTabIndex:(NSUInteger)tabIndex {
    KbStatsInfo *statsInfo = [[KbStatsInfo alloc] init];
    statsInfo.tabpageId = @(tabIndex+1);
    statsInfo.columnId = channel.realColumnId;
    statsInfo.columnType = channel.type;
    statsInfo.statsType = @(KbStatsTypeColumnCPC);
    [self addStats:statsInfo];
    
    [MobClick event:kUmengCPCChannelEvent attributes:[statsInfo umengAttributes]];
}

- (void)statsCPCWithProgram:(KbProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(KbChannels *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
{
    KbStatsInfo *statsInfo = [[KbStatsInfo alloc] init];
    if (channel) {
        statsInfo.columnId = channel.realColumnId;
        statsInfo.columnType = channel.type;
    }
    statsInfo.tabpageId = @(tabIndex+1);
    if (subTabIndex != NSNotFound) {
        statsInfo.subTabpageId = @(subTabIndex+1);
    }
    
    statsInfo.programId = program.programId;
    statsInfo.programType = program.type;
    statsInfo.programLocation = @(programLocation+1);
    statsInfo.statsType = @(KbStatsTypeProgramCPC);
    [self addStats:statsInfo];
    
    [MobClick event:kUmengCPCProgramEvent attributes:statsInfo.umengAttributes];
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forClickCount:(NSUInteger)clickCount {
    dispatch_async(self.queue, ^{
        NSArray<KbStatsInfo *> *statsInfos = [KbStatsInfo statsInfosWithStatsType:KbStatsTypeTabCPC tabIndex:tabIndex subTabIndex:subTabIndex];
        KbStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[KbStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
            statsInfo.statsType = @(KbStatsTypeTabCPC);
        }
        
        statsInfo.clickCount = @(statsInfo.clickCount.unsignedIntegerValue + clickCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forSlideCount:(NSUInteger)slideCount {
    dispatch_async(self.queue, ^{
        NSArray<KbStatsInfo *> *statsInfos = [KbStatsInfo statsInfosWithStatsType:KbStatsTypeTabPanning tabIndex:tabIndex subTabIndex:subTabIndex];
        KbStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[KbStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
            statsInfo.statsType = @(KbStatsTypeTabPanning);
        }
        
        statsInfo.slideCount = @(statsInfo.slideCount.unsignedIntegerValue + slideCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsStopDurationAtTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex {
    dispatch_async(self.queue, ^{
        NSArray<KbStatsInfo *> *statsInfos = [KbStatsInfo statsInfosWithStatsType:KbStatsTypeTabStay tabIndex:tabIndex subTabIndex:subTabIndex];
        KbStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[KbStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
            statsInfo.statsType = @(KbStatsTypeTabStay);
        }
        
        NSUInteger durationSinceStats = [[NSDate date] timeIntervalSinceDate:self.statsDate];
        statsInfo.stopDuration = @(statsInfo.stopDuration.unsignedIntegerValue + durationSinceStats);
        [statsInfo save];
        
        [self resetStatsDate];
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forBanner:(NSNumber *)bannerColumnId withSlideCount:(NSUInteger)slideCount {
    dispatch_async(self.queue, ^{
        NSArray<KbStatsInfo *> *statsInfos = [KbStatsInfo statsInfosWithStatsType:KbStatsTypeBannerPanning tabIndex:tabIndex subTabIndex:subTabIndex];
        KbStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[KbStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            statsInfo.statsType = @(KbStatsTypeBannerPanning);
            statsInfo.columnId = bannerColumnId;
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
        }
        
        statsInfo.slideCount = @(statsInfo.slideCount.unsignedIntegerValue + slideCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)resetStatsDate {
    _statsDate = [NSDate date];
}

- (void)statsPayWithOrderNo:(NSString *)orderNo
                  payAction:(KbStatsPayAction)payAction
                  payResult:(PAYRESULT)payResult
                 forProgram:(KbProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(KbChannels *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
{
    dispatch_async(self.queue, ^{
        KbStatsInfo *statsInfo = [[KbStatsInfo alloc] init];
        statsInfo.tabpageId = @(tabIndex+1);
        if (subTabIndex != NSNotFound) {
            statsInfo.subTabpageId = @(subTabIndex+1);
        }
        statsInfo.columnId = channel.realColumnId;
        statsInfo.columnType = channel.type;
        statsInfo.programId = program.programId;
        statsInfo.programType = program.type;
        statsInfo.programLocation = @(programLocation+1);
        statsInfo.isPayPopup = @(1);
        statsInfo.orderNo = orderNo;
        if (payAction == KbStatsPayActionClose) {
            statsInfo.isPayPopupClose = @(1);
        } else if (payAction == KbStatsPayActionGoToPay) {
            statsInfo.isPayConfirm = @(1);
        } else if (payAction == KbStatsPayActionPayBack) {
            NSDictionary *payStautsMapping = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(2), @(PAYRESULT_ABANDON):@(3)};
            NSNumber *payStatus = payStautsMapping[@(payResult)];
            statsInfo.payStatus = payStatus;
        } else {
            return ;
        }
        
        statsInfo.paySeq = @([KbUtil launchSeq]);
        statsInfo.statsType = @(KbStatsTypePay);
        statsInfo.network = @([KbNetworkInfo sharedInfo].networkStatus);
        [statsInfo save];
        
        [MobClick event:kUmengPayEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsPayWithPaymentInfo:(KbPaymentInfo *)paymentInfo
                   forPayAction:(KbStatsPayAction)payAction
                    andTabIndex:(NSUInteger)tabIndex
                    subTabIndex:(NSUInteger)subTabIndex
{
    dispatch_async(self.queue, ^{
        KbStatsInfo *statsInfo = [[KbStatsInfo alloc] init];
        statsInfo.tabpageId = @(tabIndex+1);
        if (subTabIndex != NSNotFound) {
            statsInfo.subTabpageId = @(subTabIndex+1);
        }
        statsInfo.columnId = paymentInfo.columnId;
        statsInfo.columnType = paymentInfo.columnType;
        statsInfo.programId = paymentInfo.contentId;
        statsInfo.programType = paymentInfo.contentType;
        statsInfo.programLocation = paymentInfo.contentLocation;
        statsInfo.isPayPopup = @(1);
        statsInfo.orderNo = paymentInfo.orderId;
        if (payAction == KbStatsPayActionClose) {
            statsInfo.isPayPopupClose = @(1);
        } else if (payAction == KbStatsPayActionGoToPay) {
            statsInfo.isPayConfirm = @(1);
        } else if (payAction == KbStatsPayActionPayBack) {
            NSDictionary *payStautsMapping = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(2), @(PAYRESULT_ABANDON):@(3)};
            NSNumber *payStatus = payStautsMapping[paymentInfo.paymentResult];
            statsInfo.payStatus = payStatus;
        } else {
            return ;
        }
    
        statsInfo.paySeq = @([KbUtil launchSeq]);
        statsInfo.statsType = @(KbStatsTypePay);
        statsInfo.network = @([KbNetworkInfo sharedInfo].networkStatus);
        [statsInfo save];
        
        [MobClick event:kUmengPayEvent attributes:statsInfo.umengAttributes];
    });
}

@end
