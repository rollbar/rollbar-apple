#import <XCTest/XCTest.h>

@import RollbarCommon;

@interface RollbarOsUtilTests : XCTestCase

@end

@implementation RollbarOsUtilTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testOsVersionDetection {

    NSOperatingSystemVersion version = [RollbarOsUtil detectOsVersion];
    NSString *versionString = [RollbarOsUtil stringFromOsVersion:version];
    NSString *detectedVersionString = [RollbarOsUtil detectOsVersionString];
    XCTAssertTrue([detectedVersionString containsString:versionString]);
}

- (void)testDetectOsUptimeInterval {
    
    NSTimeInterval interval = [RollbarOsUtil detectOsUptimeInterval];
    XCTAssertGreaterThan(interval, 0);
}

- (void)testPerformance_stringFromOsVersion {
    
    [self measureBlock:^{
        
        NSOperatingSystemVersion version = {
            .majorVersion = 1,
            .minorVersion = 2,
            .patchVersion = 3
        };
        NSString *versionString = [RollbarOsUtil stringFromOsVersion:version];
    }];
}

- (void)testPerformance_detectOsVersion {
    
    [self measureBlock:^{
        
        NSOperatingSystemVersion version = [RollbarOsUtil detectOsVersion];
    }];
}

- (void)testPerformance_detectOsVersionString {
    
    [self measureBlock:^{
        
        NSString *detectedVersionString = [RollbarOsUtil detectOsVersionString];
    }];
}

- (void)testPerformance_detectOsUptimeInterval {

    [self measureBlock:^{
        
        NSTimeInterval interval = [RollbarOsUtil detectOsUptimeInterval];
    }];
}

@end
