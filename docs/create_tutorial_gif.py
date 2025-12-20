# create_tutorial_gif.py
# Script to create animated GIF from SnakeUSBIP demo screenshots (v2 with arrows)

import os
import glob
from PIL import Image

BRAIN_DIR = r"C:\Users\snake\.gemini\[redacted]\brain\a0b7a0f3-af75-43ee-ab94-7b5f8073c980"
OUTPUT_DIR = r"D:\REPOS_GITHUB\USBIP GEMINI\docs"

# Find v2 screenshots (with arrows and captions)
screenshots_v2 = sorted(glob.glob(os.path.join(BRAIN_DIR, "demo_v2_*.png")))

# Also get original screenshots as backup
screenshots_v1 = sorted(glob.glob(os.path.join(BRAIN_DIR, "demo_0*.png")))

screenshots = screenshots_v2 if screenshots_v2 else screenshots_v1

print(f"Found {len(screenshots)} screenshots:")
for s in screenshots:
    print(f"  - {os.path.basename(s)}")

if not screenshots:
    print("No screenshots found!")
    exit(1)

# Load and resize images for web
images = []
for path in screenshots:
    img = Image.open(path)
    if img.mode != 'RGB':
        img = img.convert('RGB')
    # Optionally resize for smaller file size
    # img = img.resize((int(img.width * 0.7), int(img.height * 0.7)), Image.LANCZOS)
    images.append(img)

print(f"\nLoaded {len(images)} images")

# Durations in ms (longer for important frames)
durations = [3000] * len(images)  # 3 seconds per frame

# Create GIF
output_gif = os.path.join(OUTPUT_DIR, "snakeusbip_tutorial_v2.gif")
images[0].save(
    output_gif,
    save_all=True,
    append_images=images[1:],
    duration=durations,
    loop=0,
    optimize=True
)
print(f"✓ GIF saved: {output_gif}")

# Also save in brain dir
output_gif2 = os.path.join(BRAIN_DIR, "snakeusbip_tutorial_v2.gif")
images[0].save(
    output_gif2,
    save_all=True,
    append_images=images[1:],
    duration=durations,
    loop=0,
    optimize=True
)
print(f"✓ GIF copy: {output_gif2}")

print("\nDone! Tutorial GIF with arrows and bilingual captions created.")
