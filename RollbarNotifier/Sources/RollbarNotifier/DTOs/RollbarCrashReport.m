#import "RollbarCrashReport.h"

static NSString *const DFK_RAW = @"raw";

@interface RollbarCrashReport ()

@property (strong, nonnull, readwrite) NSString *title;
@property (strong, nonnull, readwrite) NSString *diagnostic;

@end

#pragma mark -

@implementation RollbarCrashReport

- (instancetype)initWithRawCrashReport:(nonnull NSString *)report {
    self = [super initWithDictionary:@{
        DFK_RAW:report ?: [NSNull null]
    }];

    NSRange range = [report rangeOfString:@"CrashDoctor Diagnosis: " options:NSBackwardsSearch];
    if (range.length != 0) {
        NSRange lineRange = [self lineRangeFor:report range:range];
        self.title = [self diagnosticFrom:report range:lineRange];

        NSUInteger start = range.location + range.length;
        range = NSMakeRange(start, report.length - start);
        self.diagnostic = [self diagnosticFrom:report range:range];
    }

    range = [report rangeOfString:@"Exception Type:"];
    if (range.length != 0) {
        NSRange lineRange = [self lineRangeFor:report range:range];
        self.title = [self diagnosticFrom:report range:lineRange];
        self.diagnostic = self.title;
    }

    return self;
}

//- (nonnull NSString *)title {
//    NSString *report = self.rawCrashReport;
//    NSRange range = [report rangeOfString:@"CrashDoctor Diagnosis: " options:NSBackwardsSearch];
//    if (range.length != 0) {
//        NSRange lineRange = [self lineRangeForRange:range];
//        return [self diagnosticFromRange:lineRange];
//    }
//
//    range = [report rangeOfString:@"Exception Type:"];
//    if (range.length != 0) {
//        NSRange lineRange = [self lineRangeForRange:range];
//        return [self diagnosticFromRange:lineRange];
//    }
//}
//
//- (nonnull NSString *)diagnostic {
//    NSString *report = self.rawCrashReport;
//    NSRange range = [report rangeOfString:@"CrashDoctor Diagnosis: " options:NSBackwardsSearch];
//    if (range.length != 0) {
//        NSUInteger start = range.location + range.length;
//        range = NSMakeRange(start, report.length - start);
//        return [self diagnosticFromRange:range];
//    }
//
//    range = [report rangeOfString:@"Exception Type:"];
//    if (range.length != 0) {
//        NSRange lineRange = [self lineRangeForRange:range];
//        return [self diagnosticFromRange:lineRange];
//    }
//}

- (nonnull NSString *)diagnosticFrom:(NSString *)report range:(NSRange)range {
    NSString *diagnosis = [report substringWithRange:range];
    diagnosis = [diagnosis stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    diagnosis = [diagnosis stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    RollbarSdkLog(@"%@", diagnosis);
    return diagnosis;
}

- (NSRange)lineRangeFor:(NSString *)report range:(NSRange)range {
    NSRange lineRange = [report lineRangeForRange:range];
    lineRange.location += range.length;
    lineRange.length -= range.length;
    return lineRange;
}

@end
