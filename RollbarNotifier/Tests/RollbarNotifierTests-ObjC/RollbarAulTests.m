@import Foundation;
@import OSLog;

#if !TARGET_OS_WATCH
#import <XCTest/XCTest.h>

@import RollbarNotifier;

@interface RollbarAulTests : XCTestCase

@end

@implementation RollbarAulTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAUL {
    
    NSDate *date = [NSDate date];
    
    // Log a message to the default log and default log level.os_log(OS_LOG_DEFAULT, "This is a default message.");
        
    // Log a message to the default log and debug log level
    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG, "This is a debug message.");
        
    // Log an error to a custom log object.
    os_log_t customLog = os_log_create("com.your_company.your_subsystem", "your_category_name");
    int i = 0;
    while (i++ < 1) {
        NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
        [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
        //NSString *msg = [NSString stringWithFormat:@"An error occurred at %@!", [timestampFormatter stringFromDate:[NSDate date]] ];
        os_log_error(customLog, "An error occurred at %@!", [timestampFormatter stringFromDate:[NSDate date]]);
    }
    
    NSError *error = nil;
    id osLogStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil != error) {
        
    }
    
    [NSThread sleepForTimeInterval:3.0f];
    
    OSLogPosition *logPosition = [osLogStore positionWithDate:date];
    //NSTimeInterval timeInterval = 3.0;
    //OSLogPosition *logPosition = [osLogStore positionWithTimeIntervalSinceEnd:timeInterval];
    
    //NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date >= %@", date];
    NSPredicate *subsystemPredicate = [NSPredicate predicateWithFormat:@"subsystem == %@", @"com.your_company.your_subsystem"];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category == %@", @"your_category_name"];
    NSPredicate *levelPredicate = [NSPredicate predicateWithFormat:@"level == %@", [NSNumber numberWithUnsignedInteger:OS_LOG_TYPE_ERROR] ];
    //NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[levelPredicate, subsystemPredicate, categoryPredicate]];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[subsystemPredicate, categoryPredicate]];

    [NSThread sleepForTimeInterval:3.0f];
    
    OSLogEnumerator *logEnumerator = [osLogStore entriesEnumeratorWithOptions:0
                                                                     position:logPosition
                                                                    predicate:predicate
                                                                        error:&error];
    if (nil != error) {
        
    }
    
    [NSThread sleepForTimeInterval:3.0f];
    
    //NSUInteger count = logEnumerator.allObjects.count;
    int count = 0;
    for (OSLogEntryLog *entry in logEnumerator) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
        NSLog(@">>>>> %@: %@", [formatter stringFromDate:entry.date], entry.composedMessage);
        count++;
    }
    NSLog(@"Total AUL entries: %d", count);
}

- (NSPredicate *)buildPredicateStartingAt:(NSDate *)timestamp {
    
    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
    NSLog(@">>>>> Timestamp: %@", [timestampFormatter stringFromDate:timestamp]);
}

@end
#endif
