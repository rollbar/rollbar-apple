//
//  RollbarAulEntrySnapper.m
//  
//
//  Created by Andrey Kornich on 2021-05-03.
//

#import "RollbarAulEntrySnapper.h"
#import "RollbarAulOSLogEntryLogLevelConverter.h"

@implementation RollbarAulEntrySnapper

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

@end
