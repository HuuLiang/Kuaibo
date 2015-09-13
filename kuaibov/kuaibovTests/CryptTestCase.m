//
//  CryptTestCase.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/13.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSString+md5.h"
#import "NSString+crypt.h"

@interface CryptTestCase : XCTestCase

@end

@implementation CryptTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}
- (void)testEncrypt {
    NSString *param = @"sign=0d6dfa2f50fd5971093ae6bda8e4a44f&f=ff&g=gg&d=dd&e=ee&pV=106&appId=QUBA_0001&b=bb&c=cc&a=aa&j=jj&channelNo=QB_VIDEO_QUDAO_B_00000001&k=kk&h=hh&i=ii&imsi=460030416784390";
    NSString *key = @"f7@j3%#5aiG$4";
    NSString *expected = @"9ae0ec5a2dd2745089eade3940d380b7c91eed83da53d55c0f4e32d023eae2eb5154a8d86be7e513b946422b09a6e79a900d447675a489a7be49ba0df7f49e36ac09be19929c4a248c36e4c3246482609b86fbe2b7349591b18bcbd6cd817c575df4ef25bf660d5acddbc824c4f273c0c11135ecc9be53b6ccbda292027205472cc04f62d45a9151f16e8e0c2f217c92534610e9145e42a824e40b09e2ead6496a8f93a30ce963f339b7be1fc9463357";
    
    NSString *encryptResult = [param encryptedStringWithPassword:key.md5];
    XCTAssert([encryptResult isEqualToString:expected]);
}

- (void)testEncrypt2 {
    NSString *encryptString = @"加密的类容";
    NSString *key = @"2a4e4f38f4893812";
    NSString *expected = @"b4371e55e793be4e614ae192a3fbb417";
    
    NSString *encryptResult = [encryptString encryptedStringWithPassword:key];
    XCTAssert([encryptResult isEqualToString:expected]);
}
@end
