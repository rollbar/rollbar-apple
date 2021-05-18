//
//  RollbarKSCrashReportSink.h
//  
//
//  Created by Andrey Kornich on 2020-10-28.
//

#ifndef RollbarKSCrashReportSink_h
#define RollbarKSCrashReportSink_h

@import Foundation;
@import KSCrash_Reporting_Sinks;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarKSCrashReportSink : NSObject<KSCrashReportFilter>

- (id<KSCrashReportFilter>)defaultFilterSet;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarKSCrashReportSink_h
