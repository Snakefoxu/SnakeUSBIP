# Estado del Proyecto: SnakeUSBIP

## ✅ Versión Actual: 2.0.0 [2025-12-26]

> **Nueva arquitectura:** Migración completa de PowerShell a .NET 9 (C# / WPF)

### Características Implementadas

#### Versión 2.0 (WPF)
- ✅ **Arquitectura .NET 9** - Rendimiento nativo, GUI ultra-rápida
- ✅ **Tema VS Code Dark+** - Modo oscuro profesional con acentos azules
- ✅ **Renombrar Dispositivos** - Nombres personalizados persistentes (en config.json)
- ✅ **Base de Datos Actualizada** - usb.ids Diciembre 2025 (+17K dispositivos)
- ✅ **Soporte ARM64** - Windows on ARM (drivers test-signed)
- ✅ **Versión Dinámica** - Lee versión del assembly, no hardcodeada

#### Heredadas de v1.x (PowerShell)
- ✅ Conectar/Desconectar USB/IP
- ✅ Auto-Descubrimiento (escaneo de subred puerto 3240)
- ✅ GUI TreeView con menú contextual
- ✅ Sistema de Favoritos con auto-reconexión
- ✅ Información VID:PID de dispositivos
- ✅ Contadores "(X)" en cada nodo
- ✅ Tooltips al pasar el mouse
- ✅ Bandeja del Sistema (minimizar a tray)
- ✅ Múltiples servidores simultáneamente
- ✅ Multi-idioma (Inglés/Español)
- ✅ Auto-actualización desde GitHub
- ✅ Portable e Instalador (x64 WHQL + ARM64)
- ✅ Log de Actividad con timestamps
- ✅ Conexión VPN (Tailscale/ZeroTier)
- ✅ Diálogo de configuración SSH
- ✅ **Notificaciones Toast** (eventos conectar/desconectar via bandeja del sistema)
- ✅ **Auto-reconexión** cuando cae la conexión (ConnectionMonitorService)

### ⚠️ Limitaciones Conocidas

| Problema | Razón |
|----------|-------|
| "Editor desconocido" en UAC | App no firmada digitalmente (requiere certificado ~$75/año) |
| ARM64 requiere Test Mode | Drivers son test-signed, no certificados WHQL |

### Pendiente (Roadmap)
- [ ] Dashboard de rendimiento (estadísticas de conexión, monitor de latencia)
- [ ] Idiomas adicionales (Portugués, Francés, Alemán)

---

## 📦 Artefactos de Release

| Archivo | Tamaño | Plataforma |
|---------|--------|------------|
| `SnakeUSBIP-v2.0.0-x64.zip` | 67.5 MB | Windows x64 Portable |
| `SnakeUSBIP-v2.0.0-arm64.zip` | 63.1 MB | Windows ARM64 Portable |
| `SnakeUSBIP_Setup_v2.0.0.exe` | 66.9 MB | Windows x64 Instalador |

---

## 🔗 Enlaces
- **GitHub:** https://github.com/Snakefoxu/SnakeUSBIP
- **YouTube:** https://www.youtube.com/watch?v=mETEs9INlq4
- **Documentación:** [docs/](../docs/)
