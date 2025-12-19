; ============================================
; SnakeUSBIP Installer (Inno Setup)
; ============================================
;
; Features:
; - Silent installation support (/VERYSILENT)
; - Automatic driver installation
; - Start menu + Desktop shortcuts
; - Clean uninstaller
;
; Author: SnakeFoxU
; License: GPL-3.0
; ============================================

#define AppName "SnakeUSBIP"
#define AppVersion "1.7.0"
#define AppPublisher "SnakeFoxU"
#define AppURL "https://github.com/Snakefoxu/SnakeUSBIP"

[Setup]
AppId={{SNAKEUSBIP-A1B2C3D4}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputBaseFilename=SnakeUSBIP_Setup_v{#AppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
PrivilegesRequired=admin

; This is a placeholder for GitHub language detection
; Full installer script not included in this repository
