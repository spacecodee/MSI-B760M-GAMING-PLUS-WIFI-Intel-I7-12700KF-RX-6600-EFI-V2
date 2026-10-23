# NumLockLED

Turns on the Num Lock LED of USB keyboards on macOS. Tested with a **Redragon Shiva K512** (`USB Gaming Keyboard`, VID `6700`, PID `19277`).

## Why the LED stays off

macOS has no Num Lock: the keypad always sends numbers, so the system never asks the keyboard to light that LED. This is macOS behavior, not an EFI problem. OpenCore stops running once macOS boots, so **no EFI change can fix it**.

`numled` writes the keyboard's Num Lock LED output element (HID LED page `0x08`, usage `0x01`) directly.

## Requirements

- Swift compiler (`swiftc`). Install it with `xcode-select --install` if missing.

## Run once

```bash
cd Tools/NumLockLED
swiftc -O numled.swift -o numled
./numled on     # LED on
./numled off    # LED off
```

The LED turns off again after sleep, replugging the keyboard or pressing Caps Lock. To keep it on, install the LaunchAgent below.

## Install (keeps the LED on)

```bash
cd Tools/NumLockLED
./install.sh
```

This script:

1. Builds `numled` into `~/.local/bin/numled`.
2. Creates `~/Library/LaunchAgents/local.numled.plist`, which runs `numled --daemon` at every login.
3. Starts it immediately.

The daemon turns the LED back on when a keyboard connects and after wake from sleep.

### Optional: Caps Lock

macOS rewrites all keyboard LEDs when Caps Lock toggles, which clears Num Lock. To restore the LED after Caps Lock, the daemon must read key events:

1. Open **System Settings > Privacy & Security > Input Monitoring**.
2. Click **+** and add `~/.local/bin/numled` (press `Cmd+Shift+G` to type the path).
3. Restart the daemon: `launchctl kickstart -k gui/$(id -u)/local.numled`

Without this permission, everything else still works.

## Check status

```bash
launchctl print gui/$(id -u)/local.numled | grep state
cat ~/Library/Logs/numled.log
```

## Uninstall

```bash
cd Tools/NumLockLED
./uninstall.sh
```
