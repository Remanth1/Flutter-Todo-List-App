#!/bin/bash
# Icon Generation Script for Tasks App
# This script converts the SVG icon to PNG and generates all launcher icons

echo "Converting SVG to PNG and generating launcher icons..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "⚠️  ImageMagick is not installed."
    echo ""
    echo "Quick fix options:"
    echo ""
    echo "1. Using online converter (easiest):"
    echo "   - Visit: https://cloudconvert.com/svg-to-png"
    echo "   - Upload: assets/icon.svg"
    echo "   - Convert to PNG with size 512x512"
    echo "   - Save as: assets/icon.png"
    echo ""
    echo "2. Install ImageMagick:"
    echo "   On Windows (using chocolatey): choco install imagemagick"
    echo "   On macOS: brew install imagemagick"
    echo "   On Linux: sudo apt-get install imagemagick"
    echo ""
    exit 1
fi

echo "✓ Found ImageMagick"
echo "Converting SVG to PNG (512x512)..."

# Convert SVG to PNG with 512x512 size
convert -size 512x512 assets/icon.svg -background none -gravity center -extent 512x512 assets/icon.png

if [ $? -eq 0 ]; then
    echo "✓ PNG icon created successfully"
    echo ""
    echo "Generating launcher icons for Android..."
    flutter pub run flutter_launcher_icons
    echo ""
    echo "✅ Done! Your app icon has been updated."
    echo "   - Android launcher icon generated"
    echo "   - App will show new icon on next run"
else
    echo "❌ Failed to convert SVG to PNG"
    exit 1
fi
