//
//  RollbarCrashReport.m
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


#include "RollbarCrashReport.h"

#include "RollbarCrashReportFields.h"
#include "RollbarCrashReportWriter.h"
#include "RollbarCrashDynamicLinker.h"
#include "RollbarCrashFileUtils.h"
#include "RollbarCrashJSONCodec.h"
#include "RollbarCrashCPU.h"
#include "RollbarCrashMemory.h"
#include "RollbarCrashMach.h"
#include "RollbarCrashThread.h"
#include "RollbarCrashObjC.h"
#include "RollbarCrashSignalInfo.h"
#include "RollbarCrashMonitor_Zombie.h"
#include "RollbarCrashString.h"
#include "RollbarCrashReportVersion.h"
#include "RollbarCrashStackCursor_Backtrace.h"
#include "RollbarCrashStackCursor_MachineContext.h"
#include "RollbarCrashSystemCapabilities.h"
#include "RollbarCrashCachedData.h"

//#define RollbarCrashLogger_LocalLevel TRACE
#include "RollbarCrashLogger.h"

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>

// ============================================================================
#pragma mark - Constants -
// ============================================================================

/** Default number of objects, subobjects, and ivars to record from a memory loc */
#define kDefaultMemorySearchDepth 15

/** How far to search the stack (in pointer sized jumps) for notable data. */
#define kStackNotableSearchBackDistance 20
#define kStackNotableSearchForwardDistance 10

/** How much of the stack to dump (in pointer sized jumps). */
#define kStackContentsPushedDistance 20
#define kStackContentsPoppedDistance 10
#define kStackContentsTotalDistance (kStackContentsPushedDistance + kStackContentsPoppedDistance)

/** The minimum length for a valid string. */
#define kMinStringLength 4


// ============================================================================
#pragma mark - JSON Encoding -
// ============================================================================

#define getJsonContext(REPORT_WRITER) ((RollbarCrashJSONEncodeContext*)((REPORT_WRITER)->context))

/** Used for writing hex string values. */
static const char g_hexNybbles[] =
{
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
};

// ============================================================================
#pragma mark - Runtime Config -
// ============================================================================

typedef struct
{
    /** If YES, introspect memory contents during a crash.
     * Any Objective-C objects or C strings near the stack pointer or referenced by
     * cpu registers or exceptions will be recorded in the crash report, along with
     * their contents.
     */
    bool enabled;
    
    /** List of classes that should never be introspected.
     * Whenever a class in this list is encountered, only the class name will be recorded.
     */
    const char** restrictedClasses;
    int restrictedClassesCount;
} RollbarCrash_IntrospectionRules;

static const char* g_userInfoJSON;
static RollbarCrash_IntrospectionRules g_introspectionRules;
static RollbarCrashReportWriteCallback g_userSectionWriteCallback;


#pragma mark Callbacks

static void addBooleanElement(const RollbarCrashReportWriter* const writer, const char* const key, const bool value)
{
    rcjson_addBooleanElement(getJsonContext(writer), key, value);
}

static void addFloatingPointElement(const RollbarCrashReportWriter* const writer, const char* const key, const double value)
{
    rcjson_addFloatingPointElement(getJsonContext(writer), key, value);
}

static void addIntegerElement(const RollbarCrashReportWriter* const writer, const char* const key, const int64_t value)
{
    rcjson_addIntegerElement(getJsonContext(writer), key, value);
}

static void addUIntegerElement(const RollbarCrashReportWriter* const writer, const char* const key, const uint64_t value)
{
    rcjson_addUIntegerElement(getJsonContext(writer), key, value);
}

static void addStringElement(const RollbarCrashReportWriter* const writer, const char* const key, const char* const value)
{
    rcjson_addStringElement(getJsonContext(writer), key, value, RollbarCrashJSON_SIZE_AUTOMATIC);
}

static void addTextFileElement(const RollbarCrashReportWriter* const writer, const char* const key, const char* const filePath)
{
    const int fd = open(filePath, O_RDONLY);
    if(fd < 0)
    {
        RollbarCrashLOG_ERROR("Could not open file %s: %s", filePath, strerror(errno));
        return;
    }

    if(rcjson_beginStringElement(getJsonContext(writer), key) != RollbarCrashJSON_OK)
    {
        RollbarCrashLOG_ERROR("Could not start string element");
        goto done;
    }

    char buffer[512];
    int bytesRead;
    for(bytesRead = (int)read(fd, buffer, sizeof(buffer));
        bytesRead > 0;
        bytesRead = (int)read(fd, buffer, sizeof(buffer)))
    {
        if(rcjson_appendStringElement(getJsonContext(writer), buffer, bytesRead) != RollbarCrashJSON_OK)
        {
            RollbarCrashLOG_ERROR("Could not append string element");
            goto done;
        }
    }

done:
    rcjson_endStringElement(getJsonContext(writer));
    close(fd);
}

static void addDataElement(const RollbarCrashReportWriter* const writer,
                           const char* const key,
                           const char* const value,
                           const int length)
{
    rcjson_addDataElement(getJsonContext(writer), key, value, length);
}

static void beginDataElement(const RollbarCrashReportWriter* const writer, const char* const key)
{
    rcjson_beginDataElement(getJsonContext(writer), key);
}

static void appendDataElement(const RollbarCrashReportWriter* const writer, const char* const value, const int length)
{
    rcjson_appendDataElement(getJsonContext(writer), value, length);
}

static void endDataElement(const RollbarCrashReportWriter* const writer)
{
    rcjson_endDataElement(getJsonContext(writer));
}

static void addUUIDElement(const RollbarCrashReportWriter* const writer, const char* const key, const unsigned char* const value)
{
    if(value == NULL)
    {
        rcjson_addNullElement(getJsonContext(writer), key);
    }
    else
    {
        char uuidBuffer[37];
        const unsigned char* src = value;
        char* dst = uuidBuffer;
        for(int i = 0; i < 4; i++)
        {
            *dst++ = g_hexNybbles[(*src>>4)&15];
            *dst++ = g_hexNybbles[(*src++)&15];
        }
        *dst++ = '-';
        for(int i = 0; i < 2; i++)
        {
            *dst++ = g_hexNybbles[(*src>>4)&15];
            *dst++ = g_hexNybbles[(*src++)&15];
        }
        *dst++ = '-';
        for(int i = 0; i < 2; i++)
        {
            *dst++ = g_hexNybbles[(*src>>4)&15];
            *dst++ = g_hexNybbles[(*src++)&15];
        }
        *dst++ = '-';
        for(int i = 0; i < 2; i++)
        {
            *dst++ = g_hexNybbles[(*src>>4)&15];
            *dst++ = g_hexNybbles[(*src++)&15];
        }
        *dst++ = '-';
        for(int i = 0; i < 6; i++)
        {
            *dst++ = g_hexNybbles[(*src>>4)&15];
            *dst++ = g_hexNybbles[(*src++)&15];
        }

        rcjson_addStringElement(getJsonContext(writer), key, uuidBuffer, (int)(dst - uuidBuffer));
    }
}

static void addJSONElement(const RollbarCrashReportWriter* const writer,
                           const char* const key,
                           const char* const jsonElement,
                           bool closeLastContainer)
{
    int jsonResult = rcjson_addJSONElement(getJsonContext(writer),
                                           key,
                                           jsonElement,
                                           (int)strlen(jsonElement),
                                           closeLastContainer);
    if(jsonResult != RollbarCrashJSON_OK)
    {
        char errorBuff[100];
        snprintf(errorBuff,
                 sizeof(errorBuff),
                 "Invalid JSON data: %s",
                 rcjson_stringForError(jsonResult));
        rcjson_beginObject(getJsonContext(writer), key);
        rcjson_addStringElement(getJsonContext(writer),
                                RollbarCrashField_Error,
                                errorBuff,
                                RollbarCrashJSON_SIZE_AUTOMATIC);
        rcjson_addStringElement(getJsonContext(writer),
                                RollbarCrashField_JSONData,
                                jsonElement,
                                RollbarCrashJSON_SIZE_AUTOMATIC);
        rcjson_endContainer(getJsonContext(writer));
    }
}

static void addJSONElementFromFile(const RollbarCrashReportWriter* const writer,
                                   const char* const key,
                                   const char* const filePath,
                                   bool closeLastContainer)
{
    rcjson_addJSONFromFile(getJsonContext(writer), key, filePath, closeLastContainer);
}

static void beginObject(const RollbarCrashReportWriter* const writer, const char* const key)
{
    rcjson_beginObject(getJsonContext(writer), key);
}

static void beginArray(const RollbarCrashReportWriter* const writer, const char* const key)
{
    rcjson_beginArray(getJsonContext(writer), key);
}

static void endContainer(const RollbarCrashReportWriter* const writer)
{
    rcjson_endContainer(getJsonContext(writer));
}


static void addTextLinesFromFile(const RollbarCrashReportWriter* const writer, const char* const key, const char* const filePath)
{
    char readBuffer[1024];
    RollbarCrashBufferedReader reader;
    if(!rcfu_openBufferedReader(&reader, filePath, readBuffer, sizeof(readBuffer)))
    {
        return;
    }
    char buffer[1024];
    beginArray(writer, key);
    {
        for(;;)
        {
            int length = sizeof(buffer);
            rcfu_readBufferedReaderUntilChar(&reader, '\n', buffer, &length);
            if(length <= 0)
            {
                break;
            }
            buffer[length - 1] = '\0';
            rcjson_addStringElement(getJsonContext(writer), NULL, buffer, RollbarCrashJSON_SIZE_AUTOMATIC);
        }
    }
    endContainer(writer);
    rcfu_closeBufferedReader(&reader);
}

static int addJSONData(const char* restrict const data, const int length, void* restrict userData)
{
    RollbarCrashBufferedWriter* writer = (RollbarCrashBufferedWriter*)userData;
    const bool success = rcfu_writeBufferedWriter(writer, data, length);
    return success ? RollbarCrashJSON_OK : RollbarCrashJSON_ERROR_CANNOT_ADD_DATA;
}


// ============================================================================
#pragma mark - Utility -
// ============================================================================

/** Check if a memory address points to a valid null terminated UTF-8 string.
 *
 * @param address The address to check.
 *
 * @return true if the address points to a string.
 */
static bool isValidString(const void* const address)
{
    if((void*)address == NULL)
    {
        return false;
    }

    char buffer[500];
    if((uintptr_t)address+sizeof(buffer) < (uintptr_t)address)
    {
        // Wrapped around the address range.
        return false;
    }
    if(!rcmem_copySafely(address, buffer, sizeof(buffer)))
    {
        return false;
    }
    return rcstring_isNullTerminatedUTF8String(buffer, kMinStringLength, sizeof(buffer));
}

/** Get the backtrace for the specified machine context.
 *
 * This function will choose how to fetch the backtrace based on the crash and
 * machine context. It may store the backtrace in backtraceBuffer unless it can
 * be fetched directly from memory. Do not count on backtraceBuffer containing
 * anything. Always use the return value.
 *
 * @param crash The crash handler context.
 *
 * @param machineContext The machine context.
 *
 * @param cursor The stack cursor to fill.
 *
 * @return True if the cursor was filled.
 */
static bool getStackCursor(const RollbarCrash_MonitorContext* const crash,
                           const struct RollbarCrashMachineContext* const machineContext,
                           RollbarCrashStackCursor *cursor)
{
    if(rcmc_getThreadFromContext(machineContext) == rcmc_getThreadFromContext(crash->offendingMachineContext))
    {
        *cursor = *((RollbarCrashStackCursor*)crash->stackCursor);
        return true;
    }

    rcsc_initWithMachineContext(cursor, RollbarCrashSC_STACK_OVERFLOW_THRESHOLD, machineContext);
    return true;
}


// ============================================================================
#pragma mark - Report Writing -
// ============================================================================

/** Write the contents of a memory location.
 * Also writes meta information about the data.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param address The memory address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeMemoryContents(const RollbarCrashReportWriter* const writer,
                                const char* const key,
                                const uintptr_t address,
                                int* limit);

/** Write a string to the report.
 * This will only print the first child of the array.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param objectAddress The object's address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeNSStringContents(const RollbarCrashReportWriter* const writer,
                                  const char* const key,
                                  const uintptr_t objectAddress,
                                  __unused int* limit)
{
    const void* object = (const void*)objectAddress;
    char buffer[200];
    if(rcobjc_copyStringContents(object, buffer, sizeof(buffer)))
    {
        writer->addStringElement(writer, key, buffer);
    }
}

/** Write a URL to the report.
 * This will only print the first child of the array.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param objectAddress The object's address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeURLContents(const RollbarCrashReportWriter* const writer,
                             const char* const key,
                             const uintptr_t objectAddress,
                             __unused int* limit)
{
    const void* object = (const void*)objectAddress;
    char buffer[200];
    if(rcobjc_copyStringContents(object, buffer, sizeof(buffer)))
    {
        writer->addStringElement(writer, key, buffer);
    }
}

/** Write a date to the report.
 * This will only print the first child of the array.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param objectAddress The object's address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeDateContents(const RollbarCrashReportWriter* const writer,
                              const char* const key,
                              const uintptr_t objectAddress,
                              __unused int* limit)
{
    const void* object = (const void*)objectAddress;
    writer->addFloatingPointElement(writer, key, rcobjc_dateContents(object));
}

/** Write a number to the report.
 * This will only print the first child of the array.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param objectAddress The object's address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeNumberContents(const RollbarCrashReportWriter* const writer,
                                const char* const key,
                                const uintptr_t objectAddress,
                                __unused int* limit)
{
    const void* object = (const void*)objectAddress;
    writer->addFloatingPointElement(writer, key, rcobjc_numberAsFloat(object));
}

/** Write an array to the report.
 * This will only print the first child of the array.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param objectAddress The object's address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeArrayContents(const RollbarCrashReportWriter* const writer,
                               const char* const key,
                               const uintptr_t objectAddress,
                               int* limit)
{
    const void* object = (const void*)objectAddress;
    uintptr_t firstObject;
    if(rcobjc_arrayContents(object, &firstObject, 1) == 1)
    {
        writeMemoryContents(writer, key, firstObject, limit);
    }
}

/** Write out ivar information about an unknown object.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param objectAddress The object's address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeUnknownObjectContents(const RollbarCrashReportWriter* const writer,
                                       const char* const key,
                                       const uintptr_t objectAddress,
                                       int* limit)
{
    (*limit)--;
    const void* object = (const void*)objectAddress;
    RollbarCrashObjCIvar ivars[10];
    int8_t s8;
    int16_t s16;
    int sInt;
    int32_t s32;
    int64_t s64;
    uint8_t u8;
    uint16_t u16;
    unsigned int uInt;
    uint32_t u32;
    uint64_t u64;
    float f32;
    double f64;
    bool b;
    void* pointer;
    
    
    writer->beginObject(writer, key);
    {
        if(rcobjc_isTaggedPointer(object))
        {
            writer->addIntegerElement(writer, "tagged_payload", (int64_t)rcobjc_taggedPointerPayload(object));
        }
        else
        {
            const void* class = rcobjc_isaPointer(object);
            int ivarCount = rcobjc_ivarList(class, ivars, sizeof(ivars)/sizeof(*ivars));
            *limit -= ivarCount;
            for(int i = 0; i < ivarCount; i++)
            {
                RollbarCrashObjCIvar* ivar = &ivars[i];
                switch(ivar->type[0])
                {
                    case 'c':
                        rcobjc_ivarValue(object, ivar->index, &s8);
                        writer->addIntegerElement(writer, ivar->name, s8);
                        break;
                    case 'i':
                        rcobjc_ivarValue(object, ivar->index, &sInt);
                        writer->addIntegerElement(writer, ivar->name, sInt);
                        break;
                    case 's':
                        rcobjc_ivarValue(object, ivar->index, &s16);
                        writer->addIntegerElement(writer, ivar->name, s16);
                        break;
                    case 'l':
                        rcobjc_ivarValue(object, ivar->index, &s32);
                        writer->addIntegerElement(writer, ivar->name, s32);
                        break;
                    case 'q':
                        rcobjc_ivarValue(object, ivar->index, &s64);
                        writer->addIntegerElement(writer, ivar->name, s64);
                        break;
                    case 'C':
                        rcobjc_ivarValue(object, ivar->index, &u8);
                        writer->addUIntegerElement(writer, ivar->name, u8);
                        break;
                    case 'I':
                        rcobjc_ivarValue(object, ivar->index, &uInt);
                        writer->addUIntegerElement(writer, ivar->name, uInt);
                        break;
                    case 'S':
                        rcobjc_ivarValue(object, ivar->index, &u16);
                        writer->addUIntegerElement(writer, ivar->name, u16);
                        break;
                    case 'L':
                        rcobjc_ivarValue(object, ivar->index, &u32);
                        writer->addUIntegerElement(writer, ivar->name, u32);
                        break;
                    case 'Q':
                        rcobjc_ivarValue(object, ivar->index, &u64);
                        writer->addUIntegerElement(writer, ivar->name, u64);
                        break;
                    case 'f':
                        rcobjc_ivarValue(object, ivar->index, &f32);
                        writer->addFloatingPointElement(writer, ivar->name, f32);
                        break;
                    case 'd':
                        rcobjc_ivarValue(object, ivar->index, &f64);
                        writer->addFloatingPointElement(writer, ivar->name, f64);
                        break;
                    case 'B':
                        rcobjc_ivarValue(object, ivar->index, &b);
                        writer->addBooleanElement(writer, ivar->name, b);
                        break;
                    case '*':
                    case '@':
                    case '#':
                    case ':':
                        rcobjc_ivarValue(object, ivar->index, &pointer);
                        writeMemoryContents(writer, ivar->name, (uintptr_t)pointer, limit);
                        break;
                    default:
                        RollbarCrashLOG_DEBUG("%s: Unknown ivar type [%s]", ivar->name, ivar->type);
                }
            }
        }
    }
    writer->endContainer(writer);
}

static bool isRestrictedClass(const char* name)
{
    if(g_introspectionRules.restrictedClasses != NULL)
    {
        for(int i = 0; i < g_introspectionRules.restrictedClassesCount; i++)
        {
            if(strcmp(name, g_introspectionRules.restrictedClasses[i]) == 0)
            {
                return true;
            }
        }
    }
    return false;
}

static void writeZombieIfPresent(const RollbarCrashReportWriter* const writer,
                                 const char* const key,
                                 const uintptr_t address)
{
#if RollbarCrashCRASH_HAS_OBJC
    const void* object = (const void*)address;
    const char* zombieClassName = rczombie_className(object);
    if(zombieClassName != NULL)
    {
        writer->addStringElement(writer, key, zombieClassName);
    }
#endif
}

static bool writeObjCObject(const RollbarCrashReportWriter* const writer,
                            const uintptr_t address,
                            int* limit)
{
#if RollbarCrashCRASH_HAS_OBJC
    const void* object = (const void*)address;
    switch(rcobjc_objectType(object))
    {
        case RollbarCrashObjCTypeClass:
            writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashMemType_Class);
            writer->addStringElement(writer, RollbarCrashField_Class, rcobjc_className(object));
            return true;
        case RollbarCrashObjCTypeObject:
        {
            writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashMemType_Object);
            const char* className = rcobjc_objectClassName(object);
            writer->addStringElement(writer, RollbarCrashField_Class, className);
            if(!isRestrictedClass(className))
            {
                switch(rcobjc_objectClassType(object))
                {
                    case RollbarCrashObjCClassTypeString:
                        writeNSStringContents(writer, RollbarCrashField_Value, address, limit);
                        return true;
                    case RollbarCrashObjCClassTypeURL:
                        writeURLContents(writer, RollbarCrashField_Value, address, limit);
                        return true;
                    case RollbarCrashObjCClassTypeDate:
                        writeDateContents(writer, RollbarCrashField_Value, address, limit);
                        return true;
                    case RollbarCrashObjCClassTypeArray:
                        if(*limit > 0)
                        {
                            writeArrayContents(writer, RollbarCrashField_FirstObject, address, limit);
                        }
                        return true;
                    case RollbarCrashObjCClassTypeNumber:
                        writeNumberContents(writer, RollbarCrashField_Value, address, limit);
                        return true;
                    case RollbarCrashObjCClassTypeDictionary:
                    case RollbarCrashObjCClassTypeException:
                        // TODO: Implement these.
                        if(*limit > 0)
                        {
                            writeUnknownObjectContents(writer, RollbarCrashField_Ivars, address, limit);
                        }
                        return true;
                    case RollbarCrashObjCClassTypeUnknown:
                        if(*limit > 0)
                        {
                            writeUnknownObjectContents(writer, RollbarCrashField_Ivars, address, limit);
                        }
                        return true;
                }
            }
            break;
        }
        case RollbarCrashObjCTypeBlock:
            writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashMemType_Block);
            const char* className = rcobjc_objectClassName(object);
            writer->addStringElement(writer, RollbarCrashField_Class, className);
            return true;
        case RollbarCrashObjCTypeUnknown:
            break;
    }
#endif

    return false;
}

/** Write the contents of a memory location.
 * Also writes meta information about the data.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param address The memory address.
 *
 * @param limit How many more subreferenced objects to write, if any.
 */
static void writeMemoryContents(const RollbarCrashReportWriter* const writer,
                                const char* const key,
                                const uintptr_t address,
                                int* limit)
{
    (*limit)--;
    const void* object = (const void*)address;
    writer->beginObject(writer, key);
    {
        writer->addUIntegerElement(writer, RollbarCrashField_Address, address);
        writeZombieIfPresent(writer, RollbarCrashField_LastDeallocObject, address);
        if(!writeObjCObject(writer, address, limit))
        {
            if(object == NULL)
            {
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashMemType_NullPointer);
            }
            else if(isValidString(object))
            {
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashMemType_String);
                writer->addStringElement(writer, RollbarCrashField_Value, (const char*)object);
            }
            else
            {
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashMemType_Unknown);
            }
        }
    }
    writer->endContainer(writer);
}

static bool isValidPointer(const uintptr_t address)
{
    if(address == (uintptr_t)NULL)
    {
        return false;
    }

#if RollbarCrashCRASH_HAS_OBJC
    if(rcobjc_isTaggedPointer((const void*)address))
    {
        if(!rcobjc_isValidTaggedPointer((const void*)address))
        {
            return false;
        }
    }
#endif

    return true;
}

static bool isNotableAddress(const uintptr_t address)
{
    if(!isValidPointer(address))
    {
        return false;
    }
    
    const void* object = (const void*)address;

#if RollbarCrashCRASH_HAS_OBJC
    if(rczombie_className(object) != NULL)
    {
        return true;
    }

    if(rcobjc_objectType(object) != RollbarCrashObjCTypeUnknown)
    {
        return true;
    }
#endif

    if(isValidString(object))
    {
        return true;
    }

    return false;
}

/** Write the contents of a memory location only if it contains notable data.
 * Also writes meta information about the data.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param address The memory address.
 */
static void writeMemoryContentsIfNotable(const RollbarCrashReportWriter* const writer,
                                         const char* const key,
                                         const uintptr_t address)
{
    if(isNotableAddress(address))
    {
        int limit = kDefaultMemorySearchDepth;
        writeMemoryContents(writer, key, address, &limit);
    }
}

/** Look for a hex value in a string and try to write whatever it references.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param string The string to search.
 */
static void writeAddressReferencedByString(const RollbarCrashReportWriter* const writer,
                                           const char* const key,
                                           const char* string)
{
    uint64_t address = 0;
    if(string == NULL || !rcstring_extractHexValue(string, (int)strlen(string), &address))
    {
        return;
    }
    
    int limit = kDefaultMemorySearchDepth;
    writeMemoryContents(writer, key, (uintptr_t)address, &limit);
}

#pragma mark Backtrace

/** Write a backtrace to the report.
 *
 * @param writer The writer to write the backtrace to.
 *
 * @param key The object key, if needed.
 *
 * @param stackCursor The stack cursor to read from.
 */
static void writeBacktrace(const RollbarCrashReportWriter* const writer,
                           const char* const key,
                           RollbarCrashStackCursor* stackCursor)
{
    writer->beginObject(writer, key);
    {
        writer->beginArray(writer, RollbarCrashField_Contents);
        {
            while(stackCursor->advanceCursor(stackCursor))
            {
                writer->beginObject(writer, NULL);
                {
                    if(stackCursor->symbolicate(stackCursor))
                    {
                        if(stackCursor->stackEntry.imageName != NULL)
                        {
                            writer->addStringElement(writer, RollbarCrashField_ObjectName, rcfu_lastPathEntry(stackCursor->stackEntry.imageName));
                        }
                        writer->addUIntegerElement(writer, RollbarCrashField_ObjectAddr, stackCursor->stackEntry.imageAddress);
                        if(stackCursor->stackEntry.symbolName != NULL)
                        {
                            writer->addStringElement(writer, RollbarCrashField_SymbolName, stackCursor->stackEntry.symbolName);
                        }
                        writer->addUIntegerElement(writer, RollbarCrashField_SymbolAddr, stackCursor->stackEntry.symbolAddress);
                    }
                    writer->addUIntegerElement(writer, RollbarCrashField_InstructionAddr, stackCursor->stackEntry.address);
                }
                writer->endContainer(writer);
            }
        }
        writer->endContainer(writer);
        writer->addIntegerElement(writer, RollbarCrashField_Skipped, 0);
    }
    writer->endContainer(writer);
}
                              

#pragma mark Stack

/** Write a dump of the stack contents to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param machineContext The context to retrieve the stack from.
 *
 * @param isStackOverflow If true, the stack has overflowed.
 */
static void writeStackContents(const RollbarCrashReportWriter* const writer,
                               const char* const key,
                               const struct RollbarCrashMachineContext* const machineContext,
                               const bool isStackOverflow)
{
    uintptr_t sp = rccpu_stackPointer(machineContext);
    if((void*)sp == NULL)
    {
        return;
    }

    uintptr_t lowAddress = sp + (uintptr_t)(kStackContentsPushedDistance * (int)sizeof(sp) * rccpu_stackGrowDirection() * -1);
    uintptr_t highAddress = sp + (uintptr_t)(kStackContentsPoppedDistance * (int)sizeof(sp) * rccpu_stackGrowDirection());
    if(highAddress < lowAddress)
    {
        uintptr_t tmp = lowAddress;
        lowAddress = highAddress;
        highAddress = tmp;
    }
    writer->beginObject(writer, key);
    {
        writer->addStringElement(writer, RollbarCrashField_GrowDirection, rccpu_stackGrowDirection() > 0 ? "+" : "-");
        writer->addUIntegerElement(writer, RollbarCrashField_DumpStart, lowAddress);
        writer->addUIntegerElement(writer, RollbarCrashField_DumpEnd, highAddress);
        writer->addUIntegerElement(writer, RollbarCrashField_StackPtr, sp);
        writer->addBooleanElement(writer, RollbarCrashField_Overflow, isStackOverflow);
        uint8_t stackBuffer[kStackContentsTotalDistance * sizeof(sp)];
        int copyLength = (int)(highAddress - lowAddress);
        if(rcmem_copySafely((void*)lowAddress, stackBuffer, copyLength))
        {
            writer->addDataElement(writer, RollbarCrashField_Contents, (void*)stackBuffer, copyLength);
        }
        else
        {
            writer->addStringElement(writer, RollbarCrashField_Error, "Stack contents not accessible");
        }
    }
    writer->endContainer(writer);
}

/** Write any notable addresses near the stack pointer (above and below).
 *
 * @param writer The writer.
 *
 * @param machineContext The context to retrieve the stack from.
 *
 * @param backDistance The distance towards the beginning of the stack to check.
 *
 * @param forwardDistance The distance past the end of the stack to check.
 */
static void writeNotableStackContents(const RollbarCrashReportWriter* const writer,
                                      const struct RollbarCrashMachineContext* const machineContext,
                                      const int backDistance,
                                      const int forwardDistance)
{
    uintptr_t sp = rccpu_stackPointer(machineContext);
    if((void*)sp == NULL)
    {
        return;
    }

    uintptr_t lowAddress = sp + (uintptr_t)(backDistance * (int)sizeof(sp) * rccpu_stackGrowDirection() * -1);
    uintptr_t highAddress = sp + (uintptr_t)(forwardDistance * (int)sizeof(sp) * rccpu_stackGrowDirection());
    if(highAddress < lowAddress)
    {
        uintptr_t tmp = lowAddress;
        lowAddress = highAddress;
        highAddress = tmp;
    }
    uintptr_t contentsAsPointer;
    char nameBuffer[40];
    for(uintptr_t address = lowAddress; address < highAddress; address += sizeof(address))
    {
        if(rcmem_copySafely((void*)address, &contentsAsPointer, sizeof(contentsAsPointer)))
        {
            sprintf(nameBuffer, "stack@%p", (void*)address);
            writeMemoryContentsIfNotable(writer, nameBuffer, contentsAsPointer);
        }
    }
}


#pragma mark Registers

/** Write the contents of all regular registers to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param machineContext The context to retrieve the registers from.
 */
static void writeBasicRegisters(const RollbarCrashReportWriter* const writer,
                                const char* const key,
                                const struct RollbarCrashMachineContext* const machineContext)
{
    char registerNameBuff[30];
    const char* registerName;
    writer->beginObject(writer, key);
    {
        const int numRegisters = rccpu_numRegisters();
        for(int reg = 0; reg < numRegisters; reg++)
        {
            registerName = rccpu_registerName(reg);
            if(registerName == NULL)
            {
                snprintf(registerNameBuff, sizeof(registerNameBuff), "r%d", reg);
                registerName = registerNameBuff;
            }
            writer->addUIntegerElement(writer, registerName,
                                       rccpu_registerValue(machineContext, reg));
        }
    }
    writer->endContainer(writer);
}

/** Write the contents of all exception registers to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param machineContext The context to retrieve the registers from.
 */
static void writeExceptionRegisters(const RollbarCrashReportWriter* const writer,
                                    const char* const key,
                                    const struct RollbarCrashMachineContext* const machineContext)
{
    char registerNameBuff[30];
    const char* registerName;
    writer->beginObject(writer, key);
    {
        const int numRegisters = rccpu_numExceptionRegisters();
        for(int reg = 0; reg < numRegisters; reg++)
        {
            registerName = rccpu_exceptionRegisterName(reg);
            if(registerName == NULL)
            {
                snprintf(registerNameBuff, sizeof(registerNameBuff), "r%d", reg);
                registerName = registerNameBuff;
            }
            writer->addUIntegerElement(writer,registerName,
                                       rccpu_exceptionRegisterValue(machineContext, reg));
        }
    }
    writer->endContainer(writer);
}

/** Write all applicable registers.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param machineContext The context to retrieve the registers from.
 */
static void writeRegisters(const RollbarCrashReportWriter* const writer,
                           const char* const key,
                           const struct RollbarCrashMachineContext* const machineContext)
{
    writer->beginObject(writer, key);
    {
        writeBasicRegisters(writer, RollbarCrashField_Basic, machineContext);
        if(rcmc_hasValidExceptionRegisters(machineContext))
        {
            writeExceptionRegisters(writer, RollbarCrashField_Exception, machineContext);
        }
    }
    writer->endContainer(writer);
}

/** Write any notable addresses contained in the CPU registers.
 *
 * @param writer The writer.
 *
 * @param machineContext The context to retrieve the registers from.
 */
static void writeNotableRegisters(const RollbarCrashReportWriter* const writer,
                                  const struct RollbarCrashMachineContext* const machineContext)
{
    char registerNameBuff[30];
    const char* registerName;
    const int numRegisters = rccpu_numRegisters();
    for(int reg = 0; reg < numRegisters; reg++)
    {
        registerName = rccpu_registerName(reg);
        if(registerName == NULL)
        {
            snprintf(registerNameBuff, sizeof(registerNameBuff), "r%d", reg);
            registerName = registerNameBuff;
        }
        writeMemoryContentsIfNotable(writer,
                                     registerName,
                                     (uintptr_t)rccpu_registerValue(machineContext, reg));
    }
}

#pragma mark Thread-specific

/** Write any notable addresses in the stack or registers to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param machineContext The context to retrieve the registers from.
 */
static void writeNotableAddresses(const RollbarCrashReportWriter* const writer,
                                  const char* const key,
                                  const struct RollbarCrashMachineContext* const machineContext)
{
    writer->beginObject(writer, key);
    {
        writeNotableRegisters(writer, machineContext);
        writeNotableStackContents(writer,
                                  machineContext,
                                  kStackNotableSearchBackDistance,
                                  kStackNotableSearchForwardDistance);
    }
    writer->endContainer(writer);
}

/** Write information about a thread to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param crash The crash handler context.
 *
 * @param machineContext The context whose thread to write about.
 *
 * @param shouldWriteNotableAddresses If true, write any notable addresses found.
 */
static void writeThread(const RollbarCrashReportWriter* const writer,
                        const char* const key,
                        const RollbarCrash_MonitorContext* const crash,
                        const struct RollbarCrashMachineContext* const machineContext,
                        const int threadIndex,
                        const bool shouldWriteNotableAddresses)
{
    bool isCrashedThread = rcmc_isCrashedContext(machineContext);
    RollbarCrashThread thread = rcmc_getThreadFromContext(machineContext);
    RollbarCrashLOG_DEBUG("Writing thread %x (index %d). is crashed: %d", thread, threadIndex, isCrashedThread);

    RollbarCrashStackCursor stackCursor;
    bool hasBacktrace = getStackCursor(crash, machineContext, &stackCursor);

    writer->beginObject(writer, key);
    {
        if(hasBacktrace)
        {
            writeBacktrace(writer, RollbarCrashField_Backtrace, &stackCursor);
        }
        if(rcmc_canHaveCPUState(machineContext))
        {
            writeRegisters(writer, RollbarCrashField_Registers, machineContext);
        }
        writer->addIntegerElement(writer, RollbarCrashField_Index, threadIndex);
        const char* name = rcccd_getThreadName(thread);
        if(name != NULL)
        {
            writer->addStringElement(writer, RollbarCrashField_Name, name);
        }
        name = rcccd_getQueueName(thread);
        if(name != NULL)
        {
            writer->addStringElement(writer, RollbarCrashField_DispatchQueue, name);
        }
        writer->addBooleanElement(writer, RollbarCrashField_Crashed, isCrashedThread);
        writer->addBooleanElement(writer, RollbarCrashField_CurrentThread, thread == rcthread_self());
        if(isCrashedThread)
        {
            writeStackContents(writer, RollbarCrashField_Stack, machineContext, stackCursor.state.hasGivenUp);
            if(shouldWriteNotableAddresses)
            {
                writeNotableAddresses(writer, RollbarCrashField_NotableAddresses, machineContext);
            }
        }
    }
    writer->endContainer(writer);
}

/** Write information about all threads to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param crash The crash handler context.
 */
static void writeAllThreads(const RollbarCrashReportWriter* const writer,
                            const char* const key,
                            const RollbarCrash_MonitorContext* const crash,
                            bool writeNotableAddresses)
{
    const struct RollbarCrashMachineContext* const context = crash->offendingMachineContext;
    RollbarCrashThread offendingThread = rcmc_getThreadFromContext(context);
    int threadCount = rcmc_getThreadCount(context);
    RollbarCrashMC_NEW_CONTEXT(machineContext);

    // Fetch info for all threads.
    writer->beginArray(writer, key);
    {
        RollbarCrashLOG_DEBUG("Writing %d threads.", threadCount);
        for(int i = 0; i < threadCount; i++)
        {
            RollbarCrashThread thread = rcmc_getThreadAtIndex(context, i);
            if(thread == offendingThread)
            {
                writeThread(writer, NULL, crash, context, i, writeNotableAddresses);
            }
            else
            {
                rcmc_getContextForThread(thread, machineContext, false);
                writeThread(writer, NULL, crash, machineContext, i, writeNotableAddresses);
            }
        }
    }
    writer->endContainer(writer);
}

#pragma mark Global Report Data

/** Write information about a binary image to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param index Which image to write about.
 */
static void writeBinaryImage(const RollbarCrashReportWriter* const writer,
                             const char* const key,
                             const int index)
{
    RollbarCrashBinaryImage image = {0};
    if(!rcdl_getBinaryImage(index, &image))
    {
        return;
    }

    writer->beginObject(writer, key);
    {
        writer->addUIntegerElement(writer, RollbarCrashField_ImageAddress, image.address);
        writer->addUIntegerElement(writer, RollbarCrashField_ImageVmAddress, image.vmAddress);
        writer->addUIntegerElement(writer, RollbarCrashField_ImageSize, image.size);
        writer->addStringElement(writer, RollbarCrashField_Name, image.name);
        writer->addUUIDElement(writer, RollbarCrashField_UUID, image.uuid);
        writer->addIntegerElement(writer, RollbarCrashField_CPUType, image.cpuType);
        writer->addIntegerElement(writer, RollbarCrashField_CPUSubType, image.cpuSubType);
        writer->addUIntegerElement(writer, RollbarCrashField_ImageMajorVersion, image.majorVersion);
        writer->addUIntegerElement(writer, RollbarCrashField_ImageMinorVersion, image.minorVersion);
        writer->addUIntegerElement(writer, RollbarCrashField_ImageRevisionVersion, image.revisionVersion);
        if(image.crashInfoMessage != NULL)
        {
            writer->addStringElement(writer, RollbarCrashField_ImageCrashInfoMessage, image.crashInfoMessage);
        }
        if(image.crashInfoMessage2 != NULL)
        {
            writer->addStringElement(writer, RollbarCrashField_ImageCrashInfoMessage2, image.crashInfoMessage2);
        }
    }
    writer->endContainer(writer);
}

/** Write information about all images to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 */
static void writeBinaryImages(const RollbarCrashReportWriter* const writer, const char* const key)
{
    const int imageCount = rcdl_imageCount();

    writer->beginArray(writer, key);
    {
        for(int iImg = 0; iImg < imageCount; iImg++)
        {
            writeBinaryImage(writer, NULL, iImg);
        }
    }
    writer->endContainer(writer);
}

/** Write information about system memory to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 */
static void writeMemoryInfo(const RollbarCrashReportWriter* const writer,
                            const char* const key,
                            const RollbarCrash_MonitorContext* const monitorContext)
{
    writer->beginObject(writer, key);
    {
        writer->addUIntegerElement(writer, RollbarCrashField_Size, monitorContext->System.memorySize);
        writer->addUIntegerElement(writer, RollbarCrashField_Usable, monitorContext->System.usableMemory);
        writer->addUIntegerElement(writer, RollbarCrashField_Free, monitorContext->System.freeMemory);
    }
    writer->endContainer(writer);
}

/** Write information about the error leading to the crash to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param crash The crash handler context.
 */
static void writeError(const RollbarCrashReportWriter* const writer,
                       const char* const key,
                       const RollbarCrash_MonitorContext* const crash)
{
    writer->beginObject(writer, key);
    {
#if RollbarCrashCRASH_HOST_APPLE
        writer->beginObject(writer, RollbarCrashField_Mach);
        {
            const char* machExceptionName = rcmach_exceptionName(crash->mach.type);
            const char* machCodeName = crash->mach.code == 0 ? NULL : rcmach_kernelReturnCodeName(crash->mach.code);
            writer->addUIntegerElement(writer, RollbarCrashField_Exception, (unsigned)crash->mach.type);
            if(machExceptionName != NULL)
            {
                writer->addStringElement(writer, RollbarCrashField_ExceptionName, machExceptionName);
            }
            writer->addUIntegerElement(writer, RollbarCrashField_Code, (unsigned)crash->mach.code);
            if(machCodeName != NULL)
            {
                writer->addStringElement(writer, RollbarCrashField_CodeName, machCodeName);
            }
            writer->addUIntegerElement(writer, RollbarCrashField_Subcode, (size_t)crash->mach.subcode);
        }
        writer->endContainer(writer);
#endif
        writer->beginObject(writer, RollbarCrashField_Signal);
        {
            const char* sigName = rcsignal_signalName(crash->signal.signum);
            const char* sigCodeName = rcsignal_signalCodeName(crash->signal.signum, crash->signal.sigcode);
            writer->addUIntegerElement(writer, RollbarCrashField_Signal, (unsigned)crash->signal.signum);
            if(sigName != NULL)
            {
                writer->addStringElement(writer, RollbarCrashField_Name, sigName);
            }
            writer->addUIntegerElement(writer, RollbarCrashField_Code, (unsigned)crash->signal.sigcode);
            if(sigCodeName != NULL)
            {
                writer->addStringElement(writer, RollbarCrashField_CodeName, sigCodeName);
            }
        }
        writer->endContainer(writer);

        writer->addUIntegerElement(writer, RollbarCrashField_Address, crash->faultAddress);
        if(crash->crashReason != NULL)
        {
            writer->addStringElement(writer, RollbarCrashField_Reason, crash->crashReason);
        }

        // Gather specific info.
        switch(crash->crashType)
        {
            case RollbarCrashMonitorTypeMainThreadDeadlock:
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashExcType_Deadlock);
                break;
                
            case RollbarCrashMonitorTypeMachException:
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashExcType_Mach);
                break;

            case RollbarCrashMonitorTypeCPPException:
            {
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashExcType_CPPException);
                writer->beginObject(writer, RollbarCrashField_CPPException);
                {
                    writer->addStringElement(writer, RollbarCrashField_Name, crash->CPPException.name);
                }
                writer->endContainer(writer);
                break;
            }
            case RollbarCrashMonitorTypeNSException:
            {
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashExcType_NSException);
                writer->beginObject(writer, RollbarCrashField_NSException);
                {
                    writer->addStringElement(writer, RollbarCrashField_Name, crash->NSException.name);
                    writer->addStringElement(writer, RollbarCrashField_UserInfo, crash->NSException.userInfo);
                    writeAddressReferencedByString(writer, RollbarCrashField_ReferencedObject, crash->crashReason);
                }
                writer->endContainer(writer);
                break;
            }
            case RollbarCrashMonitorTypeSignal:
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashExcType_Signal);
                break;

            case RollbarCrashMonitorTypeUserReported:
            {
                writer->addStringElement(writer, RollbarCrashField_Type, RollbarCrashExcType_User);
                writer->beginObject(writer, RollbarCrashField_UserReported);
                {
                    writer->addStringElement(writer, RollbarCrashField_Name, crash->userException.name);
                    if(crash->userException.language != NULL)
                    {
                        writer->addStringElement(writer, RollbarCrashField_Language, crash->userException.language);
                    }
                    if(crash->userException.lineOfCode != NULL)
                    {
                        writer->addStringElement(writer, RollbarCrashField_LineOfCode, crash->userException.lineOfCode);
                    }
                    if(crash->userException.customStackTrace != NULL)
                    {
                        writer->addJSONElement(writer, RollbarCrashField_Backtrace, crash->userException.customStackTrace, true);
                    }
                }
                writer->endContainer(writer);
                break;
            }
            case RollbarCrashMonitorTypeSystem:
            case RollbarCrashMonitorTypeApplicationState:
            case RollbarCrashMonitorTypeZombie:
                RollbarCrashLOG_ERROR("Crash monitor type 0x%x shouldn't be able to cause events!", crash->crashType);
                break;
        }
    }
    writer->endContainer(writer);
}

/** Write information about app runtime, etc to the report.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param monitorContext The event monitor context.
 */
static void writeAppStats(const RollbarCrashReportWriter* const writer,
                          const char* const key,
                          const RollbarCrash_MonitorContext* const monitorContext)
{
    writer->beginObject(writer, key);
    {
        writer->addBooleanElement(writer, RollbarCrashField_AppActive, monitorContext->AppState.applicationIsActive);
        writer->addBooleanElement(writer, RollbarCrashField_AppInFG, monitorContext->AppState.applicationIsInForeground);

        writer->addIntegerElement(writer, RollbarCrashField_LaunchesSinceCrash, monitorContext->AppState.launchesSinceLastCrash);
        writer->addIntegerElement(writer, RollbarCrashField_SessionsSinceCrash, monitorContext->AppState.sessionsSinceLastCrash);
        writer->addFloatingPointElement(writer, RollbarCrashField_ActiveTimeSinceCrash, monitorContext->AppState.activeDurationSinceLastCrash);
        writer->addFloatingPointElement(writer, RollbarCrashField_BGTimeSinceCrash, monitorContext->AppState.backgroundDurationSinceLastCrash);

        writer->addIntegerElement(writer, RollbarCrashField_SessionsSinceLaunch, monitorContext->AppState.sessionsSinceLaunch);
        writer->addFloatingPointElement(writer, RollbarCrashField_ActiveTimeSinceLaunch, monitorContext->AppState.activeDurationSinceLaunch);
        writer->addFloatingPointElement(writer, RollbarCrashField_BGTimeSinceLaunch, monitorContext->AppState.backgroundDurationSinceLaunch);
    }
    writer->endContainer(writer);
}

/** Write information about this process.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 */
static void writeProcessState(const RollbarCrashReportWriter* const writer,
                              const char* const key,
                              const RollbarCrash_MonitorContext* const monitorContext)
{
    writer->beginObject(writer, key);
    {
        if(monitorContext->ZombieException.address != 0)
        {
            writer->beginObject(writer, RollbarCrashField_LastDeallocedNSException);
            {
                writer->addUIntegerElement(writer, RollbarCrashField_Address, monitorContext->ZombieException.address);
                writer->addStringElement(writer, RollbarCrashField_Name, monitorContext->ZombieException.name);
                writer->addStringElement(writer, RollbarCrashField_Reason, monitorContext->ZombieException.reason);
                writeAddressReferencedByString(writer, RollbarCrashField_ReferencedObject, monitorContext->ZombieException.reason);
            }
            writer->endContainer(writer);
        }
    }
    writer->endContainer(writer);
}

/** Write basic report information.
 *
 * @param writer The writer.
 *
 * @param key The object key, if needed.
 *
 * @param type The report type.
 *
 * @param reportID The report ID.
 */
static void writeReportInfo(const RollbarCrashReportWriter* const writer,
                            const char* const key,
                            const char* const type,
                            const char* const reportID,
                            const char* const processName)
{
    writer->beginObject(writer, key);
    {
        struct timeval tp;
        gettimeofday(&tp, NULL);
        int64_t microseconds = ((int64_t)tp.tv_sec) * 1000000 + tp.tv_usec;
        
        writer->addStringElement(writer, RollbarCrashField_Version, RollbarCrashCRASH_REPORT_VERSION);
        writer->addStringElement(writer, RollbarCrashField_ID, reportID);
        writer->addStringElement(writer, RollbarCrashField_ProcessName, processName);
        writer->addIntegerElement(writer, RollbarCrashField_Timestamp, microseconds);
        writer->addStringElement(writer, RollbarCrashField_Type, type);
    }
    writer->endContainer(writer);
}

static void writeRecrash(const RollbarCrashReportWriter* const writer,
                         const char* const key,
                         const char* crashReportPath)
{
    writer->addJSONFileElement(writer, key, crashReportPath, true);
}


#pragma mark Setup

/** Prepare a report writer for use.
 *
 * @oaram writer The writer to prepare.
 *
 * @param context JSON writer contextual information.
 */
static void prepareReportWriter(RollbarCrashReportWriter* const writer, RollbarCrashJSONEncodeContext* const context)
{
    writer->addBooleanElement = addBooleanElement;
    writer->addFloatingPointElement = addFloatingPointElement;
    writer->addIntegerElement = addIntegerElement;
    writer->addUIntegerElement = addUIntegerElement;
    writer->addStringElement = addStringElement;
    writer->addTextFileElement = addTextFileElement;
    writer->addTextFileLinesElement = addTextLinesFromFile;
    writer->addJSONFileElement = addJSONElementFromFile;
    writer->addDataElement = addDataElement;
    writer->beginDataElement = beginDataElement;
    writer->appendDataElement = appendDataElement;
    writer->endDataElement = endDataElement;
    writer->addUUIDElement = addUUIDElement;
    writer->addJSONElement = addJSONElement;
    writer->beginObject = beginObject;
    writer->beginArray = beginArray;
    writer->endContainer = endContainer;
    writer->context = context;
}


// ============================================================================
#pragma mark - Main API -
// ============================================================================

void rcreport_writeRecrashReport(const RollbarCrash_MonitorContext* const monitorContext, const char* const path)
{
    char writeBuffer[1024];
    RollbarCrashBufferedWriter bufferedWriter;
    static char tempPath[RollbarCrashFU_MAX_PATH_LENGTH];
    strncpy(tempPath, path, sizeof(tempPath) - 10);
    strncpy(tempPath + strlen(tempPath) - 5, ".old", 5);
    RollbarCrashLOG_INFO("Writing recrash report to %s", path);

    if(rename(path, tempPath) < 0)
    {
        RollbarCrashLOG_ERROR("Could not rename %s to %s: %s", path, tempPath, strerror(errno));
    }
    if(!rcfu_openBufferedWriter(&bufferedWriter, path, writeBuffer, sizeof(writeBuffer)))
    {
        return;
    }

    rcccd_freeze();

    RollbarCrashJSONEncodeContext jsonContext;
    jsonContext.userData = &bufferedWriter;
    RollbarCrashReportWriter concreteWriter;
    RollbarCrashReportWriter* writer = &concreteWriter;
    prepareReportWriter(writer, &jsonContext);

    rcjson_beginEncode(getJsonContext(writer), true, addJSONData, &bufferedWriter);

    writer->beginObject(writer, RollbarCrashField_Report);
    {
        writeRecrash(writer, RollbarCrashField_RecrashReport, tempPath);
        rcfu_flushBufferedWriter(&bufferedWriter);
        if(remove(tempPath) < 0)
        {
            RollbarCrashLOG_ERROR("Could not remove %s: %s", tempPath, strerror(errno));
        }
        writeReportInfo(writer,
                        RollbarCrashField_Report,
                        RollbarCrashReportType_Minimal,
                        monitorContext->eventID,
                        monitorContext->System.processName);
        rcfu_flushBufferedWriter(&bufferedWriter);

        writer->beginObject(writer, RollbarCrashField_Crash);
        {
            writeError(writer, RollbarCrashField_Error, monitorContext);
            rcfu_flushBufferedWriter(&bufferedWriter);
            int threadIndex = rcmc_indexOfThread(monitorContext->offendingMachineContext,
                                                 rcmc_getThreadFromContext(monitorContext->offendingMachineContext));
            writeThread(writer,
                        RollbarCrashField_CrashedThread,
                        monitorContext,
                        monitorContext->offendingMachineContext,
                        threadIndex,
                        false);
            rcfu_flushBufferedWriter(&bufferedWriter);
        }
        writer->endContainer(writer);
    }
    writer->endContainer(writer);

    rcjson_endEncode(getJsonContext(writer));
    rcfu_closeBufferedWriter(&bufferedWriter);
    rcccd_unfreeze();
}

static void writeSystemInfo(const RollbarCrashReportWriter* const writer,
                            const char* const key,
                            const RollbarCrash_MonitorContext* const monitorContext)
{
    writer->beginObject(writer, key);
    {
        writer->addStringElement(writer, RollbarCrashField_SystemName, monitorContext->System.systemName);
        writer->addStringElement(writer, RollbarCrashField_SystemVersion, monitorContext->System.systemVersion);
        writer->addStringElement(writer, RollbarCrashField_Machine, monitorContext->System.machine);
        writer->addStringElement(writer, RollbarCrashField_Model, monitorContext->System.model);
        writer->addStringElement(writer, RollbarCrashField_KernelVersion, monitorContext->System.kernelVersion);
        writer->addStringElement(writer, RollbarCrashField_OSVersion, monitorContext->System.osVersion);
        writer->addBooleanElement(writer, RollbarCrashField_Jailbroken, monitorContext->System.isJailbroken);
        writer->addStringElement(writer, RollbarCrashField_BootTime, monitorContext->System.bootTime);
        writer->addStringElement(writer, RollbarCrashField_AppStartTime, monitorContext->System.appStartTime);
        writer->addStringElement(writer, RollbarCrashField_ExecutablePath, monitorContext->System.executablePath);
        writer->addStringElement(writer, RollbarCrashField_Executable, monitorContext->System.executableName);
        writer->addStringElement(writer, RollbarCrashField_BundleID, monitorContext->System.bundleID);
        writer->addStringElement(writer, RollbarCrashField_BundleName, monitorContext->System.bundleName);
        writer->addStringElement(writer, RollbarCrashField_BundleVersion, monitorContext->System.bundleVersion);
        writer->addStringElement(writer, RollbarCrashField_BundleShortVersion, monitorContext->System.bundleShortVersion);
        writer->addStringElement(writer, RollbarCrashField_AppUUID, monitorContext->System.appID);
        writer->addStringElement(writer, RollbarCrashField_CPUArch, monitorContext->System.cpuArchitecture);
        writer->addIntegerElement(writer, RollbarCrashField_CPUType, monitorContext->System.cpuType);
        writer->addIntegerElement(writer, RollbarCrashField_CPUSubType, monitorContext->System.cpuSubType);
        writer->addIntegerElement(writer, RollbarCrashField_BinaryCPUType, monitorContext->System.binaryCPUType);
        writer->addIntegerElement(writer, RollbarCrashField_BinaryCPUSubType, monitorContext->System.binaryCPUSubType);
        writer->addStringElement(writer, RollbarCrashField_TimeZone, monitorContext->System.timezone);
        writer->addStringElement(writer, RollbarCrashField_ProcessName, monitorContext->System.processName);
        writer->addIntegerElement(writer, RollbarCrashField_ProcessID, monitorContext->System.processID);
        writer->addIntegerElement(writer, RollbarCrashField_ParentProcessID, monitorContext->System.parentProcessID);
        writer->addStringElement(writer, RollbarCrashField_DeviceAppHash, monitorContext->System.deviceAppHash);
        writer->addStringElement(writer, RollbarCrashField_BuildType, monitorContext->System.buildType);
        writer->addIntegerElement(writer, RollbarCrashField_Storage, (int64_t)monitorContext->System.storageSize);

        writeMemoryInfo(writer, RollbarCrashField_Memory, monitorContext);
        writeAppStats(writer, RollbarCrashField_AppStats, monitorContext);
    }
    writer->endContainer(writer);

}

static void writeDebugInfo(const RollbarCrashReportWriter* const writer,
                            const char* const key,
                            const RollbarCrash_MonitorContext* const monitorContext)
{
    writer->beginObject(writer, key);
    {
        if(monitorContext->consoleLogPath != NULL)
        {
            addTextLinesFromFile(writer, RollbarCrashField_ConsoleLog, monitorContext->consoleLogPath);
        }
    }
    writer->endContainer(writer);
    
}

void rcreport_writeStandardReport(const RollbarCrash_MonitorContext* const monitorContext, const char* const path)
{
    RollbarCrashLOG_INFO("Writing crash report to %s", path);
    char writeBuffer[1024];
    RollbarCrashBufferedWriter bufferedWriter;

    if(!rcfu_openBufferedWriter(&bufferedWriter, path, writeBuffer, sizeof(writeBuffer)))
    {
        return;
    }

    rcccd_freeze();
    
    RollbarCrashJSONEncodeContext jsonContext;
    jsonContext.userData = &bufferedWriter;
    RollbarCrashReportWriter concreteWriter;
    RollbarCrashReportWriter* writer = &concreteWriter;
    prepareReportWriter(writer, &jsonContext);

    rcjson_beginEncode(getJsonContext(writer), true, addJSONData, &bufferedWriter);

    writer->beginObject(writer, RollbarCrashField_Report);
    {
        writeReportInfo(writer,
                        RollbarCrashField_Report,
                        RollbarCrashReportType_Standard,
                        monitorContext->eventID,
                        monitorContext->System.processName);
        rcfu_flushBufferedWriter(&bufferedWriter);

        writeBinaryImages(writer, RollbarCrashField_BinaryImages);
        rcfu_flushBufferedWriter(&bufferedWriter);

        writeProcessState(writer, RollbarCrashField_ProcessState, monitorContext);
        rcfu_flushBufferedWriter(&bufferedWriter);

        writeSystemInfo(writer, RollbarCrashField_System, monitorContext);
        rcfu_flushBufferedWriter(&bufferedWriter);

        writer->beginObject(writer, RollbarCrashField_Crash);
        {
            writeError(writer, RollbarCrashField_Error, monitorContext);
            rcfu_flushBufferedWriter(&bufferedWriter);
            writeAllThreads(writer,
                            RollbarCrashField_Threads,
                            monitorContext,
                            g_introspectionRules.enabled);
            rcfu_flushBufferedWriter(&bufferedWriter);
        }
        writer->endContainer(writer);

        if(g_userInfoJSON != NULL)
        {
            addJSONElement(writer, RollbarCrashField_User, g_userInfoJSON, false);
            rcfu_flushBufferedWriter(&bufferedWriter);
        }
        else
        {
            writer->beginObject(writer, RollbarCrashField_User);
        }
        if(g_userSectionWriteCallback != NULL)
        {
            rcfu_flushBufferedWriter(&bufferedWriter);
            if (monitorContext->currentSnapshotUserReported == false) {
                g_userSectionWriteCallback(writer);
            }
        }
        writer->endContainer(writer);
        rcfu_flushBufferedWriter(&bufferedWriter);

        writeDebugInfo(writer, RollbarCrashField_Debug, monitorContext);
    }
    writer->endContainer(writer);
    
    rcjson_endEncode(getJsonContext(writer));
    rcfu_closeBufferedWriter(&bufferedWriter);
    rcccd_unfreeze();
}



void rcreport_setUserInfoJSON(const char* const userInfoJSON)
{
    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    RollbarCrashLOG_TRACE("set userInfoJSON to %p", userInfoJSON);

    pthread_mutex_lock(&mutex);
    if(g_userInfoJSON != NULL)
    {
        free((void*)g_userInfoJSON);
    }
    if(userInfoJSON == NULL)
    {
        g_userInfoJSON = NULL;
    }
    else
    {
        g_userInfoJSON = strdup(userInfoJSON);
    }
    pthread_mutex_unlock(&mutex);
}

void rcreport_setIntrospectMemory(bool shouldIntrospectMemory)
{
    g_introspectionRules.enabled = shouldIntrospectMemory;
}

void rcreport_setDoNotIntrospectClasses(const char** doNotIntrospectClasses, int length)
{
    const char** oldClasses = g_introspectionRules.restrictedClasses;
    int oldClassesLength = g_introspectionRules.restrictedClassesCount;
    const char** newClasses = NULL;
    int newClassesLength = 0;
    
    if(doNotIntrospectClasses != NULL && length > 0)
    {
        newClassesLength = length;
        newClasses = malloc(sizeof(*newClasses) * (unsigned)newClassesLength);
        if(newClasses == NULL)
        {
            RollbarCrashLOG_ERROR("Could not allocate memory");
            return;
        }
        
        for(int i = 0; i < newClassesLength; i++)
        {
            newClasses[i] = strdup(doNotIntrospectClasses[i]);
        }
    }
    
    g_introspectionRules.restrictedClasses = newClasses;
    g_introspectionRules.restrictedClassesCount = newClassesLength;
    
    if(oldClasses != NULL)
    {
        for(int i = 0; i < oldClassesLength; i++)
        {
            free((void*)oldClasses[i]);
        }
        free(oldClasses);
    }
}

void rcreport_setUserSectionWriteCallback(const RollbarCrashReportWriteCallback userSectionWriteCallback)
{
    RollbarCrashLOG_TRACE("Set userSectionWriteCallback to %p", userSectionWriteCallback);
    g_userSectionWriteCallback = userSectionWriteCallback;
}
