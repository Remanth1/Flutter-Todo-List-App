#!/usr/bin/env python3
"""
SVG to PNG Icon Converter for Tasks App
Converts the Tasks-style icon from SVG to PNG (512x512)
"""

import os
import sys
import subprocess
from pathlib import Path

def convert_svg_to_png():
    """Convert SVG icon to PNG using available tools"""
    svg_path = Path("assets/icon.svg")
    png_path = Path("assets/icon.png")
    
    if not svg_path.exists():
        print("❌ Error: assets/icon.svg not found")
        return False
    
    print("🎨 Converting SVG to PNG (512x512)...")
    print(f"   Input:  {svg_path}")
    print(f"   Output: {png_path}")
    print("")
    
    # Try Method 1: cairosvg (best for SVG)
    try:
        import cairosvg
        print("✓ Using cairosvg for conversion...")
        cairosvg.svg2png(
            url=str(svg_path),
            write_to=str(png_path),
            output_width=512,
            output_height=512
        )
        print("✅ Successfully converted using cairosvg!")
        return True
    except ImportError:
        print("   cairosvg not installed, trying alternative...")
    except Exception as e:
        print(f"   cairosvg failed: {e}")
    
    # Try Method 2: Pillow with embedded SVG rendering
    try:
        from PIL import Image
        import io
        
        print("✓ Using Pillow for conversion...")
        
        # Read SVG as raw image (limited support)
        # Try using Pillow's SVG support
        try:
            img = Image.open(svg_path)
            img = img.resize((512, 512), Image.Resampling.LANCZOS)
            img.save(png_path, "PNG")
            print("✅ Successfully converted using Pillow!")
            return True
        except:
            print("   Pillow SVG support limited, trying ImageMagick...")
    except ImportError:
        print("   Pillow not installed")
    
    # Try Method 3: ImageMagick command line
    try:
        print("✓ Using ImageMagick via command line...")
        result = subprocess.run(
            [
                "magick",
                "convert",
                "-size", "512x512",
                str(svg_path),
                "-background", "none",
                "-gravity", "center",
                "-extent", "512x512",
                str(png_path)
            ],
            capture_output=True,
            timeout=30
        )
        
        if result.returncode == 0 and png_path.exists():
            print("✅ Successfully converted using ImageMagick!")
            return True
        else:
            print(f"   ImageMagick error: {result.stderr.decode()}")
    except (FileNotFoundError, subprocess.TimeoutExpired) as e:
        print(f"   ImageMagick not available: {e}")
    
    # Method 4: Fallback - Create a basic PNG placeholder
    print("")
    print("⚠️  No SVG converter found.")
    print("")
    print("Install one of the following:")
    print("")
    print("1. cairosvg (Python package - Recommended):")
    print("   pip install cairosvg")
    print("")
    print("2. ImageMagick (System package):")
    print("   Windows: choco install imagemagick")
    print("   macOS: brew install imagemagick")
    print("   Linux: sudo apt-get install imagemagick")
    print("")
    print("3. Or use online converter:")
    print("   https://cloudconvert.com/svg-to-png")
    print("")
    
    return False

def install_and_convert():
    """Try to install cairosvg and convert"""
    print("Attempting to install cairosvg...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "cairosvg", "-q"])
        print("✓ cairosvg installed successfully")
        return convert_svg_to_png()
    except Exception as e:
        print(f"   Installation failed: {e}")
        return False

def generate_flutter_icons():
    """Generate Flutter launcher icons"""
    print("")
    print("📦 Generating Flutter launcher icons...")
    print("")
    
    try:
        result = subprocess.run(
            ["flutter", "pub", "run", "flutter_launcher_icons"],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            print(result.stdout)
            print("✅ Flutter launcher icons generated successfully!")
            return True
        else:
            print("❌ Error generating launcher icons:")
            print(result.stderr)
            return False
    except FileNotFoundError:
        print("❌ Flutter not found in PATH")
        return False
    except subprocess.TimeoutExpired:
        print("❌ Icon generation timed out")
        return False

def main():
    """Main entry point"""
    print("=" * 60)
    print("🎯 Tasks App - Icon Generator")
    print("=" * 60)
    print("")
    
    # Check if PNG already exists
    if Path("assets/icon.png").exists():
        print("✓ assets/icon.png already exists")
        print("")
        response = input("Regenerate launcher icons? (y/n): ").strip().lower()
        if response != 'y':
            print("Skipped.")
            return
    else:
        # Try to convert SVG to PNG
        if not convert_svg_to_png():
            print("")
            print("Attempting automatic installation...")
            if not install_and_convert():
                print("")
                print("❌ Conversion failed. Please see instructions above.")
                return
    
    # Generate Flutter launcher icons
    if generate_flutter_icons():
        print("")
        print("=" * 60)
        print("✅ Next Steps:")
        print("=" * 60)
        print("  1. flutter clean")
        print("  2. flutter pub get")
        print("  3. flutter run")
        print("")
        print("Your new icon will appear on your device/emulator")
        print("=" * 60)
    else:
        print("")
        print("❌ Icon generation failed")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nCancelled by user")
        sys.exit(1)
