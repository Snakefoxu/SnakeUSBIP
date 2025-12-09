# CHANGELOG - SnakeUSBIP

## [1.2.0.0] - 2025-12-09

### Añadido
- **Contador de dispositivos** - Muestra "(X)" junto a cada nodo del TreeView
  - `📡 USB Hubs (3)` - Total de dispositivos remotos
  - `🖥️ 192.168.1.100 (3)` - Dispositivos por servidor
  - `✅ Dispositivos Conectados (2)` - Dispositivos USB/IP activos
  - `⭐ Favoritos (1)` - Total de favoritos guardados
- **Tooltips** - Info detallada al pasar el mouse sobre dispositivos
  - Dispositivos remotos: Bus ID, VID:PID, Fabricante, Producto, Servidor
  - Dispositivos conectados: Puerto, Producto, Servidor remoto
  - Favoritos: Bus ID, Servidor, Auto-conectar (Sí/No)

---

## [1.0.0.0] - 2025-12-09 (Release)

### 🎉 Versión 1.0 - Release Oficial

#### Funcionalidades Principales
- **GUI estilo VirtualHere** - TreeView jerárquico con menú contextual
- **Autodescubrimiento** - Escaneo automático de servidores en subred local
- **Conexión/Desconexión USB/IP** - Gestión completa de dispositivos remotos
- **Sistema de Favoritos** - Guardar dispositivos con reconexión automática
- **Botón SSH** - Configurar servidor USB/IP en Raspberry Pi
- **Información VID:PID** - Datos extendidos de fabricante/producto
- **Instalación de Drivers** - Botones para instalar/desinstalar drivers USB/IP
- **Portable** - Versión lista para distribuir

#### Archivos Incluidos
- `SnakeUSBIP.exe` - Aplicación principal
- `usbipw.exe` - Cliente USB/IP
- `devnode.exe` - Gestor de nodos de dispositivo
- `usb.ids` - Base de datos de fabricantes USB
- `drivers/` - Drivers USB/IP para Windows

---

### Pendiente (Futuras versiones)
- [ ] Notificaciones (conexión/desconecti ón)
- [ ] Log de actividad
- [ ] Ícono en bandeja del sistema (System Tray)
- [ ] Soporte múltiples servidores simultáneos

---

## Historial de Desarrollo

### Pre-release
- v1.1.0: Botón "Ver Conectados", instalación de drivers
- v1.2.0: Feature 2 - Información VID:PID
- v1.3.0: GUI estilo VirtualHere (TreeView)
- v1.4.0: Feature 3 - Sistema de Favoritos
- v1.5.0: Botón SSH para Raspberry Pi
- v1.5.1: Fix popups 0,1,2 al iniciar
