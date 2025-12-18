# 🦊 SnakeUSBIP - Cliente USB/IP Gratuito para Windows

> **La mejor alternativa gratuita a VirtualHere** para compartir dispositivos USB por red.

> **Solución libre y de código abierto** para compartir dispositivos USB por red. Alternativa gratuita a VirtualHere, USB Redirector, FlexiHub y USB Network Gate.

Conecta impresoras, escáneres, cámaras, dongles y cualquier dispositivo USB de forma remota a través de tu red local (WiFi o Ethernet). Transforma tu **Raspberry Pi** o servidor Linux en un Hub USB virtual accesible desde **Windows 10/11**.

[![GitHub Downloads](https://img.shields.io/github/downloads/SnakeFoxu/SnakeUSBIP/total?style=flat-square&logo=github&color=blue)](https://github.com/SnakeFoxu/SnakeUSBIP/releases)
[![GitHub Stars](https://img.shields.io/github/stars/SnakeFoxu/SnakeUSBIP?style=flat-square&logo=github&color=yellow)](https://github.com/SnakeFoxu/SnakeUSBIP/stargazers)
[![License](https://img.shields.io/badge/license-Custom-orange?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-lightgrey?style=flat-square&logo=windows)](https://github.com/SnakeFoxu/SnakeUSBIP)

---

## 🎬 Video Tutorial - Cómo usar SnakeUSBIP

<a href="https://www.youtube.com/watch?v=mETEs9INlq4">
  <img src="youtube_thumbnail.png" width="50%" alt="Tutorial SnakeUSBIP - USB over IP Windows">
</a>

▶️ **[Ver tutorial completo en YouTube](https://www.youtube.com/watch?v=mETEs9INlq4)** - Aprende a conectar USB remotos en 5 minutos

---

## ✨ Características Principales

| Característica | Descripción |
|----------------|-------------|
| 🔍 **Autodescubrimiento** | Encuentra automáticamente servidores USB/IP en tu red |
| 🔌 **Un click para conectar** | Conecta y desconecta dispositivos USB remotos fácilmente |
| ⭐ **Sistema de Favoritos** | Guarda dispositivos para reconexión automática al iniciar |
| 🖥️ **Asistente SSH** | Configura servidores Raspberry Pi directamente desde la app |
| 📋 **Info detallada** | Muestra VID:PID, fabricante y producto de cada dispositivo |
| 🎨 **Interfaz moderna** | GUI estilo macOS con botones redondos y efectos hover |
| 🌐 **Multi-idioma** | Disponible en Español e Inglés |
| 📦 **100% Portable** | No requiere instalación, ejecuta desde USB |

---

## 📥 Descarga e Instalación

### ⬇️ [Descargar última versión](https://github.com/SnakeFoxu/SnakeUSBIP/releases/latest)

**Opción 1: Instalador (Recomendado)**
- Descarga `SnakeUSBIP_Setup_v1.6.exe`
- Ejecuta como Administrador
- Incluye instalación automática de drivers USB/IP

**Opción 2: Portable**
- Descarga `SnakeUSBIP_Portable_v1.6.zip`
- Extrae y ejecuta `SnakeUSBIP.exe` como Administrador

---

## 🚀 Guía de Uso Rápido

```
1. Escanear    → Click en 🔍 para encontrar servidores en tu red
2. Seleccionar → Elige un dispositivo USB del árbol
3. Conectar    → Doble-click o clic derecho → Conectar
4. ¡Listo!     → El dispositivo USB aparece en tu PC
```

---

## 🍓 Configurar Servidor en Raspberry Pi / Linux

**Requisitos:** Raspberry Pi OS, Ubuntu, Debian o cualquier distribución Linux.

```bash
# 1. Instalar paquetes necesarios
sudo apt update && sudo apt install -y usbip hwdata usbutils

# 2. Cargar el módulo del kernel
sudo modprobe usbip_host

# 3. Iniciar el demonio USB/IP
sudo usbipd -D

# 4. Ver dispositivos USB disponibles
usbip list -l

# 5. Exportar un dispositivo (ejemplo: bus-id 1-1.4)
sudo usbip bind -b 1-1.4
```

📖 **[Guía completa de configuración](docs/RASPBERRY_PI_SERVER.md)**

---

## 💡 Casos de Uso

- **🖨️ Impresoras** - Comparte una impresora USB entre múltiples PCs
- **📷 Cámaras** - Accede a cámaras USB desde cualquier equipo de la red
- **🔐 Dongles de licencia** - Comparte dongles USB entre máquinas virtuales
- **💾 Memorias USB** - Accede a pendrives conectados a un servidor
- **🎮 Controladores** - Usa gamepads conectados a otro PC
- **🔧 Arduino/ESP32** - Programa microcontroladores remotamente

---

## ⚙️ Requisitos del Sistema

| Componente | Requisito |
|------------|-----------|
| **Sistema Operativo** | Windows 10 / Windows 11 (64 bits) |
| **Permisos** | Administrador (para drivers) |
| **Red** | LAN, WiFi o VPN con acceso al servidor |
| **Servidor** | Raspberry Pi, Linux, o cualquier sistema con usbipd |

---

## 📁 Estructura del Paquete

```
SnakeUSBIP/
├── SnakeUSBIP.exe      # Aplicación principal
├── usbipw.exe          # Cliente USB/IP (Vadim)
├── devnode.exe         # Gestor de nodos de dispositivo
├── drivers/            # Drivers USB/IP para Windows
│   ├── usbip2_ude.inf
│   └── usbip2_filter.inf
└── usb.ids             # Base de datos de fabricantes USB
```

---

## 🆚 Comparativa con otras soluciones

| Característica | SnakeUSBIP | VirtualHere | USB Redirector | FlexiHub | USB Network Gate |
|----------------|------------|-------------|----------------|----------|------------------|
| **Precio** | ✅ Gratis | ❌ $49 USD | ❌ $55-180 USD | ❌ Suscripción | ❌ $159 USD |
| **Open Source** | ✅ Sí | ❌ No | ❌ No | ❌ No | ❌ No |
| **GUI gráfica** | ✅ Sí | ✅ Sí | ⚠️ Básica | ✅ Sí | ✅ Sí |
| **Autodescubrimiento** | ✅ Sí | ✅ Sí | ❌ No | ✅ Sí | ✅ Sí |
| **Multi-idioma** | ✅ ES/EN | ❌ Solo EN | ❌ Solo EN | ❌ Solo EN | ✅ Varios |
| **Portable** | ✅ Sí | ❌ No | ⚠️ Limitado | ❌ No | ❌ No |

---

## 🚀 Próximas Actualizaciones

Estamos trabajando en mejoras continuas. Aquí está lo que viene:

### 📅 Corto Plazo (v1.7-1.8)
- 🔄 **Auto-Reconnect Inteligente** - Reconexión automática si se pierde la red
- 📊 **Logs Visuales Mejorados** - Panel de logs con colores, filtros y búsqueda
- 🌙 **Modo Oscuro/Claro** - Toggle de tema visual
- 🔔 **Notificaciones Mejoradas** - Avisos cuando dispositivos se conectan/desconectan

### 🎯 Mediano Plazo (v2.0)
- 🗜️ **Compresión de Datos** - Reduce ancho de banda para conexiones lentas
- 📈 **Dashboard de Rendimiento** - Gráficos de latencia y throughput en tiempo real
- 🏷️ **Nicknames para Dispositivos** - Nombres amigables en lugar de VID:PID
- 🔒 **Filtros IP** - Control de acceso por IP permitida
- 💾 **Perfiles de Configuración** - Guardar y cargar configuraciones completas

### 🔮 Largo Plazo (v2.x)
- 🌍 **Conexión por Internet** - NAT traversal sin port forwarding
- 🖥️ **Servidor Windows Nativo** - Sin necesidad de Linux/Raspberry Pi
- 🐧 **Cliente Multiplataforma** - Versión para Linux y macOS
- 🤖 **Detección Automática** - Identificación inteligente de tipo de dispositivo
- 🎮 **Modo Gaming** - Optimización para periféricos de baja latencia
- 📱 **Notificaciones Push** - Notificaciones push para dispositivos remotos
- 📊 **Dashboard de Rendimiento** - Gráficos de latencia y throughput en tiempo real
- 📦 **Perfiles de Configuración** - Guardar y cargar configuraciones completa

---

## 📄 Licencia

**Uso y distribución permitidos - Modificación NO permitida**

Puedes usar y distribuir este software libremente, pero no puedes modificarlo ni crear obras derivadas.

Ver [LICENSE](LICENSE) para más detalles.

---

## 🙏 Créditos y Agradecimientos

- **[USB/IP Project](http://usbip.sourceforge.net/)** - Protocolo original de Linux
- **[usbip-win](https://github.com/cezanne/usbip-win)** - Implementación Drivers para Windows
- **SnakeUSBIP** - GUI desarrollada por [SnakeFoxu](https://github.com/SnakeFoxu) © 2025

---

## 🔑 Keywords / Palabras Clave

`USB over IP` `USB remoto` `USB por red` `compartir USB` `USB network` `usb redirection` `remote usb` `usb over ethernet` `usb over wifi` `USB/IP Windows` `usbip windows 10` `usbip windows 11` `usbip client windows` `free usb over ip` `open source usb sharing` `VirtualHere alternativa gratis` `VirtualHere free alternative` `VirtualHere open source` `USB Redirector free alternative` `USB Redirector gratis` `FlexiHub free` `FlexiHub alternative` `USB Network Gate alternative` `USB Network Gate gratis` `Raspberry Pi USB server` `Raspberry Pi USB sharing` `Linux USB server` `compartir impresora USB red` `usb printer sharing` `usb scanner network` `remote usb devices` `usb passthrough` `usb forwarding` `virtual usb` `usb hub over ip` `network usb hub` `usb over lan` `usb over vpn` `usb tunnel` `remote desktop usb` `hyper-v usb` `vmware usb passthrough` `virtualbox usb` `usb redirection windows` `cliente usbip` `servidor usb red` `dongle usb remoto` `usb network sharing free`

