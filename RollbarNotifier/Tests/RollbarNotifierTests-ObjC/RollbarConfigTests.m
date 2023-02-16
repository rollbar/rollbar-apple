//
//  RollbarConfigTests.m
//  
//
//  Created by Andrey Kornich on 2022-07-14.
//

#import <XCTest/XCTest.h>

@import RollbarCommon;
@import RollbarNotifier;

@interface RollbarConfigTests : XCTestCase

@end

@implementation RollbarConfigTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRollbarDestination {

    NSString *defaultMutable = [[RollbarMutableDestination new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarDestination new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableDestination *mutable = [RollbarMutableDestination new];
    mutable.endpoint = @"test_EP";
    mutable.accessToken = @"test_AC";
    mutable.environment = @"test_ENV";
    XCTAssertTrue([mutable.endpoint isEqualToString:@"test_EP"]);
    XCTAssertTrue([mutable.accessToken isEqualToString:@"test_AC"]);
    XCTAssertTrue([mutable.environment isEqualToString:@"test_ENV"]);
    
    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_EP"]);
    XCTAssertTrue([content containsString:@"test_AC"]);
    XCTAssertTrue([content containsString:@"test_ENV"]);
    
    RollbarDestination *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue([immutable.endpoint isEqualToString:@"test_EP"]);
    XCTAssertTrue([immutable.accessToken isEqualToString:@"test_AC"]);
    XCTAssertTrue([immutable.environment isEqualToString:@"test_ENV"]);
    
    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_EP"]);
    XCTAssertTrue([content containsString:@"test_AC"]);
    XCTAssertTrue([content containsString:@"test_ENV"]);
    
    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);

    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);

    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarDeveloperOptions {
    
    NSString *defaultMutable = [[RollbarMutableDeveloperOptions new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarDeveloperOptions new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableDeveloperOptions *mutable = [RollbarMutableDeveloperOptions new];
    mutable.enabled = NO;
    mutable.transmit = NO;
    mutable.suppressSdkInfoLogging = NO;
    mutable.logTransmittedPayloads = NO;
    mutable.transmittedPayloadsLogFile = @"test_PAYLOADS.LOG_old";
    XCTAssertFalse(mutable.enabled);
    XCTAssertFalse(mutable.transmit);
    XCTAssertFalse(mutable.suppressSdkInfoLogging);
    XCTAssertFalse(mutable.logTransmittedPayloads);
    XCTAssertTrue([mutable.transmittedPayloadsLogFile isEqualToString:@"test_PAYLOADS.LOG_old"]);

    mutable.enabled = YES;
    mutable.transmit = YES;
    mutable.suppressSdkInfoLogging = YES;
    mutable.logTransmittedPayloads = YES;
    mutable.transmittedPayloadsLogFile = @"test_PAYLOADS.LOG";
    XCTAssertTrue(mutable.enabled);
    XCTAssertTrue(mutable.transmit);
    XCTAssertTrue(mutable.suppressSdkInfoLogging);
    XCTAssertTrue(mutable.logTransmittedPayloads);
    XCTAssertTrue([mutable.transmittedPayloadsLogFile isEqualToString:@"test_PAYLOADS.LOG"]);
    
    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_PAYLOADS.LOG"]);
    
    RollbarDeveloperOptions *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue(immutable.enabled);
    XCTAssertTrue(immutable.transmit);
    XCTAssertTrue(immutable.suppressSdkInfoLogging);
    XCTAssertTrue(immutable.logTransmittedPayloads);
    XCTAssertTrue([immutable.transmittedPayloadsLogFile isEqualToString:@"test_PAYLOADS.LOG"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_PAYLOADS.LOG"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarLoggingOptions {
    
    NSString *defaultMutable = [[RollbarMutableLoggingOptions new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarLoggingOptions new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableLoggingOptions *mutable = [RollbarMutableLoggingOptions new];
    mutable.logLevel = RollbarLevel_Info;
    mutable.crashLevel = RollbarLevel_Error;
    mutable.maximumReportsPerMinute = 10;
    mutable.captureIp = RollbarCaptureIpType_Anonymize;
    mutable.codeVersion = @"test_CV_old";
    mutable.framework = @"test_FW_old";
    mutable.requestId = @"test_RID_old";
    XCTAssertEqual(mutable.logLevel, RollbarLevel_Info);
    XCTAssertEqual(mutable.crashLevel, RollbarLevel_Error);
    XCTAssertEqual(mutable.maximumReportsPerMinute, 10);
    XCTAssertEqual(mutable.captureIp, RollbarCaptureIpType_Anonymize);
    XCTAssertTrue([mutable.codeVersion isEqualToString:@"test_CV_old"]);
    XCTAssertTrue([mutable.framework isEqualToString:@"test_FW_old"]);
    XCTAssertTrue([mutable.requestId isEqualToString:@"test_RID_old"]);

    mutable.logLevel = RollbarLevel_Debug;
    mutable.crashLevel = RollbarLevel_Critical;
    mutable.maximumReportsPerMinute = 25;
    mutable.captureIp = RollbarCaptureIpType_Full;
    mutable.codeVersion = @"test_CV";
    mutable.framework = @"test_FW";
    mutable.requestId = @"test_RID";
    XCTAssertEqual(mutable.logLevel, RollbarLevel_Debug);
    XCTAssertEqual(mutable.crashLevel, RollbarLevel_Critical);
    XCTAssertEqual(mutable.maximumReportsPerMinute, 25);
    XCTAssertEqual(mutable.captureIp, RollbarCaptureIpType_Full);
    XCTAssertTrue([mutable.codeVersion isEqualToString:@"test_CV"]);
    XCTAssertTrue([mutable.framework isEqualToString:@"test_FW"]);
    XCTAssertTrue([mutable.requestId isEqualToString:@"test_RID"]);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"debug"]);
    XCTAssertTrue([content containsString:@"critical"]);
    XCTAssertTrue([content containsString:@"25"]);
    XCTAssertTrue([content containsString:@"Full"]);
    XCTAssertTrue([content containsString:@"test_CV"]);
    XCTAssertTrue([content containsString:@"test_FW"]);
    XCTAssertTrue([content containsString:@"test_RID"]);

    RollbarLoggingOptions *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertEqual(immutable.logLevel, RollbarLevel_Debug);
    XCTAssertEqual(immutable.crashLevel, RollbarLevel_Critical);
    XCTAssertEqual(immutable.maximumReportsPerMinute, 25);
    XCTAssertEqual(immutable.captureIp, RollbarCaptureIpType_Full);
    XCTAssertTrue([immutable.codeVersion isEqualToString:@"test_CV"]);
    XCTAssertTrue([immutable.framework isEqualToString:@"test_FW"]);
    XCTAssertTrue([immutable.requestId isEqualToString:@"test_RID"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"debug"]);
    XCTAssertTrue([content containsString:@"critical"]);
    XCTAssertTrue([content containsString:@"25"]);
    XCTAssertTrue([content containsString:@"Full"]);
    XCTAssertTrue([content containsString:@"test_CV"]);
    XCTAssertTrue([content containsString:@"test_FW"]);
    XCTAssertTrue([content containsString:@"test_RID"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarModule {
    
    NSString *defaultMutable = [[RollbarMutableModule new] serializeToJSONString];
    NSString *defaultImmutable = [[[RollbarModule alloc] initWithName:nil] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableModule *mutable = [RollbarMutableModule new];
    mutable.name = @"test_N_old";
    mutable.version = @"test_V_old";
    XCTAssertTrue([mutable.name isEqualToString:@"test_N_old"]);
    XCTAssertTrue([mutable.version isEqualToString:@"test_V_old"]);
    
    mutable.name = @"test_N";
    mutable.version = @"test_V";
    XCTAssertTrue([mutable.name isEqualToString:@"test_N"]);
    XCTAssertTrue([mutable.version isEqualToString:@"test_V"]);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_N"]);
    XCTAssertTrue([content containsString:@"test_V"]);
    
    RollbarModule *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue([immutable.name isEqualToString:@"test_N"]);
    XCTAssertTrue([immutable.version isEqualToString:@"test_V"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_N"]);
    XCTAssertTrue([content containsString:@"test_V"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarPerson {
    
    NSString *defaultMutable = [[[RollbarMutablePerson alloc] initWithID:@"ID"] serializeToJSONString];
    NSString *defaultImmutable = [[[RollbarPerson alloc] initWithID:@"ID"] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutablePerson *mutable = [RollbarMutablePerson new];
    mutable.ID = @"test_ID_old";
    mutable.username = @"test_UN_old";
    mutable.email = @"test_EM_old";
    XCTAssertTrue([mutable.ID isEqualToString:@"test_ID_old"]);
    XCTAssertTrue([mutable.username isEqualToString:@"test_UN_old"]);
    XCTAssertTrue([mutable.email isEqualToString:@"test_EM_old"]);

    mutable.ID = @"test_ID";
    mutable.username = @"test_UN";
    mutable.email = @"test_EM";
    XCTAssertTrue([mutable.ID isEqualToString:@"test_ID"]);
    XCTAssertTrue([mutable.username isEqualToString:@"test_UN"]);
    XCTAssertTrue([mutable.email isEqualToString:@"test_EM"]);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_ID"]);
    XCTAssertTrue([content containsString:@"test_UN"]);
    XCTAssertTrue([content containsString:@"test_EM"]);

    RollbarPerson *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue([immutable.ID isEqualToString:@"test_ID"]);
    XCTAssertTrue([immutable.username isEqualToString:@"test_UN"]);
    XCTAssertTrue([immutable.email isEqualToString:@"test_EM"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_ID"]);
    XCTAssertTrue([content containsString:@"test_UN"]);
    XCTAssertTrue([content containsString:@"test_EM"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarProxy {
    
    NSString *defaultMutable = [[RollbarMutableProxy new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarProxy new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableProxy *mutable = [RollbarMutableProxy new];
    mutable.enabled = NO;
    mutable.proxyUrl = @"test_URL_old";
    mutable.proxyPort = 100;
    XCTAssertTrue(!mutable.enabled);
    XCTAssertTrue([mutable.proxyUrl isEqualToString:@"test_URL_old"]);
    XCTAssertEqual(mutable.proxyPort, 100);
    
    mutable.enabled = YES;
    mutable.proxyUrl = @"test_URL";
    mutable.proxyPort = 199;
    XCTAssertTrue(mutable.enabled);
    XCTAssertTrue([mutable.proxyUrl isEqualToString:@"test_URL"]);
    XCTAssertEqual(mutable.proxyPort, 199);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_URL"]);
    XCTAssertTrue([content containsString:@"199"]);
    
    RollbarProxy *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue(immutable.enabled);
    XCTAssertTrue([immutable.proxyUrl isEqualToString:@"test_URL"]);
    XCTAssertEqual(immutable.proxyPort, 199);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_URL"]);
    XCTAssertTrue([content containsString:@"199"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarServerConfig {
    
    NSString *defaultMutable = [[RollbarMutableServerConfig new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarServerConfig new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableServerConfig *mutable = [RollbarMutableServerConfig new];
    mutable.host = @"test_H_old";
    mutable.root = @"test_R_old";
    mutable.branch = @"test_B_old";
    mutable.codeVersion = @"test_CV_old";
    XCTAssertTrue([mutable.host isEqualToString:@"test_H_old"]);
    XCTAssertTrue([mutable.root isEqualToString:@"test_R_old"]);
    XCTAssertTrue([mutable.branch isEqualToString:@"test_B_old"]);
    XCTAssertTrue([mutable.codeVersion isEqualToString:@"test_CV_old"]);

    mutable.host = @"test_H";
    mutable.root = @"test_R";
    mutable.branch = @"test_B";
    mutable.codeVersion = @"test_CV";
    XCTAssertTrue([mutable.host isEqualToString:@"test_H"]);
    XCTAssertTrue([mutable.root isEqualToString:@"test_R"]);
    XCTAssertTrue([mutable.branch isEqualToString:@"test_B"]);
    XCTAssertTrue([mutable.codeVersion isEqualToString:@"test_CV"]);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_H"]);
    XCTAssertTrue([content containsString:@"test_R"]);
    XCTAssertTrue([content containsString:@"test_B"]);
    XCTAssertTrue([content containsString:@"test_CV"]);

    RollbarServerConfig *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue([immutable.host isEqualToString:@"test_H"]);
    XCTAssertTrue([immutable.root isEqualToString:@"test_R"]);
    XCTAssertTrue([immutable.branch isEqualToString:@"test_B"]);
    XCTAssertTrue([immutable.codeVersion isEqualToString:@"test_CV"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_H"]);
    XCTAssertTrue([content containsString:@"test_R"]);
    XCTAssertTrue([content containsString:@"test_B"]);
    XCTAssertTrue([content containsString:@"test_CV"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarScrubbingOptions {
    
    NSString *defaultMutable = [[RollbarMutableScrubbingOptions new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarScrubbingOptions new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableScrubbingOptions *mutable = [RollbarMutableScrubbingOptions new];
    mutable.enabled = NO;
    mutable.scrubFields = [@[@"F1"] mutableCopy];
    mutable.safeListFields = [@[@"S1"] mutableCopy];
    XCTAssertTrue(!mutable.enabled);
    XCTAssertTrue([mutable.scrubFields containsObject:@"F1"]);
    XCTAssertTrue(![mutable.scrubFields containsObject:@"F2"]);
    XCTAssertTrue([mutable.safeListFields containsObject:@"S1"]);
    XCTAssertTrue(![mutable.safeListFields containsObject:@"S2"]);

    mutable.enabled = YES;
    [mutable addScrubField:@"F2"];
    [mutable addScrubSafeListField:@"S2"];
    XCTAssertTrue(mutable.enabled);
    XCTAssertTrue([mutable.scrubFields containsObject:@"F1"]);
    XCTAssertTrue([mutable.scrubFields containsObject:@"F2"]);
    XCTAssertTrue([mutable.safeListFields containsObject:@"S1"]);
    XCTAssertTrue([mutable.safeListFields containsObject:@"S2"]);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"F1"]);
    XCTAssertTrue([content containsString:@"F2"]);
    XCTAssertTrue([content containsString:@"S1"]);
    XCTAssertTrue([content containsString:@"S2"]);

    RollbarScrubbingOptions *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue(immutable.enabled);
    XCTAssertTrue([immutable.scrubFields containsObject:@"F1"]);
    XCTAssertTrue([immutable.scrubFields containsObject:@"F2"]);
    XCTAssertTrue([immutable.safeListFields containsObject:@"S1"]);
    XCTAssertTrue([immutable.safeListFields containsObject:@"S2"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"F1"]);
    XCTAssertTrue([content containsString:@"F2"]);
    XCTAssertTrue([content containsString:@"S1"]);
    XCTAssertTrue([content containsString:@"S2"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarTelemetryOptions {
    
    NSString *defaultMutable = [[RollbarMutableTelemetryOptions new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarTelemetryOptions new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableTelemetryOptions *mutable = [RollbarMutableTelemetryOptions new];
    mutable.enabled = NO;
    mutable.captureLog = NO;
    mutable.captureConnectivity = NO;
    mutable.maximumTelemetryData = 10;
    mutable.memoryStatsAutocollectionInterval = 11;
    [mutable.viewInputsScrubber addScrubField:@"F1"];
    [mutable.viewInputsScrubber addScrubSafeListField:@"S1"];
    XCTAssertTrue(!mutable.enabled);
    XCTAssertTrue(!mutable.captureLog);
    XCTAssertTrue(!mutable.captureConnectivity);
    XCTAssertEqual(mutable.maximumTelemetryData, 10);
    XCTAssertEqual(mutable.memoryStatsAutocollectionInterval, 11);
    XCTAssertNotNil(mutable.viewInputsScrubber);
    XCTAssertNotNil(mutable.viewInputsScrubber.scrubFields);
    XCTAssertNotNil(mutable.viewInputsScrubber.safeListFields);
    XCTAssertEqual(mutable.viewInputsScrubber.scrubFields.count, 9);
    XCTAssertEqual(mutable.viewInputsScrubber.safeListFields.count, 1);
    XCTAssertEqual(mutable.viewInputsScrubber.scrubFields[8], @"F1");
    XCTAssertEqual(mutable.viewInputsScrubber.safeListFields[0], @"S1");

    mutable.enabled = YES;
    mutable.captureLog = YES;
    mutable.captureConnectivity = YES;
    mutable.maximumTelemetryData = 19;
    mutable.memoryStatsAutocollectionInterval = 21;
    [mutable.viewInputsScrubber addScrubField:@"F2"];
    [mutable.viewInputsScrubber addScrubSafeListField:@"S2"];
    XCTAssertTrue(mutable.enabled);
    XCTAssertTrue(mutable.captureLog);
    XCTAssertTrue(mutable.captureConnectivity);
    XCTAssertEqual(mutable.maximumTelemetryData, 19);
    XCTAssertEqual(mutable.memoryStatsAutocollectionInterval, 21);
    XCTAssertNotNil(mutable.viewInputsScrubber);
    XCTAssertNotNil(mutable.viewInputsScrubber.scrubFields);
    XCTAssertNotNil(mutable.viewInputsScrubber.safeListFields);
    XCTAssertEqual(mutable.viewInputsScrubber.scrubFields.count, 10);
    XCTAssertEqual(mutable.viewInputsScrubber.safeListFields.count, 2);
    XCTAssertTrue([mutable.viewInputsScrubber.scrubFields[8] isEqualToString:@"F1"]);
    XCTAssertTrue([mutable.viewInputsScrubber.safeListFields[0] isEqualToString:@"S1"]);
    XCTAssertTrue([mutable.viewInputsScrubber.scrubFields[9] isEqualToString:@"F2"]);
    XCTAssertTrue([mutable.viewInputsScrubber.safeListFields[1] isEqualToString:@"S2"]);

    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"19"]);
    XCTAssertTrue([content containsString:@"21"]);
    XCTAssertTrue([content containsString:@"F1"]);
    XCTAssertTrue([content containsString:@"F2"]);
    XCTAssertTrue([content containsString:@"S1"]);
    XCTAssertTrue([content containsString:@"S2"]);
    
    RollbarTelemetryOptions *immutable = [mutable copy];
    XCTAssertNotNil(immutable);
    XCTAssertTrue(immutable.enabled);
    XCTAssertTrue(immutable.captureLog);
    XCTAssertTrue(immutable.captureConnectivity);
    XCTAssertEqual(immutable.maximumTelemetryData, 19);
    XCTAssertEqual(immutable.memoryStatsAutocollectionInterval, 21);
    XCTAssertNotNil(immutable.viewInputsScrubber);
    XCTAssertNotNil(immutable.viewInputsScrubber.scrubFields);
    XCTAssertNotNil(immutable.viewInputsScrubber.safeListFields);
    XCTAssertEqual(immutable.viewInputsScrubber.scrubFields.count, 10);
    XCTAssertEqual(immutable.viewInputsScrubber.safeListFields.count, 2);
    XCTAssertTrue([immutable.viewInputsScrubber.scrubFields[8] isEqualToString:@"F1"]);
    XCTAssertTrue([immutable.viewInputsScrubber.safeListFields[0] isEqualToString:@"S1"]);
    XCTAssertTrue([immutable.viewInputsScrubber.scrubFields[9] isEqualToString:@"F2"]);
    XCTAssertTrue([immutable.viewInputsScrubber.safeListFields[1] isEqualToString:@"S2"]);

    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"19"]);
    XCTAssertTrue([content containsString:@"21"]);
    XCTAssertTrue([content containsString:@"F1"]);
    XCTAssertTrue([content containsString:@"F2"]);
    XCTAssertTrue([content containsString:@"S1"]);
    XCTAssertTrue([content containsString:@"S2"]);

    XCTAssertEqualObjects(immutable, mutable);
    XCTAssertNotIdentical(immutable, mutable);
    
    XCTAssertEqualObjects(immutable, [immutable copy]);
    XCTAssertIdentical   (immutable, [immutable copy]);
    XCTAssertEqualObjects(immutable, [immutable mutableCopy]);
    XCTAssertNotIdentical(immutable, [immutable mutableCopy]);
    
    XCTAssertEqualObjects(mutable, [mutable copy]);
    XCTAssertNotIdentical(mutable, [mutable copy]);
    XCTAssertEqualObjects(mutable, [mutable mutableCopy]);
    XCTAssertNotIdentical(mutable, [mutable mutableCopy]);
}

- (void)testRollbarConfig {
    
    NSString *defaultMutable = [[RollbarMutableConfig new] serializeToJSONString];
    NSString *defaultImmutable = [[RollbarConfig new] serializeToJSONString];
    XCTAssertTrue([defaultMutable isEqualToString:defaultImmutable]);
    
    RollbarMutableConfig *mutable = [RollbarMutableConfig new];
    mutable.destination.accessToken = @"test_AT_old";
    RollbarMutableDeveloperOptions *devOptions = [RollbarMutableDeveloperOptions new];
    devOptions.transmittedPayloadsLogFile = @"test_PL_old";
    mutable.developerOptions = devOptions;
    
    XCTAssertTrue([mutable.destination.accessToken isEqualToString:@"test_AT_old"]);
    XCTAssertTrue([mutable.developerOptions.transmittedPayloadsLogFile isEqualToString:@"test_PL_old"]);
    
    NSString *content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_AT_old"]);
    XCTAssertTrue([content containsString:@"test_PL_old"]);
    
    mutable.destination.accessToken = @"test_AT";
    mutable.developerOptions.transmittedPayloadsLogFile = @"test_PL";
    
    XCTAssertTrue([mutable.destination.accessToken isEqualToString:@"test_AT"]);
    XCTAssertTrue([mutable.developerOptions.transmittedPayloadsLogFile isEqualToString:@"test_PL"]);
    
    content = [mutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_AT"]);
    XCTAssertTrue([content containsString:@"test_PL"]);
    XCTAssertTrue(![content containsString:@"test_AT_old"]);
    XCTAssertTrue(![content containsString:@"test_PL_old"]);

    RollbarConfig *immutable = [mutable copy];

    XCTAssertTrue([immutable.destination.accessToken isEqualToString:@"test_AT"]);
    XCTAssertTrue([immutable.developerOptions.transmittedPayloadsLogFile isEqualToString:@"test_PL"]);
    
    content = [immutable serializeToJSONString];
    XCTAssertNotNil(content);
    XCTAssertTrue([content containsString:@"test_AT"]);
    XCTAssertTrue([content containsString:@"test_PL"]);
    XCTAssertTrue(![content containsString:@"test_AT_old"]);
    XCTAssertTrue(![content containsString:@"test_PL_old"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
