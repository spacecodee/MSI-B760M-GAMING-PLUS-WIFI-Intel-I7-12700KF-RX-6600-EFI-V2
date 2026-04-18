# Hackintosh EFI - MSI B760M GAMING PLUS WIFI + i7-12700KF

> [!WARNING]
> **Project Status:** 🚧 **EXPERIMENTAL / UNTESTED** 🚧
> This EFI has been built to run natively on **macOS Sequoia** and allow a future upgrade to **macOS Tahoe**. It is currently in the testing phase.

This repository contains the OpenCore configuration for a desktop Hackintosh system based on the 12th generation of Intel processors (Alder Lake).

## 💻 Hardware Specifications

*   **Motherboard:** MSI B760M GAMING PLUS WIFI
*   **Processor (CPU):** Intel Core i7-12700KF (12 Cores: 8 P-Cores / 4 E-Cores)
*   **Graphics Card (GPU):** XFX Swft 210 AMD Radeon RX 6600 8GB GDDR6
*   **RAM:** Crucial Pro DDR5 64GB (2x32GB) 6000MHz CL40
*   **Storage:** Lexar 2TB NM790 SSD PCIe Gen4 NVMe M.2
*   **Base Audio:** Audio via USB Interface (Class Compliant - No VoodooHDA/AppleALC needed)
*   **Cooler:** Cooler Master Hyper 620S
*   **Power Supply (PSU):** Cooler Master GX II GOLD 750W

## ⚙️ EFI Technical Details

*   **Bootloader:** OpenCore
*   **SMBIOS:** `MacPro7,1`
*   **SIP (System Integrity Protection):** Fully Enabled (`csr-active-config` set to `00000000`)
*   **CPU Spoofing:** The i7-12700KF is spoofed via `Cpuid1Data` to present itself as a Comet Lake (ID `0x0A0655`) due to the lack of official Apple support for Gen 12.

### 🛠️ Critical Configurations
1.  **HyperThreading Patch:** A kernel patch was configured (`_cpu_thread_alloc`) with `MinKernel` pointing to `24.0.0` (Sequoia and above).
2.  **Intel Wi-Fi/BT:** Using the `itlwm` and `IntelBluetoothFirmware` stack to keep SIP Enabled.
3.  **OTA Updates:** Injected `sbvmm` in `revpatch` to ensure support for installing system updates directly via System Settings.

### 📂 Included Kexts
*   **Essentials:** Lilu, WhateverGreen, VirtualSMC
*   **Network / Bluetooth:** RTL812xLucy, itlwm, IntelBluetoothFirmware, IntelBTPatcher, BlueToolFixup
*   **CPU / Alder Lake:** RestrictEvents, CpuTopologyRebuild, CPUFriend, CPUFriendDataProvider
*   **SMC Sensors:** SMCProcessor, SMCSuperIO, SMCRadeonSensors
*   **Storage / USB:** NVMeFix, SATA-unsupported, USBToolBox, USBMap

### 📝 Injected SSDTs
*   `SSDT-PLUG-ALT` (Power management for Alder Lake)
*   `SSDT-RTCAWAC` (System clock for Intel 700 series)
*   `SSDT-EC` & `SSDT-USBX` (Fake EC controller and USB power)
*   `SSDT-SBUS-MCHC-DVL0` (Apple SMBus injection)
*   `SSDT-HPET` (IRQ conflicts resolution)
*   `SSDT-USB-Reset` (USB controllers reset)

## 📌 Next Steps
1.  Generate valid SMBIOS (`SystemSerialNumber`, `MLB`, `SystemUUID`) and insert them into the `config.plist`.
2.  Format the bootable USB or the EFI partition of the Lexar NM790.
3.  Test boot in the **macOS Sequoia** environment.
4.  Perform stability tests on the Lexar NM790, considering its Maxio controller.
5.  Upgrade to **macOS Tahoe**.

## 🏆 Credits

A massive thank you to the open-source Hackintosh community, and specifically to:
*   [Acidanthera](https://github.com/acidanthera) for OpenCore, Lilu, WhateverGreen, VirtualSMC, and all the essential tools that make this possible.
*   [Dortania](https://dortania.github.io/OpenCore-Install-Guide/) for their incredibly detailed OpenCore Install Guide and continuous support.

---
*If you use this configuration, make sure to generate your own serials for iServices using tools like GenSMBIOS.*
