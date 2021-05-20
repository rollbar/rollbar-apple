@import Foundation;

#if TARGET_OS_OSX

@import OSLog;
@import RollbarAUL;
@import RollbarNotifier;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@interface RollbarAulLogLevelConverterTests : XCTestCase

@end

@implementation RollbarAulLogLevelConverterTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (NSArray<NSNumber *> *) getOrederedAulLevels {
    
    return @[
        
        [NSNumber numberWithUnsignedShort:OS_LOG_TYPE_DEBUG],
        [NSNumber numberWithUnsignedShort:OS_LOG_TYPE_INFO],
        [NSNumber numberWithUnsignedShort:OS_LOG_TYPE_DEFAULT],
        [NSNumber numberWithUnsignedShort:OS_LOG_TYPE_ERROR],
        [NSNumber numberWithUnsignedShort:OS_LOG_TYPE_FAULT]
    ];
}

- (NSArray<NSNumber *> *) getOrederedRollbarLevels {
    
    return @[
        
        [NSNumber numberWithUnsignedLong:RollbarLevel_Debug],
        [NSNumber numberWithUnsignedLong:RollbarLevel_Info],
        [NSNumber numberWithUnsignedLong:RollbarLevel_Warning],
        [NSNumber numberWithUnsignedLong:RollbarLevel_Error],
        [NSNumber numberWithUnsignedLong:RollbarLevel_Critical]
    ];
}

- (void)testRollbarLevelFromAulLevel {
    
    XCTAssertEqual(RollbarLevel_Debug,      [RollbarAulLogLevelConverter RollbarLevelFromAulLevel:OS_LOG_TYPE_DEBUG]);
    XCTAssertEqual(RollbarLevel_Info,       [RollbarAulLogLevelConverter RollbarLevelFromAulLevel:OS_LOG_TYPE_INFO]);
    XCTAssertEqual(RollbarLevel_Warning,    [RollbarAulLogLevelConverter RollbarLevelFromAulLevel:OS_LOG_TYPE_DEFAULT]);
    XCTAssertEqual(RollbarLevel_Error,      [RollbarAulLogLevelConverter RollbarLevelFromAulLevel:OS_LOG_TYPE_ERROR]);
    XCTAssertEqual(RollbarLevel_Critical,   [RollbarAulLogLevelConverter RollbarLevelFromAulLevel:OS_LOG_TYPE_FAULT]);
}

- (void)testRollbarLevelToAulLevel {
    
    XCTAssertEqual(OS_LOG_TYPE_DEBUG,   [RollbarAulLogLevelConverter RollbarLevelToAulLevel:RollbarLevel_Debug]);
    XCTAssertEqual(OS_LOG_TYPE_INFO,    [RollbarAulLogLevelConverter RollbarLevelToAulLevel:RollbarLevel_Info]);
    XCTAssertEqual(OS_LOG_TYPE_DEFAULT, [RollbarAulLogLevelConverter RollbarLevelToAulLevel:RollbarLevel_Warning]);
    XCTAssertEqual(OS_LOG_TYPE_ERROR,   [RollbarAulLogLevelConverter RollbarLevelToAulLevel:RollbarLevel_Error]);
    XCTAssertEqual(OS_LOG_TYPE_FAULT,   [RollbarAulLogLevelConverter RollbarLevelToAulLevel:RollbarLevel_Critical]);
}

@end

#endif // !TARGET_OS_WATCH

#endif //TARGET_OS_OSX
