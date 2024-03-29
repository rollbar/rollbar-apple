//
//  RollbarCrashCPU_x86_32.c
//
//  Created by Karl Stenerud on 2012-01-29.
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


#if defined (__i386__)


#include "RollbarCrashCPU.h"
#include "RollbarCrashCPU_Apple.h"
#include "RollbarCrashMachineContext.h"
#include "RollbarCrashMachineContext_Apple.h"
#include <stdlib.h>

//#define RollbarCrashLogger_LocalLevel TRACE
#include "RollbarCrashLogger.h"


static const char* g_registerNames[] =
{
    "eax", "ebx", "ecx", "edx",
    "edi", "esi",
    "ebp", "esp", "ss",
    "eflags", "eip",
    "cs", "ds", "es", "fs", "gs",
};
static const int g_registerNamesCount =
sizeof(g_registerNames) / sizeof(*g_registerNames);


static const char* g_exceptionRegisterNames[] =
{
    "trapno", "err", "faultvaddr"
};
static const int g_exceptionRegisterNamesCount =
sizeof(g_exceptionRegisterNames) / sizeof(*g_exceptionRegisterNames);


uintptr_t rccpu_framePointer(const RollbarCrashMachineContext* const context)
{
    return context->machineContext.__ss.__ebp;
}

uintptr_t rccpu_stackPointer(const RollbarCrashMachineContext* const context)
{
    return context->machineContext.__ss.__esp;
}

uintptr_t rccpu_instructionAddress(const RollbarCrashMachineContext* const context)
{
    return context->machineContext.__ss.__eip;
}

uintptr_t rccpu_linkRegister(__unused const RollbarCrashMachineContext* const context)
{
    return 0;
}

void rccpu_getState(RollbarCrashMachineContext* context)
{
    thread_t thread = context->thisThread;
    STRUCT_MCONTEXT_L* const machineContext = &context->machineContext;

    rccpu_i_fillState(thread, (thread_state_t)&machineContext->__ss, x86_THREAD_STATE32, x86_THREAD_STATE32_COUNT);
    rccpu_i_fillState(thread, (thread_state_t)&machineContext->__es, x86_EXCEPTION_STATE32, x86_EXCEPTION_STATE32_COUNT);
}

int rccpu_numRegisters(void)
{
    return g_registerNamesCount;
}

const char* rccpu_registerName(const int regNumber)
{
    if(regNumber < rccpu_numRegisters())
    {
        return g_registerNames[regNumber];
    }
    return NULL;
}

uint64_t rccpu_registerValue(const RollbarCrashMachineContext* const context, const int regNumber)
{
    switch(regNumber)
    {
        case 0:
            return context->machineContext.__ss.__eax;
        case 1:
            return context->machineContext.__ss.__ebx;
        case 2:
            return context->machineContext.__ss.__ecx;
        case 3:
            return context->machineContext.__ss.__edx;
        case 4:
            return context->machineContext.__ss.__edi;
        case 5:
            return context->machineContext.__ss.__esi;
        case 6:
            return context->machineContext.__ss.__ebp;
        case 7:
            return context->machineContext.__ss.__esp;
        case 8:
            return context->machineContext.__ss.__ss;
        case 9:
            return context->machineContext.__ss.__eflags;
        case 10:
            return context->machineContext.__ss.__eip;
        case 11:
            return context->machineContext.__ss.__cs;
        case 12:
            return context->machineContext.__ss.__ds;
        case 13:
            return context->machineContext.__ss.__es;
        case 14:
            return context->machineContext.__ss.__fs;
        case 15:
            return context->machineContext.__ss.__gs;
    }

    RCLOG_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

int rccpu_numExceptionRegisters(void)
{
    return g_exceptionRegisterNamesCount;
}

const char* rccpu_exceptionRegisterName(const int regNumber)
{
    if(regNumber < rccpu_numExceptionRegisters())
    {
        return g_exceptionRegisterNames[regNumber];
    }
    RCLOG_ERROR("Invalid register number: %d", regNumber);
    return NULL;
}

uint64_t rccpu_exceptionRegisterValue(const RollbarCrashMachineContext* const context, const int regNumber)
{
    switch(regNumber)
    {
        case 0:
            return context->machineContext.__es.__trapno;
        case 1:
            return context->machineContext.__es.__err;
        case 2:
            return context->machineContext.__es.__faultvaddr;
    }

    RCLOG_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t rccpu_faultAddress(const RollbarCrashMachineContext* const context)
{
    return context->machineContext.__es.__faultvaddr;
}

int rccpu_stackGrowDirection(void)
{
    return -1;
}

uintptr_t rccpu_normaliseInstructionPointer(uintptr_t ip)
{
    return ip;
}

#endif
