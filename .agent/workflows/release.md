---
description: How to publish a new release of SnakeUSBIP
---

# SnakeUSBIP Release Workflow

// turbo-all

## Pre-requisitos
- Tener Inno Setup 6 instalado en `C:\Program Files (x86)\Inno Setup 6\`
- Tener PS2EXE instalado (`Install-Module ps2exe`)

## Pasos

### 1. Actualizar versión en código
Editar `SnakeUSBIP.ps1`:
- Línea 38: `$script:APP_VERSION = "X.Y.Z"`
- Línea 50: Verificar idioma por defecto
- Línea 615 y 638: Verificar default en config

### 2. Actualizar versión en archivos
- `SnakeUSBIP.iss` línea 5: `#define MyAppVersion "X.Y.Z"`
- `README.md` y `README_ES.md`: versión en línea 5
- `CHANGELOG.md`: añadir entrada al inicio

### 3. Compilar EXE
```powershell
cd "d:\REPOS_GITHUB\USBIP GEMINI"
Invoke-PS2EXE -InputFile "SnakeUSBIP.ps1" -OutputFile "SnakeUSBIP.exe" -NoConsole -requireAdmin -iconFile "Logo-SnakeFoxU-con-e.ico"
```

### 4. Actualizar Portables
```powershell
Copy-Item "SnakeUSBIP.exe" -Destination "Portable\SnakeUSBIP.exe" -Force
Copy-Item "SnakeUSBIP.ps1" -Destination "Portable\SnakeUSBIP.ps1" -Force
Copy-Item "SnakeUSBIP.ps1" -Destination "Portable-ARM64\SnakeUSBIP.ps1" -Force
```

### 5. Crear ZIPs Portables
```powershell
$version = "X.Y.Z"  # Cambiar por la versión actual
Compress-Archive -Path "Portable\*" -DestinationPath "SnakeUSBIP_v${version}_Portable.zip" -Force
Compress-Archive -Path "Portable-ARM64\*" -DestinationPath "SnakeUSBIP_v${version}_Portable-ARM64.zip" -Force
```

### 6. Compilar Instalador
```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "SnakeUSBIP.iss"
```
El instalador se guarda en `installer/SnakeUSBIP_Setup_vX.Y.Z.exe`

### 7. Commit y Push
```powershell
git add -A
git commit -m "Release vX.Y.Z: [descripción breve]"
git push
```

### 8. Crear Release en GitHub
1. Ir a https://github.com/Snakefoxu/SnakeUSBIP/releases/new
2. Tag: `vX.Y.Z`
3. Título: `vX.Y.Z - [descripción]`
4. Subir archivos:
   - `SnakeUSBIP_vX.Y.Z_Portable.zip`
   - `SnakeUSBIP_vX.Y.Z_Portable-ARM64.zip`
   - `installer/SnakeUSBIP_Setup_vX.Y.Z.exe`

## Checklist Final
- [ ] Versión actualizada en código (.ps1)
- [ ] Versión actualizada en .iss
- [ ] README.md y README_ES.md actualizados
- [ ] CHANGELOG.md actualizado
- [ ] EXE compilado
- [ ] Portable x64 ZIP creado
- [ ] Portable ARM64 ZIP creado
- [ ] Instalador Setup creado
- [ ] Push a GitHub
- [ ] Release creado con los 3 archivos
