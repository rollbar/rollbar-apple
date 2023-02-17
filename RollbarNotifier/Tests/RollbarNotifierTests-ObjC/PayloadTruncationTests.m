@import Foundation;
@import UnitTesting;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface PayloadTruncationTests : XCTestCase

@end

@implementation PayloadTruncationTests

- (void)setUp {
    
    [super setUp];
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testMeasureTotalEncodingBytes {
    
    NSString *testString1 = @"ABCD";
    unsigned long testStringBytes1 =
        [RollbarPayloadTruncator measureTotalEncodingBytes:testString1
                                             usingEncoding:NSUTF32StringEncoding];

    NSString *testString2 = [testString1 stringByAppendingString:testString1];
    unsigned long testStringBytes2 =
        [RollbarPayloadTruncator measureTotalEncodingBytes:testString2
                                             usingEncoding:NSUTF32StringEncoding];


    XCTAssertTrue(testStringBytes2 == (2 * testStringBytes1));
    XCTAssertTrue(4 == testString1.length);
    XCTAssertTrue(testString2.length == (2 * testString1.length));
    XCTAssertTrue(testStringBytes1 == (4 * testString1.length));
    XCTAssertTrue(testStringBytes2 == (4 * testString2.length));

    XCTAssertTrue((4 * [RollbarPayloadTruncator measureTotalEncodingBytes:testString1
                                                       usingEncoding:NSUTF8StringEncoding])
                  == [RollbarPayloadTruncator measureTotalEncodingBytes:testString1
                                                          usingEncoding:NSUTF32StringEncoding]);
    XCTAssertTrue((4 * [RollbarPayloadTruncator measureTotalEncodingBytes:testString1])
                  == [RollbarPayloadTruncator measureTotalEncodingBytes:testString1
                                                          usingEncoding:NSUTF32StringEncoding]);
}

- (void)testTruncateStringToTotalBytes {
    
    // test "truncation expected" case:
    NSString *testString = @"ABCDE-ABCDE-ABCDE";
    const int truncationBytesLimit = 10;
    XCTAssertTrue(truncationBytesLimit
                  < [RollbarPayloadTruncator measureTotalEncodingBytes:testString]
                  );
    NSString *truncatedString = [RollbarPayloadTruncator truncateString:testString
                                                           toTotalBytes:truncationBytesLimit];
    XCTAssertTrue([RollbarPayloadTruncator measureTotalEncodingBytes:testString]
                  > [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]);
    XCTAssertTrue(truncationBytesLimit
                  >= [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]
                  );
    XCTAssertTrue(testString.length > truncatedString.length);
    
    // test "truncation not needed" case:
    testString = @"abcd";
    truncatedString = [RollbarPayloadTruncator truncateString:testString
                                                 toTotalBytes:truncationBytesLimit];
    XCTAssertTrue([RollbarPayloadTruncator measureTotalEncodingBytes:testString]
                  == [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]);
    XCTAssertTrue(testString.length == truncatedString.length);
    XCTAssertTrue(testString == truncatedString);
}

- (void)testTruncateStringToTotalBytesUnicode {
    
    NSArray *testStrings = @[
                             @"🌍🌍🌍🌍🌍-🌍🌍🌍🌍🌍",
                             @"A🌍🌍🌍🌍-🌍🌍🌍🌍🌍",
                             @"AB🌍🌍🌍-🌍🌍🌍🌍🌍",
                             @"ABC🌍🌍-🌍🌍🌍🌍🌍",
                             @"ABCD🌍-🌍🌍🌍🌍🌍",
                             @"ABCDE-🌍🌍🌍🌍🌍",
                             @"ABCDE-A🌍🌍🌍🌍",
                             @"ABCDE-AB🌍🌍🌍",
                             @"ABCDE-ABC🌍🌍",
                             @"ABCDE-ABCD🌍",
                             @"🌍🌍🌍🌍🌍-🌍🌍🌍🌍E",
                             @"🌍🌍🌍🌍🌍-🌍🌍🌍DE",
                             @"🌍🌍🌍🌍🌍-🌍🌍CDE",
                             @"🌍🌍🌍🌍🌍-🌍BCDE",
                             @"🌍🌍🌍🌍🌍-ABCDE",
                             @"🌍🌍🌍🌍E-ABCDE",
                             @"🌍🌍🌍DE-ABCDE",
                             @"🌍🌍CDE-ABCDE",
                             @"🌍BCDE-ABCDE",
                             @"ABCDE-ABCDE",
                             @"אספירין-אספירין",
                             @"Pound123Pound"
                             ];
    
    for (NSString *testString in testStrings) {
        const int truncationBytesLimit = 10;
        XCTAssertTrue(truncationBytesLimit
                      < [RollbarPayloadTruncator measureTotalEncodingBytes:testString]
                      );
        NSString *truncatedString = [RollbarPayloadTruncator truncateString:testString
                                                               toTotalBytes:truncationBytesLimit];
        NSLog(testString);
        NSLog(truncatedString);
        NSLog(@"%d", [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]);

        
        XCTAssertTrue([RollbarPayloadTruncator measureTotalEncodingBytes:testString]
                      > [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]);
        XCTAssertTrue(truncationBytesLimit
                      >= [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]
                      );
        XCTAssertTrue(testString.length > truncatedString.length);
        
    }
}

- (void)testVisuallyTruncateStringToTotalBytesUnicode {
    
    NSArray *testStrings = @[
                             @"🌍🌍🌍🌍🌍-🌍🌍🌍🌍🌍",
                             @"A🌍🌍🌍🌍-🌍🌍🌍🌍🌍",
                             @"AB🌍🌍🌍-🌍🌍🌍🌍🌍",
                             @"ABC🌍🌍-🌍🌍🌍🌍🌍",
                             @"ABCD🌍-🌍🌍🌍🌍🌍",
                             @"ABCDE-🌍🌍🌍🌍🌍",
                             @"ABCDE-A🌍🌍🌍🌍",
                             @"ABCDE-AB🌍🌍🌍",
                             @"ABCDE-ABC🌍🌍",
                             @"ABCDE-ABCD🌍",
                             @"🌍🌍🌍🌍🌍-🌍🌍🌍🌍E",
                             @"🌍🌍🌍🌍🌍-🌍🌍🌍DE",
                             @"🌍🌍🌍🌍🌍-🌍🌍CDE",
                             @"🌍🌍🌍🌍🌍-🌍BCDE",
                             @"🌍🌍🌍🌍🌍-ABCDE",
                             @"🌍🌍🌍🌍E-ABCDE",
                             @"🌍🌍🌍DE-ABCDE",
                             @"🌍🌍CDE-ABCDE",
                             @"🌍BCDE-ABCDE",
                             @"ABCDE-ABCDE",
                             @"אספירין-אספירין",
                             @"Pound123Pound"
                             ];
    
    int truncationBytesLimit = -1;
    while (truncationBytesLimit < 42) {
        NSLog(@"*** Truncation limit: %d", truncationBytesLimit);
        
        for (NSString *testString in testStrings) {
            NSString *truncatedString = [RollbarPayloadTruncator truncateString:testString
                                                                   toTotalBytes:truncationBytesLimit];
            NSLog(testString);
            NSLog(truncatedString);
            NSLog(@"%d", [RollbarPayloadTruncator measureTotalEncodingBytes:truncatedString]);
        }

        truncationBytesLimit++;
    }
        
    
}

- (void)testPayloadTruncation {

    RollbarMutableConfig *config =
    [RollbarMutableConfig mutableConfigWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
                                           environment:[RollbarTestHelper getRollbarEnvironment]];
    config.developerOptions.logIncomingPayloads = YES;
    config.developerOptions.logTransmittedPayloads = YES;
    config.developerOptions.logDroppedPayloads = YES;
    config.developerOptions.transmit = NO;

    [Rollbar initWithConfiguration:config];

    [RollbarTestUtil waitWithWaitTimeInSeconds:2];
    [RollbarTestUtil deleteLogFiles];
    [RollbarTestUtil waitWithWaitTimeInSeconds:1];
    
    NSArray *items = [RollbarTestUtil readTransmittedPayloadsAsDictionaries];
    XCTAssertEqual(items.count, 0);

    @try {
        NSArray *crew = [NSArray arrayWithObjects:
                         @"Dave",
                         @"Heywood",
                         @"Frank", nil];
        // This will throw an exception.
        NSLog(@"%@", [crew objectAtIndex:10]);
    }
    @catch (NSException *exception) {
        [Rollbar errorException:exception];
    }
    
    [RollbarTestUtil waitWithWaitTimeInSeconds:3];

    items = [RollbarTestUtil readTransmittedPayloadsAsDictionaries];
    XCTAssertNotNil(items);
    XCTAssertEqual(items.count, 1);
    
    for (id payload in items) {
        NSMutableArray *frames = [payload mutableArrayValueForKeyPath:@"body.trace.frames"];
        unsigned long totalFramesBeforeTruncation = frames.count;
        [RollbarPayloadTruncator truncatePayload:payload toTotalBytes:20];
        unsigned long totalFramesAfterTruncation = frames.count;
        XCTAssertTrue(totalFramesBeforeTruncation > totalFramesAfterTruncation);
        XCTAssertTrue(1 == totalFramesAfterTruncation);
        
        NSMutableString *simulatedLongString = [@"1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_1234567890_" mutableCopy];
        [[frames objectAtIndex:0] setObject:simulatedLongString forKey:@"library"];
        XCTAssertTrue([[[frames objectAtIndex:0] objectForKey:@"library"] length] > 256);
        [RollbarPayloadTruncator truncatePayload:payload toTotalBytes:20];
        XCTAssertTrue(totalFramesAfterTruncation == frames.count);
        XCTAssertTrue([[[frames objectAtIndex:0] objectForKey:@"library"] length] <= 256);
    }
}

//- (void)testErrorReportingWithTruncation {
//
//    RollbarMutableConfig *config =
//    [RollbarMutableConfig mutableConfigWithAccessToken:[RollbarTestHelper getRollbarPayloadsAccessToken]
//                                           environment:[RollbarTestHelper getRollbarEnvironment]];
//    config.developerOptions.logIncomingPayloads = YES;
//    config.developerOptions.logTransmittedPayloads = YES;
//    config.developerOptions.logDroppedPayloads = YES;
//    config.developerOptions.transmit = YES;
//
//    [Rollbar initWithConfiguration:config];
//
//    [RollbarTestUtil waitWithWaitTimeInSeconds:5];
//    [RollbarTestUtil deleteLogFiles];
//    [RollbarTestUtil waitWithWaitTimeInSeconds:1];
//
//    NSArray *items = [RollbarTestUtil readTransmittedPayloadsAsDictionaries];
//    XCTAssertEqual(items.count, 0);
//
//    NSMutableString *simulatedLongString =
//        [[NSMutableString alloc] initWithCapacity:(512 + 1)*1024];
//    while (simulatedLongString.length < (512 * 1024)) {
//        [simulatedLongString appendString:@"1234567890_"];
//    }
//
//    [Rollbar criticalMessage:@"Message with long extra data"
//                        data:@{@"extra_truncatable_data": simulatedLongString}
//     ];
//
//    [RollbarTestUtil waitWithWaitTimeInSeconds:2];
//    items = [RollbarTestUtil readIncomingPayloadsAsDictionaries];
//    XCTAssertEqual(items.count, 1);
//    XCTAssertTrue([@"Message with long extra data" isEqualToString:[items[0] valueForKeyPath:@"body.message.body"]]);
//    [RollbarTestUtil waitWithWaitTimeInSeconds:3];
//    items = [RollbarTestUtil readTransmittedPayloadsAsDictionaries];
//    XCTAssertEqual(items.count, 1);
//
//    @try {
//        NSArray *crew = [NSArray arrayWithObjects:
//                         @"Dave",
//                         @"Heywood",
//                         @"Frank", nil];
//        // This will throw an exception.
//        NSLog(@"%@", [crew objectAtIndex:10]);
//    }
//    @catch (NSException *exception) {
//
//        [Rollbar criticalMessage:simulatedLongString
//                            data:@{@"extra_truncatable_data": simulatedLongString}
//         ];
//
//        [RollbarTestUtil waitWithWaitTimeInSeconds:1];
//        items = [RollbarTestUtil readIncomingPayloadsAsDictionaries];
//        XCTAssertEqual(items.count, 2);
//        [RollbarTestUtil waitWithWaitTimeInSeconds:1];
//        items = [RollbarTestUtil readTransmittedPayloadsAsDictionaries];
//        XCTAssertEqual(items.count, 2);
//    }
//}

@end
#endif
