//
//  RollbarCrashMonitorType.h
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


#ifndef HDR_RollbarCrashMonitorType_h
#define HDR_RollbarCrashMonitorType_h

#ifdef __cplusplus
extern "C" {
#endif


/** Various aspects of the system that can be monitored:
 * - Mach kernel exception
 * - Fatal signal
 * - Uncaught C++ exception
 * - Uncaught Objective-C NSException
 * - Deadlock on the main thread
 * - User reported custom exception
 */
typedef enum
{
    /* Captures and reports Mach exceptions. */
    RollbarCrashMonitorTypeMachException      = 0x01,
    
    /* Captures and reports POSIX signals. */
    RollbarCrashMonitorTypeSignal             = 0x02,
    
    /* Captures and reports C++ exceptions.
     * Note: This will slightly slow down exception processing.
     */
    RollbarCrashMonitorTypeCPPException       = 0x04,
    
    /* Captures and reports NSExceptions. */
    RollbarCrashMonitorTypeNSException        = 0x08,
    
    /* Detects and reports a deadlock in the main thread. */
    RollbarCrashMonitorTypeMainThreadDeadlock = 0x10,
    
    /* Accepts and reports user-generated exceptions. */
    RollbarCrashMonitorTypeUserReported       = 0x20,
    
    /* Keeps track of and injects system information. */
    RollbarCrashMonitorTypeSystem             = 0x40,
    
    /* Keeps track of and injects application state. */
    RollbarCrashMonitorTypeApplicationState   = 0x80,
    
    /* Keeps track of zombies, and injects the last zombie NSException. */
    RollbarCrashMonitorTypeZombie             = 0x100,
} RollbarCrashMonitorType;

#define RollbarCrashMonitorTypeAll              \
(                                          \
    RollbarCrashMonitorTypeMachException      | \
    RollbarCrashMonitorTypeSignal             | \
    RollbarCrashMonitorTypeCPPException       | \
    RollbarCrashMonitorTypeNSException        | \
    RollbarCrashMonitorTypeMainThreadDeadlock | \
    RollbarCrashMonitorTypeUserReported       | \
    RollbarCrashMonitorTypeSystem             | \
    RollbarCrashMonitorTypeApplicationState   | \
    RollbarCrashMonitorTypeZombie               \
)

#define RollbarCrashMonitorTypeExperimental     \
(                                          \
    RollbarCrashMonitorTypeMainThreadDeadlock   \
)

#define RollbarCrashMonitorTypeDebuggerUnsafe   \
(                                          \
    RollbarCrashMonitorTypeMachException      | \
    RollbarCrashMonitorTypeSignal             | \
    RollbarCrashMonitorTypeCPPException       | \
    RollbarCrashMonitorTypeNSException          \
)

#define RollbarCrashMonitorTypeAsyncSafe        \
(                                          \
    RollbarCrashMonitorTypeMachException      | \
    RollbarCrashMonitorTypeSignal               \
)

#define RollbarCrashMonitorTypeOptional         \
(                                          \
    RollbarCrashMonitorTypeZombie               \
)
    
#define RollbarCrashMonitorTypeAsyncUnsafe (RollbarCrashMonitorTypeAll & (~RollbarCrashMonitorTypeAsyncSafe))

/** Monitors that are safe to enable in a debugger. */
#define RollbarCrashMonitorTypeDebuggerSafe (RollbarCrashMonitorTypeAll & (~RollbarCrashMonitorTypeDebuggerUnsafe))

/** Monitors that are safe to use in a production environment.
 * All other monitors should be considered experimental.
 */
#define RollbarCrashMonitorTypeProductionSafe (RollbarCrashMonitorTypeAll & (~RollbarCrashMonitorTypeExperimental))

/** Production safe monitors, minus the optional ones. */
#define RollbarCrashMonitorTypeProductionSafeMinimal (RollbarCrashMonitorTypeProductionSafe & (~RollbarCrashMonitorTypeOptional))

/** Monitors that are required for proper operation.
 * These add essential information to the reports, but do not trigger reporting.
 */
#define RollbarCrashMonitorTypeRequired (RollbarCrashMonitorTypeSystem | RollbarCrashMonitorTypeApplicationState)

/** Effectively disables automatica reporting. The only way to generate a report
 * in this mode is by manually calling kscrash_reportUserException().
 */
#define RollbarCrashMonitorTypeManual (RollbarCrashMonitorTypeRequired | RollbarCrashMonitorTypeUserReported)

#define RollbarCrashMonitorTypeNone 0

const char* kscrashmonitortype_name(RollbarCrashMonitorType monitorType);


#ifdef __cplusplus
}
#endif

#endif // HDR_RollbarCrashMonitorType_h
