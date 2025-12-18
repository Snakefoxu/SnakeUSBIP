# 🦊 SnakeUSBIP - Cliente USB/IP Gratuito para Windows

**v1.7.0** | [Descargar Última Versión](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest) | [📖 Manual de Usuario](docs/USAGE.md) | [🌐 Conexión VPN](docs/VPN_INTERNET.md)

**Comparte y conecta dispositivos USB por red (LAN/WiFi/Internet) fácilmente.**
Transforma cualquier dispositivo Linux en un Hub USB Virtual accesible desde Windows 10 y 11. Compatible con **Raspberry Pi, Orange Pi, Banana Pi, routers OpenWRT, CrealityBox** y cualquier placa ARM/x86 con Linux. Olvida la línea de comandos; usa nuestra **GUI moderna** para conectar impresoras, escáneres y dongles remotamente.

[![GitHub Downloads](https://img.shields.io/github/downloads/SnakeFoxu/SnakeUSBIP/total?style=flat-square&logo=github&color=blue)](https://github.com/SnakeFoxu/SnakeUSBIP/releases)
[![GitHub Stars](https://img.shields.io/github/stars/SnakeFoxu/SnakeUSBIP?style=flat-square&logo=github&color=yellow)](https://github.com/SnakeFoxu/SnakeUSBIP/stargazers)
[![License](https://img.shields.io/github/license/SnakeFoxu/SnakeUSBIP?style=flat-square&color=green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-lightgrey?style=flat-square&logo=windows)](https://github.com/SnakeFoxu/SnakeUSBIP)

## 🎬 Video Tutorial

<a href="https://www.youtube.com/watch?v=mETEs9INlq4">
  <img src="youtube_thumbnail.png" width="50%" alt="Video Tutorial">
</a>

▶️ **[Ver tutorial completo en YouTube](https://www.youtube.com/watch?v=mETEs9INlq4)**

## ✨ Características

- 🔍 **Autodescubrimiento** - Escanea servidores USB/IP en tu red local- 🌐 **Conexión por Internet** - Conecta vía Tailscale/ZeroTier (NAT traversal)- 🔌 **Conexión fácil** - Conecta/desconecta dispositivos con un click
- ⭐ **Favoritos** - Guarda dispositivos para reconexión rápida
- � **Log de Actividad** - Historial de conexiones, escaneos y errores
- 🖥️ **SSH integrado** - Configura servidores Raspberry Pi directamente
- 📋 **Info detallada** - VID:PID y fabricante de cada dispositivo
- 🎨 **GUI moderna** - Interfaz estilo macOS con botones redondos
- 🌐 **Multi-idioma** - Español e Inglés
- 🔄 **Auto-actualización** - Detecta nuevas versiones desde GitHub

## 📦 Instalación

### Opción 1: Portable (Recomendado)
1. Descarga `SnakeUSBIP-Portable.zip` desde [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest)
2. Extrae el ZIP en cualquier carpeta
3. Ejecuta `SnakeUSBIP.exe` como Administrador
4. ¡Listo!

### Opción 2: Instalador
1. Descarga `SnakeUSBIP-Setup.exe` desde [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest)
2. Ejecuta el instalador como Administrador
3. Sigue el asistente de instalación

### Opción 3: Desde código fuente
```powershell
# Requiere PS2EXE (https://github.com/MScholtes/PS2EXE)
Invoke-PS2EXE -InputFile "SnakeUSBIP.ps1" -OutputFile "SnakeUSBIP.exe" -NoConsole -requireAdmin -iconFile "Logo-SnakeFoxU-con-e.ico"
```

## 🚀 Uso Rápido

1. **Escanear** - Click en `🔍 Escanear` para encontrar servidores
2. **Listar** - Click en `🔄 Listar` para ver dispositivos disponibles
3. **Conectar** - Doble-click en un dispositivo o click derecho → Conectar
4. **Desconectar** - Click derecho → Desconectar

### 🌐 Conexión por Internet (VPN)

1. Instala **[Tailscale](https://tailscale.com/download)** en Windows y en tu servidor
2. Click en `🌐 VPN` para ver peers con USB/IP activo
3. Selecciona un servidor remoto y conecta

Ver [docs/VPN_INTERNET.md](docs/VPN_INTERNET.md) para guía completa.

## 🐧 Servidor USB/IP (Linux)

Funciona en **cualquier dispositivo con Linux** que tenga puertos USB:

| Dispositivo | Compatibilidad |
|-------------|----------------|
| 🍓 Raspberry Pi (todos) | ✅ Recomendado |
| 🍊 Orange Pi / Banana Pi | ✅ |
| 📦 Arduino Yún / similar | ✅ |
| 📡 Routers con OpenWRT | ✅ |
| 🖨️ CrealityBox (OpenWRT) | ✅ |
| 💻 Cualquier PC Linux | ✅ |
| 🖥️ Servidor x86/ARM | ✅ |

Ver [docs/RASPBERRY_PI_SERVER.md](docs/RASPBERRY_PI_SERVER.md) para instrucciones completas.

**Resumen rápido (Debian/Ubuntu/Raspbian):**
```bash
sudo apt update && sudo apt install -y linux-tools-generic hwdata
sudo modprobe usbip_host
sudo usbipd -D
sudo usbip list -l
sudo usbip bind -b 1-1.4  # Reemplaza con tu bus-id
```

**OpenWRT:**
```bash
opkg update && opkg install usbip-server kmod-usb-ohci
usbipd -D
```

## � ¿Qué puedo hacer con mi dispositivo?

¿Tienes una **Raspberry Pi, Orange Pi o CrealityBox** sin usar? ¡Conviértelos en un Hub USB remoto!

| Dispositivo | Caso de Uso |
|-------------|-------------|
| 🖨️ **CrealityBox** | Comparte la impresora 3D USB por red. Conecta desde cualquier PC sin cables |
| 🍓 **Raspberry Pi** | Hub USB central: escáneres, dongles de licencia, lectores de tarjetas |
| 🍊 **Orange Pi** | Servidor USB compacto y económico para oficina |
| 📡 **Router OpenWRT** | Comparte USB de almacenamiento o impresora desde el router |
| 🔐 **Dongle de Licencia** | Comparte llaves USB de software (AutoCAD, etc.) entre PCs |

### Ejemplo real: CrealityBox como servidor USB
```bash
# 1. Accede por SSH a tu CrealityBox
ssh root@192.168.1.x

# 2. Instala USB/IP
opkg update && opkg install usbip-server kmod-usb-ohci

# 3. Inicia el servidor
usbipd -D

# 4. Exporta la impresora USB
usbip list -l          # Ver dispositivos
usbip bind -b 1-1      # Exportar impresora
```

Ahora conecta desde Windows con SnakeUSBIP y tu impresora 3D aparece como si estuviera conectada localmente.

## �🚀 Próximas Actualizaciones

**v1.8:**
- 🔄 Auto-Reconnect | 🌙 Modo Oscuro | 🔔 Notificaciones

**v2.0:**
- 🗜️ Compresión de Datos | 📈 Dashboard de Rendimiento | 🏷️ Nicknames | 🔒 Filtros IP

**v2.x:**
- 🖥️ Servidor Windows | 🐧 Cliente Multiplataforma (Linux/Mac) | 🤖 Detección Auto

## 📁 Estructura

```
Portable/
├── SnakeUSBIP.exe      # Aplicación principal
├── SnakeUSBIP.ps1      # Código fuente PowerShell
├── usbipw.exe          # Cliente USB/IP
├── devnode.exe         # Gestor de dispositivos
├── libusbip.dll        # Librería USB/IP
├── drivers/            # Drivers USB/IP
├── usb.ids             # Base de datos USB
├── CleanDrivers.ps1    # Script para limpiar drivers
└── Logo-SnakeFoxU-con-e.ico  # Icono de la app
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
