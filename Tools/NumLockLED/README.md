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

### Required: Input Monitoring

Processes started by launchd cannot open keyboards without Input Monitoring, so the daemon cannot touch the LED until you allow it. Running `./numled on` from Terminal works without this step because Terminal already has the permission.

1. Open **System Settings > Privacy & Security > Input Monitoring**.
2. Turn on `numled`. If it is not listed, click **+** and add `~/.local/bin/numled` (press `Cmd+Shift+G` to type the path).

The daemon waits until the permission is granted, then starts. No restart is needed.

Each reinstall builds a new binary, and macOS treats it as a different app: turn the permission off and on again after running `./install.sh`.

### What the daemon does

- Turns the LED on when a keyboard connects and after wake from sleep.
- Restores it after Caps Lock presses (macOS rewrites all keyboard LEDs when Caps Lock toggles).
- Checks the LED every second and turns it back on if anything cleared it, such as macOS during login.

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
