//
//  RollbarCrashMonitor_NSException.m
//
//  Created by Karl Stenerud on 2012-01-28.
//
//  Copyright (c) 2012 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RollbarCrashHandler.h"
#import "RollbarCrashMonitor_NSException.h"
#import "RollbarCrashStackCursor_Backtrace.h"
#include "RollbarCrashMonitorContext.h"
#include "RollbarCrashID.h"
#include "RollbarCrashThread.h"
#import <Foundation/Foundation.h>

//#define RollbarCrashLogger_LocalLevel TRACE
#import "RollbarCrashLogger.h"


// ============================================================================
#pragma mark - Globals -
// ============================================================================

static volatile bool g_isEnabled = 0;

static RollbarCrash_MonitorContext g_monitorContext;

/** The exception handler that was in place before we installed ours. */
static NSUncaughtExceptionHandler* g_previousUncaughtExceptionHandler;


// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

/** Our custom excepetion handler.
 * Fetch the stack trace from the exception and write a report.
 *
 * @param exception The exception that was raised.
 */

static void handleException(NSException* exception, BOOL currentSnapshotUserReported) {
    RCLOG_DEBUG(@"Trapped exception %@", exception);
    if(g_isEnabled)
    {
        thread_act_array_t threads = NULL;
        mach_msg_type_number_t numThreads = 0;
        rcmc_suspendEnvironment(&threads, &numThreads);
        rcm_notifyFatalExceptionCaptured(false);

        RCLOG_DEBUG(@"Filling out context.");
        NSArray* addresses = [exception callStackReturnAddresses];
        NSUInteger numFrames = addresses.count;
        uintptr_t* callstack = malloc(numFrames * sizeof(*callstack));
        for(NSUInteger i = 0; i < numFrames; i++)
        {
            callstack[i] = (uintptr_t)[addresses[i] unsignedLongLongValue];
        }

        char eventID[37];
        rcid_generate(eventID);
        RollbarCrashMC_NEW_CONTEXT(machineContext);
        rcmc_getContextForThread(rcthread_self(), machineContext, true);
        RollbarCrashStackCursor cursor;
        rcsc_initWithBacktrace(&cursor, callstack, (int)numFrames, 0);

        RollbarCrash_MonitorContext* crashContext = &g_monitorContext;
        memset(crashContext, 0, sizeof(*crashContext));
        crashContext->crashType = RollbarCrashMonitorTypeNSException;
        crashContext->eventID = eventID;
        crashContext->offendingMachineContext = machineContext;
        crashContext->registersAreValid = false;
        crashContext->NSException.name = [[exception name] UTF8String];
        crashContext->NSException.userInfo = [[NSString stringWithFormat:@"%@", exception.userInfo] UTF8String];
        crashContext->exceptionName = crashContext->NSException.name;
        crashContext->crashReason = [[exception reason] UTF8String];
        crashContext->stackCursor = &cursor;
        crashContext->currentSnapshotUserReported = currentSnapshotUserReported;

        RCLOG_DEBUG(@"Calling main crash handler.");
        rcm_handleException(crashContext);

        free(callstack);
        if (currentSnapshotUserReported) {
            rcmc_resumeEnvironment(threads, numThreads);
        }
        if (g_previousUncaughtExceptionHandler != NULL)
        {
            RCLOG_DEBUG(@"Calling original exception handler.");
            g_previousUncaughtExceptionHandler(exception);
        }
    }
}

static void handleCurrentSnapshotUserReportedException(NSException* exception) {
    handleException(exception, true);
}

static void handleUncaughtException(NSException* exception) {
    handleException(exception, false);
}

// ============================================================================
#pragma mark - API -
// ============================================================================

static void setEnabled(bool isEnabled)
{

//    Wise: Wise has tooling already in place for crash reports, so we don't want to set a crash handler when
//    setting up Rollbar. Currently there's no option to disable this from the public API of the Rollbar SDK.
//    Rollbar have placed this into their feature backlog, which we should adopt once available.

    const bool isWiseEnabled = FALSE

    if(isWiseEnabled != g_isEnabled)
    {
        g_isEnabled = isWiseEnabled;
        if(isWiseEnabled)
        {
            RCLOG_DEBUG(@"Backing up original handler.");
            g_previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
            
            RCLOG_DEBUG(@"Setting new handler.");
            NSSetUncaughtExceptionHandler(&handleUncaughtException);
            RollbarCrashHandler.sharedInstance.uncaughtExceptionHandler = &handleUncaughtException;
            RollbarCrashHandler.sharedInstance.currentSnapshotUserReportedExceptionHandler = &handleCurrentSnapshotUserReportedException;
        }
        else
        {
            RCLOG_DEBUG(@"Restoring original handler.");
            NSSetUncaughtExceptionHandler(g_previousUncaughtExceptionHandler);
        }
    }
}

static bool isEnabled(void)
{
    return g_isEnabled;
}

RollbarCrashMonitorAPI* rcm_nsexception_getAPI(void)
{
    static RollbarCrashMonitorAPI api =
    {
        .setEnabled = setEnabled,
        .isEnabled = isEnabled
    };
    return &api;
}
