; SnakeUSBIP Installer Script
; Inno Setup 6

#define MyAppName "SnakeUSBIP"
#define MyAppVersion "1.6"
#define MyAppPublisher "SnakeFoxu"
#define MyAppURL "https://github.com/Snakefoxu/SnakeUSBIP"
#define MyAppExeName "SnakeUSBIP.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE
OutputDir=installer
OutputBaseFilename=SnakeUSBIP_Setup_v{#MyAppVersion}
SetupIconFile=Logo-SnakeFoxU-con-e.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
WizardImageFile=wizard_image.bmp
WizardSmallImageFile=wizard_small.bmp

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "installdrivers"; Description: "Instalar drivers USB/IP (recomendado)"; GroupDescription: "Drivers:"; Flags: checkedonce

[Files]
; Aplicación principal
Source: "Portable\SnakeUSBIP.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\usbipw.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\devnode.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\libusbip.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\resources.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\usb.ids"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\CleanDrivers.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Portable\Logo-SnakeFoxU-con-e.ico"; DestDir: "{app}"; Flags: ignoreversion

; Drivers
Source: "Portable\drivers\*"; DestDir: "{app}\drivers"; Flags: ignoreversion recursesubdirs createallsubdirs

; Documentación
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Instalar drivers si el usuario lo seleccionó
Filename: "pnputil.exe"; Parameters: "/add-driver ""{app}\drivers\usbip2_ude.inf"" /install"; StatusMsg: "Instalando driver UDE..."; Tasks: installdrivers; Flags: runhidden waituntilterminated
Filename: "pnputil.exe"; Parameters: "/add-driver ""{app}\drivers\usbip2_filter.inf"" /install"; StatusMsg: "Instalando driver Filter..."; Tasks: installdrivers; Flags: runhidden waituntilterminated
Filename: "{app}\devnode.exe"; Parameters: "install ROOT\USBIP_WIN2\UDE ""{app}\drivers\usbip2_ude.inf"""; StatusMsg: "Creando nodo de dispositivo..."; Tasks: installdrivers; Flags: runhidden waituntilterminated

; Ejecutar aplicación al finalizar
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallRun]
; Eliminar nodo de dispositivo al desinstalar
Filename: "{app}\devnode.exe"; Parameters: "remove ROOT\USBIP_WIN2\UDE"; Flags: runhidden waituntilterminated

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
  // Verificar si ya está instalado
  if RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}_is1') then
  begin
    if MsgBox('SnakeUSBIP ya está instalado. ¿Desea continuar con la instalación?', mbConfirmation, MB_YESNO) = IDNO then
      Result := False;
  end;
end;
