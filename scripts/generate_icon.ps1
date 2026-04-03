# Icon Generation Script for Tasks App (Windows)
# Convert SVG to PNG and generate launcher icons

Write-Host "🎨 Tasks App Icon Generator" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Check if we need to convert SVG to PNG
if (-Not (Test-Path "assets/icon.png")) {
    Write-Host "⚠️  icon.png not found. Need to convert SVG to PNG first." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quick Options:" -ForegroundColor Green
    Write-Host ""
    Write-Host "1️⃣  Online Converter (Recommended - No Installation):" -ForegroundColor Green
    Write-Host "   - Go to: https://cloudconvert.com/svg-to-png" -ForegroundColor Cyan
    Write-Host "   - Upload: assets/icon.svg" -ForegroundColor Cyan
    Write-Host "   - Settings: Output size 512x512 pixels" -ForegroundColor Cyan
    Write-Host "   - Download and save as: assets/icon.png" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2️⃣  Using ImageMagick (Requires Installation):" -ForegroundColor Green
    Write-Host "   - Install: choco install imagemagick" -ForegroundColor Cyan
    Write-Host "   - Then run: .\scripts\generate_icon.ps1 again" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3️⃣  Using ffmpeg:" -ForegroundColor Green
    Write-Host "   - Install: choco install ffmpeg" -ForegroundColor Cyan
    Write-Host "   - Command: ffmpeg -i assets/icon.svg -s 512x512 assets/icon.png" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "✓ Found icon.png" -ForegroundColor Green
Write-Host ""
Write-Host "Generating launcher icons for Android/iOS..." -ForegroundColor Cyan
Write-Host ""

# Run flutter_launcher_icons
flutter pub run flutter_launcher_icons

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Success! Your app icon has been updated." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "  1. Run: flutter clean" -ForegroundColor Cyan
    Write-Host "  2. Run: flutter pub get" -ForegroundColor Cyan
    Write-Host "  3. Run: flutter run" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "The new Tasks icon will appear on your device/emulator home screen" -ForegroundColor Green
} else {
    Write-Host "❌ Error generating launcher icons" -ForegroundColor Red
    exit 1
}
