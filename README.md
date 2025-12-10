# 🦊 SnakeUSBIP

**Cliente USB/IP para Windows** - Gestiona dispositivos USB remotos a través de la red.

![Version](https://img.shields.io/badge/version-1.6-blue)
![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎬 Video Tutorial

[![Video Tutorial](youtube_thumbnail.png)](https://www.youtube.com/watch?v=mETEs9INlq4)

▶️ **[Ver tutorial completo en YouTube](https://www.youtube.com/watch?v=mETEs9INlq4)**

## ✨ Características

- 🔍 **Autodescubrimiento** - Escanea servidores USB/IP en tu red local
- 🔌 **Conexión fácil** - Conecta/desconecta dispositivos con un click
- ⭐ **Favoritos** - Guarda dispositivos para reconexión rápida
- 🖥️ **SSH integrado** - Configura servidores Raspberry Pi directamente
- 📋 **Info detallada** - VID:PID y fabricante de cada dispositivo
- 🎨 **GUI moderna** - Interfaz estilo macOS con botones redondos
- 🌐 **Multi-idioma** - Español e Inglés

## 📦 Instalación

### Opción 1: Portable (Recomendado)
1. Descarga la carpeta `Portable/`
2. Ejecuta `SnakeUSBIP.exe` como Administrador
3. ¡Listo!

### Opción 2: Desde código fuente
```powershell
# Requiere PS2EXE
Invoke-PS2EXE -InputFile "SnakeUSBIP.ps1" -OutputFile "SnakeUSBIP.exe" -NoConsole -requireAdmin
```

## 🚀 Uso Rápido

1. **Escanear** - Click en `🔍 Escanear` para encontrar servidores
2. **Listar** - Click en `🔄 Listar` para ver dispositivos disponibles
3. **Conectar** - Doble-click en un dispositivo o click derecho → Conectar
4. **Desconectar** - Click derecho → Desconectar

## 🍓 Servidor en Raspberry Pi

Ver [docs/RASPBERRY_PI_SERVER.md](docs/RASPBERRY_PI_SERVER.md) para instrucciones completas.

**Resumen rápido:**
```bash
sudo apt update && sudo apt install -y linux-tools-generic
sudo modprobe usbip_host
sudo usbipd -D
sudo usbip list -l
sudo usbip bind -b 1-1.4  # Reemplaza con tu bus-id
```

## 📁 Estructura

```
Portable/
├── SnakeUSBIP.exe      # Aplicación principal
├── usbipw.exe          # Cliente USB/IP
├── devnode.exe         # Gestor de dispositivos
├── drivers/            # Drivers USB/IP
└── usb.ids             # Base de datos USB
```

## ⚙️ Requisitos

- Windows 10/11
- Permisos de Administrador
- Red local con servidor USB/IP

## 📄 Licencia

MIT License - Ver [LICENSE](LICENSE)

## 🙏 Créditos

- **USB/IP**: Proyecto original de Linux
- **SnakeUSBIP**: GUI por SnakeFoxu 2025
