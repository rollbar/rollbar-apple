@import Foundation;
@import OSLog;
@import RollbarNotifier;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface RollbarAulOSLogEntryLogLevelConverterTests : XCTestCase

@end

@implementation RollbarAulOSLogEntryLogLevelConverterTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRollbarLevelFromOSLogEntryLogLevel {
    
    XCTAssertEqual(RollbarLevel_Debug,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:OSLogEntryLogLevelUndefined]);
    XCTAssertEqual(RollbarLevel_Debug,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:OSLogEntryLogLevelDebug]);
    XCTAssertEqual(RollbarLevel_Info,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:OSLogEntryLogLevelInfo]);
    XCTAssertEqual(RollbarLevel_Warning,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:OSLogEntryLogLevelNotice]);
    XCTAssertEqual(RollbarLevel_Error,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:OSLogEntryLogLevelError]);
    XCTAssertEqual(RollbarLevel_Critical,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:OSLogEntryLogLevelFault]);
}

- (void)testRollbarLevelToOSLogEntryLogLevel {
    
    XCTAssertEqual(OSLogEntryLogLevelDebug,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelToOSLogEntryLogLevel:RollbarLevel_Debug]);
    XCTAssertEqual(OSLogEntryLogLevelInfo,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelToOSLogEntryLogLevel:RollbarLevel_Info]);
    XCTAssertEqual(OSLogEntryLogLevelNotice,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelToOSLogEntryLogLevel:RollbarLevel_Warning]);
    XCTAssertEqual(OSLogEntryLogLevelError,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelToOSLogEntryLogLevel:RollbarLevel_Error]);
    XCTAssertEqual(OSLogEntryLogLevelFault,
                   [RollbarAulOSLogEntryLogLevelConverter RollbarLevelToOSLogEntryLogLevel:RollbarLevel_Critical]);
}

@end
#endif
