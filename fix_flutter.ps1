# Script para solucionar problemas de Flutter/Dart con Device Guard
# EJECUTAR COMO ADMINISTRADOR

Write-Host "=== Solucionando Flutter Daemon y Dart Analysis Server ===" -ForegroundColor Cyan

# 1. Agregar exclusiones a Windows Defender
Write-Host "`n[1/5] Agregando exclusiones a Windows Defender..." -ForegroundColor Yellow
$flutterPath = "C:\src\flutter"
$dartSdkPath = "$flutterPath\bin\cache\dart-sdk"

try {
    Add-MpPreference -ExclusionPath $flutterPath -ErrorAction Stop
    Add-MpPreference -ExclusionPath $dartSdkPath -ErrorAction Stop
    Add-MpPreference -ExclusionProcess "dart.exe" -ErrorAction Stop
    Add-MpPreference -ExclusionProcess "flutter.exe" -ErrorAction Stop
    Add-MpPreference -ExclusionProcess "pub.exe" -ErrorAction Stop
    Write-Host "   Exclusiones agregadas correctamente" -ForegroundColor Green
} catch {
    Write-Host "   Error: $_" -ForegroundColor Red
}

# 2. Desbloquear archivos de Flutter
Write-Host "`n[2/5] Desbloqueando archivos de Flutter..." -ForegroundColor Yellow
Get-ChildItem -Path $flutterPath -Recurse -Include *.exe,*.dll,*.bat | ForEach-Object {
    Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue
}
Write-Host "   Archivos desbloqueados" -ForegroundColor Green

# 3. Limpiar cache de Flutter
Write-Host "`n[3/5] Limpiando cache de Flutter..." -ForegroundColor Yellow
if (Test-Path "$flutterPath\bin\cache") {
    Remove-Item -Path "$flutterPath\bin\cache" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Cache eliminada" -ForegroundColor Green
} else {
    Write-Host "   Cache no encontrada" -ForegroundColor Yellow
}

# 4. Regenerar Flutter
Write-Host "`n[4/5] Regenerando Flutter (esto puede tomar unos minutos)..." -ForegroundColor Yellow
Set-Location $flutterPath
& "$flutterPath\bin\flutter.bat" doctor -v

# 5. Verificar instalacion
Write-Host "`n[5/5] Verificando instalacion..." -ForegroundColor Yellow
& "$flutterPath\bin\flutter.bat" --version

Write-Host "`n=== COMPLETADO ===" -ForegroundColor Green
Write-Host "Ahora reinicia VSCode completamente (cierra todas las ventanas)" -ForegroundColor Cyan
Write-Host "Presiona cualquier tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
