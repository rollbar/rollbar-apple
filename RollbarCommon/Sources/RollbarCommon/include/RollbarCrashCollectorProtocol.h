#ifndef RollbarCrashCollectorProtocol_h
#define RollbarCrashCollectorProtocol_h

@import Foundation;

@class RollbarCrashReportData;

/// Crash collector observer protocol.
@protocol RollbarCrashCollectorObserver

@required
/// Collback invoked when discovered crash reports  are loaded.
/// @param crashReports discovered crash reports.
-(void)onCrashReportsCollectionCompletion:(NSArray<RollbarCrashReportData *> *)crashReports;

@optional
//...

@end

/// Crash collector protocol.
@protocol RollbarCrashCollector

@required
/// Triggers a collection of crash reports (if any).
/// @param observer an observer to notify after the collection is done.
-(void)collectCrashReportsWithObserver:(id<RollbarCrashCollectorObserver>)observer;

@optional
/// Triggers a collection of crash reports (if any).
-(void)collectCrashReports;

@end

#endif /* RollbarCrashCollectorProtocol_h */
