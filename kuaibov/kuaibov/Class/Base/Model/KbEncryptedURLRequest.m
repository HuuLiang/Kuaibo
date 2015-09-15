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
    return @{@"appId":[KbUtil appId],
             kEncryptionKeyName:kEncryptionPasssword,
             @"imsi":@"000000000000000",
             @"channelNo":[KbConfig sharedConfig].channelNo,
             @"pV":[KbUtil appVersion]
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
    return [super requestURLPath:urlPath withParams:[self encryptWithParams:params] responseHandler:responseHandler];
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
    if (jsonObject == nil) {
        jsonObject = decryptedString;
    }
    
    DLog(@"Decrypted response: %@", jsonObject);
    [super processResponseObject:jsonObject withResponseHandler:responseHandler];
}
@end