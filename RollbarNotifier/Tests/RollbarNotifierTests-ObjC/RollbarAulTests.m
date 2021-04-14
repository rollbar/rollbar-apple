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

- (void)testSampleAULEntries {
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-3.0];
    
    [self traceTimestamp:date];
    
    NSError *error = nil;
    OSLogStore *logStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil != error) {
        NSLog(@"AUL ERROR: %@", error);
    }

    OSLogPosition *logPosition = [logStore positionWithDate:date];

    OSLogEnumerator *logEnumerator = [self buildAulLogEnumeratorWithinLogStore:logStore
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

// LEGACY WORKING VERSION:
//    NSError *error = nil;
//    id osLogStore = [OSLogStore localStoreAndReturnError:&error];
//    if (nil != error) {
//        NSLog(@"AUL ERROR: %@", error);
//    }
//
//    //[NSThread sleepForTimeInterval:1.0f];
//
//    OSLogPosition *logPosition = [osLogStore positionWithDate:date];
//    //NSTimeInterval timeInterval = 3.0;
//    //OSLogPosition *logPosition = [osLogStore positionWithTimeIntervalSinceEnd:timeInterval];
//
//    //NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startDate, endDate];
//    //NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date >= %@", date];
//    NSPredicate *subsystemPredicate = [NSPredicate predicateWithFormat:@"subsystem == %@", @"com.your_company.your_subsystem"];
//    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category == %@", @"your_category_name"];
//    NSPredicate *levelPredicate = [NSPredicate predicateWithFormat:@"level == %@", [NSNumber numberWithUnsignedInteger:OS_LOG_TYPE_DEFAULT] ];
//    //NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[levelPredicate, subsystemPredicate, categoryPredicate]];
//    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[subsystemPredicate, categoryPredicate]];
//
//    //[NSThread sleepForTimeInterval:1.0f];
//
//    OSLogEnumerator *logEnumerator = [osLogStore entriesEnumeratorWithOptions:0
//                                                                     position:logPosition
//                                                                    predicate:predicate
//                                                                        error:&error];
//    if (nil != error) {
//        NSLog(@"AUL ERROR: %@", error);
//    }
//
//    //[NSThread sleepForTimeInterval:1.0f];
//
//    //NSUInteger count = logEnumerator.allObjects.count;
//    int count = 0;
//    for (OSLogEntryLog *entry in logEnumerator) {
//
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
//        NSLog(@">>>>> %@: %@", [formatter stringFromDate:entry.date], entry.composedMessage);
//        count++;
//    }
//    NSLog(@"LEGACY Total AUL entries: %d", count);
    
    [NSThread sleepForTimeInterval:20.0f];
    
// NEW MORE STRUCTURED IMPLEMENTATION:
    NSError *error = nil;
    OSLogStore *logStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil != error) {
        NSLog(@"AUL ERROR: %@", error);
    }

    OSLogPosition *logPosition = [logStore positionWithDate:date];

    OSLogEnumerator *logEnumerator = [self buildAulLogEnumeratorWithinLogStore:logStore
                                                             staringAtPosition:logPosition
                                                                  forSubsystem:@"com.your_company.your_subsystem"
                                                                andForCategory:@"your_category_name"];
    int count = [self processLogEntries:logEnumerator];
    NSLog(@"Total AUL entries: %d", count);
    XCTAssertEqual(count, 2 * maxIterations);
}

#pragma mark - RollbarNotifier RollbarAulEntrySnapper

// make it public
- (void)captureOSLogEntry:(nullable OSLogEntry *)entry
             intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot {
    
    if (nil == entry) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];

    snapshot[@"date"] = [formatter stringFromDate:entry.date];
    snapshot[@"className"] = entry.className;
    snapshot[@"composedMessage"] = entry.composedMessage;
    //snapShot[@""] = entry.storeCategory;
    
    if ([entry isKindOfClass:[OSLogEntryLog class]]) {
        
        [self captureOSLogEntryLog:(OSLogEntryLog *)entry
                      intoSnapshot:snapshot];
    }
    else if ([entry isKindOfClass:[OSLogEntryActivity class]]) {
        
        [self captureOSLogEntryActivity:(OSLogEntryActivity *)entry
                           intoSnapshot:snapshot];
    }
    else if ([entry isKindOfClass:[OSLogEntrySignpost class]]) {
        
        [self captureOSLogEntrySignpost:(OSLogEntrySignpost *)entry
                           intoSnapshot:snapshot];
    }
    else if ([entry conformsToProtocol:@protocol(OSLogEntryFromProcess)]) {
        
        [self captureOSLogEntryFromProcess:(OSLogEntry<OSLogEntryFromProcess> *)entry
                              intoSnapshot:snapshot];
    }
    else if ([entry conformsToProtocol:@protocol(OSLogEntryWithPayload)]) {
        
        [self captureOSLogEntryWithPayload:(OSLogEntry<OSLogEntryWithPayload> *)entry
                              intoSnapshot:snapshot];
    }
}

// make it private
- (void)captureOSLogEntryLog:(nullable OSLogEntryLog *)entry
                intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot {
    
    if (nil == entry) {
        return;
    }
    
    snapshot[@"level"] = [RollbarAulOSLogEntryLogLevelConverter OSLogEntryLogLevelToString:entry.level];
}

// make it private
- (void)captureOSLogEntryActivity:(nullable OSLogEntryActivity *)entry
                     intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot {

    if (nil == entry) {
        return;
    }
    
    snapshot[@"parentActivityIdentifier"] = [NSNumber numberWithUnsignedInt:entry.parentActivityIdentifier];
}

// make it private
- (void)captureOSLogEntrySignpost:(nullable OSLogEntrySignpost *)entry
                     intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot {

    if (nil == entry) {
        return;
    }
    
    snapshot[@"signpostIdentifier"] = [NSNumber numberWithUnsignedInt:entry.signpostIdentifier];
    snapshot[@"signpostName"] = entry.signpostName;
    snapshot[@"signpostType"] = [NSNumber numberWithInteger:entry.signpostType];
}

// make it private
- (void)captureOSLogEntryFromProcess:(nullable OSLogEntry<OSLogEntryFromProcess> *)entry
                        intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot {

    if (nil == entry) {
        return;
    }
    
    snapshot[@"activityIdentifier"] = [NSNumber numberWithUnsignedInt:entry.activityIdentifier]; //uint64
    snapshot[@"process"] = entry.process;
    snapshot[@"processIdentifier"] = [NSNumber numberWithInt:entry.processIdentifier];
    snapshot[@"sender"] = entry.sender;
    snapshot[@"threadIdentifier"] = [NSNumber numberWithUnsignedInt:entry.threadIdentifier];
}

// make it private
- (void)captureOSLogEntryWithPayload:(nullable OSLogEntry<OSLogEntryWithPayload> *)entry
                        intoSnapshot:(nonnull NSMutableDictionary<NSString *, id> *)snapshot {

    if (nil == entry) {
        return;
    }
    
    snapshot[@"category"] = entry.category;
    snapshot[@"subsystem"] = entry.subsystem;
}


#pragma mark - RollbarNotifier RollbarAulClient

- (int)processLogEntries:(OSLogEnumerator *)logEnumerator {
    
    int count = 0;
    for (OSLogEntryLog *entry in logEnumerator) {
        
        //TODO: reimplement to forward the log entries to Rollbar!!!

//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
//        NSLog(@">>>>> %@: %@", [formatter stringFromDate:entry.date], entry.composedMessage);
        
        NSLog(@"");
        NSLog(@"=== START AUL ENTRY ===");
        NSMutableDictionary<NSString *, id> *entrySnapshot = [NSMutableDictionary<NSString *, id> dictionaryWithCapacity:20];
        [self captureOSLogEntry:entry intoSnapshot:entrySnapshot];
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

- (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category {

    if (nil == logStore) {
        
        return nil;
    }
    
    NSPredicate *predicate = [self buildRollbarAulPredicateForSubsystem:subsystem
                                                         andForCategory:category];
    
    NSError *error = nil;
    OSLogEnumerator *logEnumerator = [logStore entriesEnumeratorWithOptions:0
                                                                   position:logPosition
                                                                  predicate:predicate
                                                                      error:&error];
    if (nil != error) {
        
        //TODO: log into the SDK log
        return nil;
    }
    
    return logEnumerator;
}

#pragma mark - RollbarNotifier RollbarAulPredicateBuilder

- (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                                andForCategory:(nullable NSString *)category {
    
    NSPredicate *subsystemPredicate = [self buildSubsystemPredicate:subsystem];
    NSPredicate *categoryPredicate = [self buildCategoryPredicate:category];

    if ((nil != subsystemPredicate) && (nil != categoryPredicate)) {
        
        NSPredicate *predicate =
        [NSCompoundPredicate andPredicateWithSubpredicates:@[subsystemPredicate, categoryPredicate]];
        return predicate;
    }
    else if (nil != subsystemPredicate) {
        
        return subsystemPredicate;
    }
    else if (nil != categoryPredicate) {
        
        return categoryPredicate;
    }
    else {
        return nil;
    }
}

- (nullable NSPredicate *)buildSubsystemPredicate:(nullable NSString *)subsystem {
    
    NSPredicate *predicate = nil;
    
    if (nil != subsystem) {
        
        //predicate = [NSPredicate predicateWithFormat:@"subsystem == %@", subsystem];
        
        predicate = [self buildStringPredicateWithValue:subsystem
                                            forProperty:@"subsystem"];
    }

    return predicate;
}

- (nullable NSPredicate *)buildCategoryPredicate:(nullable NSString *)category {
    
    NSPredicate *predicate = nil;
    
    if (nil != category) {
        
        //predicate = [NSPredicate predicateWithFormat:@"category == %@", category];

        predicate = [self buildStringPredicateWithValue:category
                                            forProperty:@"category"];
    }

    return predicate;
}

- (nullable NSPredicate *)buildInclusiveTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                               endingAt:(nullable NSDate *)endTime {
    
    NSPredicate *predicate = [self buildInclusiveTimeIntervalPredicateStartingAt:startTime
                                                                        endingAt:endTime
                                                                     forProperty:@"data"];
    return predicate;
}

#pragma mark - RollbarCommon RollbarPredicateBuilder

- (nullable NSPredicate *)buildStringPredicateWithValue:(nullable NSString *)value
                                            forProperty:(nullable NSString *)property {
    
    NSPredicate *predicate = nil;
    
    if ((nil != property) && (nil != value)) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K == %@", property, value];
    }
    else if (nil != property) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K == nil", property, value];
    }

    return predicate;
}

- (nullable NSPredicate *)buildInclusiveTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                               endingAt:(nullable NSDate *)endTime
                                                            forProperty:(nullable NSString *)property {
    
    if (nil == property) {
        
        return nil;
    }
    
    NSPredicate *predicate = nil;
    
    if ((nil != startTime) && (nil != endTime)) {
        
        predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", startTime, endTime];
    }
    else if (nil != startTime) {
        
        predicate = [NSPredicate predicateWithFormat:@"date >= %@", startTime];
    }
    else if (nil != endTime) {
        
        predicate = [NSPredicate predicateWithFormat:@"date <= %@", endTime];
    }

    return predicate;
}

- (void)traceTimestamp:(nonnull NSDate *)timestamp {
    
    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
    NSLog(@">>>>> Timestamp: %@", [timestampFormatter stringFromDate:timestamp]);
}

@end
#endif
