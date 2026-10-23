// numled — turn on the Num Lock LED of USB keyboards on macOS.
//
// macOS has no Num Lock concept, so it never lights that LED.
// This tool writes the LED output element (LED page 0x08, usage 0x01) directly.
//
// Usage:
//   numled on        Turn the Num Lock LED on once and exit.
//   numled off       Turn the Num Lock LED off once and exit.
//   numled --daemon  Keep the LED on: re-apply on keyboard connect,
//                    after wake from sleep, after Caps Lock presses
//                    and whenever a 1 s watchdog finds it off.

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

/// Reads the Num Lock LED state from the kernel's cached element value (no USB traffic).
/// A long-lived handle only sees its own writes, so a fresh handle is opened per read
/// to also see writes made by macOS.
func isNumLockOn(_ device: IOHIDDevice) -> Bool? {
    guard let fresh = IOHIDDeviceCreate(kCFAllocatorDefault, IOHIDDeviceGetService(device)),
          IOHIDDeviceOpen(fresh, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else {
        return nil
    }
    defer { IOHIDDeviceClose(fresh, IOOptionBits(kIOHIDOptionsTypeNone)) }
    guard let element = (IOHIDDeviceCopyMatchingElements(fresh, numLockMatch, IOOptionBits(kIOHIDOptionsTypeNone)) as? [IOHIDElement])?.first else {
        return nil
    }
    var value = Unmanaged.passUnretained(IOHIDValueCreateWithIntegerValue(kCFAllocatorDefault, element, 0, 0))
    guard IOHIDDeviceGetValue(fresh, element, &value) == kIOReturnSuccess else { return nil }
    return IOHIDValueGetIntegerValue(value.takeUnretainedValue()) != 0
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
    // launchd redirects stdout to a log file; flush every line so the log stays current.
    setvbuf(stdout, nil, _IOLBF, 0)

    // Without Input Monitoring, launchd-started processes cannot open keyboards at all,
    // so no LED write reaches the device. Terminal runs work because Terminal has it.
    if IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) != kIOHIDAccessTypeGranted {
        print("\(Date()) Input Monitoring not granted. Enable numled in System Settings > Privacy & Security > Input Monitoring")
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        while IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) != kIOHIDAccessTypeGranted {
            sleep(5)
        }
        print("\(Date()) Input Monitoring granted")
    }

    // Keyboard connected (also fires once per keyboard at startup).
    IOHIDManagerRegisterDeviceMatchingCallback(manager, { _, _, _, device in
        setNumLock(device, on: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { setNumLock(device, on: true) }
    }, nil)

    // macOS rewrites the whole LED report when Caps Lock toggles, which clears Num Lock.
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

    // Watchdog: macOS clears the LED during login and on other LED writes we get no event for.
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return }
        for device in devices where isNumLockOn(device) == false && setNumLock(device, on: true) {
            print("\(Date()) \(productName(device)): Num Lock LED was cleared, turned back on")
        }
    }

    CFRunLoopRun()

default:
    fputs("Usage: numled [on|off|--daemon]\n", stderr)
    exit(2)
}
