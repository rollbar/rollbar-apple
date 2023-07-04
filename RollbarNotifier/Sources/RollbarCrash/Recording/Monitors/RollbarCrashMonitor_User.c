//
//  RollbarCrashMonitor_User.c
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

#include "RollbarCrashMonitor_User.h"
#include "RollbarCrashMonitorContext.h"
#include "RollbarCrashID.h"
#include "RollbarCrashThread.h"
#include "RollbarCrashStackCursor_SelfThread.h"

//#define RollbarCrashLogger_LocalLevel TRACE
#include "RollbarCrashLogger.h"

#include <memory.h>
#include <stdlib.h>


/** Context to fill with crash information. */

static volatile bool g_isEnabled = false;


void rcm_reportUserException(const char* name,
                              const char* reason,
                              const char* language,
                              const char* lineOfCode,
                              const char* stackTrace,
                              bool logAllThreads,
                              bool terminateProgram)
{
    if(!g_isEnabled)
    {
        RollbarCrashLOG_WARN("User-reported exception monitor is not installed. Exception has not been recorded.");
    }
    else
    {
        thread_act_array_t threads = NULL;
        mach_msg_type_number_t numThreads = 0;
        if(logAllThreads)
        {
            rcmc_suspendEnvironment(&threads, &numThreads);
        }
        if(terminateProgram)
        {
            rcm_notifyFatalExceptionCaptured(false);
        }

        char eventID[37];
        rcid_generate(eventID);
        RollbarCrashMC_NEW_CONTEXT(machineContext);
        rcmc_getContextForThread(rcthread_self(), machineContext, true);
        RollbarCrashStackCursor stackCursor;
        rcsc_initSelfThread(&stackCursor, 0);


        RollbarCrashLOG_DEBUG("Filling out context.");
        RollbarCrash_MonitorContext context;
        memset(&context, 0, sizeof(context));
        context.crashType = RollbarCrashMonitorTypeUserReported;
        context.eventID = eventID;
        context.offendingMachineContext = machineContext;
        context.registersAreValid = false;
        context.crashReason = reason;
        context.userException.name = name;
        context.userException.language = language;
        context.userException.lineOfCode = lineOfCode;
        context.userException.customStackTrace = stackTrace;
        context.stackCursor = &stackCursor;

        rcm_handleException(&context);

        if(logAllThreads)
        {
            rcmc_resumeEnvironment(threads, numThreads);
        }
        if(terminateProgram)
        {
            abort();
        }
    }
}

static void setEnabled(bool isEnabled)
{
    g_isEnabled = isEnabled;
}

static bool isEnabled()
{
    return g_isEnabled;
}

RollbarCrashMonitorAPI* rcm_user_getAPI()
{
    static RollbarCrashMonitorAPI api =
    {
        .setEnabled = setEnabled,
        .isEnabled = isEnabled
    };
    return &api;
}
