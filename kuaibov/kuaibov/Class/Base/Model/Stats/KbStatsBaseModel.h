//
//  KbStatsBaseModel.h
//  Kbuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "KbEncryptedURLRequest.h"

typedef NS_ENUM(NSUInteger, KbStatsType) {
    KbStatsTypeUnknown,
    KbStatsTypeColumnCPC,
    KbStatsTypeProgramCPC,
    KbStatsTypeTabCPC,
    KbStatsTypeTabPanning,
    KbStatsTypeTabStay,
    KbStatsTypeBannerPanning,
    KbStatsTypePay = 1000
};

typedef NS_ENUM(NSInteger, KbStatsNetwork) {
    KbStatsNetworkUnknown = 0,
    KbStatsNetworkWifi = 1,
    KbStatsNetwork2G = 2,
    KbStatsNetwork3G = 3,
    KbStatsNetwork4G = 4,
    KbStatsNetworkOther = -1
};

@interface KbStatsInfo : DBPersistence

// Unique ID
@property (nonatomic) NSNumber *statsId;

// System Info
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *pv;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *osv;

// Tab/Column/Program
@property (nonatomic) NSNumber *tabpageId;
@property (nonatomic) NSNumber *subTabpageId;
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *columnType;
@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSNumber *programType;
@property (nonatomic) NSNumber *programLocation;
@property (nonatomic) NSNumber *statsType; //KbStatsType

// Accumalation stats
@property (nonatomic) NSNumber *clickCount;
@property (nonatomic) NSNumber *slideCount;
@property (nonatomic) NSNumber *stopDuration;

// Payment
@property (nonatomic) NSNumber *isPayPopup;
@property (nonatomic) NSNumber *isPayPopupClose;
@property (nonatomic) NSNumber *isPayConfirm;
@property (nonatomic) NSNumber *payStatus;
@property (nonatomic) NSNumber *paySeq;
@property (nonatomic) NSString *orderNo;
@property (nonatomic) NSNumber *network; //KbStatsNetwork
//
+ (NSArray<KbStatsInfo *> *)allStatsInfos;
+ (NSArray<KbStatsInfo *> *)statsInfosWithStatsType:(KbStatsType)statsType;
+ (NSArray<KbStatsInfo *> *)statsInfosWithStatsType:(KbStatsType)statsType tabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex;
+ (void)removeStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos;

- (BOOL)save;
- (BOOL)removeFromDB;
- (NSDictionary *)RESTData;
- (NSDictionary *)umengAttributes;

@end

@interface KbStatsResponse : KbURLResponse
@property (nonatomic) NSNumber *errCode;
@end

@interface KbStatsBaseModel : KbEncryptedURLRequest

- (NSArray<NSDictionary *> *)validateParamsWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos;
- (NSArray<NSDictionary *> *)validateParamsWithStatsInfos:(NSArray<KbStatsInfo *> *)statsInfos shouldIncludeStatsType:(BOOL)includeStatsType;

@end
