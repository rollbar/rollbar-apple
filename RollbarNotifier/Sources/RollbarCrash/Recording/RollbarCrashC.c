//
//  RollbarCrashC.c
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


#include "RollbarCrashC.h"

#include "RollbarCrashCachedData.h"
#include "RollbarCrashReport.h"
#include "RollbarCrashReportFixer.h"
#include "RollbarCrashReportStore.h"
#include "RollbarCrashMonitor_CPPException.h"
#include "RollbarCrashMonitor_Deadlock.h"
#include "RollbarCrashMonitor_User.h"
#include "RollbarCrashFileUtils.h"
#include "RollbarCrashObjC.h"
#include "RollbarCrashString.h"
#include "RollbarCrashMonitor_System.h"
#include "RollbarCrashMonitor_Zombie.h"
#include "RollbarCrashMonitor_AppState.h"
#include "RollbarCrashMonitorContext.h"
#include "RollbarCrashSystemCapabilities.h"

//#define RollbarCrashLogger_LocalLevel TRACE
#include "RollbarCrashLogger.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum
{
    RollbarCrashApplicationStateNone,
    RollbarCrashApplicationStateDidBecomeActive,
    RollbarCrashApplicationStateWillResignActiveActive,
    RollbarCrashApplicationStateDidEnterBackground,
    RollbarCrashApplicationStateWillEnterForeground,
    RollbarCrashApplicationStateWillTerminate
} RollbarCrashApplicationState;

// ============================================================================
#pragma mark - Globals -
// ============================================================================

/** True if RollbarCrash has been installed. */
static volatile bool g_installed = 0;

static bool g_shouldAddConsoleLogToReport = false;
static bool g_shouldPrintPreviousLog = false;
static char g_consoleLogPath[RollbarCrashFU_MAX_PATH_LENGTH];
static RollbarCrashMonitorType g_monitoring = RollbarCrashMonitorTypeProductionSafeMinimal;
static char g_lastCrashReportFilePath[RollbarCrashFU_MAX_PATH_LENGTH];
static RollbarCrashReportWrittenCallback g_reportWrittenCallback;
static RollbarCrashApplicationState g_lastApplicationState = RollbarCrashApplicationStateNone;

// ============================================================================
#pragma mark - Utility -
// ============================================================================

static void printPreviousLog(const char* filePath)
{
    char* data;
    int length;
    if(rcfu_readEntireFile(filePath, &data, &length, 0))
    {
        printf("\nvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv Previous Log vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n\n");
        printf("%s\n", data);
        free(data);
        printf("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n");
        fflush(stdout);
    }
}

static void notifyOfBeforeInstallationState(void)
{
    RollbarCrashLOG_DEBUG("Notifying of pre-installation state");
    switch (g_lastApplicationState)
    {
        case RollbarCrashApplicationStateDidBecomeActive:
            return rc_notifyAppActive(true);
        case RollbarCrashApplicationStateWillResignActiveActive:
            return rc_notifyAppActive(false);
        case RollbarCrashApplicationStateDidEnterBackground:
            return rc_notifyAppInForeground(false);
        case RollbarCrashApplicationStateWillEnterForeground:
            return rc_notifyAppInForeground(true);
        case RollbarCrashApplicationStateWillTerminate:
            return rc_notifyAppTerminate();
        default:
            return;
    }
}

// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

/** Called when a crash occurs.
 *
 * This function gets passed as a callback to a crash handler.
 */
static void onCrash(struct RollbarCrash_MonitorContext* monitorContext)
{
    if (monitorContext->currentSnapshotUserReported == false) {
        RollbarCrashLOG_DEBUG("Updating application state to note crash.");
        rcstate_notifyAppCrash();
    }
    monitorContext->consoleLogPath = g_shouldAddConsoleLogToReport ? g_consoleLogPath : NULL;

    if(monitorContext->crashedDuringCrashHandling)
    {
        rcreport_writeRecrashReport(monitorContext, g_lastCrashReportFilePath);
    }
    else
    {
        char crashReportFilePath[RollbarCrashFU_MAX_PATH_LENGTH];
        int64_t reportID = rccrs_getNextCrashReport(crashReportFilePath);
        strncpy(g_lastCrashReportFilePath, crashReportFilePath, sizeof(g_lastCrashReportFilePath));
        rcreport_writeStandardReport(monitorContext, crashReportFilePath);

        if(g_reportWrittenCallback)
        {
            g_reportWrittenCallback(reportID);
        }
    }
}


// ============================================================================
#pragma mark - API -
// ============================================================================

RollbarCrashMonitorType rc_install(const char* appName, const char* const installPath)
{
    RollbarCrashLOG_DEBUG("Installing crash reporter.");

    if(g_installed)
    {
        RollbarCrashLOG_DEBUG("Crash reporter already installed.");
        return g_monitoring;
    }
    g_installed = 1;

    char path[RollbarCrashFU_MAX_PATH_LENGTH];
    snprintf(path, sizeof(path), "%s/Reports", installPath);
    rcfu_makePath(path);
    rccrs_initialize(appName, path);

    snprintf(path, sizeof(path), "%s/Data", installPath);
    rcfu_makePath(path);
    snprintf(path, sizeof(path), "%s/Data/CrashState.json", installPath);
    rcstate_initialize(path);

    snprintf(g_consoleLogPath, sizeof(g_consoleLogPath), "%s/Data/ConsoleLog.txt", installPath);
    if(g_shouldPrintPreviousLog)
    {
        printPreviousLog(g_consoleLogPath);
    }
    rclog_setLogFilename(g_consoleLogPath, true);
    
    rcccd_init(60);

    rcm_setEventCallback(onCrash);
    RollbarCrashMonitorType monitors = rc_setMonitoring(g_monitoring);

    RollbarCrashLOG_DEBUG("Installation complete.");

    notifyOfBeforeInstallationState();

    return monitors;
}

RollbarCrashMonitorType rc_setMonitoring(RollbarCrashMonitorType monitors)
{
    g_monitoring = monitors;
    
    if(g_installed)
    {
        rcm_setActiveMonitors(monitors);
        return rcm_getActiveMonitors();
    }
    // Return what we will be monitoring in future.
    return g_monitoring;
}

void rc_setUserInfoJSON(const char* const userInfoJSON)
{
    rcreport_setUserInfoJSON(userInfoJSON);
}

void rc_setDeadlockWatchdogInterval(double deadlockWatchdogInterval)
{
#if RollbarCrashCRASH_HAS_OBJC
    rcm_setDeadlockHandlerWatchdogInterval(deadlockWatchdogInterval);
#endif
}

void rc_setSearchQueueNames(bool searchQueueNames)
{
    rcccd_setSearchQueueNames(searchQueueNames);
}

void rc_setIntrospectMemory(bool introspectMemory)
{
    rcreport_setIntrospectMemory(introspectMemory);
}

void rc_setDoNotIntrospectClasses(const char** doNotIntrospectClasses, int length)
{
    rcreport_setDoNotIntrospectClasses(doNotIntrospectClasses, length);
}

void rc_setCrashNotifyCallback(const RollbarCrashReportWriteCallback onCrashNotify)
{
    rcreport_setUserSectionWriteCallback(onCrashNotify);
}

void rc_setReportWrittenCallback(const RollbarCrashReportWrittenCallback onReportWrittenNotify)
{
    g_reportWrittenCallback = onReportWrittenNotify;
}

void rc_setAddConsoleLogToReport(bool shouldAddConsoleLogToReport)
{
    g_shouldAddConsoleLogToReport = shouldAddConsoleLogToReport;
}

void rc_setPrintPreviousLog(bool shouldPrintPreviousLog)
{
    g_shouldPrintPreviousLog = shouldPrintPreviousLog;
}

void rc_setMaxReportCount(int maxReportCount)
{
    rccrs_setMaxReportCount(maxReportCount);
}

void rc_reportUserException(const char* name,
                                 const char* reason,
                                 const char* language,
                                 const char* lineOfCode,
                                 const char* stackTrace,
                                 bool logAllThreads,
                                 bool terminateProgram)
{
    rcm_reportUserException(name,
                             reason,
                             language,
                             lineOfCode,
                             stackTrace,
                             logAllThreads,
                             terminateProgram);
    if(g_shouldAddConsoleLogToReport)
    {
        rclog_clearLogFile();
    }
}

void enableSwapCxaThrow(void)
{
    rcm_enableSwapCxaThrow();
}

void rc_notifyObjCLoad(void)
{
    rcstate_notifyObjCLoad();
}

void rc_notifyAppActive(bool isActive)
{
    if (g_installed)
    {
        rcstate_notifyAppActive(isActive);
    }
    g_lastApplicationState = isActive
        ? RollbarCrashApplicationStateDidBecomeActive
        : RollbarCrashApplicationStateWillResignActiveActive;
}

void rc_notifyAppInForeground(bool isInForeground)
{
    if (g_installed)
    {
        rcstate_notifyAppInForeground(isInForeground);
    }
    g_lastApplicationState = isInForeground
        ? RollbarCrashApplicationStateWillEnterForeground
        : RollbarCrashApplicationStateDidEnterBackground;
}

void rc_notifyAppTerminate(void)
{
    if (g_installed)
    {
        rcstate_notifyAppTerminate();
    }
    g_lastApplicationState = RollbarCrashApplicationStateWillTerminate;
}

void rc_notifyAppCrash(void)
{
    rcstate_notifyAppCrash();
}

int rc_getReportCount()
{
    return rccrs_getReportCount();
}

int rc_getReportIDs(int64_t* reportIDs, int count)
{
    return rccrs_getReportIDs(reportIDs, count);
}

char* rc_readReport(int64_t reportID)
{
    if(reportID <= 0)
    {
        RollbarCrashLOG_ERROR("Report ID was %" PRIx64, reportID);
        return NULL;
    }

    char* rawReport = rccrs_readReport(reportID);
    if(rawReport == NULL)
    {
        RollbarCrashLOG_ERROR("Failed to load report ID %" PRIx64, reportID);
        return NULL;
    }

    char* fixedReport = rccrf_fixupCrashReport(rawReport);
    if(fixedReport == NULL)
    {
        RollbarCrashLOG_ERROR("Failed to fixup report ID %" PRIx64, reportID);
    }

    free(rawReport);
    return fixedReport;
}

int64_t rc_addUserReport(const char* report, int reportLength)
{
    return rccrs_addUserReport(report, reportLength);
}

void rc_deleteAllReports()
{
    rccrs_deleteAllReports();
}

void rc_deleteReportWithID(int64_t reportID)
{
    rccrs_deleteReportWithID(reportID);
}
