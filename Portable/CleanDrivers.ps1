# Script para limpiar drivers USB/IP
# Ejecutar como Administrador

Write-Host "=== Limpieza de Drivers USB/IP ===" -ForegroundColor Cyan

# [0] Eliminar nodos de dispositivo VHCI duplicados
Write-Host "`n[0] Buscando nodos de dispositivo VHCI duplicados..." -ForegroundColor Yellow
$deviceOutput = pnputil /enum-devices 2>&1
$deviceLines = $deviceOutput -join "`n"

# Buscar instancias ROOT\USB\000x (USBip Emulated Host Controller)
$usbipDevices = @()
$matches = [regex]::Matches($deviceLines, 'ROOT\\USB\\(\d{4})')
foreach ($match in $matches) {
    $deviceId = "ROOT\USB\$($match.Groups[1].Value)"
    if ($deviceId -notin $usbipDevices) {
        $usbipDevices += $deviceId
    }
}

if ($usbipDevices.Count -gt 1) {
    Write-Host "  Encontradas $($usbipDevices.Count) instancias de USBip Host Controller" -ForegroundColor DarkYellow
    Write-Host "  Eliminando instancias duplicadas (manteniendo la primera)..." -ForegroundColor White
    
    for ($i = 1; $i -lt $usbipDevices.Count; $i++) {
        $deviceId = $usbipDevices[$i]
        Write-Host "    Eliminando: $deviceId" -ForegroundColor Gray
        $result = pnputil /remove-device "$deviceId" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "      OK: Dispositivo eliminado" -ForegroundColor Green
        } else {
            Write-Host "      ADVERTENCIA: No se pudo eliminar (puede requerir reinicio)" -ForegroundColor DarkYellow
        }
    }
} elseif ($usbipDevices.Count -eq 1) {
    Write-Host "  Solo una instancia encontrada (OK)" -ForegroundColor Green
} else {
    Write-Host "  No se encontraron nodos de dispositivo USB/IP" -ForegroundColor Green
}

# Buscar drivers USB/IP instalados
Write-Host "`n[1] Buscando drivers USB/IP instalados..." -ForegroundColor Yellow
$driverList = @()
$output = pnputil /enum-drivers
$blocks = $output -join "`n" -split "(?=Nombre publicado:|Published name:)"

foreach ($block in $blocks) {
    if ($block -match "usbip|vhci" -and $block -match "(oem\d+\.inf)") {
        $oemName = $matches[1]
        $driverList += $oemName
        Write-Host "  Encontrado: $oemName" -ForegroundColor White
    }
}

if ($driverList.Count -eq 0) {
    Write-Host "  No se encontraron drivers USB/IP instalados." -ForegroundColor Green
    Write-Host "`nPresiona Enter para salir..."
    Read-Host
    exit
}

# Detener servicios relacionados
Write-Host "`n[2] Deteniendo servicios USB/IP..." -ForegroundColor Yellow
$services = @("usbip2_ude", "usbip2_filter", "vhci_ude", "usbip_vhci")
foreach ($svc in $services) {
    try {
        $svcObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($svcObj) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Write-Host "  Servicio detenido: $svc" -ForegroundColor White
        }
    }
    catch { }
}

# Eliminar drivers con pnputil /uninstall
Write-Host "`n[3] Eliminando drivers del sistema..." -ForegroundColor Yellow
foreach ($driver in $driverList) {
    Write-Host "  Eliminando $driver..." -ForegroundColor White
    $result = pnputil /delete-driver $driver /uninstall 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    OK: Driver eliminado" -ForegroundColor Green
    }
    else {
        # Intentar sin /uninstall si falla
        $result = pnputil /delete-driver $driver /force 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    OK: Driver eliminado (forzado)" -ForegroundColor Green
        }
        else {
            Write-Host "    ADVERTENCIA: No se pudo eliminar completamente. Puede requerir reinicio." -ForegroundColor DarkYellow
        }
    }
}

# Verificar resultado
Write-Host "`n[4] Verificando drivers restantes..." -ForegroundColor Yellow
$remainingOutput = pnputil /enum-drivers
$remainingBlocks = $remainingOutput -join "`n" -split "(?=Nombre publicado:|Published name:)"
$remaining = 0
foreach ($block in $remainingBlocks) {
    if ($block -match "usbip|vhci" -and $block -match "(oem\d+\.inf)") {
        $remaining++
        Write-Host "  Aun instalado: $($matches[1])" -ForegroundColor DarkYellow
    }
}

if ($remaining -eq 0) {
    Write-Host "`n=== LIMPIEZA COMPLETADA ===" -ForegroundColor Green
    Write-Host "Todos los drivers USB/IP han sido eliminados."
}
else {
    Write-Host "`n=== LIMPIEZA PARCIAL ===" -ForegroundColor Yellow
    Write-Host "Algunos drivers no pudieron eliminarse."
    Write-Host "Reinicia el PC e intenta ejecutar este script de nuevo."
}

Write-Host "`nPresiona Enter para salir..."
Read-Host
