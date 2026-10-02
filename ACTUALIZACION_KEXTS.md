# Plan de Actualizacion de Kexts para OpenCore

Este documento contiene las especificaciones tecnicas y los pasos exactos para que el agente ejecute la actualizacion de los kexts pendientes en la EFI.

## Ubicaciones Clave

- Directorio EFI: `MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/EFI`
- Directorio de Kexts: `MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/EFI/OC/Kexts`
- Archivo config.plist: `MSI-B760M-GAMING-PLUS-WIFI-Intel-I7-12700KF-RX-6600-EFI-V2/EFI/OC/config.plist`

## Kexts a Actualizar

1. VirtualSMC Suite
   - Componentes: VirtualSMC.kext, SMCProcessor.kext, SMCSuperIO.kext
   - Version actual: 1.3.7
   - Version objetivo: 1.3.8
   - Repositorio oficial: https://github.com/acidanthera/VirtualSMC/releases/latest
   - Descarga directa: Buscar asset VirtualSMC-1.3.8-RELEASE.zip

2. WhateverGreen
   - Componente: WhateverGreen.kext
   - Version actual: 1.7.0
   - Version objetivo: 1.7.1
   - Repositorio oficial: https://github.com/acidanthera/WhateverGreen/releases/latest
   - Descarga directa: Buscar asset WhateverGreen-1.7.1-RELEASE.zip

3. LucyRTL8125Ethernet (Realtek 2.5GbE)
   - Componente actual: RTL812xLucy.kext (Version 1.1.1)
   - Version objetivo: LucyRTL8125Ethernet.kext (Version 1.2.3)
   - Repositorio oficial: https://github.com/Mieze/LucyRTL8125Ethernet/releases/latest
   - Descarga directa: Buscar asset LucyRTL8125Ethernet-1.2.300.zip
   - Nota para config.plist: Si el nuevo kext se llama `LucyRTL8125Ethernet.kext`, actualizar el campo `BundlePath` en `Kernel -> Add` dentro de `config.plist` (o conservar el nombre `RTL812xLucy.kext` si se prefiere no alterar el plist).

## Procedimiento de Ejecucion para el Agente

1. Crear carpeta temporal en `/tmp/kext_update`.
2. Descargar los releases correspondientes desde la API de GitHub o enlaces oficiales de Release.
3. Extraer los archivos `.zip` y copiar los `.kext` reemplazando los existentes en `EFI/OC/Kexts/`.
4. Asignar permisos y eliminar atributos extendidos si aplica (`xattr -cr`).
5. En caso de cambio de nombre de archivo (por ejemplo RTL812xLucy -> LucyRTL8125Ethernet), sincronizar la clave correspondiente en `Kernel -> Add` de `config.plist`.
6. Validar la integridad del `config.plist` mediante lectura estructurada o con `ocvalidate` si esta disponible.
7. Limpiar los archivos temporales en `/tmp/kext_update`.
8. Reportar al usuario las versiones finales aplicadas y el estado del repositorio git.
