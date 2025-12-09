# CHANGELOG - SnakeUSBIP

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

#### Notas Técnicas
- Requiere Windows 10/11
- Requiere permisos de Administrador
- Compatible con usbip-win2

---

### Pendiente (Futuras versiones)
- [ ] Ícono en bandeja del sistema (System Tray)
- [ ] Soporte múltiples servidores simultáneos

---

## Historial de Desarrollo

### Pre-release: Características implementadas durante desarrollo
- v1.1.0: Botón "Ver Conectados", instalación de drivers
- v1.2.0: Feature 2 - Información VID:PID
- v1.3.0: GUI estilo VirtualHere (TreeView)
- v1.4.0: Feature 3 - Sistema de Favoritos
- v1.5.0: Botón SSH para Raspberry Pi
- v1.5.1: Fix popups 0,1,2 al iniciar
