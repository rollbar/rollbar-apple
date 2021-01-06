//
//  Test.m
//  
//
//  Created by Andrey Kornich on 2021-01-04.
//

#import <XCTest/XCTest.h>

@import Foundation;
@import RollbarCommon;

#import "TestData/CrashReports.h"

@interface RollbarCrashReportUtilTest : XCTestCase

@end

@implementation RollbarCrashReportUtilTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"Set to go...");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSLog(@"Teared down.");
}

- (void)testExtractLinesFromCrashReport {
    NSArray<NSString *> *lines = [RollbarCrashReportUtil extractLinesFromCrashReport:CRASH_REPORT_PLCRASH_SYMBOLICATED];
    XCTAssert(lines != nil, @"Lines are never nil!");
    XCTAssert(lines.count > 0, "Expecting is not an empty crash report!");
    XCTAssert(lines.count > 400, "Expecting a large crash report!");
}

- (void)testExtractExceptionInfoFromCrashReport {
    NSDictionary *exceptionInfo = [RollbarCrashReportUtil extractExceptionInfoFromCrashReport:CRASH_REPORT_PLCRASH_SYMBOLICATED];
    XCTAssert(exceptionInfo != nil, @"Result is never nil!");
    XCTAssert(exceptionInfo.count > 0, @"Expected non-empty result!");
    XCTAssert(exceptionInfo[@(RollbarExceptionInfo_Type)] != nil, @"Expected exception type!");
    XCTAssert(((NSString *)exceptionInfo[@(RollbarExceptionInfo_Type)]).length > 0, @"Expected non-empty exception type!");

    XCTAssert(exceptionInfo[@(RollbarExceptionInfo_Codes)] != nil, @"Expected exception codes!");
    XCTAssert(((NSString *)exceptionInfo[@(RollbarExceptionInfo_Codes)]).length > 0, @"Expected non-empty exception codes!");

    XCTAssert(exceptionInfo[@(RollbarExceptionInfo_Backtraces)] != nil, @"Expected exception backtraces!");
    XCTAssert(((NSArray *)exceptionInfo[@(RollbarExceptionInfo_Backtraces)]).count > 0, @"Expected non-empty exception backtraces!");
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
