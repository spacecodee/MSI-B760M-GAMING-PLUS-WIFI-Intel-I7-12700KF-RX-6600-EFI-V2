// numled — turn on the Num Lock LED of USB keyboards on macOS.
//
// macOS has no Num Lock concept, so it never lights that LED.
// This tool writes the LED output element (LED page 0x08, usage 0x01) directly.
//
// Usage:
//   numled on        Turn the Num Lock LED on once and exit.
//   numled off       Turn the Num Lock LED off once and exit.
//   numled --daemon  Keep the LED on: re-apply on keyboard connect,
//                    after wake from sleep and after Caps Lock presses.

import Foundation
import IOKit.hid
import IOKit.pwr_mgt

let keyboardMatch = [
    kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
    kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard,
] as CFDictionary

let numLockMatch = [
    kIOHIDElementUsagePageKey: kHIDPage_LEDs,
    kIOHIDElementUsageKey: kHIDUsage_LED_NumLock,
] as CFDictionary

/// Sets the Num Lock LED of one device. Returns true when at least one LED element accepted the value.
@discardableResult
func setNumLock(_ device: IOHIDDevice, on: Bool) -> Bool {
    guard let elements = IOHIDDeviceCopyMatchingElements(device, numLockMatch, IOOptionBits(kIOHIDOptionsTypeNone)) as? [IOHIDElement] else {
        return false
    }
    var applied = false
    for element in elements {
        let value = IOHIDValueCreateWithIntegerValue(kCFAllocatorDefault, element, 0, on ? 1 : 0)
        if IOHIDDeviceSetValue(device, element, value) == kIOReturnSuccess {
            applied = true
        }
    }
    return applied
}

func productName(_ device: IOHIDDevice) -> String {
    IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Unknown keyboard"
}

let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
IOHIDManagerSetDeviceMatching(manager, keyboardMatch)

func applyToAll(on: Bool) -> Int {
    guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return 0 }
    var count = 0
    for device in devices where setNumLock(device, on: on) {
        print("\(productName(device)): Num Lock LED \(on ? "on" : "off")")
        count += 1
    }
    return count
}

// A short delay lets macOS finish its own LED write before ours.
func reapplySoon() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { _ = applyToAll(on: true) }
}

// Globals so the C power callback can reach them.
var notifier: io_object_t = 0
var notifyPort: IONotificationPortRef?
var rootPort: io_connect_t = 0

// IOKit message macros are not imported into Swift (see IOMessage.h).
let kSystemCanSleep: UInt32 = 0xE000_0270
let kSystemWillSleep: UInt32 = 0xE000_0280
let kSystemHasPoweredOn: UInt32 = 0xE000_0300

let mode = CommandLine.arguments.dropFirst().first ?? "on"

switch mode {
case "on", "off":
    IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    if applyToAll(on: mode == "on") == 0 {
        fputs("numled: no keyboard with a Num Lock LED found\n", stderr)
        exit(1)
    }

case "--daemon":
    // Keyboard connected (also fires once per keyboard at startup).
    IOHIDManagerRegisterDeviceMatchingCallback(manager, { _, _, _, device in
        setNumLock(device, on: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { setNumLock(device, on: true) }
    }, nil)

    // macOS rewrites the whole LED report when Caps Lock toggles, which clears Num Lock.
    // Reading key events needs Input Monitoring permission; without it this callback stays silent.
    IOHIDManagerSetInputValueMatching(manager, [
        kIOHIDElementUsagePageKey: kHIDPage_KeyboardOrKeypad,
        kIOHIDElementUsageKey: kHIDUsage_KeyboardCapsLock,
    ] as CFDictionary)
    IOHIDManagerRegisterInputValueCallback(manager, { _, _, _, value in
        if IOHIDValueGetIntegerValue(value) == 0 { reapplySoon() }
    }, nil)

    IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))

    // Wake from sleep.
    rootPort = IORegisterForSystemPower(nil, &notifyPort, { _, _, messageType, argument in
        switch messageType {
        case kSystemHasPoweredOn:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { _ = applyToAll(on: true) }
        case kSystemCanSleep, kSystemWillSleep:
            IOAllowPowerChange(rootPort, Int(bitPattern: argument))
        default:
            break
        }
    }, &notifier)
    if rootPort != 0, let notifyPort {
        CFRunLoopAddSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(notifyPort).takeUnretainedValue(), .defaultMode)
    }

    CFRunLoopRun()

default:
    fputs("Usage: numled [on|off|--daemon]\n", stderr)
    exit(2)
}
