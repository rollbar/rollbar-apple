//
//  RollbarCrashReportFields.h
//
//  Created by Karl Stenerud on 2012-10-07.
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


#ifndef HDR_RollbarCrashReportFields_h
#define HDR_RollbarCrashReportFields_h


#pragma mark - Report Types -

#define RollbarCrashReportType_Minimal          "minimal"
#define RollbarCrashReportType_Standard         "standard"
#define RollbarCrashReportType_Custom           "custom"


#pragma mark - Memory Types -

#define RollbarCrashMemType_Block               "objc_block"
#define RollbarCrashMemType_Class               "objc_class"
#define RollbarCrashMemType_NullPointer         "null_pointer"
#define RollbarCrashMemType_Object              "objc_object"
#define RollbarCrashMemType_String              "string"
#define RollbarCrashMemType_Unknown             "unknown"


#pragma mark - Exception Types -

#define RollbarCrashExcType_CPPException        "cpp_exception"
#define RollbarCrashExcType_Deadlock            "deadlock"
#define RollbarCrashExcType_Mach                "mach"
#define RollbarCrashExcType_NSException         "nsexception"
#define RollbarCrashExcType_Signal              "signal"
#define RollbarCrashExcType_User                "user"


#pragma mark - Common -

#define RollbarCrashField_Address               "address"
#define RollbarCrashField_Contents              "contents"
#define RollbarCrashField_Exception             "exception"
#define RollbarCrashField_FirstObject           "first_object"
#define RollbarCrashField_Index                 "index"
#define RollbarCrashField_Ivars                 "ivars"
#define RollbarCrashField_Language              "language"
#define RollbarCrashField_Name                  "name"
#define RollbarCrashField_UserInfo              "userInfo"
#define RollbarCrashField_ReferencedObject      "referenced_object"
#define RollbarCrashField_Type                  "type"
#define RollbarCrashField_UUID                  "uuid"
#define RollbarCrashField_Value                 "value"

#define RollbarCrashField_Error                 "error"
#define RollbarCrashField_JSONData              "json_data"


#pragma mark - Notable Address -

#define RollbarCrashField_Class                 "class"
#define RollbarCrashField_LastDeallocObject     "last_deallocated_obj"


#pragma mark - Backtrace -

#define RollbarCrashField_InstructionAddr       "instruction_addr"
#define RollbarCrashField_LineOfCode            "line_of_code"
#define RollbarCrashField_ObjectAddr            "object_addr"
#define RollbarCrashField_ObjectName            "object_name"
#define RollbarCrashField_SymbolAddr            "symbol_addr"
#define RollbarCrashField_SymbolName            "symbol_name"


#pragma mark - Stack Dump -

#define RollbarCrashField_DumpEnd               "dump_end"
#define RollbarCrashField_DumpStart             "dump_start"
#define RollbarCrashField_GrowDirection         "grow_direction"
#define RollbarCrashField_Overflow              "overflow"
#define RollbarCrashField_StackPtr              "stack_pointer"


#pragma mark - Thread Dump -

#define RollbarCrashField_Backtrace             "backtrace"
#define RollbarCrashField_Basic                 "basic"
#define RollbarCrashField_Crashed               "crashed"
#define RollbarCrashField_CurrentThread         "current_thread"
#define RollbarCrashField_DispatchQueue         "dispatch_queue"
#define RollbarCrashField_NotableAddresses      "notable_addresses"
#define RollbarCrashField_Registers             "registers"
#define RollbarCrashField_Skipped               "skipped"
#define RollbarCrashField_Stack                 "stack"


#pragma mark - Binary Image -

#define RollbarCrashField_CPUSubType            "cpu_subtype"
#define RollbarCrashField_CPUType               "cpu_type"
#define RollbarCrashField_ImageAddress          "image_addr"
#define RollbarCrashField_ImageVmAddress        "image_vmaddr"
#define RollbarCrashField_ImageSize             "image_size"
#define RollbarCrashField_ImageMajorVersion     "major_version"
#define RollbarCrashField_ImageMinorVersion     "minor_version"
#define RollbarCrashField_ImageRevisionVersion  "revision_version"
#define RollbarCrashField_ImageCrashInfoMessage    "crash_info_message"
#define RollbarCrashField_ImageCrashInfoMessage2   "crash_info_message2"


#pragma mark - Memory -

#define RollbarCrashField_Free                  "free"
#define RollbarCrashField_Usable                "usable"


#pragma mark - Error -

#define RollbarCrashField_Backtrace             "backtrace"
#define RollbarCrashField_Code                  "code"
#define RollbarCrashField_CodeName              "code_name"
#define RollbarCrashField_CPPException          "cpp_exception"
#define RollbarCrashField_ExceptionName         "exception_name"
#define RollbarCrashField_Mach                  "mach"
#define RollbarCrashField_NSException           "nsexception"
#define RollbarCrashField_Reason                "reason"
#define RollbarCrashField_Signal                "signal"
#define RollbarCrashField_Subcode               "subcode"
#define RollbarCrashField_UserReported          "user_reported"


#pragma mark - Process State -

#define RollbarCrashField_LastDeallocedNSException "last_dealloced_nsexception"
#define RollbarCrashField_ProcessState             "process"


#pragma mark - App Stats -

#define RollbarCrashField_ActiveTimeSinceCrash  "active_time_since_last_crash"
#define RollbarCrashField_ActiveTimeSinceLaunch "active_time_since_launch"
#define RollbarCrashField_AppActive             "application_active"
#define RollbarCrashField_AppInFG               "application_in_foreground"
#define RollbarCrashField_BGTimeSinceCrash      "background_time_since_last_crash"
#define RollbarCrashField_BGTimeSinceLaunch     "background_time_since_launch"
#define RollbarCrashField_LaunchesSinceCrash    "launches_since_last_crash"
#define RollbarCrashField_SessionsSinceCrash    "sessions_since_last_crash"
#define RollbarCrashField_SessionsSinceLaunch   "sessions_since_launch"


#pragma mark - Report -

#define RollbarCrashField_Crash                 "crash"
#define RollbarCrashField_Debug                 "debug"
#define RollbarCrashField_Diagnosis             "diagnosis"
#define RollbarCrashField_ID                    "id"
#define RollbarCrashField_ProcessName           "process_name"
#define RollbarCrashField_Report                "report"
#define RollbarCrashField_Timestamp             "timestamp"
#define RollbarCrashField_Version               "version"

#pragma mark Minimal
#define RollbarCrashField_CrashedThread         "crashed_thread"

#pragma mark Standard
#define RollbarCrashField_AppStats              "application_stats"
#define RollbarCrashField_BinaryImages          "binary_images"
#define RollbarCrashField_System                "system"
#define RollbarCrashField_Memory                "memory"
#define RollbarCrashField_Threads               "threads"
#define RollbarCrashField_User                  "user"
#define RollbarCrashField_ConsoleLog            "console_log"

#pragma mark Incomplete
#define RollbarCrashField_Incomplete            "incomplete"
#define RollbarCrashField_RecrashReport         "recrash_report"

#pragma mark System
#define RollbarCrashField_AppStartTime          "app_start_time"
#define RollbarCrashField_AppUUID               "app_uuid"
#define RollbarCrashField_BootTime              "boot_time"
#define RollbarCrashField_BundleID              "CFBundleIdentifier"
#define RollbarCrashField_BundleName            "CFBundleName"
#define RollbarCrashField_BundleShortVersion    "CFBundleShortVersionString"
#define RollbarCrashField_BundleVersion         "CFBundleVersion"
#define RollbarCrashField_CPUArch               "cpu_arch"
#define RollbarCrashField_CPUType               "cpu_type"
#define RollbarCrashField_CPUSubType            "cpu_subtype"
#define RollbarCrashField_BinaryCPUType         "binary_cpu_type"
#define RollbarCrashField_BinaryCPUSubType      "binary_cpu_subtype"
#define RollbarCrashField_DeviceAppHash         "device_app_hash"
#define RollbarCrashField_Executable            "CFBundleExecutable"
#define RollbarCrashField_ExecutablePath        "CFBundleExecutablePath"
#define RollbarCrashField_Jailbroken            "jailbroken"
#define RollbarCrashField_KernelVersion         "kernel_version"
#define RollbarCrashField_Machine               "machine"
#define RollbarCrashField_Model                 "model"
#define RollbarCrashField_OSVersion             "os_version"
#define RollbarCrashField_ParentProcessID       "parent_process_id"
#define RollbarCrashField_ProcessID             "process_id"
#define RollbarCrashField_ProcessName           "process_name"
#define RollbarCrashField_Size                  "size"
#define RollbarCrashField_Storage               "storage"
#define RollbarCrashField_SystemName            "system_name"
#define RollbarCrashField_SystemVersion         "system_version"
#define RollbarCrashField_TimeZone              "time_zone"
#define RollbarCrashField_BuildType             "build_type"

#endif
