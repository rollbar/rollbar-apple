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

- (void)testExtractComponentsFromBacktrace {

    NSArray<NSString *> *symbolecatedBackTraces = @[
        @"0   macosAppObjC                        0x000000010eae70c8 crashIt + 8",
        @"1   macosAppObjC                        0x000000010eae6f84 -[AppDelegate applicationDidFinishLaunching:] + 484",
        @"2   CoreFoundation                      0x00007fff2044cfec __CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__ + 12",
        @"3   CoreFoundation                      0x00007fff204e889b ___CFXRegistrationPost_block_invoke + 49",
        @"4   CoreFoundation                      0x00007fff204e880f _CFXRegistrationPost + 454",
        @"5   CoreFoundation                      0x00007fff2041dbde _CFXNotificationPost + 723",
        @"6   Foundation                          0x00007fff2118cabe -[NSNotificationCenter postNotificationName:object:userInfo:] + 59",
        @"7   AppKit                              0x00007fff22c7bf6d -[NSApplication _postDidFinishNotification] + 305",
        @"8   AppKit                              0x00007fff22c7bcbb -[NSApplication _sendFinishLaunchingNotification] + 208",
        @"9   AppKit                              0x00007fff22c78eb2 -[NSApplication(NSAppleEventHandling) _handleAEOpenEvent:] + 541",
        @"10  AppKit                              0x00007fff22c78b07 -[NSApplication(NSAppleEventHandling) _handleCoreEvent:withReplyEvent:] + 665",
    ];
    
    for(NSString *trace in symbolecatedBackTraces) {
        NSDictionary *traceComponents = [RollbarCrashReportUtil extractComponentsFromBacktrace:trace];
        XCTAssertNotNil(traceComponents);
        XCTAssertEqual(traceComponents.count, RollbarBacktraceComponent_LineNumber + 1);
        
        NSLog(@"Trace #: %@",  traceComponents[@(RollbarBacktraceComponent_Index)]);
        NSLog(@"Library: %@",  traceComponents[@(RollbarBacktraceComponent_Library)]);
        NSLog(@"Address: %@",  traceComponents[@(RollbarBacktraceComponent_Address)]);
        NSLog(@"Method: %@",  traceComponents[@(RollbarBacktraceComponent_Method)]);
        NSLog(@"Method: %@",  traceComponents[@(RollbarBacktraceComponent_LineNumber)]);
    }

    NSArray<NSString *> *nonsymbolecatedBackTraces = @[
        @"0   macosAppObjC                        0x000000010eae70c8 ",
        @"1   macosAppObjC                        0x000000010eae6f84",
        @"2   CoreFoundation                      0x00007fff2044cfec   ",
        @"3   CoreFoundation                      0x00007fff204e889b ",
        @"6   Foundation                          0x00007fff2118cabe",
        @"7   AppKit                              0x00007fff22c7bf6d",
    ];
    
    for(NSString *trace in nonsymbolecatedBackTraces) {
        NSDictionary *traceComponents = [RollbarCrashReportUtil extractComponentsFromBacktrace:trace];
        XCTAssertNotNil(traceComponents);
        //XCTAssert(traceComponents.count == RollbarBacktraceComponent_LineNumber + 1);
        XCTAssertEqual(traceComponents.count, RollbarBacktraceComponent_Address + 1);
        
        NSLog(@"Trace #: %@",  traceComponents[@(RollbarBacktraceComponent_Index)]);
        NSLog(@"Library: %@",  traceComponents[@(RollbarBacktraceComponent_Library)]);
        NSLog(@"Address: %@",  traceComponents[@(RollbarBacktraceComponent_Address)]);
        NSLog(@"Method: %@",  traceComponents[@(RollbarBacktraceComponent_Method)]);
    }
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
