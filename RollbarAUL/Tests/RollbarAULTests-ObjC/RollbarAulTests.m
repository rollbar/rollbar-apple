@import Foundation;

#if TARGET_OS_OSX

@import OSLog;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;
@import RollbarAUL;

@interface RollbarAulTests : XCTestCase

@end

@implementation RollbarAulTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSampleAULEntries {
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3.0];
    
    [self traceTimestamp:date];
    
    NSError *error = nil;
    OSLogStore *logStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil != error) {
        NSLog(@"AUL ERROR: %@", error);
    }

    OSLogPosition *logPosition = [logStore positionWithDate:date];

    OSLogEnumerator *logEnumerator =
    [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                        staringAtPosition:logPosition
                                             forSubsystem:nil //@"com.your_company.your_subsystem"
                                           andForCategory:nil]; //@"your_category_name"];
    int count = [self processLogEntries:logEnumerator];
    NSLog(@"Total AUL entries: %d", count);
}

- (void)testAUL {
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-1.0];
    
    [self traceTimestamp:date];
    
    // Log a message to the default log and default log level.os_log(OS_LOG_DEFAULT, "This is a default message.");
        
    // Log a message to the default log and debug log level
    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG, "This is a debug message.");
        
    // Log an error to a custom log object.
    os_log_t customLog = os_log_create("com.your_company.your_subsystem", "your_category_name");
    int i = 0;
    int maxIterations = 4;
    while (i++ < maxIterations) {
        NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
        [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
        //NSString *msg = [NSString stringWithFormat:@"An error occurred at %@!", [timestampFormatter stringFromDate:[NSDate date]] ];
        os_log_error(customLog, "An error occurred at %@!", [timestampFormatter stringFromDate:[NSDate date]]);
        os_log_debug(customLog, "An error occurred at %@!", [timestampFormatter stringFromDate:[NSDate date]]);
        NSLog(@"Test NSLog");
    }

        
// NEW MORE STRUCTURED IMPLEMENTATION:
    NSError *error = nil;
    OSLogStore *logStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil != error) {
        NSLog(@"AUL ERROR: %@", error);
    }

    OSLogPosition *logPosition = [logStore positionWithDate:date];

    OSLogEnumerator *logEnumerator =
    [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                        staringAtPosition:logPosition
                                             forSubsystem:@"com.your_company.your_subsystem"
                                           andForCategory:@"your_category_name"];
    int count = [self processLogEntries:logEnumerator];
    NSLog(@"Total AUL entries: %d", count);
    //XCTAssertEqual(count, 2 * maxIterations);
}

#pragma mark - RollbarNotifier RollbarAulClient

- (int)processLogEntries:(OSLogEnumerator *)logEnumerator {
    
    int count = 0;
    RollbarAulEntrySnapper *entrySnapper = [RollbarAulEntrySnapper new];
    for (OSLogEntryLog *entry in logEnumerator) {
        
        //TODO: reimplement to forward the log entries to Rollbar!!!

//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
//        NSLog(@">>>>> %@: %@", [formatter stringFromDate:entry.date], entry.composedMessage);
        
        NSLog(@"");
        NSLog(@"=== START AUL ENTRY ===");
        NSMutableDictionary<NSString *, id> *entrySnapshot = [NSMutableDictionary<NSString *, id> dictionaryWithCapacity:20];
        
        [entrySnapper captureOSLogEntry:entry intoSnapshot:entrySnapshot];
        for (NSString *key in entrySnapshot) {
            id value = entrySnapshot[key];
            NSLog(@"   %@: %@", key, value);
        }
        NSLog(@"=== END AUL ENTRY ===");
        NSLog(@"");

        count++;
    }
    return count;
}

#pragma mark - RollbarCommon RollbarPredicateBuilder

- (void)traceTimestamp:(nonnull NSDate *)timestamp {
    
    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
    NSLog(@">>>>> Timestamp: %@", [timestampFormatter stringFromDate:timestamp]);
}

@end

#endif //!TARGET_OS_WATCH

#endif //TARGET_OS_OSX

