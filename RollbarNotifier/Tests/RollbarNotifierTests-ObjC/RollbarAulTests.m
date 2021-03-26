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
    
    NSDate *date = [NSDate now];

    // Log a message to the default log and default log level.os_log(OS_LOG_DEFAULT, "This is a default message.");
        
    // Log a message to the default log and debug log level
    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_DEBUG, "This is a debug message.");
        
    // Log an error to a custom log object.
    os_log_t customLog = os_log_create("com.your_company.your_subsystem", "your_category_name");
    int i = 0;
    while (i++ < 10) {
        os_log_with_type(customLog, OS_LOG_TYPE_ERROR, "An error occurred!");
    }
    
    NSError *error = nil;
    id osLogStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil != error) {
        
    }
    
    OSLogPosition *logPosition = [osLogStore positionWithDate:date];
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(date >= %@)", date];
    NSPredicate *subsystemPredicate = [NSPredicate predicateWithFormat:@"subsystem == %@", @"com.your_company.your_subsystem"];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category == %@", @"[your_category_name]"];
    NSPredicate *levelPredicate = [NSPredicate predicateWithFormat:@"level == %@", [NSNumber numberWithInt:OS_LOG_TYPE_ERROR] ];
    //NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[levelPredicate, subsystemPredicate, categoryPredicate]];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[subsystemPredicate]];

    OSLogEnumerator *logEnumerator = [osLogStore entriesEnumeratorWithOptions:0
                                                                     position:nil
                                                                    predicate:predicate
                                                                        error:&error];
    if (nil != error) {
        
    }
    
    //NSUInteger count = logEnumerator.allObjects.count;
    int count = 0;
    for (OSLogEntryLog *entry in logEnumerator) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:MM:ss.SSSXXXXX"];
        NSLog(@">>>>> %@: %@", [formatter stringFromDate:entry.date], entry.composedMessage);
        count++;
    }
    NSLog(@"Total AUL entries: %d", count);
}

@end
#endif
