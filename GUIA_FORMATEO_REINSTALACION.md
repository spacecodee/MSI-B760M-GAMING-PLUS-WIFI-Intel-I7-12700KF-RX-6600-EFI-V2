# Guía para Formatear o Restablecer Hackintosh desde Cero

Esta guía explica el procedimiento recomendado y seguro para reinstalar macOS desde cero en tu Hackintosh (**MSI B760M GAMING PLUS WIFI + i7-12700KF + RX 6600**), evitando perder el acceso al sistema o romper el arranque OpenCore.

---

## ⚠️ Advertencia Fundamental en Hackintosh

> **NUNCA utilices la opción nativa "Borrar contenidos y ajustes" (Erase All Content and Settings) de macOS.**
> En un Hackintosh esto suele corromper el arranque OpenCore, dejar el sistema en bootloop o romper NVRAM.
> El método 100% confiable y recomendado por la comunidad OpenCore es **hacer una instalación limpia mediante una memoria USB Booteable**.

---

## 1. Preparativos Previos (Imprescindibles)

### A. Respaldo de tu información
- Haz copia de tus archivos importantes en un disco externo o en la nube (Time Machine, disco USB, Google Drive, etc.).

### B. Ten siempre un USB de rescate con tu EFI funcional
1. Consigue un pendrive USB (puede ser de 4GB a 16GB, formateado en **FAT32** con esquema **MBR** o **GUID**).
2. Monta su partición EFI (o usa la raíz si está formateada en FAT32) y copia la carpeta `EFI` de tu proyecto:
   ```bash
   # La carpeta EFI debe contener BOOT y OC
   EFI/
   ├── BOOT/
   └── OC/
   ```
3. **¿Por qué?** Si durante el formateo se borra por error la partición EFI de tu disco principal, podrás iniciar el ordenador conectando este USB y seleccionándolo desde el menú de arranque del BIOS (tecla `F11` en MSI).

---

## 2. Crear el USB Instalador de macOS

Si aún tienes macOS funcionando:

1. **Descargar el instalador oficial de macOS**:
   - Descarga la versión deseada (Sonoma, Sequoia, etc.) desde la App Store o usando la herramienta [`gibMacOS`](https://github.com/corpnewt/gibMacOS) o `mist-cli`.
2. **Crear el medio de instalación en el pendrive (mínimo 16GB)**:
   - Abre la Terminal y ejecuta el comando nativo `createinstallmedia`:
     ```bash
     sudo /Applications/Install\ macOS\ Sonoma.app/Contents/Resources/createinstallmedia --volume /Volumes/MiUSB
     ```
     *(Ajusta la ruta según la versión que descargues y el nombre de tu pendrive).*
3. **Copiar tu EFI al instalador**:
   - Una vez finalizada la creación, monta la partición EFI del pendrive USB (usando una herramienta como *MountEFI*, *OpenCore Configurator* o vía terminal con `diskutil`).
   - Pega tu carpeta `EFI` actualizada (la que tiene el SMBIOS recién configurado) en la partición EFI del pendrive.

---

## 3. Proceso de Formateo e Instalación Limpia

1. **Arrancar desde el instalador**:
   - Apaga o reinicia tu PC.
   - Presiona repetidamente **F11** para acceder al menú de arranque de la placa MSI.
   - Selecciona tu pendrive USB (versión UEFI).
   - En el menú gráfico de OpenCore, selecciona **Install macOS...**.

2. **Formatear el disco con Utilidad de Discos**:
   - En la pantalla de bienvenida del instalador, selecciona **Utilidad de Discos** (Disk Utility) y pulsa *Continuar*.
   - Arriba a la izquierda, haz clic en **Visualización** -> **Mostrar todos los dispositivos** (`Show All Devices`).
   - Selecciona el **disco físico principal** donde se instalará macOS (no el volumen hijo, sino la raíz de tu SSD NVMe).
   - Haz clic en **Borrar** (Erase) y configura los siguientes parámetros:
     - **Nombre**: `Macintosh HD` (o el de tu preferencia).
     - **Formato**: `APFS`.
     - **Esquema**: `Mapa de particiones GUID` (*GUID Partition Map*).
   - Confirma el borrado. Una vez terminado, cierra Utilidad de Discos.

3. **Instalar macOS**:
   - Elige la opción **Instalar macOS** y sigue el asistente seleccionando el disco que acabas de formatear (`Macintosh HD`).
   - El equipo se reiniciará varias veces (generalmente entre 2 y 4 veces).
   - En cada reinicio, mantén el USB conectado y deja que OpenCore arranque automáticamente la opción que dice **macOS Installer** o el nombre de tu disco hasta completar la instalación y llegar a la pantalla de configuración de cuenta/idioma.

---

## 4. Post-Instalación: Hacer el arranque autónomo (Sin USB)

Una vez llegues al escritorio de macOS recién instalado:

1. Monta la partición EFI del **disco interno SSD** y la partición EFI del **USB instalador**.
2. Copia la carpeta `EFI` del USB a la partición EFI de tu SSD interno.
3. Expulsa el USB y reinicia el equipo.
4. En el primer inicio autónomo:
   - Entra al BIOS (tecla `DEL` o `F2`) y asegúrate de que tu SSD (con OpenCore) esté como **Opción 1 de arranque**.
   - Haz un **Reset NVRAM** desde el menú de OpenCore si notas algún comportamiento inusual.

---

## 5. Recomendaciones de Servicios Apple (iMessage, iCloud)

Dado que acabas de generar un nuevo SMBIOS:
- Antes de iniciar sesión con tu Apple ID, verifica la conexión de red (Ethernet `en0` como dispositivo Built-in).
- No uses un Apple ID nuevo o sin actividad; un Apple ID con historial de compras/tarjeta previa evita bloqueos automáticos en nuevos números de serie de Hackintosh.
