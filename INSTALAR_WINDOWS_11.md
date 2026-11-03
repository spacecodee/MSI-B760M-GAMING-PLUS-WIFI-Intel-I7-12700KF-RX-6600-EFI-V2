# Instalar Windows 11 en este equipo (ex-Hackintosh)

Guía para pasar de macOS (OpenCore) a Windows 11 en la **MSI B760M Gaming Plus WiFi** (i7-12700KF + RX 6600).

> Los nombres de los menús pueden variar según la versión de BIOS.

## 1. Preparación

- Descargá la ISO oficial de Windows 11 y creá el USB con **Rufus** (esquema **GPT**, destino **UEFI**) o con el Media Creation Tool.
- La placa trae LAN **Realtek 2.5G**. El instalador a veces no incluye su driver:
  guardá el driver de MSI en otro pendrive, o tené a mano WiFi / tethering del celular.
- Desconectá los demás discos durante la instalación para no pisar datos por error.

## 2. BIOS

Entrá con `Del` al arrancar.

### 2.1 Reset a valores de fábrica

1. Presioná `F9` (**Load Optimized Defaults**) y guardá con `F10`.
2. Opcional: hacé un **Clear CMOS** para eliminar por completo los ajustes de hackintosh
   (CFG Lock, VT-d, Above 4G, etc.).

### 2.2 Requisitos de Windows 11

| Ajuste | Ruta | Valor |
| --- | --- | --- |
| TPM 2.0 | `Settings → Security → Trusted Computing` | *Security Device Support*: **Enabled**, *TPM Device Selection*: **PTT** |
| Secure Boot | `Settings → Security → Secure Boot` | **Enabled**, con las claves de fábrica (*Factory Key Provision* / *Install default keys*) |
| Modo de arranque | `Settings → Boot` | **UEFI only**, CSM/Legacy **Disabled** |
| Modo de disco | `Settings → Advanced → Integrated Peripherals` | SATA en **AHCI** |
| Intel VMD / RST | `Settings → Advanced` | **Disabled** (así el instalador ve el NVMe sin drivers) |

### 2.3 Recomendados

| Ajuste | Valor | Motivo |
| --- | --- | --- |
| XMP / EXPO | Enabled | RAM a su velocidad nominal |
| Above 4G Decoding | Enabled | Requisito de Resizable BAR |
| Resizable BAR | Enabled | Mejor rendimiento de la RX 6600 (SAM) |
| Fast Boot | Disabled | Evita problemas durante la instalación |

## 3. Limpiar el disco de macOS

Si Windows va en el mismo disco que macOS:

1. En el instalador, en la pantalla de particiones, **borrá todas** las particiones del disco,
   incluida la **EFI** de OpenCore.
2. Seleccioná el espacio sin asignar y continuá. Windows crea sus propias particiones.

Si la EFI de OpenCore queda, puede seguir apareciendo en el menú de arranque.

## 4. Instalación

1. Arrancá desde el USB (`F11` abre el Boot Menu) y elegí la entrada **UEFI: <tu USB>**.
2. Instalá Windows 11 normalmente.
3. Si no hay red, instalá el driver LAN Realtek desde el pendrive o conectate por tethering.

## 5. Después de instalar

1. Ejecutá Windows Update.
2. Instalá los drivers de **AMD Adrenalin** (RX 6600) y el **chipset Intel** desde las páginas oficiales.
3. Verificá `tpm.msc` (TPM 2.0 presente) y `msinfo32` (*Secure Boot State*: **On**).
4. Confirmá en Adrenalin que **Smart Access Memory** está activo.

## 6. Dónde buscar los drivers

| Componente | Hardware | Dónde buscarlo |
| --- | --- | --- |
| GPU | XFX RX 6600 8GB | **AMD Adrenalin** (amd.com/support). No usar el de XFX. |
| Chipset / ME / Serial IO | Intel B760 + i7-12700KF | **Intel Driver & Support Assistant** o la página de la placa en msi.com |
| LAN | Realtek 2.5G | Página de soporte de la placa en msi.com |
| Wi-Fi y Bluetooth | Intel (`itlwm` + `IntelBluetoothFirmware` en macOS) | Windows Update, o Intel Driver & Support Assistant |
| SSD | Lexar NM790 NVMe | Driver NVMe nativo de Windows. Firmware solo si hace falta (Lexar) |
| Audio | Interfaz USB class-compliant | No necesita driver. El audio onboard usaría el Realtek de MSI |

Descargá el driver de la **LAN** antes de formatear y guardalo en un pendrive.

El modelo exacto del chip Intel Wi-Fi/BT (AX211, AX210, etc.) se ve en el Administrador de dispositivos.

## Problemas comunes

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| "Este equipo no puede ejecutar Windows 11" | TPM o Secure Boot apagados | Revisar la sección 2.2 |
| El instalador no ve el disco NVMe | Intel VMD/RST activo | Desactivarlo en BIOS |
| Sin internet en el instalador | Falta driver Realtek 2.5G | Driver en pendrive o tethering |
| Aparece OpenCore al arrancar | EFI vieja sin borrar | Borrar todas las particiones del disco (sección 3) |
