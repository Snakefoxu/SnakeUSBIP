# 📖 Uso de SnakeUSBIP

## Interfaz Principal

```
┌─────────────────────────────────────────┐
│ 🦊 SnakeFoxu    USB/IP Manager          │
├─────────────────────────────────────────┤
│ Servidor: [192.168.1.x] [Escanear][Listar][SSH] │
├─────────────────────────────────────────┤
│ 📡 USB Hubs                             │
│   └─ 🖥️ 192.168.1.100                  │
│       └─ 📱 1-1.4: USB Device           │
│ ✅ Dispositivos Conectados              │
│ ⭐ Favoritos                            │
├─────────────────────────────────────────┤
│ ✓ Listo                  [Drivers: OK] │
└─────────────────────────────────────────┘
```

## Acciones Principales

### 🔍 Escanear
Busca servidores USB/IP en tu red local (puerto 3240).

### 🔄 Listar
Muestra los dispositivos USB disponibles en el servidor.

### 🖥️ SSH
Abre configuración para conectar a Raspberry Pi vía SSH.

## Menú Contextual (Click Derecho)

| Opción | Descripción |
|--------|-------------|
| 🔌 Conectar | Conecta el dispositivo a tu PC |
| ❌ Desconectar | Desconecta el dispositivo |
| ⭐ Añadir a Favoritos | Guarda para reconexión rápida |
| 📋 Propiedades | Muestra info detallada |

## Atajos

- **Doble-click** en dispositivo → Conectar
- **Enter** en campo IP → Listar dispositivos
- **F5** → Actualizar lista

## Favoritos

Los favoritos se guardan en `config.json` y pueden reconectarse automáticamente al iniciar la aplicación.

## 📝 Log de Actividad

El panel inferior muestra un historial de eventos:
- ✅ **Conexiones exitosas** - Dispositivos conectados
- ❌ **Errores** - Fallos de conexión o escaneo
- 🔍 **Escaneos** - Servidores encontrados
- ⚠️ **Advertencias** - Problemas menores

Usa el botón **Limpiar** para borrar el historial.

## 🖥️ System Tray (Bandeja del Sistema)

- Al minimizar, la aplicación se oculta en la bandeja del sistema
- **Doble-click** en el icono para restaurar la ventana
- **Click derecho** para menú: Escanear Red, Mostrar Ventana, Salir

## 🌐 Cambiar Idioma

Usa el botón **ESP/ENG** en la barra de título para alternar entre Español e Inglés.

## Drivers

- **Instalar Drivers**: Instala drivers USB/IP en Windows
- **Desinstalar Drivers**: Elimina drivers (requiere reinicio)

> ⚠️ La primera instalación de drivers puede requerir reiniciar Windows.
