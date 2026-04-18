# Hackintosh EFI - MSI B760M GAMING PLUS WIFI + i7-12700KF

> [!NOTE]
> **Project Status:** ✅ **macOS Sequoia — Working**
> This EFI is confirmed working on **macOS Sequoia 15**. Wi-Fi and Bluetooth via `itlwm` are fully functional.

This repository contains the OpenCore configuration for a desktop Hackintosh system based on the 12th generation of Intel processors (Alder Lake).

## 💻 Hardware Specifications

| Component | Details |
|-----------|---------|
| **Motherboard** | MSI B760M GAMING PLUS WIFI |
| **CPU** | Intel Core i7-12700KF (12 Cores: 8P + 4E) |
| **GPU** | XFX Swft 210 AMD Radeon RX 6600 8GB GDDR6 |
| **RAM** | Crucial Pro DDR5 64GB (2×32GB) 6000MHz CL40 |
| **Storage** | Lexar 2TB NM790 SSD PCIe Gen4 NVMe M.2 |
| **Audio** | USB Audio Interface (Class Compliant — no AppleALC needed) |
| **Cooler** | Cooler Master Hyper 620S |
| **PSU** | Cooler Master GX II GOLD 750W |

## ✅ What Works

- [x] macOS Sequoia boot & installation
- [x] AMD Radeon RX 6600 (native support via WhateverGreen)
- [x] Intel Wi-Fi via `itlwm`
- [x] Intel Bluetooth via `IntelBluetoothFirmware` + `BlueToolFixup`
- [x] USB ports (mapped via USBToolBox + USBMap, done on Windows)
- [x] NVMe SSD (Lexar NM790)
- [x] CPU power management (Alder Lake E-cores + P-cores)
- [x] OTA updates (via `sbvmm` revpatch)
- [x] SIP fully enabled

## ⚙️ EFI Technical Details

- **Bootloader:** OpenCore REL-107
- **SMBIOS:** `MacPro7,1`
- **SIP (System Integrity Protection):** Fully Enabled (`csr-active-config` = `00000000`)
- **CPU Spoofing:** i7-12700KF spoofed as Comet Lake (`Cpuid1Data`: `0x0A0655`) for Apple compatibility
- **Boot Args:** `-v keepsyms=1 debug=0x100 agdpmod=pikera ctrsmt=full revpatch=sbvmm`

### 🛠️ Critical Configurations
1. **USB Mapping:** Mapped via USBToolBox on Windows; deployed as `USBToolBox.kext` + `USBMap.kext`
2. **Intel Wi-Fi / BT:** Using `itlwm` + `IntelBluetoothFirmware` stack (SIP-compatible)
3. **OTA Updates:** `sbvmm` injected in `revpatch` for System Settings update support
4. **Alder Lake HT Patch:** `_cpu_thread_alloc` kernel patch with `MinKernel` = `24.0.0`

### 📦 Included Kexts

| Category | Kexts |
|----------|-------|
| **Essentials** | Lilu, WhateverGreen, VirtualSMC |
| **Wi-Fi / BT** | itlwm, IntelBluetoothFirmware, IntelBTPatcher, BlueToolFixup |
| **Ethernet** | RTL812xLucy |
| **CPU / Alder Lake** | RestrictEvents, CpuTopologyRebuild, CPUFriend, CPUFriendDataProvider |
| **SMC Sensors** | SMCProcessor, SMCSuperIO, SMCRadeonSensors |
| **Storage / USB** | NVMeFix, SATA-unsupported, USBToolBox, USBMap |

### 📝 Injected SSDTs

| SSDT | Purpose |
|------|---------|
| `SSDT-PLUG-ALT` | Power management for Alder Lake |
| `SSDT-RTCAWAC` | System clock fix for Intel 700 series |
| `SSDT-EC` + `SSDT-USBX` | Fake EC controller and USB power |
| `SSDT-SBUS-MCHC-DVL0` | Apple SMBus injection |
| `SSDT-HPET` | IRQ conflict resolution |
| `SSDT-USB-Reset` | USB controller reset |

## ⚠️ Important Notes

- **Generate your own SMBIOS serials** before using this EFI. Use [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) to create unique `SystemSerialNumber`, `MLB`, and `SystemUUID` values. Using shared serials will break iServices.
- **iServices** (iMessage, FaceTime, iCloud) require valid, unique SMBIOS serials.
- This EFI has **no Secure Boot** support — keep it disabled in BIOS.

## 🏆 Credits

- [Acidanthera](https://github.com/acidanthera) — OpenCore, Lilu, WhateverGreen, VirtualSMC and all core tools
- [Dortania](https://dortania.github.io/OpenCore-Install-Guide/) — OpenCore Install Guide
- [USBToolBox](https://github.com/USBToolBox/tool) — USB mapping tool
- [OpenIntelWireless](https://github.com/OpenIntelWireless) — itlwm & IntelBluetoothFirmware

---
*If you use this EFI, always generate your own SMBIOS serials with GenSMBIOS before booting.*
