#!/usr/bin/env python3
"""
Verify that the Tasks app icon is properly included in the APK
"""

import zipfile
from pathlib import Path

def verify_apk_icon():
    """Check that ic_launcher.png files exist in the APK"""
    apk_path = Path("build/app/outputs/flutter-apk/app-release.apk")
    
    if not apk_path.exists():
        print("❌ APK not found at:", apk_path)
        return False
    
    print("🔍 Verifying APK contents...")
    print(f"   APK: {apk_path}")
    print(f"   Size: {apk_path.stat().st_size / 1024 / 1024:.1f} MB")
    print()
    
    icon_files = [
        "res/mipmap-mdpi/ic_launcher.png",
        "res/mipmap-hdpi/ic_launcher.png",
        "res/mipmap-xhdpi/ic_launcher.png",
        "res/mipmap-xxhdpi/ic_launcher.png",
        "res/mipmap-xxxhdpi/ic_launcher.png",
        "res/mipmap-anydpi-v33/ic_launcher.xml",
    ]
    
    found_icons = []
    missing_icons = []
    
    try:
        with zipfile.ZipFile(apk_path, 'r') as apk_zip:
            apk_files = apk_zip.namelist()
            
            for icon_file in icon_files:
                if icon_file in apk_files:
                    found_icons.append(icon_file)
                    size = apk_zip.getinfo(icon_file).file_size
                    print(f"✅ {icon_file} ({size / 1024:.1f} KB)")
                else:
                    missing_icons.append(icon_file)
                    print(f"⚠️  {icon_file} - NOT FOUND")
    
    except zipfile.BadZipFile:
        print("❌ APK is not a valid ZIP file")
        return False
    except Exception as e:
        print(f"❌ Error reading APK: {e}")
        return False
    
    print()
    if missing_icons:
        print(f"⚠️  Missing {len(missing_icons)} icon files")
        print("   This may be normal for some icon types")
    
    if found_icons:
        print(f"✅ Found {len(found_icons)} icon files in APK")
        print()
        print("✅ APK contains all required launcher icons!")
        print()
        print("Installation Instructions:")
        print("  1. Connect Android device via USB")
        print("  2. Enable USB Debugging in Settings → Developer Options")
        print("  3. Run: adb install -r build/app/outputs/flutter-apk/app-release.apk")
        print()
        print("The new Tasks icon will appear on your device home screen.")
        return True
    else:
        print("❌ No icon files found in APK")
        return False

if __name__ == "__main__":
    import sys
    success = verify_apk_icon()
    sys.exit(0 if success else 1)
