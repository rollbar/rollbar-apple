//
//  RollbarTrace.m
//  Rollbar
//
//  Created by Andrey Kornich on 2019-11-27.
//  Copyright © 2019 Rollbar. All rights reserved.
//

#import "RollbarTrace.h"
//#import "DataTransferObject+Protected.h"
//#import "DataTransferObject+CustomData.h"
#import "RollbarCallStackFrame.h"
#import "RollbarException.h"

static NSString * const DFK_FRAMES = @"frames";
static NSString * const DFK_EXCEPTION = @"exception";

@implementation RollbarTrace

#pragma mark - Properties

-(nonnull NSArray<RollbarCallStackFrame *> *)frames {
    
    NSArray *dataArray = [self getDataByKey:DFK_FRAMES];
    if (dataArray) {
        NSMutableArray<RollbarCallStackFrame *> *result = [NSMutableArray arrayWithCapacity:dataArray.count];
        for(NSDictionary *data in dataArray) {
            if (data) {
                [result addObject:[[RollbarCallStackFrame alloc] initWithDictionary:data]];
            }
        }
        return result;
    }
    return [NSMutableArray array];
}

-(void)setFrames:(nonnull NSArray<RollbarCallStackFrame *> *)frames {
    
    [self setData:[self getJsonFriendlyDataFromFrames:frames] byKey:DFK_FRAMES];
}

-(nonnull RollbarException *)exception {
    NSDictionary *data = [self getDataByKey:DFK_EXCEPTION];
    if (!data) {
        data = [NSMutableDictionary dictionary];
    }
    return [[RollbarException alloc] initWithDictionary:data];
}

-(void)setException:(nonnull RollbarException *)exception {
    if(exception) {
        [self setData:exception.jsonFriendlyData byKey:DFK_EXCEPTION];
    }
    else {
        [self setData:nil byKey:DFK_EXCEPTION];
    }
}

#pragma mark - Initializers

-(instancetype)initWithRollbarException:(nonnull RollbarException *)exception
                 rollbarCallStackFrames:(nonnull NSArray<RollbarCallStackFrame *> *)frames {
    
    NSArray *framesData = [self getJsonFriendlyDataFromFrames:frames];
    self = [super initWithDictionary:@{
        DFK_EXCEPTION: exception ? exception.jsonFriendlyData : [NSNull null],
        DFK_FRAMES: framesData ? framesData : [NSNull null]
    }];
    return self;
}

-(instancetype)initWithException:(nonnull NSException *)exception {
    
    RollbarException *exceptionDto =
    [[RollbarException alloc] initWithExceptionClass:NSStringFromClass([exception class])
                                    exceptionMessage:exception.reason
                                exceptionDescription:exception.description];
    [exceptionDto tryAddKeyed:@"user_info" Object:exception.userInfo];
    
    NSMutableArray<RollbarCallStackFrame *> *frames = [NSMutableArray array];
    for (NSString *line in exception.callStackSymbols) {
        RollbarCallStackFrame *frame = [self buildStackFrameFromBacktraceLine:line];
        [frames addObject:frame];
    }
    
    self = [self initWithRollbarException:exceptionDto
                   rollbarCallStackFrames:frames];
    return self;
}

-(instancetype)initWithCrashReport:(nonnull NSString *)crashReport {
    
    NSDictionary *exceptionInfo =
    [RollbarCrashReportUtil extractExceptionInfoFromCrashReport:crashReport];
    
    NSString *exceptionTypePrefix = @"Exception Type: ";
    NSString *exceptionClass = (NSString *) exceptionInfo[@(RollbarExceptionInfo_Type)];
    exceptionClass = [exceptionClass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *exceptionCodesPrefix = @"Exception Codes: ";
    NSString *exceptionMessage = (NSString *) exceptionInfo[@(RollbarExceptionInfo_Codes)];
    exceptionMessage = [exceptionMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    RollbarException *exceptionDto =
    [[RollbarException alloc] initWithExceptionClass:exceptionClass
                                    exceptionMessage:exceptionMessage
                                exceptionDescription:nil];

    NSMutableArray<RollbarCallStackFrame *> *frames = [NSMutableArray array];
    for (NSString *line in (NSArray<NSString *> *) exceptionInfo[@(RollbarExceptionInfo_Backtraces)]) {
        RollbarCallStackFrame *frame = [self buildStackFrameFromBacktraceLine:line];
        [frames addObject:frame];
    }

    self = [self initWithRollbarException:exceptionDto
                   rollbarCallStackFrames:frames];
    return self;
}

#pragma mark - Private methods

-(NSArray *)getJsonFriendlyDataFromFrames:(NSArray<RollbarCallStackFrame *> *)frames {
    if (frames) {
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:frames.count];
        for(RollbarCallStackFrame *frame in frames) {
            if (frame) {
                [data addObject:frame.jsonFriendlyData];
            }
        }
        return data;
    }
    else {
        return nil;
    }
}

- (nonnull RollbarCallStackFrame *)buildStackFrameFromBacktraceLine:(nonnull NSString *)backtraceLine {
    
    NSDictionary *backtrace = [RollbarCrashReportUtil extractComponentsFromBacktrace:backtraceLine];
    NSString *library = backtrace[@(RollbarBacktraceComponent_Library)];
    NSString *address = backtrace[@(RollbarBacktraceComponent_Address)];
    NSString *method = backtrace[@(RollbarBacktraceComponent_Method)];
    NSString *lineNo = backtrace[@(RollbarBacktraceComponent_LineNumber)];
    
    RollbarCallStackFrame *frame = [[RollbarCallStackFrame alloc] initWithFileName:backtraceLine];
    if (library && library.length > 0) {
        [frame tryAddKeyed:@"library" Object:library];
    }
    if (address && address.length > 0) {
        [frame tryAddKeyed:@"address" Object:address];
    }
    if (method && method.length > 0) {
        frame.method = method;
    }
    if (lineNo && lineNo.length > 0) {
        NSNumber *no = @([lineNo intValue]);
        frame.lineno = no;
    }
    
    return frame;
}

@end
