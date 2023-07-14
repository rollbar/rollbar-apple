import Darwin

/// A data structure holding a CPU architecture.
struct CPU {
    /// The overarching architecture, eg. arm.
    let type: cpu_type_t

    /// The specific architecture, eg. arm64e.
    let subtype: cpu_subtype_t

    /// A crash reporting appropriate formatted String of the general architecture.
    var typeName: String {
        switch type {
        case CPU_TYPE_ARM: return "ARM"
        case CPU_TYPE_ARM64: return "ARM-64"
        case CPU_TYPE_ARM64_32: return "ARM-64_32"
        case CPU_TYPE_X86 | CPU_TYPE_I386: return "X86"
        case CPU_TYPE_X86_64: return "X86-64"
        case _: return "UNKNOWN"
        }
    }

    /// A crash reporting appropriate formatted String of the specific architecture.
    var subtypeName: String {
        switch self.type {
        case CPU_TYPE_ARM:
            return [
                (mask: CPU_SUBTYPE_ARM_V6, name: "armv6"),
                (mask: CPU_SUBTYPE_ARM_V7, name: "armv7"),
                (mask: CPU_SUBTYPE_ARM_V7F, name: "armv7f"),
                (mask: CPU_SUBTYPE_ARM_V7S, name: "armv7s"),
                (mask: CPU_SUBTYPE_ARM_V7K, name: "armv7k"),
                (mask: CPU_SUBTYPE_ARM_V7M, name: "armv7m"),
                (mask: CPU_SUBTYPE_ARM_V7EM, name: "armv7em"),
                (mask: CPU_SUBTYPE_ARM_V8, name: "armv8"),
                (mask: CPU_SUBTYPE_ARM_V8M, name: "armv8m")
            ].first(where: { self.subtype & $0.mask == $0.mask })?.name ?? "arm"
        case CPU_TYPE_ARM64:
            return [
                (mask: CPU_SUBTYPE_ARM64_V8, name: "arm64v8"),
                (mask: CPU_SUBTYPE_ARM64E, name: "arm64e")
            ].first(where: { self.subtype & $0.mask == $0.mask })?.name ?? "arm64"
        case CPU_TYPE_ARM64_32:
            return [
                (mask: CPU_SUBTYPE_ARM64_32_V8, name: "arm64_32v8"),
            ].first(where: { self.subtype & $0.mask == $0.mask })?.name ?? "arm64_32"
        case CPU_TYPE_X86 | CPU_TYPE_I386:
            return "x86"
        case CPU_TYPE_X86_64:
            return "x86_64"
        case _:
            return "unknown"
        }
    }

    /// An ordered list of registers for this CPU's architecture.
    var registers: [String] {
        switch type {
        case CPU_TYPE_ARM: return [
            "r0", "r1", "r2", "r3", "r4",  "r5",
            "r6", "r7", "r8", "r9", "r10", "r11",
            "ip", "sp", "lr", "pc", "cpsr"
        ]

        case CPU_TYPE_ARM64: return [
            "x0",  "x1",  "x2",  "x3",  "x4",
            "x5",  "x6",  "x7",  "x8",  "x9",
            "x10", "x11", "x12", "x13", "x14",
            "x15", "x16", "x17", "x18", "x19",
            "x20", "x21", "x22", "x23", "x24",
            "x25", "x26", "x27", "x28", "x29",
            "fp",  "sp",  "lr",  "pc",  "cspr"
        ]

        case CPU_TYPE_X86: return [
            "eax", "ebx", "ecx", "edx",
            "edi", "esi",
            "ebp", "esp", "ss", "eflags", "eip",
            "cs", "ds", "es", "fs", "gs"
        ]

        //case CPU_TYPE_X86_64: return [
        //    "rax", "rbx", "rcx", "rdx",
        //    "rdi", "rsi", "rbp", "rsp",
        //    "r8",  "r9",  "r10", "r11", "r12", "r13", "r14", "r15",
        //    "rip", "rfl", "cr2"
        //]

        case CPU_TYPE_X86_64: return [
            "rip", "rbp", "rsp",
            "rax", "rbx", "rcx", "rdx",
            "rdi", "rsi",
            "r8",  "r9",  "r10", "r11", "r12", "r13", "r14", "r15",
            "rflags", "cs", "fs", "gs"
        ]

        case _:
            return []
        }
    }
}

extension CPU: CustomDebugStringConvertible {

    var debugDescription: String {
        """
        CPU (\(self.typeName), \(self.subtypeName)) {
            type:    \(self.type)
            subtype: \(self.subtype)
        }
        """
    }
}
