//
//  RollbarCrashCPU.h
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

#ifndef HDR_RollbarCrashCPU_h
#define HDR_RollbarCrashCPU_h

#ifdef __cplusplus
extern "C" {
#endif


#include "RollbarCrashMachineContext.h"

#include <stdbool.h>
#include <stdint.h>

/** Get the current CPU architecture.
 *
 * @return The current architecture.
 */
const char* rccpu_currentArch(void);

/** Get the frame pointer for a machine context.
 * The frame pointer marks the top of the call stack.
 *
 * @param context The machine context.
 *
 * @return The context's frame pointer.
 */
uintptr_t rccpu_framePointer(const struct RollbarCrashMachineContext* const context);

/** Get the current stack pointer for a machine context.
 *
 * @param context The machine context.
 *
 * @return The context's stack pointer.
 */
uintptr_t rccpu_stackPointer(const struct RollbarCrashMachineContext* const context);

/** Get the address of the instruction about to be, or being executed by a
 * machine context.
 *
 * @param context The machine context.
 *
 * @return The context's next instruction address.
 */
uintptr_t rccpu_instructionAddress(const struct RollbarCrashMachineContext* const context);

/** Get the address stored in the link register (arm only). This may
 * contain the first return address of the stack.
 *
 * @param context The machine context.
 *
 * @return The link register value.
 */
uintptr_t rccpu_linkRegister(const struct RollbarCrashMachineContext* const context);

/** Get the address whose access caused the last fault.
 *
 * @param context The machine context.
 *
 * @return The faulting address.
 */
uintptr_t rccpu_faultAddress(const struct RollbarCrashMachineContext* const context);

/** Get the number of normal (not floating point or exception) registers the
 *  currently running CPU has.
 *
 * @return The number of registers.
 */
int rccpu_numRegisters(void);

/** Get the name of a normal register.
 *
 * @param regNumber The register index.
 *
 * @return The register's name or NULL if not found.
 */
const char* rccpu_registerName(int regNumber);

/** Get the value stored in a normal register.
 *
 * @param regNumber The register index.
 *
 * @return The register's current value.
 */
uint64_t rccpu_registerValue(const struct RollbarCrashMachineContext* const context, int regNumber);

/** Get the number of exception registers the currently running CPU has.
 *
 * @return The number of registers.
 */
int rccpu_numExceptionRegisters(void);

/** Get the name of an exception register.
 *
 * @param regNumber The register index.
 *
 * @return The register's name or NULL if not found.
 */
const char* rccpu_exceptionRegisterName(int regNumber);

/** Get the value stored in an exception register.
 *
 * @param regNumber The register index.
 *
 * @return The register's current value.
 */
uint64_t rccpu_exceptionRegisterValue(const struct RollbarCrashMachineContext* const context, int regNumber);

/** Get the direction in which the stack grows on the current architecture.
 *
 * @return 1 or -1, depending on which direction the stack grows in.
 */
int rccpu_stackGrowDirection(void);

/** Fetch the CPU state for this context and store it in the context.
 *
 * @param destinationContext The context to fill.
 */
void rccpu_getState(struct RollbarCrashMachineContext* destinationContext);

/** Strip PAC from an instruction pointer.
 *
 * @param ip PAC encoded instruction pointer.
 *
 * @return Instruction pointer without PAC.
 */
uintptr_t rccpu_normaliseInstructionPointer(uintptr_t ip);
    
#ifdef __cplusplus
}
#endif

#endif // HDR_RollbarCrashCPU_h
