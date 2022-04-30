#import <XCTest/XCTest.h>

#import "../../Sources/RollbarNotifier/RollbarSession.h"
@import RollbarNotifier;

@interface RollbarSessionTests : XCTestCase

@end

@implementation RollbarSessionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self deleteSessionFile];
    XCTAssertTrue(NO == [self sessionFileExists]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRollbarSessionBasics {

    XCTAssertTrue(NO == [self sessionFileExists]);
    RollbarSession *session = [RollbarSession sharedInstance];
    XCTAssertTrue(YES == [self sessionFileExists]);
    RollbarSessionState *persistedSessionState = [self readSessionState];
    XCTAssertNotNil(persistedSessionState);
    NSLog(@"Persisted: %@", persistedSessionState);
    RollbarSessionState *currentSessionState = [[RollbarSession sharedInstance] getCurrentState];
    NSLog(@"Current: %@", currentSessionState);
    XCTAssertTrue(NSOrderedSame ==
                  [[persistedSessionState serializeToJSONString] compare:
                   [currentSessionState serializeToJSONString]
                  ]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - test helpers

- (void)deleteSessionFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [RollbarCachesDirectory getCacheFilePath:@"rollbar.session"];
    NSError *error;
    if (NO == [fileManager removeItemAtPath:filePath error:&error]) {
        
        NSLog(@"Couln't remove the session file");
        if (error) {
            
            NSLog(@"Reason: %@", [error localizedDescription]);
        }
    }
}

- (BOOL)sessionFileExists {
    
    return [RollbarCachesDirectory checkCacheFileExists:@"rollbar.session"];
}

- (RollbarSessionState *)readSessionState {
    
    [NSThread sleepForTimeInterval:1.0f];
    NSData *data =
    [[NSData alloc] initWithContentsOfFile:[RollbarCachesDirectory getCacheFilePath:@"rollbar.session"]];
    RollbarSessionState *state =
    [[RollbarSessionState alloc] initWithJSONData:data];
    return state;
}

@end
