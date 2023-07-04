//
//  RollbarCrashMonitor.c
//
//  Created by Karl Stenerud on 2012-02-12.
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


#include "RollbarCrashMonitor.h"
#include "RollbarCrashMonitorContext.h"
#include "RollbarCrashMonitorType.h"

#include "RollbarCrashMonitor_Deadlock.h"
#include "RollbarCrashMonitor_MachException.h"
#include "RollbarCrashMonitor_CPPException.h"
#include "RollbarCrashMonitor_NSException.h"
#include "RollbarCrashMonitor_Signal.h"
#include "RollbarCrashMonitor_System.h"
#include "RollbarCrashMonitor_User.h"
#include "RollbarCrashMonitor_AppState.h"
#include "RollbarCrashMonitor_Zombie.h"
#include "RollbarCrashDebug.h"
#include "RollbarCrashThread.h"
#include "RollbarCrashSystemCapabilities.h"

#include <memory.h>

//#define RollbarCrashLogger_LocalLevel TRACE
#include "RollbarCrashLogger.h"


// ============================================================================
#pragma mark - Globals -
// ============================================================================

typedef struct
{
    RollbarCrashMonitorType monitorType;
    RollbarCrashMonitorAPI* (*getAPI)(void);
} Monitor;

static Monitor g_monitors[] =
{
#if RollbarCrashCRASH_HAS_MACH
    {
        .monitorType = RollbarCrashMonitorTypeMachException,
        .getAPI = rcm_machexception_getAPI,
    },
#endif
#if RollbarCrashCRASH_HAS_SIGNAL
    {
        .monitorType = RollbarCrashMonitorTypeSignal,
        .getAPI = rcm_signal_getAPI,
    },
#endif
#if RollbarCrashCRASH_HAS_OBJC
    {
        .monitorType = RollbarCrashMonitorTypeNSException,
        .getAPI = rcm_nsexception_getAPI,
    },
    {
        .monitorType = RollbarCrashMonitorTypeMainThreadDeadlock,
        .getAPI = rcm_deadlock_getAPI,
    },
    {
        .monitorType = RollbarCrashMonitorTypeZombie,
        .getAPI = rcm_zombie_getAPI,
    },
#endif
    {
        .monitorType = RollbarCrashMonitorTypeCPPException,
        .getAPI = rcm_cppexception_getAPI,
    },
    {
        .monitorType = RollbarCrashMonitorTypeUserReported,
        .getAPI = rcm_user_getAPI,
    },
    {
        .monitorType = RollbarCrashMonitorTypeSystem,
        .getAPI = rcm_system_getAPI,
    },
    {
        .monitorType = RollbarCrashMonitorTypeApplicationState,
        .getAPI = rcm_appstate_getAPI,
    },
};
static int g_monitorsCount = sizeof(g_monitors) / sizeof(*g_monitors);

static RollbarCrashMonitorType g_activeMonitors = RollbarCrashMonitorTypeNone;

static bool g_handlingFatalException = false;
static bool g_crashedDuringExceptionHandling = false;
static bool g_requiresAsyncSafety = false;

static void (*g_onExceptionEvent)(struct RollbarCrash_MonitorContext* monitorContext);

// ============================================================================
#pragma mark - API -
// ============================================================================

static inline RollbarCrashMonitorAPI* getAPI(Monitor* monitor)
{
    if(monitor != NULL && monitor->getAPI != NULL)
    {
        return monitor->getAPI();
    }
    return NULL;
}

static inline void setMonitorEnabled(Monitor* monitor, bool isEnabled)
{
    RollbarCrashMonitorAPI* api = getAPI(monitor);
    if(api != NULL && api->setEnabled != NULL)
    {
        api->setEnabled(isEnabled);
    }
}

static inline bool isMonitorEnabled(Monitor* monitor)
{
    RollbarCrashMonitorAPI* api = getAPI(monitor);
    if(api != NULL && api->isEnabled != NULL)
    {
        return api->isEnabled();
    }
    return false;
}

static inline void addContextualInfoToEvent(Monitor* monitor, struct RollbarCrash_MonitorContext* eventContext)
{
    RollbarCrashMonitorAPI* api = getAPI(monitor);
    if(api != NULL && api->addContextualInfoToEvent != NULL)
    {
        api->addContextualInfoToEvent(eventContext);
    }
}

void rcm_setEventCallback(void (*onEvent)(struct RollbarCrash_MonitorContext* monitorContext))
{
    g_onExceptionEvent = onEvent;
}

void rcm_setActiveMonitors(RollbarCrashMonitorType monitorTypes)
{
    if(rcdebug_isBeingTraced() && (monitorTypes & RollbarCrashMonitorTypeDebuggerUnsafe))
    {
        static bool hasWarned = false;
        if(!hasWarned)
        {
            hasWarned = true;
            RollbarCrashLOGBASIC_WARN("    ************************ Crash Handler Notice ************************");
            RollbarCrashLOGBASIC_WARN("    *     App is running in a debugger. Masking out unsafe monitors.     *");
            RollbarCrashLOGBASIC_WARN("    * This means that most crashes WILL NOT BE RECORDED while debugging! *");
            RollbarCrashLOGBASIC_WARN("    **********************************************************************");
        }
        monitorTypes &= RollbarCrashMonitorTypeDebuggerSafe;
    }
    if(g_requiresAsyncSafety && (monitorTypes & RollbarCrashMonitorTypeAsyncUnsafe))
    {
        RollbarCrashLOG_DEBUG("Async-safe environment detected. Masking out unsafe monitors.");
        monitorTypes &= RollbarCrashMonitorTypeAsyncSafe;
    }

    RollbarCrashLOG_DEBUG("Changing active monitors from 0x%x tp 0x%x.", g_activeMonitors, monitorTypes);

    RollbarCrashMonitorType activeMonitors = RollbarCrashMonitorTypeNone;
    for(int i = 0; i < g_monitorsCount; i++)
    {
        Monitor* monitor = &g_monitors[i];
        bool isEnabled = monitor->monitorType & monitorTypes;
        setMonitorEnabled(monitor, isEnabled);
        if(isMonitorEnabled(monitor))
        {
            activeMonitors |= monitor->monitorType;
        }
        else
        {
            activeMonitors &= ~monitor->monitorType;
        }
    }

    RollbarCrashLOG_DEBUG("Active monitors are now 0x%x.", activeMonitors);
    g_activeMonitors = activeMonitors;
}

RollbarCrashMonitorType rcm_getActiveMonitors()
{
    return g_activeMonitors;
}


// ============================================================================
#pragma mark - Private API -
// ============================================================================

bool rcm_notifyFatalExceptionCaptured(bool isAsyncSafeEnvironment)
{
    g_requiresAsyncSafety |= isAsyncSafeEnvironment; // Don't let it be unset.
    if(g_handlingFatalException)
    {
        g_crashedDuringExceptionHandling = true;
    }
    g_handlingFatalException = true;
    if(g_crashedDuringExceptionHandling)
    {
        RollbarCrashLOG_INFO("Detected crash in the crash reporter. Uninstalling RollbarCrash.");
        rcm_setActiveMonitors(RollbarCrashMonitorTypeNone);
    }
    return g_crashedDuringExceptionHandling;
}

void rcm_handleException(struct RollbarCrash_MonitorContext* context)
{
    context->requiresAsyncSafety = g_requiresAsyncSafety;
    if(g_crashedDuringExceptionHandling)
    {
        context->crashedDuringCrashHandling = true;
    }
    for(int i = 0; i < g_monitorsCount; i++)
    {
        Monitor* monitor = &g_monitors[i];
        if(isMonitorEnabled(monitor))
        {
            addContextualInfoToEvent(monitor, context);
        }
    }

    g_onExceptionEvent(context);

    if (context->currentSnapshotUserReported) {
        g_handlingFatalException = false;
    } else {
        if(g_handlingFatalException && !g_crashedDuringExceptionHandling) {
            RollbarCrashLOG_DEBUG("Exception is fatal. Restoring original handlers.");
            rcm_setActiveMonitors(RollbarCrashMonitorTypeNone);
        }
    }
}
