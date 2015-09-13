//
//  KbEncryptedURLRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/14.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbEncryptedURLRequest.h"
#import "NSDictionary+KbSign.h"
#import "NSString+crypt.h"

static NSString *const kEncryptionPasssword = @"f7@j3%#5aiG$4";

@implementation KbEncryptedURLRequest

+ (NSDictionary *)commonParams {
    return @{@"appId":[KbConfig appId],
             kEncryptionKeyName:kEncryptionPasssword,
             @"imsi":@"000000000000000",
             @"channelNo":[KbConfig sharedConfig].channelNo,
             @"pV":[KbConfig appVersion]
             };
}

+ (NSArray *)keyOrdersOfCommonParams {
    return @[@"appId",kEncryptionKeyName,@"imsi",@"channelNo",@"pV"];
}

- (BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler {
    NSMutableDictionary *mergedParams = params ? params.mutableCopy : [NSMutableDictionary dictionary];
    NSDictionary *commonParams = [[self class] commonParams];
    if (commonParams) {
        [mergedParams addEntriesFromDictionary:commonParams];
    }
    
    NSDictionary *signedParams = [mergedParams encryptedDictionarySignedTogetherWithDictionary:commonParams keyOrders:[[self class] keyOrdersOfCommonParams] passwordKeyName:kEncryptionKeyName];
    
    BOOL success = [super requestURLPath:urlPath withParams:signedParams responseHandler:^(KbURLResponseStatus respStatus, NSString *errorMessage) {
        if (responseHandler) {
            responseHandler(respStatus,errorMessage);
        }
    }];
    return success;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(KbURLResponseHandler)responseHandler {

    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        [super processResponseObject:nil withResponseHandler:responseHandler];
        return ;
    }
    
    NSDictionary *originalResponse = (NSDictionary *)responseObject;
    NSArray *keys = [originalResponse objectForKey:kEncryptionKeyName];
    NSString *dataString = [originalResponse objectForKey:kEncryptionDataName];
    if (!keys || !dataString) {
        [super processResponseObject:nil withResponseHandler:responseHandler];
        return ;
    }
    
    NSString *decryptedString = [dataString decryptedStringWithKeys:keys];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    [super processResponseObject:jsonObject withResponseHandler:responseHandler];
}
@end
