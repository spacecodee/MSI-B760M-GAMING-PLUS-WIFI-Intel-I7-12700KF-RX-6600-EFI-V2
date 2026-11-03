<div align="center">

# Hackintosh EFI

### MSI B760M GAMING PLUS WIFI · Intel Core i7-12700KF · Radeon RX 6600

A clean, working **OpenCore** configuration for a 12th-gen (Alder Lake) desktop Hackintosh.

[![macOS Tahoe](https://img.shields.io/badge/macOS-Tahoe%2026-blueviolet?style=for-the-badge&logo=apple&logoColor=white)](#version-history)
[![macOS Sequoia](https://img.shields.io/badge/macOS-Sequoia%2015-informational?style=for-the-badge&logo=apple&logoColor=white)](#version-history)
[![OpenCore](https://img.shields.io/badge/OpenCore-1.0.8-success?style=for-the-badge)](https://github.com/acidanthera/OpenCorePkg)
[![SIP](https://img.shields.io/badge/SIP-Enabled-brightgreen?style=for-the-badge)](#efi-technical-details)

[![Latest release](https://img.shields.io/github/v/tag/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2?style=flat-square&label=release&color=blue)](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/tags)
[![Last commit](https://img.shields.io/github/last-commit/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2?style=flat-square)](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/commits/main)
[![Stars](https://img.shields.io/github/stars/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2?style=flat-square)](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/stargazers)
[![Forks](https://img.shields.io/github/forks/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2?style=flat-square)](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/network/members)

[Hardware](#hardware-specifications) · [What Works](#what-works) · [Technical Details](#efi-technical-details) · [Kexts](#included-kexts) · [Windows 11](#switching-to-windows-11) · [Credits](#credits)

</div>

---

> [!NOTE]
> **Project status: working on macOS Sequoia 15 and macOS Tahoe 26.**
> Wi-Fi and Bluetooth via `itlwm` are fully functional.

## Table of Contents

- [Version History](#version-history)
- [Hardware Specifications](#hardware-specifications)
- [What Works](#what-works)
- [EFI Technical Details](#efi-technical-details)
- [Included Kexts](#included-kexts)
- [Injected SSDTs](#injected-ssdts)
- [Extra Guides and Tools](#extra-guides-and-tools)
- [Switching to Windows 11](#switching-to-windows-11)
- [Important Notes](#important-notes)
- [Credits](#credits)

## Version History

| Tag | macOS | Status | Notes |
| --- | --- | --- | --- |
| [`v1.0-sequoia`](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/releases/tag/v1.0-sequoia) | Sequoia 15 | Stable | First stable release |
| [`v1.1-tahoe`](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/releases/tag/v1.1-tahoe) | Tahoe 26 | Working | USB port schema fix for Tahoe |
| [`v1.2-tahoe`](https://github.com/spacecodee/MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/releases/tag/v1.2-tahoe) | Tahoe 26 | Working | OpenCanopy theme, debug off, picker tuning |

## Hardware Specifications

| Component | Details |
| --- | --- |
| **Motherboard** | MSI B760M GAMING PLUS WIFI |
| **CPU** | Intel Core i7-12700KF (12 cores: 8P + 4E) |
| **GPU** | XFX Swft 210 AMD Radeon RX 6600 8GB GDDR6 |
| **RAM** | Crucial Pro DDR5 64GB (2×32GB) 6000MHz CL40 |
| **Storage** | Lexar 2TB NM790 SSD PCIe Gen4 NVMe M.2 |
| **Audio** | USB Audio Interface (class-compliant, no AppleALC needed) |
| **Cooler** | Cooler Master Hyper 620S |
| **PSU** | Cooler Master GX II GOLD 750W |

## What Works

- [x] macOS Sequoia boot and installation
- [x] macOS Tahoe boot and installation
- [x] AMD Radeon RX 6600 (native support via WhateverGreen)
- [x] Intel Wi-Fi via `itlwm`
- [x] Intel Bluetooth via `IntelBluetoothFirmware` + `BlueToolFixup`
- [x] USB ports (mapped via USBToolBox + USBMap, done on Windows)
- [x] NVMe SSD (Lexar NM790)
- [x] CPU power management (Alder Lake E-cores + P-cores)
- [x] OTA updates (via `sbvmm` revpatch)
- [x] SIP fully enabled

## EFI Technical Details

| Setting | Value |
| --- | --- |
| **Bootloader** | OpenCore REL-108 (1.0.8) |
| **SMBIOS** | `MacPro7,1` |
| **SIP** | Fully enabled (`csr-active-config` = `00000000`) |
| **CPU spoofing** | i7-12700KF as Comet Lake (`Cpuid1Data`: `0x0A0655`) for Apple compatibility |
| **Boot args** | `agdpmod=pikera` |
| **RestrictEvents (NVRAM `4D1FDA02-…`)** | `revpatch=sbvmm,pci,cpuname`, `revcpu=1`, `revcpuname=12-Core Intel i7-12700KF` |

### Critical Configurations

1. **USB mapping:** mapped via USBToolBox on Windows; deployed as `USBToolBox.kext` + `USBMap.kext`.
2. **Intel Wi-Fi / BT:** `itlwm` + `IntelBluetoothFirmware` stack (SIP-compatible).
3. **OTA updates:** `sbvmm` injected in `revpatch` for System Settings update support.
4. **RestrictEvents `revpatch`:** `pci` hides the MacPro7,1 PCI slots view. Keep `revpatch` out of `boot-args`: a boot-arg overrides the NVRAM value. On Tahoe the CPU still shows as "Unknown" (cosmetic): `cpuname` only renames core counts that match a Mac Pro model, and this CPU reports 20 cores.
5. **XhciPortLimit:** enabled (`true`), required for Tahoe compatibility with the USB port map.

<details>
<summary><b>Tahoe USB fix (v1.1)</b></summary>

<br>

macOS Tahoe changed the USB port descriptor schema inside `USBMap.kext/Contents/Info.plist`.
Previous Sequoia maps only declared a `port` key per entry. **Tahoe requires two additional keys per port:**

```xml
<key>usb-port-number</key>
<data>AQAAAA==</data>   <!-- port number encoded as little-endian Base64 -->
<key>usb-port-type</key>
<integer>3</integer>    <!-- 0 = USB 2.0, 3 = USB 3.x, 255 = internal -->
```

Without these keys, the HID (Human Interface Device) stack fails to initialize after kernel handoff,
leaving keyboard and mouse completely unresponsive at the login screen even though the system is running.

</details>

<details>
<summary><b>OpenCanopy theme and picker tuning (v1.2)</b></summary>

<br>

The boot picker uses the **chris1111/Flavours-macOS26** OpenCanopy theme with the following configuration:

| Key | Value | Notes |
| --- | --- | --- |
| `PickerMode` | `External` | Enables OpenCanopy GUI picker |
| `PickerVariant` | `chris1111\Flavours-macOS26` | macOS 26-style icon set |
| `PickerAttributes` | `145` | Mouse/pointer support + volume icons (128 + 17) |
| `HibernateSkipsPicker` | `true` | Skip picker on wake from hibernation |
| `HideAuxiliary` | `true` | Tools hidden by default, press **Space** to reveal |

Debug logging was fully disabled for a clean boot experience:

| Key | Value | Effect |
| --- | --- | --- |
| `Target` | `0` | No log files written, no verbose screen |
| `AppleDebug` | `false` | Kernel debug output off |
| `ApplePanic` | `false` | No panic log files |
| `boot-args` | removed `-v keepsyms=1 debug=0x100` | Silent graphical boot |

</details>

## Included Kexts

| Category | Kexts |
| --- | --- |
| **Essentials** | Lilu, WhateverGreen, VirtualSMC |
| **Wi-Fi / BT** | itlwm, IntelBluetoothFirmware, IntelBTPatcher, BlueToolFixup |
| **Ethernet** | RTL812xLucy |
| **CPU / Alder Lake** | RestrictEvents, CPUFriend, CPUFriendDataProvider |
| **SMC sensors** | SMCProcessor, SMCSuperIO, SMCRadeonSensors |
| **Storage / USB** | NVMeFix, SATA-unsupported, USBToolBox, USBMap |

## Injected SSDTs

| SSDT | Purpose |
| --- | --- |
| `SSDT-PLUG-ALT` | Power management for Alder Lake |
| `SSDT-RTCAWAC` | System clock fix for Intel 700 series |
| `SSDT-EC` + `SSDT-USBX` | Fake EC controller and USB power |
| `SSDT-SBUS-MCHC-DVL0` | Apple SMBus injection |
| `SSDT-HPET` | IRQ conflict resolution |
| `SSDT-USB-Reset` | USB controller reset |

## Extra Guides and Tools

| Resource | Description |
| --- | --- |
| [`ACTUALIZACION_KEXTS.md`](ACTUALIZACION_KEXTS.md) | Kext update plan (Spanish) |
| [`GUIA_FORMATEO_REINSTALACION.md`](GUIA_FORMATEO_REINSTALACION.md) | Reinstalling macOS from scratch (Spanish) |
| [`INSTALAR_WINDOWS_11.md`](INSTALAR_WINDOWS_11.md) | Installing Windows 11 on this hardware (Spanish) |
| [`Tools/NumLockLED`](Tools/NumLockLED/README.md) | User-space fix for the Num Lock LED on external keyboards |

## Switching to Windows 11

Planning to install Windows 11 on this hardware? See [`INSTALAR_WINDOWS_11.md`](INSTALAR_WINDOWS_11.md) for the BIOS settings and install steps (Spanish). Where to get each driver:

| Component | Hardware | Where to get the driver |
| --- | --- | --- |
| GPU | XFX RX 6600 8GB | AMD Adrenalin (amd.com/support), not the XFX package |
| Chipset / ME / Serial IO | Intel B760 + i7-12700KF | Intel Driver & Support Assistant or the MSI board support page |
| LAN | Realtek 2.5G | MSI board support page (download it before wiping the disk) |
| Wi-Fi / Bluetooth | Intel | Windows Update or Intel Driver & Support Assistant |
| SSD | Lexar NM790 NVMe | Native Windows NVMe driver |
| Audio | USB class-compliant interface | No driver needed |

## Important Notes

> [!WARNING]
> **Generate your own SMBIOS serials** before using this EFI. Use [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) to create unique `SystemSerialNumber`, `MLB`, and `SystemUUID` values. Shared serials will break iServices (iMessage, FaceTime, iCloud).

- This EFI has **no Secure Boot** support: keep it disabled in BIOS.
- **Num Lock LED** stays off on external keyboards because macOS has no Num Lock. This is not an EFI issue; see [`Tools/NumLockLED`](Tools/NumLockLED/README.md) for a user-space fix.

## Credits

- [Acidanthera](https://github.com/acidanthera): OpenCore, Lilu, WhateverGreen, VirtualSMC and all core tools
- [Dortania](https://dortania.github.io/OpenCore-Install-Guide/): OpenCore Install Guide
- [USBToolBox](https://github.com/USBToolBox/tool): USB mapping tool
- [OpenIntelWireless](https://github.com/OpenIntelWireless): itlwm and IntelBluetoothFirmware
- [chris1111](https://github.com/chris1111): Flavours-macOS26 OpenCanopy theme

---

<div align="center">

*If you use this EFI, always generate your own SMBIOS serials with GenSMBIOS before booting.*

If this repo helped you, consider giving it a star!

</div>
