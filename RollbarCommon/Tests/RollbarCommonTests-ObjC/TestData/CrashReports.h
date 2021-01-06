//
//  CrashReports.h
//  
//
//  Created by Andrey Kornich on 2021-01-04.
//

#ifndef CrashReports_h
#define CrashReports_h

static NSString * const CRASH_REPORT_PLCRASH_SYMBOLICATED =
@"Incident Identifier: BA7320A4-46FE-4BBB-A155-CBE0D26770E8\n\n\n\
Hardware Model:      MacBookPro15,2\n\n\n\
Process:         macosAppObjC [82683]\n\n\n\
Path:            /Users/andrey/Library/Developer/Xcode/DerivedData/RollbarSDK-bqhpftugdppqiqegefieglodlzsz/Build/Products/Debug/macosAppObjC.app/Contents/MacOS/macosAppObjC\n\n\n\
Identifier:      com.rollbar.macosAppObjC\n\
Version:         1.0 (1)\n\
Code Type:       X86-64\n\
Parent Process:  launchd [1]\n\
\n\
Date/Time:       2020-12-30 01:31:58 +0000\n\
OS Version:      Mac OS X 11.1 (20C69)\n\
Report Version:  104\n\
\n\
Exception Type:  SIGSEGV\n\
Exception Codes: SEGV_MAPERR at 0x1\n\
Crashed Thread:  0\n\
\n\
Thread 0 Crashed:\n\
0   macosAppObjC                        0x000000010eae70c8 crashIt + 8\n\
1   macosAppObjC                        0x000000010eae6f84 -[AppDelegate applicationDidFinishLaunching:] + 484\n\
2   CoreFoundation                      0x00007fff2044cfec __CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__ + 12\n\
3   CoreFoundation                      0x00007fff204e889b ___CFXRegistrationPost_block_invoke + 49\n\
4   CoreFoundation                      0x00007fff204e880f _CFXRegistrationPost + 454\n\
5   CoreFoundation                      0x00007fff2041dbde _CFXNotificationPost + 723\n\
6   Foundation                          0x00007fff2118cabe -[NSNotificationCenter postNotificationName:object:userInfo:] + 59\n\
7   AppKit                              0x00007fff22c7bf6d -[NSApplication _postDidFinishNotification] + 305\n\
8   AppKit                              0x00007fff22c7bcbb -[NSApplication _sendFinishLaunchingNotification] + 208\n\
9   AppKit                              0x00007fff22c78eb2 -[NSApplication(NSAppleEventHandling) _handleAEOpenEvent:] + 541\n\
10  AppKit                              0x00007fff22c78b07 -[NSApplication(NSAppleEventHandling) _handleCoreEvent:withReplyEvent:] + 665\n\
11  Foundation                          0x00007fff211b8056 -[NSAppleEventManager dispatchRawAppleEvent:withRawReply:handlerRefCon:] + 308\n\
12  Foundation                          0x00007fff211b7ec6 _NSAppleEventManagerGenericHandler + 80\n\
13  AE                                  0x00007fff26230ed9 _AppleEventsCheckInAppWithBlock + 15850\n\
14  AE                                  0x00007fff262305f4 _AppleEventsCheckInAppWithBlock + 13573\n\
15  AE                                  0x00007fff26229260 aeProcessAppleEvent + 452\n\
16  HIToolbox                           0x00007fff286ec612 AEProcessAppleEvent + 54\n\
17  AppKit                              0x00007fff22c73276 _DPSNextEvent + 2048\n\
18  AppKit                              0x00007fff22c715af -[NSApplication(NSEvent) _nextEventMatchingEventMask:untilDate:inMode:dequeue:] + 1366\n\
19  AppKit                              0x00007fff22c63b0a -[NSApplication run] + 586\n\
20  AppKit                              0x00007fff22c37df2 NSApplicationMain + 816\n\
21  macosAppObjC                        0x000000010eae6d8f main + 47\n\
22  libdyld.dylib                       0x00007fff2037a621 start + 1\n\
\n\
Thread 1:\n\
0   libsystem_kernel.dylib              0x00007fff2032c53e __workq_kernreturn + 10\n\
1   libsystem_pthread.dylib             0x00007fff2035b467 start_wqthread + 15\n\
\n\
Thread 2:\n\
0   libsystem_kernel.dylib              0x00007fff2032c53e __workq_kernreturn + 10\n\
1   libsystem_pthread.dylib             0x00007fff2035b467 start_wqthread + 15\n\
\n\
Thread 3:\n\
0   libsystem_kernel.dylib              0x00007fff2032c53e __workq_kernreturn + 10\n\
1   libsystem_pthread.dylib             0x00007fff2035b467 start_wqthread + 15\n\
\n\
Thread 4:\n\
0   libsystem_kernel.dylib              0x00007fff2032c53e __workq_kernreturn + 10\n\
1   libsystem_pthread.dylib             0x00007fff2035b467 start_wqthread + 15\n\
\n\
Thread 5:\n\
0   libsystem_kernel.dylib              0x00007fff2032c53e __workq_kernreturn + 10\n\
1   libsystem_pthread.dylib             0x00007fff2035b467 start_wqthread + 15\n\
\n\
Thread 6:\n\
0   libsystem_kernel.dylib              0x00007fff2032c53e __workq_kernreturn + 10\n\
1   libsystem_pthread.dylib             0x00007fff2035b467 start_wqthread + 15\n\
\n\
Thread 7:\n\
0   macosAppObjC                        0x000000010eb21f5c mach_exception_callback + 380\n\
1   macosAppObjC                        0x000000010eb15ede exception_server_thread + 766\n\
2   libsystem_pthread.dylib             0x00007fff2035f950 _pthread_start + 224\n\
3   libsystem_pthread.dylib             0x00007fff2035b47b thread_start + 15\n\
\n\
Thread 8:\n\
0   libsystem_kernel.dylib              0x00007fff2032b886 close + 10\n\
1   Foundation                          0x00007fff212034d9 __NSThreadPerformPerform + 204\n\
2   CoreFoundation                      0x00007fff20457a0c __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17\n\
3   CoreFoundation                      0x00007fff20457974 __CFRunLoopDoSource0 + 180\n\
4   CoreFoundation                      0x00007fff204576ef __CFRunLoopDoSources0 + 248\n\
5   CoreFoundation                      0x00007fff20456121 __CFRunLoopRun + 890\n\
6   CoreFoundation                      0x00007fff204556ce CFRunLoopRunSpecific + 563\n\
7   Foundation                          0x00007fff211e2fa1 -[NSRunLoop(NSRunLoop) runMode:beforeDate:] + 212\n\
8   macosAppObjC                        0x000000010ebd7337 -[RollbarThread run] + 407\n\
9   Foundation                          0x00007fff211dbe1d __NSThread__start__ + 1042\n\
10  libsystem_pthread.dylib             0x00007fff2035f950 _pthread_start + 224\n\
11  libsystem_pthread.dylib             0x00007fff2035b47b thread_start + 15\n\
\n\
Thread 9:\n\
0   libsystem_kernel.dylib              0x00007fff2032ae7e mach_msg_trap + 10\n\
1   CoreFoundation                      0x00007fff20457bf7 __CFRunLoopServiceMachPort + 316\n\
2   CoreFoundation                      0x00007fff204562ca __CFRunLoopRun + 1315\n\
3   CoreFoundation                      0x00007fff204556ce CFRunLoopRunSpecific + 563\n\
4   CFNetwork                           0x00007fff248d9132 _CFURLStorageSessionCopyCache + 34277\n\
5   Foundation                          0x00007fff211dbe1d __NSThread__start__ + 1042\n\
6   libsystem_pthread.dylib             0x00007fff2035f950 _pthread_start + 224\n\
7   libsystem_pthread.dylib             0x00007fff2035b47b thread_start + 15\n\
\n\
Thread 0 crashed with X86-64 Thread State:\n\
   rip: 0x000000010eae70c8    rbp: 0x00007ffee111c290    rsp: 0x00007ffee111c290    rax: 0x0000000000000000\n\
   rbx: 0x00007ffee111c3a8    rcx: 0x0000000000000000    rdx: 0x0000600001301f80    rdi: 0x000000010ebf94e8\n\
   rsi: 0x00007fff7c5a3c83     r8: 0x00000000000001ff     r9: 0x00000000000007fb    r10: 0x00007fff883deaa8\n\
   r11: 0x00007fff203f87b2    r12: 0x0000000000001400    r13: 0x0000600001d3e4f0    r14: 0x0000600001d1dfb0\n\
   r15: 0x0000000000000000 rflags: 0x0000000000010246     cs: 0x000000000000002b     fs: 0x0000000000000000\n\
    gs: 0x0000000000000000\n\
\n\
Binary Images:\n\
       0x10eae2000 -        0x10ebf5fff +macosAppObjC x86_64  <24b1dc026b4e3447a811dfc387566a6c> /Users/andrey/Library/Developer/Xcode/DerivedData/RollbarSDK-bqhpftugdppqiqegefieglodlzsz/Build/Products/Debug/macosAppObjC.app/Contents/MacOS/macosAppObjC\n\
       0x111dd0000 -        0x111ddffff  libobjc-trampolines.dylib x86_64  <12b587a286313b7ab8625091c411ac2c> /usr/lib/libobjc-trampolines.dylib\n\
    0x7fff20095000 -     0x7fff20096fff  libsystem_blocks.dylib x86_64  <9cf131c616fb3dd0b0469e0b6ab99935> /usr/lib/system/libsystem_blocks.dylib\n\
    0x7fff20097000 -     0x7fff200ccfff  libxpc.dylib x86_64  <003a027d9ce33794a31988495844662d> /usr/lib/system/libxpc.dylib\n\
    0x7fff200cd000 -     0x7fff200e4fff  libsystem_trace.dylib x86_64  <48c14376626e3c81b0f57416e64580c7> /usr/lib/system/libsystem_trace.dylib\n\
    0x7fff200e5000 -     0x7fff20183fff  libcorecrypto.dylib x86_64  <92f0211e506e3760a3c2808bf3905c07> /usr/lib/system/libcorecrypto.dylib\n\
    0x7fff20184000 -     0x7fff201b0fff  libsystem_malloc.dylib x86_64  <2ef43b9690fb3c50b73e035238504e33> /usr/lib/system/libsystem_malloc.dylib\n\
    0x7fff201b1000 -     0x7fff201f5fff  libdispatch.dylib x86_64  <cef1460b1362381aae696bce2d8c215b> /usr/lib/system/libdispatch.dylib\n\
    0x7fff201f6000 -     0x7fff2022efff  libobjc.A.dylib x86_64  <45ea2de2b6123486b1562359ce279159> /usr/lib/libobjc.A.dylib\n\
    0x7fff2022f000 -     0x7fff20231fff  libsystem_featureflags.dylib x86_64  <7b4ebddb244e3f788895566fe22288f3> /usr/lib/system/libsystem_featureflags.dylib\n\
    0x7fff20232000 -     0x7fff202bafff  libsystem_c.dylib x86_64  <06d9f593c815385d957f2b5bcc223a8a> /usr/lib/system/libsystem_c.dylib\n\
    0x7fff202bb000 -     0x7fff20310fff  libc++.1.dylib x86_64  <ae3a940a7a9c3f99b1753511528d8dfe> /usr/lib/libc++.1.dylib\n\
    0x7fff20311000 -     0x7fff20329fff  libc++abi.dylib x86_64  <ddfcbf9c432d3b8a8641578d2eddcad8> /usr/lib/libc++abi.dylib\n\
    0x7fff2032a000 -     0x7fff20358fff  libsystem_kernel.dylib x86_64  <4bd6136529af32348002d989d295fdbb> /usr/lib/system/libsystem_kernel.dylib\n\
    0x7fff20359000 -     0x7fff20364fff  libsystem_pthread.dylib x86_64  <8dd3a0bc2c9231e3bbabce923a4342e4> /usr/lib/system/libsystem_pthread.dylib\n\
    0x7fff20365000 -     0x7fff2039ffff  libdyld.dylib x86_64  <2f8a14f57cb83edd85ea7fa960bbc04e> /usr/lib/system/libdyld.dylib\n\
    0x7fff203a0000 -     0x7fff203a9fff  libsystem_platform.dylib x86_64  <3f7f64617b5c3197acd7c8a0cfcc6f55> /usr/lib/system/libsystem_platform.dylib\n\
    0x7fff203aa000 -     0x7fff203d5fff  libsystem_info.dylib x86_64  <0979757c5f0d3f5a9e0eebf234b310af> /usr/lib/system/libsystem_info.dylib\n\
    0x7fff203d6000 -     0x7fff20871fff  CoreFoundation x86_64  <eac298c4ce3e3551a83242ed9a13ef74> /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation\n\
    0x7fff20872000 -     0x7fff20aa1fff  LaunchServices x86_64  <caeec25468ae39b58452ec3e1ee8577b> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/LaunchServices\n\
    0x7fff20aa2000 -     0x7fff20b75fff  MetalTools x86_64  <c235d5fa0b9d3e72a8ce67174e1b9e7c> /System/Library/PrivateFrameworks/MetalTools.framework/Versions/A/MetalTools\n\
    0x7fff20b76000 -     0x7fff20dd9fff  libBLAS.dylib x86_64  <ad2d155c12943d10817af6a581e6acf1> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib\n\
    0x7fff20dda000 -     0x7fff20e27fff  Lexicon x86_64  <d54364a61c4c33d78b24c753777b3654> /System/Library/PrivateFrameworks/Lexicon.framework/Versions/A/Lexicon\n\
    0x7fff20e28000 -     0x7fff20e96fff  libSparse.dylib x86_64  <605592266e4b3601b6cae3b85b5eb27b> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libSparse.dylib\n\
    0x7fff20e97000 -     0x7fff20f14fff  SystemConfiguration x86_64  <8524ee4c628f315a953144dd83ce275e> /System/Library/Frameworks/SystemConfiguration.framework/Versions/A/SystemConfiguration\n\
    0x7fff20f15000 -     0x7fff20f4afff  libCRFSuite.dylib x86_64  <6ca29eaa058536829ad2dfd3d87a74d4> /usr/lib/libCRFSuite.dylib\n\
    0x7fff20f4b000 -     0x7fff21182fff  libmecabra.dylib x86_64  <39f5ad503af23cfbbd212dc45aa92a91> /usr/lib/libmecabra.dylib\n\
    0x7fff21183000 -     0x7fff214e6fff  Foundation x86_64  <44a7115b7ff03300b61b0fa71b63c715> /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation\n\
    0x7fff214e7000 -     0x7fff215d3fff  LanguageModeling x86_64  <bcb1f8a754b936d1b74270df7657bf0b> /System/Library/PrivateFrameworks/LanguageModeling.framework/Versions/A/LanguageModeling\n\
    0x7fff215d4000 -     0x7fff2170afff  CoreDisplay x86_64  <229bf97a1d563cb48338e0d464f73a33> /System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay\n\
    0x7fff2170b000 -     0x7fff21980fff  AudioToolboxCore x86_64  <5682180207b93fa9af73d943bae0de57> /System/Library/PrivateFrameworks/AudioToolboxCore.framework/Versions/A/AudioToolboxCore\n\
    0x7fff21981000 -     0x7fff21b69fff  CoreText x86_64  <b0b2a8dda6f13ef793511ba604353a11> /System/Library/Frameworks/CoreText.framework/Versions/A/CoreText\n\
    0x7fff21b6a000 -     0x7fff2220dfff  CoreAudio x86_64  <df623ec9fc553b3c94ff6a5c50a981b3> /System/Library/Frameworks/CoreAudio.framework/Versions/A/CoreAudio\n\
    0x7fff2220e000 -     0x7fff2255ffff  Security x86_64  <a20ab68d51da340bb813f2afc81f7143> /System/Library/Frameworks/Security.framework/Versions/A/Security\n\
    0x7fff22560000 -     0x7fff227c1fff  libicucore.A.dylib x86_64  <6c0a01962778303581ce7ca48d6c0628> /usr/lib/libicucore.A.dylib\n\
    0x7fff227c2000 -     0x7fff227cbfff  libsystem_darwin.dylib x86_64  <bd269412c9d032eeb42bb09a187a9b95> /usr/lib/system/libsystem_darwin.dylib\n\
    0x7fff227cc000 -     0x7fff22ab3fff  CarbonCore x86_64  <9c6159676d8e307fb0286278a4fa7c8c> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/CarbonCore\n\
    0x7fff22ab4000 -     0x7fff22af2fff  CoreServicesInternal x86_64  <fd1692f7a4b43fe5b9c8e0840d53c7d0> /System/Library/PrivateFrameworks/CoreServicesInternal.framework/Versions/A/CoreServicesInternal\n\
    0x7fff22af3000 -     0x7fff22b2dfff  CoreServicesStore x86_64  <088d0108aa14361086a089d0c605384f> /System/Library/PrivateFrameworks/CoreServicesStore.framework/Versions/A/CoreServicesStore\n\
    0x7fff22b2e000 -     0x7fff22bdbfff  IOKit x86_64  <f22996825884363f9069aa804e712c74> /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit\n\
    0x7fff22bdc000 -     0x7fff22be7fff  libsystem_notify.dylib x86_64  <98d74eef60d93665b8777be1558ba83e> /usr/lib/system/libsystem_notify.dylib\n\
    0x7fff22be8000 -     0x7fff22c33fff  libsandbox.1.dylib x86_64  <243c983d0aef3a099489cf1fc75925cc> /usr/lib/libsandbox.1.dylib\n\
    0x7fff22c34000 -     0x7fff23996fff  AppKit x86_64  <4cb42914672d3af0a0a52209088a3da0> /System/Library/Frameworks/AppKit.framework/Versions/C/AppKit\n\
    0x7fff23997000 -     0x7fff23beafff  UIFoundation x86_64  <71c63ce5094d34afb5388dcab3b66de9> /System/Library/PrivateFrameworks/UIFoundation.framework/Versions/A/UIFoundation\n\
    0x7fff23beb000 -     0x7fff23bfdfff  UniformTypeIdentifiers x86_64  <7bec7ddc2b7a3b5db9945fa352fc485a> /System/Library/Frameworks/UniformTypeIdentifiers.framework/Versions/A/UniformTypeIdentifiers\n\
    0x7fff23bfe000 -     0x7fff23d88fff  DesktopServicesPriv x86_64  <732c8a0ce7f8372dae5b84497067135e> /System/Library/PrivateFrameworks/DesktopServicesPriv.framework/Versions/A/DesktopServicesPriv\n\
    0x7fff23d9c000 -     0x7fff23f99fff  CoreDuet x86_64  <a8010564458f310da1650ca0c734cbbf> /System/Library/PrivateFrameworks/CoreDuet.framework/Versions/A/CoreDuet\n\
    0x7fff23f9a000 -     0x7fff24054fff  libboringssl.dylib x86_64  <bd80c2ffc8de3905ab6f311fe9f888f3> /usr/lib/libboringssl.dylib\n\
    0x7fff24055000 -     0x7fff24698fff  libnetwork.dylib x86_64  <180fe9168dd63385b2310c423b7d2bd3> /usr/lib/libnetwork.dylib\n\
    0x7fff24699000 -     0x7fff24b36fff  CFNetwork x86_64  <60de4cd6b5af3e0e8af139ecfc1b8c98> /System/Library/Frameworks/CFNetwork.framework/Versions/A/CFNetwork\n\
    0x7fff24b37000 -     0x7fff24b45fff  libsystem_networkextension.dylib x86_64  <f476b1cb356130c5a78e44e99b1720a3> /usr/lib/system/libsystem_networkextension.dylib\n\
    0x7fff24b46000 -     0x7fff24b46fff  libenergytrace.dylib x86_64  <9be5e51af5313d59bbbc486fff97bd30> /usr/lib/libenergytrace.dylib\n\
    0x7fff24b47000 -     0x7fff24ba2fff  libMobileGestalt.dylib x86_64  <f721b1850e6a396ba50f0f55810d9a67> /usr/lib/libMobileGestalt.dylib\n\
    0x7fff24ba3000 -     0x7fff24bb9fff  libsystem_asl.dylib x86_64  <940c5bb949283a6397f2132797c8b7e5> /usr/lib/system/libsystem_asl.dylib\n\
    0x7fff24bba000 -     0x7fff24bd1fff  TCC x86_64  <457d5f24a34638fc8fa143b0c835e035> /System/Library/PrivateFrameworks/TCC.framework/Versions/A/TCC\n\
    0x7fff24bd2000 -     0x7fff24f37fff  SkyLight x86_64  <3587638445f93c62995b38ec31be75d7> /System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight\n\
    0x7fff24f38000 -     0x7fff255cbfff  CoreGraphics x86_64  <323f725fcb033aadafbc37b430b3fd4e> /System/Library/Frameworks/CoreGraphics.framework/Versions/A/CoreGraphics\n\
    0x7fff255cc000 -     0x7fff256c2fff  ColorSync x86_64  <7387ebc7cbd934feb4a3345e4750fd81> /System/Library/Frameworks/ColorSync.framework/Versions/A/ColorSync\n\
    0x7fff256c3000 -     0x7fff2571efff  HIServices x86_64  <9af2cdd98b6836068c9e1842420acda7> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/HIServices\n\
    0x7fff25811000 -     0x7fff259d5fff  Montreal x86_64  <63ce03638ddc3d97a0637840b02f3f58> /System/Library/PrivateFrameworks/Montreal.framework/Versions/A/Montreal\n\
    0x7fff25aca000 -     0x7fff25ee8fff  CoreData x86_64  <76179a55ca893967a0a7c419db735983> /System/Library/Frameworks/CoreData.framework/Versions/A/CoreData\n\
    0x7fff25ee9000 -     0x7fff25efffff  ProtocolBuffer x86_64  <8ee538e72bb13e298fc3938335998b22> /System/Library/PrivateFrameworks/ProtocolBuffer.framework/Versions/A/ProtocolBuffer\n\
    0x7fff25f00000 -     0x7fff260bffff  libsqlite3.dylib x86_64  <d70174298d463ecb8b704625c74918f3> /usr/lib/libsqlite3.dylib\n\
    0x7fff260c0000 -     0x7fff2613cfff  Accounts x86_64  <99421243019f3a2fa671092026fa2f74> /System/Library/Frameworks/Accounts.framework/Versions/A/Accounts\n\
    0x7fff2613d000 -     0x7fff26155fff  CommonUtilities x86_64  <76711775ff4638ca88f3b4201c285c7f> /System/Library/PrivateFrameworks/CommonUtilities.framework/Versions/A/CommonUtilities\n\
    0x7fff26156000 -     0x7fff261d7fff  BaseBoard x86_64  <38c24b3a82263fd58c28b11d02747b56> /System/Library/PrivateFrameworks/BaseBoard.framework/Versions/A/BaseBoard\n\
    0x7fff261d8000 -     0x7fff26223fff  RunningBoardServices x86_64  <f99a0d0cd0633e3f8d1f0e0b35e7ce2c> /System/Library/PrivateFrameworks/RunningBoardServices.framework/Versions/A/RunningBoardServices\n\
    0x7fff26224000 -     0x7fff26299fff  AE x86_64  <3a298716a130345eb8ff74194849015e> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/AE.framework/Versions/A/AE\n\
    0x7fff2629a000 -     0x7fff262a0fff  libdns_services.dylib x86_64  <61eb26adc09e3140955e16bf7dd2d6e3> /usr/lib/libdns_services.dylib\n\
    0x7fff262a1000 -     0x7fff262a8fff  libsystem_symptoms.dylib x86_64  <88f35aac746f317681df49ce3d285636> /usr/lib/system/libsystem_symptoms.dylib\n\
    0x7fff262a9000 -     0x7fff2642dfff  Network x86_64  <eed4099eb17c3e0baa8f78a2d4f26cbf> /System/Library/Frameworks/Network.framework/Versions/A/Network\n\
    0x7fff2642e000 -     0x7fff26452fff  CoreAnalytics x86_64  <99fe0234454f36ff9de936b94d8753f9> /System/Library/PrivateFrameworks/CoreAnalytics.framework/Versions/A/CoreAnalytics\n\
    0x7fff26453000 -     0x7fff26455fff  libDiagnosticMessagesClient.dylib x86_64  <1014a32b89ee3add971f9cb973172f69> /usr/lib/libDiagnosticMessagesClient.dylib\n\
    0x7fff26456000 -     0x7fff264a2fff  MetadataUtilities x86_64  <37a1e7602006366c9facfb70227393fb> /System/Library/PrivateFrameworks/MetadataUtilities.framework/Versions/A/MetadataUtilities\n\
    0x7fff264a3000 -     0x7fff2653dfff  Metadata x86_64  <509c6597abb23b818e09c51a755ccda2> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Metadata\n\
    0x7fff2653e000 -     0x7fff26544fff  DiskArbitration x86_64  <83ded679be6534758affd664bbafa60a> /System/Library/Frameworks/DiskArbitration.framework/Versions/A/DiskArbitration\n\
    0x7fff26545000 -     0x7fff26bebfff  vImage x86_64  <305d97ccb47c32fd9ec543259a469a14> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vImage.framework/Versions/A/vImage\n\
    0x7fff26bec000 -     0x7fff26eb9fff  QuartzCore x86_64  <d59138dc10cd3df89f04ccdb6102c370> /System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore\n\
    0x7fff26eba000 -     0x7fff26efbfff  libFontRegistry.dylib x86_64  <790676a32b743239a60d429069933542> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/A/Resources/libFontRegistry.dylib\n\
    0x7fff26efc000 -     0x7fff2703dfff  CoreUI x86_64  <0da8f4e09473374e8b48f0a40aec63ce> /System/Library/PrivateFrameworks/CoreUI.framework/Versions/A/CoreUI\n\
    0x7fff2703e000 -     0x7fff27129fff  ViewBridge x86_64  <36d0dca7caae33c190f698876cb8bcf3> /System/Library/PrivateFrameworks/ViewBridge.framework/Versions/A/ViewBridge\n\
    0x7fff2712a000 -     0x7fff27135fff  PerformanceAnalysis x86_64  <2f811ee6d4d4347eb4a0961f0df050e5> /System/Library/PrivateFrameworks/PerformanceAnalysis.framework/Versions/A/PerformanceAnalysis\n\
    0x7fff27136000 -     0x7fff27145fff  OpenDirectory x86_64  <7710743e6f55342e88fa18796cf83700> /System/Library/Frameworks/OpenDirectory.framework/Versions/A/OpenDirectory\n\
    0x7fff27146000 -     0x7fff27165fff  CFOpenDirectory x86_64  <32eccb0656d83704935b7d5363b2988e> /System/Library/Frameworks/OpenDirectory.framework/Versions/A/Frameworks/CFOpenDirectory.framework/Versions/A/CFOpenDirectory\n\
    0x7fff27166000 -     0x7fff2716efff  FSEvents x86_64  <fb18b8d7c7f53cabb5383f4b4e85d1f1> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/FSEvents.framework/Versions/A/FSEvents\n\
    0x7fff2716f000 -     0x7fff27193fff  SharedFileList x86_64  <93d2192d7a273fd4b3aba4dcbf8419b7> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/SharedFileList.framework/Versions/A/SharedFileList\n\
    0x7fff27194000 -     0x7fff27196fff  libapp_launch_measurement.dylib x86_64  <9e2700c3e9933695988efef798b75e34> /usr/lib/libapp_launch_measurement.dylib\n\
    0x7fff27197000 -     0x7fff271dffff  CoreAutoLayout x86_64  <998bc461f4f5396e97981c8126ad61da> /System/Library/PrivateFrameworks/CoreAutoLayout.framework/Versions/A/CoreAutoLayout\n\
    0x7fff271e0000 -     0x7fff272c2fff  libxml2.2.dylib x86_64  <683961818100390c8886efb79f5b484c> /usr/lib/libxml2.2.dylib\n\
    0x7fff272c3000 -     0x7fff2730ffff  CoreVideo x86_64  <0d5ad16ea8713acbb91039b87928e937> /System/Library/Frameworks/CoreVideo.framework/Versions/A/CoreVideo\n\
    0x7fff27310000 -     0x7fff27312fff  loginsupport x86_64  <4f860927f6f53a99a103744cf365634f> /System/Library/PrivateFrameworks/login.framework/Versions/A/Frameworks/loginsupport.framework/Versions/A/loginsupport\n\
    0x7fff27313000 -     0x7fff2733bfff  ApplePushService x86_64  <f8faeb30afcf36a19e7225681e6c5bf7> /System/Library/PrivateFrameworks/ApplePushService.framework/Versions/A/ApplePushService\n\
    0x7fff2733c000 -     0x7fff27359fff  UserManagement x86_64  <b5ceaa264c5f3af4bdfe35de7c8de1be> /System/Library/PrivateFrameworks/UserManagement.framework/Versions/A/UserManagement\n\
    0x7fff2735a000 -     0x7fff274f9fff  CloudKit x86_64  <2d82071d495c3e80bf3ccb181fecb500> /System/Library/Frameworks/CloudKit.framework/Versions/A/CloudKit\n\
    0x7fff2757d000 -     0x7fff27922fff  CoreML x86_64  <5d76fa8e93353ed8b301e0313128307e> /System/Library/Frameworks/CoreML.framework/Versions/A/CoreML\n\
    0x7fff28276000 -     0x7fff282f2fff  CoreLocation x86_64  <f4c3d15dbefe37a9a55f2bfb16842fbe> /System/Library/Frameworks/CoreLocation.framework/Versions/A/CoreLocation\n\
    0x7fff282f3000 -     0x7fff28303fff  libsystem_containermanager.dylib x86_64  <4ed09a1904cc34649efbf674932020b5> /usr/lib/system/libsystem_containermanager.dylib\n\
    0x7fff28304000 -     0x7fff28315fff  IOSurface x86_64  <a3b10665590930eebe34f3284d6d5975> /System/Library/Frameworks/IOSurface.framework/Versions/A/IOSurface\n\
    0x7fff28316000 -     0x7fff2831efff  IOAccelerator x86_64  <3944c92d78383d2fa4539db15c815d7b> /System/Library/PrivateFrameworks/IOAccelerator.framework/Versions/A/IOAccelerator\n\
    0x7fff2831f000 -     0x7fff28444fff  Metal x86_64  <413b81ae653f3cf7b5a4a4391436e6d1> /System/Library/Frameworks/Metal.framework/Versions/A/Metal\n\
    0x7fff28445000 -     0x7fff28461fff  caulk x86_64  <952ba9d4bad333198c17f7bb2655f80c> /System/Library/PrivateFrameworks/caulk.framework/Versions/A/caulk\n\
    0x7fff28462000 -     0x7fff2854bfff  CoreMedia x86_64  <cbcd783bb3c937b8835ca3bacec35bb5> /System/Library/Frameworks/CoreMedia.framework/Versions/A/CoreMedia\n\
    0x7fff2854c000 -     0x7fff286a8fff  libFontParser.dylib x86_64  <76c6c92a1b163fb79ea27227d379c20f> /System/Library/PrivateFrameworks/FontServices.framework/libFontParser.dylib\n\
    0x7fff286a9000 -     0x7fff289a8fff  HIToolbox x86_64  <93518490429f3e31834415d479c2f4ce> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/HIToolbox\n\
    0x7fff289a9000 -     0x7fff289bcfff  DFRFoundation x86_64  <fb85651d622138afbd6d29bff5830d36> /System/Library/PrivateFrameworks/DFRFoundation.framework/Versions/A/DFRFoundation\n\
    0x7fff289bd000 -     0x7fff289c0fff  XCTTargetBootstrap x86_64  <13add312f6f53c03bd3b9331b3851285> /System/Library/PrivateFrameworks/XCTTargetBootstrap.framework/Versions/A/XCTTargetBootstrap\n\
    0x7fff289c1000 -     0x7fff289eafff  CoreSVG x86_64  <a0dae6ae9dda37b4a087545a242cf982> /System/Library/PrivateFrameworks/CoreSVG.framework/Versions/A/CoreSVG\n\
    0x7fff289eb000 -     0x7fff28c24fff  ImageIO x86_64  <0fe3d51bec763558bd567bff61a6793d> /System/Library/Frameworks/ImageIO.framework/Versions/A/ImageIO\n\
    0x7fff28c25000 -     0x7fff28fa2fff  CoreImage x86_64  <46f1e4f5df8f32d48d0c6fcf2c27a5cd> /System/Library/Frameworks/CoreImage.framework/Versions/A/CoreImage\n\
    0x7fff28fa3000 -     0x7fff28ffefff  MPSCore x86_64  <e237727553d731a0aeaf0a0273b99b92> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/Frameworks/MPSCore.framework/Versions/A/MPSCore\n\
    0x7fff28fff000 -     0x7fff29002fff  libsystem_configuration.dylib x86_64  <c57b346b0a033f87bcac87b702fa0719> /usr/lib/system/libsystem_configuration.dylib\n\
    0x7fff29003000 -     0x7fff29007fff  libsystem_sandbox.dylib x86_64  <8ce27199d63331d2ab0856380a1da9fb> /usr/lib/system/libsystem_sandbox.dylib\n\
    0x7fff29008000 -     0x7fff29009fff  AggregateDictionary x86_64  <7f2afebbff063194b691b411f3456962> /System/Library/PrivateFrameworks/AggregateDictionary.framework/Versions/A/AggregateDictionary\n\
    0x7fff2900a000 -     0x7fff2900dfff  AppleSystemInfo x86_64  <250cd2cae7963cb09add054998903b1d> /System/Library/PrivateFrameworks/AppleSystemInfo.framework/Versions/A/AppleSystemInfo\n\
    0x7fff2900e000 -     0x7fff2900ffff  liblangid.dylib x86_64  <224dc0452b6039afb89ee524175667f5> /usr/lib/liblangid.dylib\n\
    0x7fff29010000 -     0x7fff290b0fff  CoreNLP x86_64  <f876fd71f0773cf7b94d9e05a17e03d7> /System/Library/PrivateFrameworks/CoreNLP.framework/Versions/A/CoreNLP\n\
    0x7fff290b1000 -     0x7fff290b7fff  LinguisticData x86_64  <d1b7f1d5eb9e3555ba573611fa153c44> /System/Library/PrivateFrameworks/LinguisticData.framework/Versions/A/LinguisticData\n\
    0x7fff290b8000 -     0x7fff29774fff  libBNNS.dylib x86_64  <e3ff47d57dd93a9ea819c79b0cc17c03> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBNNS.dylib\n\
    0x7fff29775000 -     0x7fff29948fff  libvDSP.dylib x86_64  <9434101de001357f95039896c6011f52> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libvDSP.dylib\n\
    0x7fff29949000 -     0x7fff2995bfff  CoreEmoji x86_64  <7ccfc59a87463e52af1d1b67798e940c> /System/Library/PrivateFrameworks/CoreEmoji.framework/Versions/A/CoreEmoji\n\
    0x7fff2995c000 -     0x7fff29966fff  IOMobileFramebuffer x86_64  <9a6f913cec793fc1a92c3a1ba96d8dfb> /System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/Versions/A/IOMobileFramebuffer\n\
    0x7fff29967000 -     0x7fff29a39fff  CoreWLAN x86_64  <ab3f880b52c5300682fe9e6857c09de7> /System/Library/Frameworks/CoreWLAN.framework/Versions/A/CoreWLAN\n\
    0x7fff29a3a000 -     0x7fff29c39fff  CoreUtils x86_64  <198a42735b923a05a99d7fd4914a959a> /System/Library/PrivateFrameworks/CoreUtils.framework/Versions/A/CoreUtils\n\
    0x7fff29c3a000 -     0x7fff29c5cfff  MobileKeyBag x86_64  <2b6bf51a68b0310895978b618e6b457b> /System/Library/PrivateFrameworks/MobileKeyBag.framework/Versions/A/MobileKeyBag\n\
    0x7fff29c5d000 -     0x7fff29c6dfff  AssertionServices x86_64  <9f8620bda58d3a429b9edec21517ef1a> /System/Library/PrivateFrameworks/AssertionServices.framework/Versions/A/AssertionServices\n\
    0x7fff29c6e000 -     0x7fff29cfafff  SecurityFoundation x86_64  <5f06d14162f43405ba7224673b170a16> /System/Library/Frameworks/SecurityFoundation.framework/Versions/A/SecurityFoundation\n\
    0x7fff29cfb000 -     0x7fff29d04fff  BackgroundTaskManagement x86_64  <c5e4b35cffda3423890f06dad1f684f5> /System/Library/PrivateFrameworks/BackgroundTaskManagement.framework/Versions/A/BackgroundTaskManagement\n\
    0x7fff29d05000 -     0x7fff29d09fff  ServiceManagement x86_64  <2c03beb7915c3a3aa44fa77775e1bfd5> /System/Library/Frameworks/ServiceManagement.framework/Versions/A/ServiceManagement\n\
    0x7fff29d0a000 -     0x7fff29d0cfff  libquarantine.dylib x86_64  <19d42b9d33363543af756e605ea31599> /usr/lib/system/libquarantine.dylib\n\
    0x7fff29d0d000 -     0x7fff29d18fff  libCheckFix.dylib x86_64  <3381fc93f188348c93455567a7116cef> /usr/lib/libCheckFix.dylib\n\
    0x7fff29d19000 -     0x7fff29d30fff  libcoretls.dylib x86_64  <9c2440296b453583b27fbb7bbf84d814> /usr/lib/libcoretls.dylib\n\
    0x7fff29d31000 -     0x7fff29d41fff  libbsm.0.dylib x86_64  <dc652d50fa6938019361004d4d6832d0> /usr/lib/libbsm.0.dylib\n\
    0x7fff29d42000 -     0x7fff29d8bfff  libmecab.dylib x86_64  <b5d8c96cd3b832f884f9a432cead4e5c> /usr/lib/libmecab.dylib\n\
    0x7fff29d8c000 -     0x7fff29d91fff  libgermantok.dylib x86_64  <f9772a767afa3e0ba02ca61fc6ca8d8b> /usr/lib/libgermantok.dylib\n\
    0x7fff29d92000 -     0x7fff29da7fff  libLinearAlgebra.dylib x86_64  <d2826fab174c3cd6a76506d83a9a0edb> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libLinearAlgebra.dylib\n\
    0x7fff29da8000 -     0x7fff29fcffff  MPSNeuralNetwork x86_64  <231cf580952a32bca4239b9756ac9744> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/Frameworks/MPSNeuralNetwork.framework/Versions/A/MPSNeuralNetwork\n\
    0x7fff29fd0000 -     0x7fff2a01ffff  MPSRayIntersector x86_64  <65a993e43dc2315298d5a1df3db4573f> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/Frameworks/MPSRayIntersector.framework/Versions/A/MPSRayIntersector\n\
    0x7fff2a020000 -     0x7fff2a166fff  MLCompute x86_64  <bcea1149197e398f9424e29b0ad0829f> /System/Library/Frameworks/MLCompute.framework/Versions/A/MLCompute\n\
    0x7fff2a167000 -     0x7fff2a19dfff  MPSMatrix x86_64  <f719da57eaaa3527b85921025722932f> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/Frameworks/MPSMatrix.framework/Versions/A/MPSMatrix\n\
    0x7fff2a19e000 -     0x7fff2a1dbfff  MPSNDArray x86_64  <fccc0d3f74d2310782b3e2b500e36aae> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/Frameworks/MPSNDArray.framework/Versions/A/MPSNDArray\n\
    0x7fff2a1dc000 -     0x7fff2a26cfff  MPSImage x86_64  <21527a172d6f3bdf9a74f90fa6e26bb3> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/Frameworks/MPSImage.framework/Versions/A/MPSImage\n\
    0x7fff2a26d000 -     0x7fff2a27cfff  AppleFSCompression x86_64  <d1e7dc71192930a8b73e268387110608> /System/Library/PrivateFrameworks/AppleFSCompression.framework/Versions/A/AppleFSCompression\n\
    0x7fff2a27d000 -     0x7fff2a28afff  libbz2.1.0.dylib x86_64  <0575c0d0b1073e53857fdec55998197b> /usr/lib/libbz2.1.0.dylib\n\
    0x7fff2a28b000 -     0x7fff2a28ffff  libsystem_coreservices.dylib x86_64  <a2d875b98ba833adbe92adab915a8d5b> /usr/lib/system/libsystem_coreservices.dylib\n\
    0x7fff2a290000 -     0x7fff2a2bdfff  OSServices x86_64  <870f34bec0ed318b858d5f1e4757d552> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/OSServices.framework/Versions/A/OSServices\n\
    0x7fff2a2be000 -     0x7fff2a3effff  AuthKit x86_64  <8239c23554de39f398dc920af2be6187> /System/Library/PrivateFrameworks/AuthKit.framework/Versions/A/AuthKit\n\
    0x7fff2a493000 -     0x7fff2a4a5fff  libz.1.dylib x86_64  <9f89fd6003f73175ab345112b99e2b8a> /usr/lib/libz.1.dylib\n\
    0x7fff2a4a6000 -     0x7fff2a4edfff  libsystem_m.dylib x86_64  <79820d9e0ff13f20af4ff87ee20ce8c9> /usr/lib/system/libsystem_m.dylib\n\
    0x7fff2a4ee000 -     0x7fff2a4eefff  libcharset.1.dylib x86_64  <414f6a1c1ebc3956ac2dccb0458f31af> /usr/lib/libcharset.1.dylib\n\
    0x7fff2a4ef000 -     0x7fff2a4f4fff  libmacho.dylib x86_64  <28ae164922ed3c4da23229d37f821c39> /usr/lib/system/libmacho.dylib\n\
    0x7fff2a4f5000 -     0x7fff2a510fff  libkxld.dylib x86_64  <3600a314332a343db45dd9d8b302545d> /usr/lib/system/libkxld.dylib\n\
    0x7fff2a511000 -     0x7fff2a51cfff  libcommonCrypto.dylib x86_64  <1d0a75a5dec539c6ab3de789b8866712> /usr/lib/system/libcommonCrypto.dylib\n\
    0x7fff2a51d000 -     0x7fff2a527fff  libunwind.dylib x86_64  <c5792a9cdf0f3821bc14238a78462e8a> /usr/lib/system/libunwind.dylib\n\
    0x7fff2a528000 -     0x7fff2a52ffff  liboah.dylib x86_64  <ff72e19b3b0234d4a8213397bb28ac02> /usr/lib/liboah.dylib\n\
    0x7fff2a530000 -     0x7fff2a53afff  libcopyfile.dylib x86_64  <89483cd4da463af2ae78fc37ced05acc> /usr/lib/system/libcopyfile.dylib\n\
    0x7fff2a53b000 -     0x7fff2a542fff  libcompiler_rt.dylib x86_64  <0db26ec8b4cd3268b865c2fc07e4d2aa> /usr/lib/system/libcompiler_rt.dylib\n\
    0x7fff2a543000 -     0x7fff2a545fff  libsystem_collections.dylib x86_64  <d40d80970abf3645b065168f43acff4c> /usr/lib/system/libsystem_collections.dylib\n\
    0x7fff2a546000 -     0x7fff2a548fff  libsystem_secinit.dylib x86_64  <99b5fd991a8b37c1bd7004990fa33b1c> /usr/lib/system/libsystem_secinit.dylib\n\
    0x7fff2a549000 -     0x7fff2a54bfff  libremovefile.dylib x86_64  <750012c2709733c3b7962766e6cde8c1> /usr/lib/system/libremovefile.dylib\n\
    0x7fff2a54c000 -     0x7fff2a54cfff  libkeymgr.dylib x86_64  <2c7b58b0be543a50b399aa49c19083a9> /usr/lib/system/libkeymgr.dylib\n\
    0x7fff2a54d000 -     0x7fff2a554fff  libsystem_dnssd.dylib x86_64  <81efc44d450e3aa3ac8fd7ef68f464b4> /usr/lib/system/libsystem_dnssd.dylib\n\
    0x7fff2a555000 -     0x7fff2a55afff  libcache.dylib x86_64  <2f7f7303db23359e85cd8b2f93223e2a> /usr/lib/system/libcache.dylib\n\
    0x7fff2a55b000 -     0x7fff2a55cfff  libSystem.B.dylib x86_64  <a7fb48999e0437ed9dd88fff0400879c> /usr/lib/libSystem.B.dylib\n\
    0x7fff2a55d000 -     0x7fff2a560fff  libfakelink.dylib x86_64  <34b6dc95e19a37c0b9d0558f692d85f5> /usr/lib/libfakelink.dylib\n\
    0x7fff2a561000 -     0x7fff2a561fff  SoftLinking x86_64  <90d679b3dffd3604b89f1bcf70b3eba4> /System/Library/PrivateFrameworks/SoftLinking.framework/Versions/A/SoftLinking\n\
    0x7fff2a562000 -     0x7fff2a599fff  libpcap.A.dylib x86_64  <e1995a1c7eeb3340b1e1dd45fa625c12> /usr/lib/libpcap.A.dylib\n\
    0x7fff2a59a000 -     0x7fff2a68afff  libiconv.2.dylib x86_64  <3e53f7351d7e3abbbc45aaa37f535830> /usr/lib/libiconv.2.dylib\n\
    0x7fff2a68b000 -     0x7fff2a69cfff  libcmph.dylib x86_64  <865fa425831d3e49bd1b14188d2a98aa> /usr/lib/libcmph.dylib\n\
    0x7fff2a69d000 -     0x7fff2a70efff  libarchive.2.dylib x86_64  <76b2f421533537fb9cd51018878b9e74> /usr/lib/libarchive.2.dylib\n\
    0x7fff2a70f000 -     0x7fff2a776fff  SearchKit x86_64  <7bdd2800bddc3de0a4a8b1e855130e3b> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/SearchKit.framework/Versions/A/SearchKit\n\
    0x7fff2a777000 -     0x7fff2a778fff  libThaiTokenizer.dylib x86_64  <513547cd5c7f37bea2ad55a22f279588> /usr/lib/libThaiTokenizer.dylib\n\
    0x7fff2a779000 -     0x7fff2a7a0fff  AppleSauce x86_64  <ae5252432ce7373e994ec2457611eb3c> /System/Library/PrivateFrameworks/AppleSauce.framework/Versions/A/AppleSauce\n\
    0x7fff2a7a1000 -     0x7fff2a7b8fff  libapple_nghttp2.dylib x86_64  <cc0047686e3b3d80943161149ebe2e10> /usr/lib/libapple_nghttp2.dylib\n\
    0x7fff2a7b9000 -     0x7fff2a7cbfff  libSparseBLAS.dylib x86_64  <cebd7b0fa54d3a43bd7ee8bc2c7b7f0c> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libSparseBLAS.dylib\n\
    0x7fff2a7cc000 -     0x7fff2a7cdfff  MetalPerformanceShaders x86_64  <1bfeb124cf05342fbc65b233eab661d9> /System/Library/Frameworks/MetalPerformanceShaders.framework/Versions/A/MetalPerformanceShaders\n\
    0x7fff2a7ce000 -     0x7fff2a7d2fff  libpam.2.dylib x86_64  <ae84f5faddb03028af25d6b6a12dba6a> /usr/lib/libpam.2.dylib\n\
    0x7fff2a7d3000 -     0x7fff2a7ebfff  libcompression.dylib x86_64  <45b8b8218eb634fe92e95cba474499e2> /usr/lib/libcompression.dylib\n\
    0x7fff2a7ec000 -     0x7fff2a7f1fff  libQuadrature.dylib x86_64  <fb21f53d4a40327fbd3bc7c8d08c6a86> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libQuadrature.dylib\n\
    0x7fff2a7f2000 -     0x7fff2ab8efff  libLAPACK.dylib x86_64  <509fbcc64ecb319298a6d0c030e4e9d8> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libLAPACK.dylib\n\
    0x7fff2ab8f000 -     0x7fff2abddfff  DictionaryServices x86_64  <83cdce836b4835f1bacf83240d940777> /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/DictionaryServices.framework/Versions/A/DictionaryServices\n\
    0x7fff2abde000 -     0x7fff2abf6fff  liblzma.5.dylib x86_64  <a45348bcaa9c39d6a7c32246a3efa34c> /usr/lib/liblzma.5.dylib\n\
    0x7fff2abf7000 -     0x7fff2abf8fff  libcoretls_cfhelpers.dylib x86_64  <c0f19e92dacb3100861062dec5e5fb81> /usr/lib/libcoretls_cfhelpers.dylib\n\
    0x7fff2abf9000 -     0x7fff2acf2fff  APFS x86_64  <8271ee40cdf53e0b9f42b49dc7c46c98> /System/Library/PrivateFrameworks/APFS.framework/Versions/A/APFS\n\
    0x7fff2acf3000 -     0x7fff2ad00fff  libxar.1.dylib x86_64  <3f3da942dc7b31efbcf138f99f59a660> /usr/lib/libxar.1.dylib\n\
    0x7fff2ad01000 -     0x7fff2ad04fff  libutil.dylib x86_64  <85cf2b3b6beb381d86831de2b0167ecc> /usr/lib/libutil.dylib\n\
    0x7fff2ad05000 -     0x7fff2ad2dfff  libxslt.1.dylib x86_64  <2c881e826e2c3e928dc53c2d05fe7c95> /usr/lib/libxslt.1.dylib\n\
    0x7fff2ad2e000 -     0x7fff2ad38fff  libChineseTokenizer.dylib x86_64  <36891bb54a8333a39995cc5db2ab53ce> /usr/lib/libChineseTokenizer.dylib\n\
    0x7fff2ad39000 -     0x7fff2adf7fff  libvMisc.dylib x86_64  <219319e1bdbd34d197b7e46256785d3c> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libvMisc.dylib\n\
    0x7fff2adf8000 -     0x7fff2ae90fff  libate.dylib x86_64  <51d50d08f6143929afb1bf4ed9be4751> /usr/lib/libate.dylib\n\
    0x7fff2ae91000 -     0x7fff2ae98fff  libIOReport.dylib x86_64  <3c26fbdc931e33188225c10849cf1d60> /usr/lib/libIOReport.dylib\n\
    0x7fff2ae99000 -     0x7fff2aec7fff  CrashReporterSupport x86_64  <5377e0c95d8938c0b1291a086716f3e9> /System/Library/PrivateFrameworks/CrashReporterSupport.framework/Versions/A/CrashReporterSupport\n\
    0x7fff2aec8000 -     0x7fff2aedefff  AppSSOCore x86_64  <0f55307040c73a179759098bcd8f510c> /System/Library/PrivateFrameworks/AppSSOCore.framework/Versions/A/AppSSOCore\n\
    0x7fff2aedf000 -     0x7fff2af5ffff  CVNLP x86_64  <610073887d6a3b8ab4188f7fc07d874f> /System/Library/PrivateFrameworks/CVNLP.framework/Versions/A/CVNLP\n\
    0x7fff2af7e000 -     0x7fff2afb3fff  PlugInKit x86_64  <68a4c478de413693bd645a8d0f4f316e> /System/Library/PrivateFrameworks/PlugInKit.framework/Versions/A/PlugInKit\n\
    0x7fff2afb4000 -     0x7fff2afbbfff  libMatch.1.dylib x86_64  <dc1e67e026903ee0840d461da2980d9d> /usr/lib/libMatch.1.dylib\n\
    0x7fff2afbc000 -     0x7fff2b047fff  libCoreStorage.dylib x86_64  <8eeb1047efc13c1b8e33a446eb043ad5> /usr/lib/libCoreStorage.dylib\n\
    0x7fff2b048000 -     0x7fff2b09bfff  AppleVA x86_64  <8a5b1c42dd83303b85de754fb6c10e1a> /System/Library/PrivateFrameworks/AppleVA.framework/Versions/A/AppleVA\n\
    0x7fff2b09c000 -     0x7fff2b0b5fff  libexpat.1.dylib x86_64  <4408fc72bdaa33aebe144008642794ed> /usr/lib/libexpat.1.dylib\n\
    0x7fff2b0b6000 -     0x7fff2b0bffff  libheimdal-asn1.dylib x86_64  <032931c8b0423b3d93d35b3e27431fea> /usr/lib/libheimdal-asn1.dylib\n\
    0x7fff2b0c0000 -     0x7fff2b0d4fff  IconFoundation x86_64  <650c91c9d6a13ff7964bde1065f2243c> /System/Library/PrivateFrameworks/IconFoundation.framework/Versions/A/IconFoundation\n\
    0x7fff2b0d5000 -     0x7fff2b142fff  IconServices x86_64  <63cab1abc485382a9088f6e3937bb8e9> /System/Library/PrivateFrameworks/IconServices.framework/Versions/A/IconServices\n\
    0x7fff2b143000 -     0x7fff2b1e0fff  MediaExperience x86_64  <a7a754ce61ab39b8aa313aeb14695f55> /System/Library/PrivateFrameworks/MediaExperience.framework/Versions/A/MediaExperience\n\
    0x7fff2b1e1000 -     0x7fff2b20afff  PersistentConnection x86_64  <c3f975d3a87c353cba1f072825e60e8c> /System/Library/PrivateFrameworks/PersistentConnection.framework/Versions/A/PersistentConnection\n\
    0x7fff2b20b000 -     0x7fff2b219fff  GraphVisualizer x86_64  <7035ccdf5b9d365ca1fa1d961ebee44d> /System/Library/PrivateFrameworks/GraphVisualizer.framework/Versions/A/GraphVisualizer\n\
    0x7fff2b21a000 -     0x7fff2b635fff  FaceCore x86_64  <e0518821b65d31a48c37df3569cf8867> /System/Library/PrivateFrameworks/FaceCore.framework/Versions/A/FaceCore\n\
    0x7fff2b636000 -     0x7fff2b680fff  OTSVG x86_64  <d27224316c713144a0246ed06334aee0> /System/Library/PrivateFrameworks/OTSVG.framework/Versions/A/OTSVG\n\
    0x7fff2b681000 -     0x7fff2b687fff  AppServerSupport x86_64  <27b96aa0421e3e5ab9d89ba3f0d133e9> /System/Library/PrivateFrameworks/AppServerSupport.framework/Versions/A/AppServerSupport\n\
    0x7fff2b688000 -     0x7fff2b699fff  libhvf.dylib x86_64  <cad788030f56316ea7f1d2bf26ca2dd6> /System/Library/PrivateFrameworks/FontServices.framework/libhvf.dylib\n\
    0x7fff2b69a000 -     0x7fff2b69cfff  libspindump.dylib x86_64  <c6f804a356823766a32476667364873d> /usr/lib/libspindump.dylib\n\
    0x7fff2b69d000 -     0x7fff2b75dfff  Heimdal x86_64  <8bb183355dd3315485c80145c64556a2> /System/Library/PrivateFrameworks/Heimdal.framework/Versions/A/Heimdal\n\
    0x7fff2b75e000 -     0x7fff2b778fff  login x86_64  <343a182af6c9366ebf0c2124e5367f19> /System/Library/PrivateFrameworks/login.framework/Versions/A/login\n\
    0x7fff2b779000 -     0x7fff2b84bfff  CoreBrightness x86_64  <3b80fa12c9f6317186ac1054f435f7e3> /System/Library/PrivateFrameworks/CoreBrightness.framework/Versions/A/CoreBrightness\n\
    0x7fff2b8fc000 -     0x7fff2b966fff  Bom x86_64  <a62eeee530273f25bcd932d36922106e> /System/Library/PrivateFrameworks/Bom.framework/Versions/A/Bom\n\
    0x7fff2b967000 -     0x7fff2b9b1fff  AppleJPEG x86_64  <a2e9e2a4aedc3481bdc905d9ad84fc25> /System/Library/PrivateFrameworks/AppleJPEG.framework/Versions/A/AppleJPEG\n\
    0x7fff2b9b2000 -     0x7fff2ba90fff  libJP2.dylib x86_64  <9d837c013d6c3d718e923673ce06a21f> /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libJP2.dylib\n\
    0x7fff2ba91000 -     0x7fff2ba94fff  WatchdogClient x86_64  <8374bbbb65cb3d469ad60dd1fb99ad88> /System/Library/PrivateFrameworks/WatchdogClient.framework/Versions/A/WatchdogClient\n\
    0x7fff2ba95000 -     0x7fff2bac8fff  MultitouchSupport x86_64  <e9a952725e843b6482638c7f84456269> /System/Library/PrivateFrameworks/MultitouchSupport.framework/Versions/A/MultitouchSupport\n\
    0x7fff2bac9000 -     0x7fff2bc1bfff  VideoToolbox x86_64  <35098775a1883be0b0b17ce0027ba295> /System/Library/Frameworks/VideoToolbox.framework/Versions/A/VideoToolbox\n\
    0x7fff2bc1c000 -     0x7fff2bc4efff  libAudioToolboxUtility.dylib x86_64  <58b4505bf0ea37fc9f5a6f9f05b0f2a5> /usr/lib/libAudioToolboxUtility.dylib\n\
    0x7fff2bc4f000 -     0x7fff2bc75fff  libPng.dylib x86_64  <1f3fed3bfb073f438ead6100017fbab5> /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libPng.dylib\n\
    0x7fff2bc76000 -     0x7fff2bcd3fff  libTIFF.dylib x86_64  <27e9a2d3003d3d97ad85be595ea0516f> /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libTIFF.dylib\n\
    0x7fff2bcd4000 -     0x7fff2bceefff  IOPresentment x86_64  <070919dc978e3db380fdfb0c1baae80a> /System/Library/PrivateFrameworks/IOPresentment.framework/Versions/A/IOPresentment\n\
    0x7fff2bcef000 -     0x7fff2bcf5fff  GPUWrangler x86_64  <f4b3905fc02433c182c8f1744af8516e> /System/Library/PrivateFrameworks/GPUWrangler.framework/Versions/A/GPUWrangler\n\
    0x7fff2bcf6000 -     0x7fff2bcf9fff  libRadiance.dylib x86_64  <7abf94d25281363fa6139c945d77aae8> /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libRadiance.dylib\n\
    0x7fff2bcfa000 -     0x7fff2bcfffff  DSExternalDisplay x86_64  <ba802582f1eb35b8902f3d0f426124e0> /System/Library/PrivateFrameworks/DSExternalDisplay.framework/Versions/A/DSExternalDisplay\n\
    0x7fff2bd00000 -     0x7fff2bd24fff  libJPEG.dylib x86_64  <fdd55379667331e4b9167949459b60ae> /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libJPEG.dylib\n\
    0x7fff2bd25000 -     0x7fff2bd54fff  ATSUI x86_64  <b82d099b4f533b608baa975c41efd356> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATSUI.framework/Versions/A/ATSUI\n\
    0x7fff2bd55000 -     0x7fff2bd59fff  libGIF.dylib x86_64  <c51fb0bae5c0335b9c64185b1ddc9166> /System/Library/Frameworks/ImageIO.framework/Versions/A/Resources/libGIF.dylib\n\
    0x7fff2bd5a000 -     0x7fff2bd63fff  CMCaptureCore x86_64  <a0d43e58b9603a8088074115f0e1ef74> /System/Library/PrivateFrameworks/CMCaptureCore.framework/Versions/A/CMCaptureCore\n\
    0x7fff2bd64000 -     0x7fff2bdabfff  PrintCore x86_64  <fc56a643f50235789eff375be6b87691> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/PrintCore\n\
    0x7fff2bdac000 -     0x7fff2be78fff  TextureIO x86_64  <0ac150034b6a3fb39b413ef61a2bd430> /System/Library/PrivateFrameworks/TextureIO.framework/Versions/A/TextureIO\n\
    0x7fff2be79000 -     0x7fff2be81fff  InternationalSupport x86_64  <5485ffdcce4437f4865f91b2efbc6caf> /System/Library/PrivateFrameworks/InternationalSupport.framework/Versions/A/InternationalSupport\n\
    0x7fff2be82000 -     0x7fff2befdfff  DataDetectorsCore x86_64  <a2deef63764337aa9420ed875629d1b2> /System/Library/PrivateFrameworks/DataDetectorsCore.framework/Versions/A/DataDetectorsCore\n\
    0x7fff2befe000 -     0x7fff2bf5cfff  UserActivity x86_64  <075fd35428fd3a13881c955fa9106d5c> /System/Library/PrivateFrameworks/UserActivity.framework/Versions/A/UserActivity\n\
    0x7fff2bf5d000 -     0x7fff2c6c7fff  MediaToolbox x86_64  <8f9d0503298b3fca81353b3722ef287c> /System/Library/Frameworks/MediaToolbox.framework/Versions/A/MediaToolbox\n\
    0x7fff2c6c8000 -     0x7fff2c72ffff  libusrtcp.dylib x86_64  <3280b35e4b0332c0a69fd9360524ac80> /usr/lib/libusrtcp.dylib\n\
    0x7fff2cb81000 -     0x7fff2cba9fff  LocationSupport x86_64  <f02d602516b43c77acea89b4808214d3> /System/Library/PrivateFrameworks/LocationSupport.framework/Versions/A/LocationSupport\n\
    0x7fff2cbaa000 -     0x7fff2cbdbfff  libSessionUtility.dylib x86_64  <95615ede46b932ae96ec7f6e5eb6a932> /System/Library/PrivateFrameworks/AudioSession.framework/libSessionUtility.dylib\n\
    0x7fff2cbdc000 -     0x7fff2cd0cfff  AudioToolbox x86_64  <d0f9f628f2413fa2a7857b9dcbb2fec4> /System/Library/Frameworks/AudioToolbox.framework/Versions/A/AudioToolbox\n\
    0x7fff2cd0d000 -     0x7fff2cd74fff  AudioSession x86_64  <c0b1c9eba59431e3addf118583840e6f> /System/Library/PrivateFrameworks/AudioSession.framework/Versions/A/AudioSession\n\
    0x7fff2cd75000 -     0x7fff2cd87fff  libAudioStatistics.dylib x86_64  <1d07ea54be7c37c4aa735224d402f0c3> /usr/lib/libAudioStatistics.dylib\n\
    0x7fff2cd88000 -     0x7fff2cd97fff  SpeechSynthesis x86_64  <b86a21368dd7395dbb9f9416c56dd2d6> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/SpeechSynthesis.framework/Versions/A/SpeechSynthesis\n\
    0x7fff2cd98000 -     0x7fff2ce03fff  ATS x86_64  <3a435648cc5f387eab37391aaeabe314> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/A/ATS\n\
    0x7fff2ce04000 -     0x7fff2ce1cfff  libresolv.9.dylib x86_64  <9957a6f48b66342986cd6df4993eb6f5> /usr/lib/libresolv.9.dylib\n\
    0x7fff2ceea000 -     0x7fff2cf4efff  CoreMediaIO x86_64  <cffd2205bfea313abaf461cca9ba6d68> /System/Library/Frameworks/CoreMediaIO.framework/Versions/A/CoreMediaIO\n\
    0x7fff2cf4f000 -     0x7fff2d02efff  libSMC.dylib x86_64  <ce5162b7379e3df09d1e44bc98bd2422> /usr/lib/libSMC.dylib\n\
    0x7fff2d02f000 -     0x7fff2d08efff  libcups.2.dylib x86_64  <04a4801ee1b539199f14100f0c2d049b> /usr/lib/libcups.2.dylib\n\
    0x7fff2d08f000 -     0x7fff2d09efff  LangAnalysis x86_64  <120945d9b74d3a6fb1602678e6b6481d> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/LangAnalysis.framework/Versions/A/LangAnalysis\n\
    0x7fff2d09f000 -     0x7fff2d0a9fff  NetAuth x86_64  <c65b2f5467ea3e4db84abba94998bd6b> /System/Library/PrivateFrameworks/NetAuth.framework/Versions/A/NetAuth\n\
    0x7fff2d0aa000 -     0x7fff2d0b1fff  ColorSyncLegacy x86_64  <33da9348eadf36d2b99956854481d272> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ColorSyncLegacy.framework/Versions/A/ColorSyncLegacy\n\
    0x7fff2d0b2000 -     0x7fff2d0bdfff  QD x86_64  <7ffc90497e42372b91051c4c94de0110> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/QD.framework/Versions/A/QD\n\
    0x7fff2d0be000 -     0x7fff2d72cfff  AudioResourceArbitration x86_64  <098fd431d3023dd59ad1453615a73e68> /System/Library/PrivateFrameworks/AudioResourceArbitration.framework/Versions/A/AudioResourceArbitration\n\
    0x7fff2d72d000 -     0x7fff2d739fff  perfdata x86_64  <85a57a6787213035bceed4ac98332d2c> /System/Library/PrivateFrameworks/perfdata.framework/Versions/A/perfdata\n\
    0x7fff2d73a000 -     0x7fff2d748fff  libperfcheck.dylib x86_64  <67113817a463360ab3219286dc50feda> /usr/lib/libperfcheck.dylib\n\
    0x7fff2d749000 -     0x7fff2d758fff  Kerberos x86_64  <2e87270508413695af794160d2a436ab> /System/Library/Frameworks/Kerberos.framework/Versions/A/Kerberos\n\
    0x7fff2d759000 -     0x7fff2d7a8fff  GSS x86_64  <2a38d59f5f3a3779a4212f8128f22b95> /System/Library/Frameworks/GSS.framework/Versions/A/GSS\n\
    0x7fff2d7a9000 -     0x7fff2d7b9fff  CommonAuth x86_64  <d9431f22a16b32379676b6159b36f5ea> /System/Library/PrivateFrameworks/CommonAuth.framework/Versions/A/CommonAuth\n\
    0x7fff2d80e000 -     0x7fff2d830fff  KeychainCircle x86_64  <3554a1b0a9ad3d89a7551c9cc7cea239> /System/Library/PrivateFrameworks/KeychainCircle.framework/Versions/A/KeychainCircle\n\
    0x7fff2d831000 -     0x7fff2d839fff  CorePhoneNumbers x86_64  <0df4c527e7d330e094024c43b29729cb> /System/Library/PrivateFrameworks/CorePhoneNumbers.framework/Versions/A/CorePhoneNumbers\n\
    0x7fff2d83a000 -     0x7fff2d8c5fff  libTelephonyUtilDynamic.dylib x86_64  <fd27be4017a0356190e3ffb96048c2ad> /usr/lib/libTelephonyUtilDynamic.dylib\n\
    0x7fff2d98e000 -     0x7fff2d98efff  liblaunch.dylib x86_64  <05a7efdd41113e4db668239b69de3d0f> /usr/lib/system/liblaunch.dylib\n\
    0x7fff2e189000 -     0x7fff2e2d0fff  Sharing x86_64  <4e590a26593433eebfd9391a64686fde> /System/Library/PrivateFrameworks/Sharing.framework/Versions/A/Sharing\n\
    0x7fff2e2d1000 -     0x7fff2e3f1fff  IOBluetooth x86_64  <e3cf73c4b4393e30b74d3344c2ea2fc9> /System/Library/Frameworks/IOBluetooth.framework/Versions/A/IOBluetooth\n\
    0x7fff2e3f2000 -     0x7fff2e406fff  AppContainer x86_64  <a9d28e73b08f34e3ae7b0855dba96c3c> /System/Library/PrivateFrameworks/AppContainer.framework/Versions/A/AppContainer\n\
    0x7fff2e407000 -     0x7fff2e40afff  SecCodeWrapper x86_64  <55b0c208b1763fe48ca29f28ca59f8f1> /System/Library/PrivateFrameworks/SecCodeWrapper.framework/Versions/A/SecCodeWrapper\n\
    0x7fff2e40b000 -     0x7fff2e464fff  ProtectedCloudStorage x86_64  <c84c9c9853823e278275ac9816aa28e8> /System/Library/PrivateFrameworks/ProtectedCloudStorage.framework/Versions/A/ProtectedCloudStorage\n\
    0x7fff2e465000 -     0x7fff2e4c4fff  QuickLook x86_64  <ac6665d676c33792ab694ef566dd411b> /System/Library/Frameworks/QuickLook.framework/Versions/A/QuickLook\n\
    0x7fff2e4c5000 -     0x7fff2e4e1fff  MetalKit x86_64  <3d1b6242aa6537eda6f501e39f1cc463> /System/Library/Frameworks/MetalKit.framework/Versions/A/MetalKit\n\
    0x7fff2e6b8000 -     0x7fff2fba7fff  GeoServices x86_64  <4d6f8ef447d43f9390ac3f4a5772cbcb> /System/Library/PrivateFrameworks/GeoServices.framework/Versions/A/GeoServices\n\
    0x7fff2fbb4000 -     0x7fff2fbdffff  RemoteViewServices x86_64  <ac6e2d2f81313a4097d7e24e2a45cd66> /System/Library/PrivateFrameworks/RemoteViewServices.framework/Versions/A/RemoteViewServices\n\
    0x7fff2fbe0000 -     0x7fff2fbeffff  SpeechRecognitionCore x86_64  <f2a0e41a79763175959a98dc24aaffcc> /System/Library/PrivateFrameworks/SpeechRecognitionCore.framework/Versions/A/SpeechRecognitionCore\n\
    0x7fff2fbf0000 -     0x7fff2fbf7fff  SpeechRecognition x86_64  <9c14fa0ad905375b8c32e311ed59b6ad> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/SpeechRecognition.framework/Versions/A/SpeechRecognition\n\
    0x7fff2fe3b000 -     0x7fff2fe3bfff  libsystem_product_info_filter.dylib x86_64  <7ccaf1a8f570341eb2750c80b092f8e0> /usr/lib/system/libsystem_product_info_filter.dylib\n\
    0x7fff2ff16000 -     0x7fff2ff16fff  vecLib x86_64  <510a463f5ca53585969f2d44583b71c8> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/vecLib\n\
    0x7fff2ff3d000 -     0x7fff2ff3dfff  CoreServices x86_64  <5ddb040c6e923dbe9049873f510f26e2> /System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices\n\
    0x7fff3020b000 -     0x7fff3020bfff  Accelerate x86_64  <f2ffcc7bee3d3768a73b342851b53741> /System/Library/Frameworks/Accelerate.framework/Versions/A/Accelerate\n\
    0x7fff3024c000 -     0x7fff30257fff  MediaAccessibility x86_64  <9b4710c9623835079918fda38cdc0b00> /System/Library/Frameworks/MediaAccessibility.framework/Versions/A/MediaAccessibility\n\
    0x7fff30258000 -     0x7fff30277fff  AlgosScoreFramework x86_64  <dab4077257a1354594fd4c823d13135c> /System/Library/PrivateFrameworks/AlgosScoreFramework.framework/Versions/A/AlgosScoreFramework\n\
    0x7fff30278000 -     0x7fff3027cfff  AppleSRP x86_64  <882084c9f925308fb778398fe6741654> /System/Library/PrivateFrameworks/AppleSRP.framework/Versions/A/AppleSRP\n\
    0x7fff3027d000 -     0x7fff30288fff  CoreDaemon x86_64  <9684931753463d5d95b76c48c3015427> /System/Library/PrivateFrameworks/CoreDaemon.framework/Versions/B/CoreDaemon\n\
    0x7fff30a82000 -     0x7fff30ae4fff  CoreBluetooth x86_64  <0ff4cfb1b8dd31c3a0005016cfe45eb9> /System/Library/Frameworks/CoreBluetooth.framework/Versions/A/CoreBluetooth\n\
    0x7fff30ae5000 -     0x7fff30aeefff  SymptomDiagnosticReporter x86_64  <4536ffdf598e30858ddd26798e1eebd6> /System/Library/PrivateFrameworks/SymptomDiagnosticReporter.framework/Versions/A/SymptomDiagnosticReporter\n\
    0x7fff30aef000 -     0x7fff30b02fff  PowerLog x86_64  <7ea1c552e90e3df6a5b6915d26694670> /System/Library/PrivateFrameworks/PowerLog.framework/Versions/A/PowerLog\n\
    0x7fff30b03000 -     0x7fff30b0ffff  AppleIDAuthSupport x86_64  <1ee8869240593a33b492e7d7112efb0c> /System/Library/PrivateFrameworks/AppleIDAuthSupport.framework/Versions/A/AppleIDAuthSupport\n\
    0x7fff30b10000 -     0x7fff30bb8fff  DiscRecording x86_64  <8676cdcb15cc372394118b8afa3b370a> /System/Library/Frameworks/DiscRecording.framework/Versions/A/DiscRecording\n\
    0x7fff30bb9000 -     0x7fff30becfff  MediaKit x86_64  <c7fb3929e0e13a6cb138ee504cce9ef0> /System/Library/PrivateFrameworks/MediaKit.framework/Versions/A/MediaKit\n\
    0x7fff30bed000 -     0x7fff30cd8fff  DiskManagement x86_64  <328db6ad221b35fa8e312e5cd860a0f3> /System/Library/PrivateFrameworks/DiskManagement.framework/Versions/A/DiskManagement\n\
    0x7fff30cd9000 -     0x7fff31093fff  CoreAUC x86_64  <5e5a1d7f5d433975aa23aa0815dce998> /System/Library/PrivateFrameworks/CoreAUC.framework/Versions/A/CoreAUC\n\
    0x7fff31094000 -     0x7fff31097fff  Mangrove x86_64  <81a9ba84c61f3cbfa127406e3fd2459e> /System/Library/PrivateFrameworks/Mangrove.framework/Versions/A/Mangrove\n\
    0x7fff31098000 -     0x7fff310c5fff  CoreAVCHD x86_64  <10ca0e3419b1365c888c94543a25f10f> /System/Library/PrivateFrameworks/CoreAVCHD.framework/Versions/A/CoreAVCHD\n\
    0x7fff310c6000 -     0x7fff311e6fff  FileProvider x86_64  <b2a33b9e66d930b5a18cad0d7f3592c5> /System/Library/Frameworks/FileProvider.framework/Versions/A/FileProvider\n\
    0x7fff311e7000 -     0x7fff3120afff  GenerationalStorage x86_64  <f2740ca7334b3f24afe82451d1a041c2> /System/Library/PrivateFrameworks/GenerationalStorage.framework/Versions/A/GenerationalStorage\n\
    0x7fff31581000 -     0x7fff31651fff  CoreTelephony x86_64  <149ccba2e5c73fafaea10bbc4e7a9887> /System/Library/Frameworks/CoreTelephony.framework/Versions/A/CoreTelephony\n\
    0x7fff31676000 -     0x7fff31803fff  AVFCore x86_64  <461370474b3d3a90a6ed68b829489c20> /System/Library/PrivateFrameworks/AVFCore.framework/Versions/A/AVFCore\n\
    0x7fff31804000 -     0x7fff31876fff  FrontBoardServices x86_64  <9eaef19a41673914a9a825c36e586550> /System/Library/PrivateFrameworks/FrontBoardServices.framework/Versions/A/FrontBoardServices\n\
    0x7fff31877000 -     0x7fff318a0fff  BoardServices x86_64  <87d88a0aa43d301b9393d06e971baedf> /System/Library/PrivateFrameworks/BoardServices.framework/Versions/A/BoardServices\n\
    0x7fff31a59000 -     0x7fff31a98fff  AppleVPA x86_64  <df632ed6e23032088741446e8e35a515> /System/Library/PrivateFrameworks/AppleVPA.framework/Versions/A/AppleVPA\n\
    0x7fff31b69000 -     0x7fff31ba5fff  DebugSymbols x86_64  <6aa76bbcb0f23f37a6ee19014dcd06d9> /System/Library/PrivateFrameworks/DebugSymbols.framework/Versions/A/DebugSymbols\n\
    0x7fff31ba6000 -     0x7fff31c63fff  CoreSymbolication x86_64  <a100000df8813c3cabc53eac7a272579> /System/Library/PrivateFrameworks/CoreSymbolication.framework/Versions/A/CoreSymbolication\n\
    0x7fff31c64000 -     0x7fff31c6dfff  CoreTime x86_64  <1be28f6e940c31c8b4602761fc6b4a3f> /System/Library/PrivateFrameworks/CoreTime.framework/Versions/A/CoreTime\n\
    0x7fff31c6e000 -     0x7fff31ce4fff  Rapport x86_64  <d333f84f874b3b98a4b2babd63b019cb> /System/Library/PrivateFrameworks/Rapport.framework/Versions/A/Rapport\n\
    0x7fff3252d000 -     0x7fff3257afff  CoreDuetContext x86_64  <d841df38170f3b40a41c56ec30e94fb8> /System/Library/PrivateFrameworks/CoreDuetContext.framework/Versions/A/CoreDuetContext\n\
    0x7fff3257b000 -     0x7fff32af8fff  Intents x86_64  <606e26db606d3be99225a4b780a1d73c> /System/Library/Frameworks/Intents.framework/Versions/A/Intents\n\
    0x7fff32af9000 -     0x7fff32b5cfff  Apple80211 x86_64  <2dbc65aca7df38f991743382667fbf0f> /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Apple80211\n\
    0x7fff32b5d000 -     0x7fff32caffff  CoreWiFi x86_64  <c18d2e57a964380fa74baefdb3b3adec> /System/Library/PrivateFrameworks/CoreWiFi.framework/Versions/A/CoreWiFi\n\
    0x7fff32cb0000 -     0x7fff32cc8fff  BackBoardServices x86_64  <d0cc236067853fff931171a03c78b51a> /System/Library/PrivateFrameworks/BackBoardServices.framework/Versions/A/BackBoardServices\n\
    0x7fff32f1c000 -     0x7fff32f2bfff  RemoteServiceDiscovery x86_64  <efefc279e73a3557a4aebf67e7c96962> /System/Library/PrivateFrameworks/RemoteServiceDiscovery.framework/Versions/A/RemoteServiceDiscovery\n\
    0x7fff32f2c000 -     0x7fff32f43fff  RemoteXPC x86_64  <dc43aed26dd731ab8186ef69ed7027c4> /System/Library/PrivateFrameworks/RemoteXPC.framework/Versions/A/RemoteXPC\n\
    0x7fff32f8b000 -     0x7fff32f8efff  Help x86_64  <599f7e42def13b7083abc3bdf727cf93> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/Help.framework/Versions/A/Help\n\
    0x7fff32f8f000 -     0x7fff32f96fff  EFILogin x86_64  <b94bfcca45b63e8084e7758350d7cafd> /System/Library/PrivateFrameworks/EFILogin.framework/Versions/A/EFILogin\n\
    0x7fff32f97000 -     0x7fff32fa2fff  libcsfde.dylib x86_64  <1f4dff1317ec36728a41056f4e44a377> /usr/lib/libcsfde.dylib\n\
    0x7fff33011000 -     0x7fff33074fff  AppSupport x86_64  <49ffb3f5c620307d929a0c4cbc8cbbf6> /System/Library/PrivateFrameworks/AppSupport.framework/Versions/A/AppSupport\n\
    0x7fff331d0000 -     0x7fff331d0fff  ApplicationServices x86_64  <7b5368713f103138b06b9c2a3c07ec1e> /System/Library/Frameworks/ApplicationServices.framework/Versions/A/ApplicationServices\n\
    0x7fff334d0000 -     0x7fff334d0fff  libHeimdalProxy.dylib x86_64  <1bd94bf68e633b2195dce5eeebfb8ae8> /System/Library/Frameworks/Kerberos.framework/Versions/A/Libraries/libHeimdalProxy.dylib\n\
    0x7fff33583000 -     0x7fff33583fff  AudioUnit x86_64  <f5ec07dd893737cb84dfc7475ffa573e> /System/Library/Frameworks/AudioUnit.framework/Versions/A/AudioUnit\n\
    0x7fff335eb000 -     0x7fff3360bfff  DuetActivityScheduler x86_64  <ca10d6cb848e3ac98d2d4d5961fe1b5b> /System/Library/PrivateFrameworks/DuetActivityScheduler.framework/Versions/A/DuetActivityScheduler\n\
    0x7fff3361f000 -     0x7fff3362cfff  IntentsFoundation x86_64  <9a6961e477693005a38038f701252ba0> /System/Library/PrivateFrameworks/IntentsFoundation.framework/Versions/A/IntentsFoundation\n\
    0x7fff3362d000 -     0x7fff33632fff  PushKit x86_64  <309b12ff9b683120abc68b52a0e26127> /System/Library/Frameworks/PushKit.framework/Versions/A/PushKit\n\
    0x7fff33633000 -     0x7fff33669fff  C2 x86_64  <5370f4a21c27395c80e4a36e5bf414e9> /System/Library/PrivateFrameworks/C2.framework/Versions/A/C2\n\
    0x7fff3366a000 -     0x7fff3369bfff  QuickLookThumbnailing x86_64  <c7826d324b8b3f179138aa978ca579fa> /System/Library/Frameworks/QuickLookThumbnailing.framework/Versions/A/QuickLookThumbnailing\n\
    0x7fff3369c000 -     0x7fff33ea9fff  Espresso x86_64  <c2903f045ee03fcaa7d86abfdd38a27b> /System/Library/PrivateFrameworks/Espresso.framework/Versions/A/Espresso\n\
    0x7fff33eaa000 -     0x7fff33ec1fff  ANEServices x86_64  <f86b479b3fa0366c84a6d35253abbf5e> /System/Library/PrivateFrameworks/ANEServices.framework/Versions/A/ANEServices\n\
    0x7fff33fde000 -     0x7fff33fe0fff  CoreDuetDebugLogging x86_64  <65e1262f01d63c96bfaf3be6bb0996a8> /System/Library/PrivateFrameworks/CoreDuetDebugLogging.framework/Versions/A/CoreDuetDebugLogging\n\
    0x7fff33fe1000 -     0x7fff33feefff  CoreDuetDaemonProtocol x86_64  <42503d845d783f8f83ca73cc5e78160d> /System/Library/PrivateFrameworks/CoreDuetDaemonProtocol.framework/Versions/A/CoreDuetDaemonProtocol\n\
    0x7fff34539000 -     0x7fff34589fff  ChunkingLibrary x86_64  <e392ab7f6eac3e2e93f801ba240feacd> /System/Library/PrivateFrameworks/ChunkingLibrary.framework/Versions/A/ChunkingLibrary\n\
    0x7fff34e55000 -     0x7fff34e6bfff  AppleNeuralEngine x86_64  <bb0c2e059f1039909a4b0a3796f912ab> /System/Library/PrivateFrameworks/AppleNeuralEngine.framework/Versions/A/AppleNeuralEngine\n\
    0x7fff34fd1000 -     0x7fff34fd4fff  Cocoa x86_64  <e44ac98b5bea3087ab41c73ceb8a98c8> /System/Library/Frameworks/Cocoa.framework/Versions/A/Cocoa\n\
    0x7fff35b46000 -     0x7fff35b4dfff  DisplayServices x86_64  <e2038e6363e33f32a9a1aaf16f5bfadb> /System/Library/PrivateFrameworks/DisplayServices.framework/Versions/A/DisplayServices\n\
    0x7fff363de000 -     0x7fff363fffff  MarkupUI x86_64  <55fc61834cc738c28797097c24ffcb76> /System/Library/PrivateFrameworks/MarkupUI.framework/Versions/A/MarkupUI\n\
    0x7fff36414000 -     0x7fff3642ffff  OpenScripting x86_64  <d0b98df97a613810ae812f870dcc2ac0> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/OpenScripting.framework/Versions/A/OpenScripting\n\
    0x7fff36430000 -     0x7fff36433fff  SecurityHI x86_64  <dd7770f7661c363ba1f48b69eb0ffb6a> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/SecurityHI.framework/Versions/A/SecurityHI\n\
    0x7fff36434000 -     0x7fff36437fff  Ink x86_64  <e10c40b6265636d1882c2091ce02883a> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/Ink.framework/Versions/A/Ink\n\
    0x7fff36438000 -     0x7fff3643bfff  CommonPanels x86_64  <101582bae64f391abd2350dcc3cf8939> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/CommonPanels.framework/Versions/A/CommonPanels\n\
    0x7fff3643c000 -     0x7fff36443fff  ImageCapture x86_64  <fe9d13ddd7333b2ab4a6d3c8313005f5> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/ImageCapture.framework/Versions/A/ImageCapture\n\
    0x7fff36444000 -     0x7fff376ecfff  JavaScriptCore x86_64  <3ceff6349e8633f89e9caacad4e3412b> /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/JavaScriptCore\n\
    0x7fff37757000 -     0x7fff3783efff  AVFAudio x86_64  <4f121dc8938f3e2eabcf49cd95f5fd5c> /System/Library/Frameworks/AVFoundation.framework/Versions/A/Frameworks/AVFAudio.framework/Versions/A/AVFAudio\n\
    0x7fff3783f000 -     0x7fff37953fff  AVFCapture x86_64  <fea644f16d583e38905733dbcc85d91a> /System/Library/PrivateFrameworks/AVFCapture.framework/Versions/A/AVFCapture\n\
    0x7fff37954000 -     0x7fff379e8fff  Quagga x86_64  <7c13c66e77483d6387f3b4f24530e2b8> /System/Library/PrivateFrameworks/Quagga.framework/Versions/A/Quagga\n\
    0x7fff379e9000 -     0x7fff37c44fff  CMCapture x86_64  <21771336d58a3f59a4be679b1308a4b0> /System/Library/PrivateFrameworks/CMCapture.framework/Versions/A/CMCapture\n\
    0x7fff38656000 -     0x7fff38665fff  HID x86_64  <e5202792f20f34588cc76b158058dc33> /System/Library/PrivateFrameworks/HID.framework/Versions/A/HID\n\
    0x7fff38666000 -     0x7fff3878dfff  QuickLookUI x86_64  <559b08287637319f98563f336376faa0> /System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuickLookUI.framework/Versions/A/QuickLookUI\n\
    0x7fff39429000 -     0x7fff3942cfff  OSAServicesClient x86_64  <44e39868f6243644b453962d34737998> /System/Library/PrivateFrameworks/OSAServicesClient.framework/Versions/A/OSAServicesClient\n\
    0x7fff39460000 -     0x7fff39467fff  URLFormatting x86_64  <b77a6e0a66ad3044ab1710eca706a151> /System/Library/PrivateFrameworks/URLFormatting.framework/Versions/A/URLFormatting\n\
    0x7fff3c1d2000 -     0x7fff3c1f6fff  QuickLookSupport x86_64  <44ccd2f4b9e334fd81bc388b730d8068> /System/Library/PrivateFrameworks/QuickLookSupport.framework/Versions/A/QuickLookSupport\n\
    0x7fff3c1f7000 -     0x7fff3c28efff  AirPlaySync x86_64  <74bb0488c51236a1a153956d7a874ae6> /System/Library/PrivateFrameworks/AirPlaySync.framework/Versions/A/AirPlaySync\n\
    0x7fff3d0aa000 -     0x7fff3d12dfff  CorePDF x86_64  <7e6d5bfd7a7a399984ea28afeb1c2ca2> /System/Library/PrivateFrameworks/CorePDF.framework/Versions/A/CorePDF\n\
    0x7fff3d12e000 -     0x7fff3d131fff  Print x86_64  <8411879f7e3e3882bd0668e797a3b9d6> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/Print.framework/Versions/A/Print\n\
    0x7fff3d132000 -     0x7fff3d135fff  Carbon x86_64  <5683716a56103b97b473b4652067e7a6> /System/Library/Frameworks/Carbon.framework/Versions/A/Carbon\n\
    0x7fff3d22f000 -     0x7fff3d22ffff  AVFoundation x86_64  <12890aa514d53dea9fbbfbb7e3f34bdf> /System/Library/Frameworks/AVFoundation.framework/Versions/A/AVFoundation\n\
    0x7fff3d350000 -     0x7fff3d3affff  libquic.dylib x86_64  <9abf4a0555ce36b28d938de240b0ec40> /usr/lib/libquic.dylib\n\
    0x7fff3d3ba000 -     0x7fff3d3d9fff  SystemPolicy x86_64  <cfe0b0c6df5b31eb9d79b23e00a80b05> /System/Library/PrivateFrameworks/SystemPolicy.framework/Versions/A/SystemPolicy\n\
    0x7fff3d586000 -     0x7fff3d5a3fff  SidecarCore x86_64  <7d771e631a573b3dbbc02ace9d19ba64> /System/Library/PrivateFrameworks/SidecarCore.framework/Versions/A/SidecarCore\n\
    0x7fff3d5a4000 -     0x7fff3d5abfff  QuickLookNonBaseSystem x86_64  <9e56c6ab08733982b3d6573761702607> /System/Library/PrivateFrameworks/QuickLookNonBaseSystem.framework/Versions/A/QuickLookNonBaseSystem\n\
    0x7fff3db52000 -     0x7fff3db69fff  SafariServices x86_64  <011f7af4198c3430b6779ce84c23d211> /System/Library/Frameworks/SafariServices.framework/Versions/A/SafariServices\n\
    0x7fff3dd03000 -     0x7fff3dd0efff  MallocStackLogging x86_64  <c1a21524381d39caad63a3b9f67fc6ca> /System/Library/PrivateFrameworks/MallocStackLogging.framework/Versions/A/MallocStackLogging\n\
    0x7fff3dd24000 -     0x7fff3dd36fff  libmis.dylib x86_64  <54387457a60b3390ad6d3b380792cd79> /usr/lib/libmis.dylib\n\
    0x7fff3dd53000 -     0x7fff3dec5fff  CoreHandwriting x86_64  <503717bee9b63805b9c88da329788629> /System/Library/PrivateFrameworks/CoreHandwriting.framework/Versions/A/CoreHandwriting\n\
    0x7fff3dec6000 -     0x7fff3e125fff  ImageKit x86_64  <0fb1cd826dcd333b831e9e81a4a14c7b> /System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/ImageKit.framework/Versions/A/ImageKit\n\
    0x7fff3e126000 -     0x7fff3e245fff  PencilKit x86_64  <61dd751594af35a692afb1473bc8e8bf> /System/Library/Frameworks/PencilKit.framework/Versions/A/PencilKit\n\
    0x7fff3e246000 -     0x7fff3e257fff  SidecarUI x86_64  <65430ca2e7ac3569947bb8b8e8d4bf9e> /System/Library/PrivateFrameworks/SidecarUI.framework/Versions/A/SidecarUI\n\
    0x7fff3e841000 -     0x7fff3e8a3fff  ImageCaptureCore x86_64  <505f35f399b2360897669ad477a0d5eb> /System/Library/Frameworks/ImageCaptureCore.framework/Versions/A/ImageCaptureCore\n\
    0x7fff3e8a4000 -     0x7fff3e8cafff  QuartzFilters x86_64  <9c2f0204d8443c03aee21ec2da58acfd> /System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuartzFilters.framework/Versions/A/QuartzFilters\n\
    0x7fff3f070000 -     0x7fff3f1a1fff  AnnotationKit x86_64  <60747c5f37473d9da1a8c351e83e6e40> /System/Library/PrivateFrameworks/AnnotationKit.framework/Versions/A/AnnotationKit\n\
    0x7fff3f1a2000 -     0x7fff3f643fff  QuartzComposer x86_64  <cecfd875ece535a1b97ac493f183639c> /System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/QuartzComposer.framework/Versions/A/QuartzComposer\n\
    0x7fff3f644000 -     0x7fff3f731fff  PDFKit x86_64  <13be9a0bf8c53c02b5bcabdddc4a8932> /System/Library/Frameworks/PDFKit.framework/Versions/A/PDFKit\n\
    0x7fff4154b000 -     0x7fff4154efff  Quartz x86_64  <f7a81e93fdf93dac80f9af4d5887b2e0> /System/Library/Frameworks/Quartz.framework/Versions/A/Quartz\n\
    0x7fff4192a000 -     0x7fff41948fff  libCGInterfaces.dylib x86_64  <488d608d374c3a2fb8acd78e2f6e6db7> /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vImage.framework/Versions/A/Libraries/libCGInterfaces.dylib\n\
    0x7fff4829c000 -     0x7fff482eafff  OSAnalytics x86_64  <ef7537e3982b3fa2bffcf8071eff0b31> /System/Library/PrivateFrameworks/OSAnalytics.framework/Versions/A/OSAnalytics\n\
    0x7fff5225a000 -     0x7fff522ecfff  Symbolication x86_64  <ec806042524935dc90ba953a86d1854a> /System/Library/PrivateFrameworks/Symbolication.framework/Versions/A/Symbolication\n\
    0x7fff6c82e000 -     0x7fff6c834fff  libCoreFSCache.dylib x86_64  <4ece128d5e793adf8fe74fe8f565f8aa> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libCoreFSCache.dylib\n\
    0x7fff6c835000 -     0x7fff6c839fff  libCoreVMClient.dylib x86_64  <e0dbed1d39b43e519ea8d1ecaed93eab> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libCoreVMClient.dylib\n\
    0x7fff6c83a000 -     0x7fff6c849fff  OpenGL x86_64  <d8ee3ad0c0d032f79c6d39341099eb55> /System/Library/Frameworks/OpenGL.framework/Versions/A/OpenGL\n\
    0x7fff6c84a000 -     0x7fff6c84cfff  libCVMSPluginSupport.dylib x86_64  <5f020d3286633cb8a50cf939d4d4c31f> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libCVMSPluginSupport.dylib\n\
    0x7fff6c84d000 -     0x7fff6c855fff  libGFXShared.dylib x86_64  <2271532de2b33d4dadf00935f8dce89b> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGFXShared.dylib\n\
    0x7fff6c856000 -     0x7fff6c889fff  libGLImage.dylib x86_64  <528e53a333e134c78ee3c42ae5255553> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGLImage.dylib\n\
    0x7fff6c88a000 -     0x7fff6c8c6fff  libGLU.dylib x86_64  <15cbdf208a873d8490f8d19f4a2b06e2> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGLU.dylib\n\
    0x7fff6ca5c000 -     0x7fff6ca66fff  libGL.dylib x86_64  <157b74e1f30d3f9d9af8aaa333d2812d> /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib\n\
    0x7fff6de9d000 -     0x7fff6def5fff  OpenCL x86_64  <8a3d06d54e82355cae1be2c91db58233> /System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL\n\
    0x7fff783b5000 -     0x7fff783bcfff  libRosetta.dylib x86_64  <ff72e19b3b0234d4a8213397bb28ac02> /usr/lib/libRosetta.dylib\n\
";

#endif /* CrashReports_h */
