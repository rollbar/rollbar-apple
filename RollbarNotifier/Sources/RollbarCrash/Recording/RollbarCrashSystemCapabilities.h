//
//  RollbarCrashSystemCapabilities.h
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


#ifndef HDR_RollbarCrashSystemCapabilities_h
#define HDR_RollbarCrashSystemCapabilities_h

#ifdef __APPLE__
#include <TargetConditionals.h>
#define RollbarCrashCRASH_HOST_APPLE 1
#endif

#ifdef __ANDROID__
#define RollbarCrashCRASH_HOST_ANDROID 1
#endif

#define RollbarCrashCRASH_HOST_IOS (RollbarCrashCRASH_HOST_APPLE && TARGET_OS_IOS)
#define RollbarCrashCRASH_HOST_TV (RollbarCrashCRASH_HOST_APPLE && TARGET_OS_TV)
#define RollbarCrashCRASH_HOST_WATCH (RollbarCrashCRASH_HOST_APPLE && TARGET_OS_WATCH)
#define RollbarCrashCRASH_HOST_MAC (RollbarCrashCRASH_HOST_APPLE && TARGET_OS_MAC && !(TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH))

#if RollbarCrashCRASH_HOST_APPLE
#define RollbarCrashCRASH_CAN_GET_MAC_ADDRESS 1
#else
#define RollbarCrashCRASH_CAN_GET_MAC_ADDRESS 0
#endif

#if RollbarCrashCRASH_HOST_APPLE
#define RollbarCrashCRASH_HAS_OBJC 1
#define RollbarCrashCRASH_HAS_SWIFT 1
#else
#define RollbarCrashCRASH_HAS_OBJC 0
#define RollbarCrashCRASH_HAS_SWIFT 0
#endif

#if RollbarCrashCRASH_HOST_APPLE
#define RollbarCrashCRASH_HAS_KINFO_PROC 1
#else
#define RollbarCrashCRASH_HAS_KINFO_PROC 0
#endif

#if RollbarCrashCRASH_HOST_APPLE
#define RollbarCrashCRASH_HAS_STRNSTR 1
#else
#define RollbarCrashCRASH_HAS_STRNSTR 0
#endif

#if RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_TV || RollbarCrashCRASH_HOST_WATCH
#define RollbarCrashCRASH_HAS_UIKIT 1
#else
#define RollbarCrashCRASH_HAS_UIKIT 0
#endif

#if RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_UIAPPLICATION 1
#else
#define RollbarCrashCRASH_HAS_UIAPPLICATION 0
#endif

#if RollbarCrashCRASH_HOST_WATCH
#define RollbarCrashCRASH_HAS_NSEXTENSION 1
#else
#define RollbarCrashCRASH_HAS_NSEXTENSION 0
#endif

#if RollbarCrashCRASH_HOST_IOS
#define RollbarCrashCRASH_HAS_MESSAGEUI 1
#else
#define RollbarCrashCRASH_HAS_MESSAGEUI 0
#endif

#if RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_UIDEVICE 1
#else
#define RollbarCrashCRASH_HAS_UIDEVICE 0
#endif

#if RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_MAC || RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_ALERTVIEW 1
#else
#define RollbarCrashCRASH_HAS_ALERTVIEW 0
#endif

#if RollbarCrashCRASH_HOST_IOS
#define RollbarCrashCRASH_HAS_UIALERTVIEW 1
#else
#define RollbarCrashCRASH_HAS_UIALERTVIEW 0
#endif

#if RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_UIALERTCONTROLLER 1
#else
#define RollbarCrashCRASH_HAS_UIALERTCONTROLLER 0
#endif

#if RollbarCrashCRASH_HOST_MAC
#define RollbarCrashCRASH_HAS_NSALERT 1
#else
#define RollbarCrashCRASH_HAS_NSALERT 0
#endif

#if RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_MAC
#define RollbarCrashCRASH_HAS_MACH 1
#else
#define RollbarCrashCRASH_HAS_MACH 0
#endif

// WatchOS signal is broken as of 3.1
#if RollbarCrashCRASH_HOST_ANDROID || RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_MAC || RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_SIGNAL 1
#else
#define RollbarCrashCRASH_HAS_SIGNAL 0
#endif

#if RollbarCrashCRASH_HOST_ANDROID || RollbarCrashCRASH_HOST_MAC || RollbarCrashCRASH_HOST_IOS
#define RollbarCrashCRASH_HAS_SIGNAL_STACK 1
#else
#define RollbarCrashCRASH_HAS_SIGNAL_STACK 0
#endif

#if RollbarCrashCRASH_HOST_MAC || RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_THREADS_API 1
#else
#define RollbarCrashCRASH_HAS_THREADS_API 0
#endif

#if RollbarCrashCRASH_HOST_MAC || RollbarCrashCRASH_HOST_IOS || RollbarCrashCRASH_HOST_TV
#define RollbarCrashCRASH_HAS_REACHABILITY 1
#else
#define RollbarCrashCRASH_HAS_REACHABILITY 0
#endif

#endif // HDR_RollbarCrashSystemCapabilities_h
