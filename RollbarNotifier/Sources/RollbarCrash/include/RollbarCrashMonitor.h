//
//  RollbarCrashMonitor.h
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


/** Keeps watch for crashes and informs via callback when on occurs.
 */


#ifndef HDR_RollbarCrashMonitor_h
#define HDR_RollbarCrashMonitor_h

#ifdef __cplusplus
extern "C" {
#endif


#include "RollbarCrashMonitorType.h"
#include "RollbarCrashThread.h"
    
#include <stdbool.h>

struct RollbarCrash_MonitorContext;


// ============================================================================
#pragma mark - External API -
// ============================================================================

/** Set which monitors are active.
 *
 * @param monitorTypes Which monitors should be active.
 */
void rcm_setActiveMonitors(RollbarCrashMonitorType monitorTypes);

/** Get the currently active monitors.
 */
RollbarCrashMonitorType rcm_getActiveMonitors(void);

/** Set the callback to call when an event is captured.
 *
 * @param onEvent Called whenever an event is captured.
 */
void rcm_setEventCallback(void (*onEvent)(struct RollbarCrash_MonitorContext* monitorContext));


// ============================================================================
#pragma mark - Internal API -
// ============================================================================

typedef struct
{
    void (*setEnabled)(bool isEnabled);
    bool (*isEnabled)(void);
    void (*addContextualInfoToEvent)(struct RollbarCrash_MonitorContext* eventContext);
} RollbarCrashMonitorAPI;

/** Notify that a fatal exception has been captured.
 *  This allows the system to take appropriate steps in preparation.
 *
 * @oaram isAsyncSafeEnvironment If true, only async-safe functions are allowed from now on.
 */
bool rcm_notifyFatalExceptionCaptured(bool isAsyncSafeEnvironment);

/** Start general exception processing.
 *
 * @oaram context Contextual information about the exception.
 */
void rcm_handleException(struct RollbarCrash_MonitorContext* context);


#ifdef __cplusplus
}
#endif

#endif // HDR_RollbarCrashMonitor_h
