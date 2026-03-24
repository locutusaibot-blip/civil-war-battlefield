#!/usr/bin/env python3
"""Generate pixel art sprites for Civil War Battlefield"""

import struct
import zlib
import os

def write_png(filename, width, height, pixels):
    """Write a PNG file from raw RGBA pixel data"""
    
    def png_chunk(chunk_type, data):
        chunk = chunk_type + data
        crc = zlib.crc32(chunk) & 0xffffffff
        return struct.pack(">I", len(data)) + chunk + struct.pack(">I", crc)
    
    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)  # RGBA
    ihdr = png_chunk(b'IHDR', ihdr_data)
    
    # IDAT chunk (compressed image data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # Filter byte (no filter)
        for x in range(width):
            i = (y * width + x) * 4
            raw_data += bytes(pixels[i:i+4])
    
    compressed = zlib.compress(raw_data)
    idat = png_chunk(b'IDAT', compressed)
    
    # IEND chunk
    iend = png_chunk(b'IEND', b'')
    
    # Write file
    with open(filename, 'wb') as f:
        f.write(signature + ihdr + idat + iend)

def create_infantry(color_scheme="union"):
    """Create 32x32 infantry sprite"""
    width, height = 32, 32
    pixels = [0, 0, 0, 0] * (width * height)  # Transparent
    
    # Colors
    if color_scheme == "union":
        uniform = (38, 89, 153, 255)  # Union blue
    else:
        uniform = (115, 115, 128, 255)  # Confederate grey
    
    skin = (216, 178, 140, 255)
    hat = (51, 51, 64, 255)
    rifle = (102, 64, 38, 255)
    belt = (128, 102, 51, 255)
    buckle = (204, 178, 76, 255)
    boots = (38, 25, 20, 255)
    bayonet = (178, 178, 191, 255)
    
    def set_pixel(x, y, color):
        if 0 <= x < width and 0 <= y < height:
            idx = (y * width + x) * 4
            pixels[idx:idx+4] = color
    
    def fill_rect(x1, y1, x2, y2, color):
        for x in range(x1, x2):
            for y in range(y1, y2):
                set_pixel(x, y, color)
    
    # Body (8x10)
    fill_rect(12, 14, 20, 24, uniform)
    
    # Head
    fill_rect(13, 8, 19, 14, skin)
    
    # Hat
    fill_rect(12, 6, 20, 10, hat)
    fill_rect(11, 9, 21, 10, hat)  # Brim
    
    # Rifle (vertical)
    fill_rect(21, 10, 23, 28, rifle)
    fill_rect(20, 24, 23, 28, rifle)  # Stock
    # Bayonet
    fill_rect(21, 8, 23, 10, bayonet)
    
    # Belt
    fill_rect(12, 20, 20, 21, belt)
    set_pixel(15, 20, buckle)
    set_pixel(16, 20, buckle)
    
    # Legs
    fill_rect(13, 24, 15, 30, uniform)
    fill_rect(17, 24, 19, 30, uniform)
    
    # Boots
    fill_rect(12, 30, 15, 31, boots)
    fill_rect(17, 30, 20, 31, boots)
    
    return pixels

def create_cavalry(color_scheme="union"):
    """Create 32x32 cavalry sprite"""
    width, height = 32, 32
    pixels = [0, 0, 0, 0] * (width * height)
    
    if color_scheme == "union":
        uniform = (38, 89, 153, 255)
    else:
        uniform = (115, 115, 128, 255)
    
    horse = (153, 102, 51, 255)
    mane = (51, 38, 25, 255)
    skin = (216, 178, 140, 255)
    hat = (51, 51, 64, 255)
    saber = (204, 204, 217, 255)
    hoof = (76, 51, 38, 255)
    
    def set_pixel(x, y, color):
        if 0 <= x < width and 0 <= y < height:
            idx = (y * width + x) * 4
            pixels[idx:idx+4] = color
    
    def fill_rect(x1, y1, x2, y2, color):
        for x in range(x1, x2):
            for y in range(y1, y2):
                set_pixel(x, y, color)
    
    # Horse body (wide)
    fill_rect(8, 16, 26, 24, horse)
    
    # Horse neck (angled)
    for i in range(8):
        x = 7 + i
        y = 16 - i
        fill_rect(x, y, x+3, y+4, horse)
    
    # Horse head
    fill_rect(14, 6, 20, 12, horse)
    fill_rect(18, 8, 22, 11, horse)  # Snout
    
    # Mane
    fill_rect(13, 8, 15, 16, mane)
    
    # Legs
    leg_pos = [(10, 24), (12, 24), (20, 24), (22, 24)]
    for x, y in leg_pos:
        fill_rect(x, y, x+2, 30, horse)
        fill_rect(x, 30, x+2, 31, hoof)
    
    # Rider body
    fill_rect(13, 12, 19, 18, uniform)
    
    # Rider head
    fill_rect(14, 8, 18, 12, skin)
    
    # Rider hat
    fill_rect(13, 6, 19, 9, hat)
    fill_rect(14, 9, 20, 10, hat)
    
    # Saber (raised, angled)
    for i in range(12):
        x = 19 + i
        y = 10 - i
        if 0 <= x < width and 0 <= y < height:
            set_pixel(x, y, saber)
            if x + 1 < width:
                set_pixel(x + 1, y, saber)
    
    return pixels

def create_artillery(color_scheme="union"):
    """Create 32x32 artillery sprite"""
    width, height = 32, 32
    pixels = [0, 0, 0, 0] * (width * height)
    
    if color_scheme == "union":
        uniform = (38, 89, 153, 255)
    else:
        uniform = (115, 115, 128, 255)
    
    cannon = (64, 64, 76, 255)
    bronze = (153, 102, 51, 255)
    wheel = (102, 64, 38, 255)
    skin = (216, 178, 140, 255)
    ramrod = (102, 64, 38, 255)
    
    def set_pixel(x, y, color):
        if 0 <= x < width and 0 <= y < height:
            idx = (y * width + x) * 4
            pixels[idx:idx+4] = color
    
    def fill_rect(x1, y1, x2, y2, color):
        for x in range(x1, x2):
            for y in range(y1, y2):
                set_pixel(x, y, color)
    
    # Cannon barrel (angled)
    for i in range(20):
        x = 6 + i
        y = 16 + (i // 5)
        fill_rect(x, y, x+1, y+4, cannon)
    
    # Muzzle ring
    fill_rect(25, 16, 27, 22, bronze)
    
    # Carriage
    fill_rect(10, 20, 22, 24, cannon)
    
    # Wheels (simplified as circles)
    # Back wheel
    import math
    for angle in range(360):
        rad = math.radians(angle)
        wx = int(10 + math.cos(rad) * 6)
        wy = int(24 + math.sin(rad) * 6)
        if wy >= 24 and 0 <= wx < width and 0 <= wy < height:
            set_pixel(wx, wy, wheel)
            set_pixel(wx + 1, wy, wheel)
    
    # Front wheel
    for angle in range(360):
        rad = math.radians(angle)
        wx = int(20 + math.cos(rad) * 6)
        wy = int(24 + math.sin(rad) * 6)
        if wy >= 24 and 0 <= wx < width and 0 <= wy < height:
            set_pixel(wx, wy, wheel)
            set_pixel(wx + 1, wy, wheel)
    
    # Crew member
    fill_rect(26, 16, 30, 24, uniform)
    fill_rect(27, 13, 29, 16, skin)
    fill_rect(26, 24, 30, 30, uniform)
    
    # Ramrod
    fill_rect(30, 14, 31, 22, ramrod)
    
    return pixels

def create_cannonball():
    """Create 16x16 cannonball sprite"""
    width, height = 16, 16
    pixels = [0, 0, 0, 0] * (width * height)
    
    ball = (38, 38, 38, 255)
    highlight = (102, 102, 102, 255)
    
    def set_pixel(x, y, color):
        if 0 <= x < width and 0 <= y < height:
            idx = (y * width + x) * 4
            pixels[idx:idx+4] = color
    
    # Circle
    import math
    for x in range(16):
        for y in range(16):
            dx = x - 8
            dy = y - 8
            dist = math.sqrt(dx * dx + dy * dy)
            if dist < 5:
                set_pixel(x, y, ball)
            elif dist < 6:
                set_pixel(x, y, (25, 25, 25, 255))
    
    # Highlight
    set_pixel(6, 6, highlight)
    set_pixel(7, 6, highlight)
    set_pixel(6, 7, highlight)
    
    return pixels

def main():
    # Create directory
    os.makedirs("assets/sprites", exist_ok=True)
    
    # Generate all sprites
    print("Generating infantry sprites...")
    write_png("assets/sprites/infantry_union.png", 32, 32, create_infantry("union"))
    write_png("assets/sprites/infantry_confederate.png", 32, 32, create_infantry("confederate"))
    
    print("Generating cavalry sprites...")
    write_png("assets/sprites/cavalry_union.png", 32, 32, create_cavalry("union"))
    write_png("assets/sprites/cavalry_confederate.png", 32, 32, create_cavalry("confederate"))
    
    print("Generating artillery sprites...")
    write_png("assets/sprites/artillery_union.png", 32, 32, create_artillery("union"))
    write_png("assets/sprites/artillery_confederate.png", 32, 32, create_artillery("confederate"))
    
    print("Generating cannonball...")
    write_png("assets/sprites/cannonball.png", 16, 16, create_cannonball())
    
    print("\n✅ All sprites generated in assets/sprites/")
    print("Files created:")
    for f in os.listdir("assets/sprites"):
        print(f"  - assets/sprites/{f}")

if __name__ == "__main__":
    main()
