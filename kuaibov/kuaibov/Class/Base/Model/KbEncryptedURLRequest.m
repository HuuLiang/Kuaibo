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

+ (NSString *)signKey {
    return kEncryptionPasssword;
}

+ (NSDictionary *)commonParams {
    return @{@"appId":KB_REST_APP_ID,
             kEncryptionKeyName:[self class].signKey,
             @"imsi":@"999999999999999",
             @"channelNo":KB_CHANNEL_NO,
             @"pV":KB_REST_PV
             };
}

+ (NSArray *)keyOrdersOfCommonParams {
    return @[@"appId",kEncryptionKeyName,@"imsi",@"channelNo",@"pV"];
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSMutableDictionary *mergedParams = params ? params.mutableCopy : [NSMutableDictionary dictionary];
    NSDictionary *commonParams = [[self class] commonParams];
    if (commonParams) {
        [mergedParams addEntriesFromDictionary:commonParams];
    }
    
    return [mergedParams encryptedDictionarySignedTogetherWithDictionary:commonParams keyOrders:[[self class] keyOrdersOfCommonParams] passwordKeyName:kEncryptionKeyName];
}

- (BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler {
    return [self requestURLPath:urlPath standbyURLPath:nil withParams:params responseHandler:responseHandler];
}

- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(KbURLResponseHandler)responseHandler {
    return [super requestURLPath:urlPath standbyURLPath:standbyUrlPath withParams:[self encryptWithParams:params] responseHandler:responseHandler];
}

- (id)decryptResponse:(id)encryptedResponse {
    if (![encryptedResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *originalResponse = (NSDictionary *)encryptedResponse;
    NSArray *keys = [originalResponse objectForKey:kEncryptionKeyName];
    NSString *dataString = [originalResponse objectForKey:kEncryptionDataName];
    if (!keys || !dataString) {
        return nil;
    }
    
    NSString *decryptedString = [dataString decryptedStringWithKeys:keys];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (jsonObject == nil) {
        jsonObject = decryptedString;
    }
    return jsonObject;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(KbURLResponseHandler)responseHandler {

    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        [super processResponseObject:nil withResponseHandler:responseHandler];
        return ;
    }
    
    id decryptedResponse = [self decryptResponse:responseObject];
    DLog(@"Decrypted response: %@", decryptedResponse);
    [super processResponseObject:decryptedResponse withResponseHandler:responseHandler];
}
@end
