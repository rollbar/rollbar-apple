//
//  RollbarCrashReportUtil.h
//  
//
//  Created by Andrey Kornich on 2021-01-04.
//

#ifndef RollbarCrashReportUtil_h
#define RollbarCrashReportUtil_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RollbarExceptionInfo) {
    RollbarExceptionInfo_Type,
    RollbarExceptionInfo_Codes,
    RollbarExceptionInfo_Backtraces
};

@interface RollbarCrashReportUtil : NSObject

+ (nonnull NSArray<NSString *> *)extractLinesFromCrashReport:(nonnull NSString *)report;

+ (nonnull NSDictionary *)extractExceptionInfoFromCrashReport:(nonnull NSString *)crashReport;

#pragma mark - Initializers

- (instancetype _Nonnull )init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* RollbarCrashReportUtil_h */

