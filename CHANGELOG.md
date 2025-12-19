# CHANGELOG - SnakeUSBIP

## [1.7.1] - 2025-12-19

### Corregido
- **Escaneo de redes VPN** 🌐
  - Ahora el escaneo automático detecta subredes de Tailscale/ZeroTier (100.x.x.x)
  - Eliminado filtro que excluía interfaces tipo "Tunnel"
  - Permite encontrar servidores USB/IP conectados vía VPN

---

## [1.7.0] - 2025-12-19

### Añadido
- **Botón VPN / Internet** 🌐
  - Nuevo botón "🌐 VPN" para conexión remota por Internet
  - Detecta automáticamente Tailscale y ZeroTier instalados
  - Escanea peers VPN buscando servidores USB/IP activos
  - Dialog con lista de peers y estado de conexión
  - Conectar directamente a servidores USB/IP remotos
- **Traducciones VPN**
  - Nuevas cadenas en español e inglés para la funcionalidad VPN
- **Interfaz más ancha**
  - Formulario principal ampliado de 520 a 590 píxeles
  - Espacio para nuevo botón sin afectar diseño existente

### Cambiado
- Ajustados anchos de TreeView, LogPanel y ServerPanel

---

## [1.6.1] - 2025-12-18

### Añadido
- **Log de Actividad** 📋
  - Panel con historial de eventos
  - Registra conexiones, desconexiones, escaneos y errores
  - Botón para limpiar historial
  - Timestamps en cada entrada

### Corregido
- **Escaneo inicial** 🐛
  - Ahora encuentra todos los servidores desde el arranque
  - Solucionado problema de concurrencia en callbacks
- **Timeout de escaneo** ⏱️
  - Aumentado de 100ms a 300ms para servidores lentos

---

## [1.6.0] - 2025-12-10

### Añadido
- **Interfaz estilo macOS** 🍎
  - Botones de ventana redondos (🟡🟢🔴)
  - Sin barra de Windows (custom title bar)
  - Arrastrar ventana desde barra de título
- **Estilos mejorados** ✨
  - Botones con efectos hover
  - Colores vibrantes y modernos
  - Zorro naranja en el título
- **Traducciones mejoradas** 🌐
  - Más elementos se traducen al cambiar idioma
  - TreeView y labels actualizados

---

## [1.5.0] - 2025-12-10

### Añadido
- **Multi-idioma** 🌐
  - Español (ESP) e Inglés (ENG)
  - Botón selector en barra de título
  - Se guarda preferencia en config
- **Auto-actualización** ⬆️
  - Comprueba versión en GitHub
  - Descarga e instala automáticamente

### Cambiado  
- Botón cerrar (X) ahora cierra la aplicación
- Botón minimizar sigue enviando a bandeja del sistema

---

## [1.4.0.0] - 2025-12-10

### Añadido
- **Múltiples Servidores Simultáneos** 🎉
  - Escaneo encuentra TODOS los servidores en la subred
  - TreeView muestra múltiples servidores al mismo tiempo

---

## [1.3.0.0] - 2025-12-10

### Añadido
- **System Tray (Bandeja del sistema)** 🎉
  - Ícono en la bandeja del sistema con el logo de SnakeFoxU
  - Minimizar a tray (al minimizar o cerrar la ventana)
  - Menú contextual: Escanear Red, Mostrar Ventana, Salir
  - Doble-click en ícono restaura la ventana
  - Notificación balloon al minimizar
  - La app sigue corriendo en segundo plano

---

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
- [ ] Notificaciones (conexión/desconexión)
- [ ] Log de actividad
- [x] ~~Ícono en bandeja del sistema (System Tray)~~ ✅ v1.3.0
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
