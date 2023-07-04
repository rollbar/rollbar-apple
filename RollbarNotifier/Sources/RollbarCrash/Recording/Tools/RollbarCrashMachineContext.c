//
//  RollbarCrashMachineContext.c
//
//  Created by Karl Stenerud on 2016-12-02.
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

#include "RollbarCrashMachineContext_Apple.h"
#include "RollbarCrashMachineContext.h"
#include "RollbarCrashSystemCapabilities.h"
#include "RollbarCrashCPU.h"
#include "RollbarCrashCPU_Apple.h"
#include "RollbarCrashStackCursor_MachineContext.h"

#include <mach/mach.h>

//#define RollbarCrashLogger_LocalLevel TRACE
#include "RollbarCrashLogger.h"

#ifdef __arm64__
    #define UC_MCONTEXT uc_mcontext64

typedef ucontext64_t SignalUserContext;
#else
    #define UC_MCONTEXT uc_mcontext
    typedef ucontext_t SignalUserContext;
#endif

static RollbarCrashThread g_reservedThreads[10];
static int g_reservedThreadsMaxIndex = sizeof(g_reservedThreads) / sizeof(g_reservedThreads[0]) - 1;
static int g_reservedThreadsCount = 0;


static inline bool isStackOverflow(const RollbarCrashMachineContext* const context)
{
    RollbarCrashStackCursor stackCursor;
    rcsc_initWithMachineContext(&stackCursor, RollbarCrashSC_STACK_OVERFLOW_THRESHOLD, context);
    while(stackCursor.advanceCursor(&stackCursor))
    {
    }
    return stackCursor.state.hasGivenUp;
}

static inline bool getThreadList(RollbarCrashMachineContext* context)
{
    const task_t thisTask = mach_task_self();
    RollbarCrashLOG_DEBUG("Getting thread list");
    kern_return_t kr;
    thread_act_array_t threads;
    mach_msg_type_number_t actualThreadCount;

    if((kr = task_threads(thisTask, &threads, &actualThreadCount)) != KERN_SUCCESS)
    {
        RollbarCrashLOG_ERROR("task_threads: %s", mach_error_string(kr));
        return false;
    }
    RollbarCrashLOG_TRACE("Got %d threads", context->threadCount);
    int threadCount = (int)actualThreadCount;
    int maxThreadCount = sizeof(context->allThreads) / sizeof(context->allThreads[0]);
    if(threadCount > maxThreadCount)
    {
        RollbarCrashLOG_ERROR("Thread count %d is higher than maximum of %d", threadCount, maxThreadCount);
        threadCount = maxThreadCount;
    }
    for(int i = 0; i < threadCount; i++)
    {
        context->allThreads[i] = threads[i];
    }
    context->threadCount = threadCount;

    for(mach_msg_type_number_t i = 0; i < actualThreadCount; i++)
    {
        mach_port_deallocate(thisTask, threads[i]);
    }
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) * actualThreadCount);

    return true;
}

int rcmc_contextSize()
{
    return sizeof(RollbarCrashMachineContext);
}

RollbarCrashThread rcmc_getThreadFromContext(const RollbarCrashMachineContext* const context)
{
    return context->thisThread;
}

bool rcmc_getContextForThread(RollbarCrashThread thread, RollbarCrashMachineContext* destinationContext, bool isCrashedContext)
{
    RollbarCrashLOG_DEBUG("Fill thread 0x%x context into %p. is crashed = %d", thread, destinationContext, isCrashedContext);
    memset(destinationContext, 0, sizeof(*destinationContext));
    destinationContext->thisThread = (thread_t)thread;
    destinationContext->isCurrentThread = thread == rcthread_self();
    destinationContext->isCrashedContext = isCrashedContext;
    destinationContext->isSignalContext = false;
    if(rcmc_canHaveCPUState(destinationContext))
    {
        rccpu_getState(destinationContext);
    }
    if(rcmc_isCrashedContext(destinationContext))
    {
        destinationContext->isStackOverflow = isStackOverflow(destinationContext);
        getThreadList(destinationContext);
    }
    RollbarCrashLOG_TRACE("Context retrieved.");
    return true;
}

bool rcmc_getContextForSignal(void* signalUserContext, RollbarCrashMachineContext* destinationContext)
{
    RollbarCrashLOG_DEBUG("Get context from signal user context and put into %p.", destinationContext);
    _STRUCT_MCONTEXT* sourceContext = ((SignalUserContext*)signalUserContext)->UC_MCONTEXT;
    memcpy(&destinationContext->machineContext, sourceContext, sizeof(destinationContext->machineContext));
    destinationContext->thisThread = (thread_t)rcthread_self();
    destinationContext->isCrashedContext = true;
    destinationContext->isSignalContext = true;
    destinationContext->isStackOverflow = isStackOverflow(destinationContext);
    getThreadList(destinationContext);
    RollbarCrashLOG_TRACE("Context retrieved.");
    return true;
}

void rcmc_addReservedThread(RollbarCrashThread thread)
{
    int nextIndex = g_reservedThreadsCount;
    if(nextIndex > g_reservedThreadsMaxIndex)
    {
        RollbarCrashLOG_ERROR("Too many reserved threads (%d). Max is %d", nextIndex, g_reservedThreadsMaxIndex);
        return;
    }
    g_reservedThreads[g_reservedThreadsCount++] = thread;
}

#if RollbarCrashCRASH_HAS_THREADS_API
static inline bool isThreadInList(thread_t thread, RollbarCrashThread* list, int listCount)
{
    for(int i = 0; i < listCount; i++)
    {
        if(list[i] == (RollbarCrashThread)thread)
        {
            return true;
        }
    }
    return false;
}
#endif

void rcmc_suspendEnvironment(__unused thread_act_array_t *suspendedThreads, __unused mach_msg_type_number_t *numSuspendedThreads)
{
#if RollbarCrashCRASH_HAS_THREADS_API
    RollbarCrashLOG_DEBUG("Suspending environment.");
    kern_return_t kr;
    const task_t thisTask = mach_task_self();
    const thread_t thisThread = (thread_t)rcthread_self();
    
    if((kr = task_threads(thisTask, suspendedThreads, numSuspendedThreads)) != KERN_SUCCESS)
    {
        RollbarCrashLOG_ERROR("task_threads: %s", mach_error_string(kr));
        return;
    }
    
    for(mach_msg_type_number_t i = 0; i < *numSuspendedThreads; i++)
    {
        thread_t thread = (*suspendedThreads)[i];
        if(thread != thisThread && !isThreadInList(thread, g_reservedThreads, g_reservedThreadsCount))
        {
            if((kr = thread_suspend(thread)) != KERN_SUCCESS)
            {
                // Record the error and keep going.
                RollbarCrashLOG_ERROR("thread_suspend (%08x): %s", thread, mach_error_string(kr));
            }
        }
    }
    
    RollbarCrashLOG_DEBUG("Suspend complete.");
#endif
}

void rcmc_resumeEnvironment(__unused thread_act_array_t threads, __unused mach_msg_type_number_t numThreads)
{
#if RollbarCrashCRASH_HAS_THREADS_API
    RollbarCrashLOG_DEBUG("Resuming environment.");
    kern_return_t kr;
    const task_t thisTask = mach_task_self();
    const thread_t thisThread = (thread_t)rcthread_self();
    
    if(threads == NULL || numThreads == 0)
    {
        RollbarCrashLOG_ERROR("we should call rcmc_suspendEnvironment() first");
        return;
    }
    
    for(mach_msg_type_number_t i = 0; i < numThreads; i++)
    {
        thread_t thread = threads[i];
        if(thread != thisThread && !isThreadInList(thread, g_reservedThreads, g_reservedThreadsCount))
        {
            if((kr = thread_resume(thread)) != KERN_SUCCESS)
            {
                // Record the error and keep going.
                RollbarCrashLOG_ERROR("thread_resume (%08x): %s", thread, mach_error_string(kr));
            }
        }
    }
    
    for(mach_msg_type_number_t i = 0; i < numThreads; i++)
    {
        mach_port_deallocate(thisTask, threads[i]);
    }
    vm_deallocate(thisTask, (vm_address_t)threads, sizeof(thread_t) * numThreads);
    
    RollbarCrashLOG_DEBUG("Resume complete.");
#endif
}

int rcmc_getThreadCount(const RollbarCrashMachineContext* const context)
{
    return context->threadCount;
}

RollbarCrashThread rcmc_getThreadAtIndex(const RollbarCrashMachineContext* const context, int index)
{
    return context->allThreads[index];
    
}

int rcmc_indexOfThread(const RollbarCrashMachineContext* const context, RollbarCrashThread thread)
{
    RollbarCrashLOG_TRACE("check thread vs %d threads", context->threadCount);
    for(int i = 0; i < (int)context->threadCount; i++)
    {
        RollbarCrashLOG_TRACE("%d: %x vs %x", i, thread, context->allThreads[i]);
        if(context->allThreads[i] == thread)
        {
            return i;
        }
    }
    return -1;
}

bool rcmc_isCrashedContext(const RollbarCrashMachineContext* const context)
{
    return context->isCrashedContext;
}

static inline bool isContextForCurrentThread(const RollbarCrashMachineContext* const context)
{
    return context->isCurrentThread;
}

static inline bool isSignalContext(const RollbarCrashMachineContext* const context)
{
    return context->isSignalContext;
}

bool rcmc_canHaveCPUState(const RollbarCrashMachineContext* const context)
{
    return !isContextForCurrentThread(context) || isSignalContext(context);
}

bool rcmc_hasValidExceptionRegisters(const RollbarCrashMachineContext* const context)
{
    return rcmc_canHaveCPUState(context) && rcmc_isCrashedContext(context);
}
