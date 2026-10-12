#!/usr/bin/env python3
"""Build a Catppuccin recolor of KDE Breeze cursors (SVG + Xcursor).

Usage: build-breeze-cursors.py [frappe|mocha]   (default: mocha)
Writes ~/.local/share/icons/catppuccin-<flavour>-breeze-cursors."""
import json, os, re, shutil, struct, subprocess, sys, zlib

SRC = '/usr/share/icons/breeze_cursors'
PALETTES = {
    'mocha':  dict(base='#1e1e2e', text='#cdd6f4', mauve='#cba6f7', lavender='#b4befe',
                   red='#f38ba8', green='#a6e3a1', peach='#fab387'),
    'frappe': dict(base='#303446', text='#c6d0f5', mauve='#ca9ee6', lavender='#babbf1',
                   red='#e78284', green='#a6d189', peach='#ef9f76'),
}
FLAVOUR = sys.argv[1] if len(sys.argv) > 1 else 'mocha'
P = PALETTES[FLAVOUR]
NAME = {'mocha': 'Mocha', 'frappe': 'Frappé'}[FLAVOUR]
DST = os.path.expanduser(f'~/.local/share/icons/catppuccin-{FLAVOUR}-breeze-cursors')
SIZES = [12, 18, 24, 28, 30, 36, 42, 48, 54, 60, 66, 72]

BASE, TEXT = P['base'], P['text']
COLORS = {
    '#fff': TEXT, '#ffffff': TEXT,
    '#333': BASE, '#0d0d0d': BASE, '#0c0c0c': BASE, '#0a0a0a': BASE, '#070707': BASE,
    '#46a7ac': P['mauve'],  # spinner -> mauve
    '#d4497f': P['lavender'],  # spinner -> lavender
    '#3daee9': P['mauve'],  # accent -> mauve
    '#ed1515': P['red'],  # red
    '#18c087': P['green'], '#11d116': P['green'],  # green
    '#f67400': P['peach'],  # peach
}

def recolor(svg):
    svg = re.sub(r'#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b',
                 lambda m: COLORS.get(m.group(0).lower(), m.group(0)), svg)
    # paths with no fill default to black: make the root fill the flavour's Base
    return re.sub(r'<svg\b', f'<svg fill="{BASE}"', svg, count=1)

def png_rgba(data):
    """Decode an 8-bit RGBA non-interlaced PNG (what rsvg-convert emits)."""
    pos, idat = 8, b''
    while pos < len(data):
        ln, typ = struct.unpack('>I4s', data[pos:pos+8])
        chunk = data[pos+8:pos+8+ln]
        if typ == b'IHDR':
            w, h, depth, ctype = struct.unpack('>IIBB', chunk[:10])
            assert depth == 8 and ctype == 6, (depth, ctype)
        elif typ == b'IDAT':
            idat += chunk
        pos += 12 + ln
    raw, stride, out, prev = zlib.decompress(idat), w * 4, bytearray(), bytearray(w * 4)
    for y in range(h):
        f, line = raw[y*(stride+1)], bytearray(raw[y*(stride+1)+1:(y+1)*(stride+1)])
        for i in range(stride):
            a = line[i-4] if i >= 4 else 0
            b = prev[i]
            c = prev[i-4] if i >= 4 else 0
            if f == 1: line[i] = (line[i] + a) & 255
            elif f == 2: line[i] = (line[i] + b) & 255
            elif f == 3: line[i] = (line[i] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c; pa, pb, pc = abs(p-a), abs(p-b), abs(p-c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        out += line; prev = line
    return w, h, out

def argb_premul(rgba):
    px = []
    for i in range(0, len(rgba), 4):
        r, g, b, a = rgba[i:i+4]
        px.append((a << 24) | ((r*a//255) << 16) | ((g*a//255) << 8) | (b*a//255))
    return struct.pack(f'<{len(px)}I', *px)

def render(svg_path, px):
    return png_rgba(subprocess.run(['rsvg-convert', '-w', str(px), '-h', str(px), svg_path],
                                   check=True, capture_output=True).stdout)

def write_xcursor(path, images):  # images: [(size, w, h, xhot, yhot, delay, argb)]
    hdr = struct.pack('<4sIII', b'Xcur', 16, 0x10000, len(images))
    toc, body, pos = b'', b'', 16 + 12 * len(images)
    for size, w, h, xh, yh, delay, argb in images:
        toc += struct.pack('<III', 0xfffd0002, size, pos + len(body))
        body += struct.pack('<9I', 36, 0xfffd0002, size, 1, w, h, xh, yh, delay) + argb
    open(path, 'wb').write(hdr + toc + body)

if os.path.exists(DST):
    shutil.rmtree(DST)
os.makedirs(DST)
shutil.copytree(f'{SRC}/cursors_scalable', f'{DST}/cursors_scalable', symlinks=True)
os.makedirs(f'{DST}/cursors')
for name in os.listdir(f'{SRC}/cursors'):
    p = f'{SRC}/cursors/{name}'
    if os.path.islink(p):
        os.symlink(os.readlink(p), f'{DST}/cursors/{name}')

for name in sorted(os.listdir(f'{DST}/cursors_scalable')):
    d = f'{DST}/cursors_scalable/{name}'
    if os.path.islink(d):
        continue
    for f in os.listdir(d):
        if f.endswith('.svg'):
            p = f'{d}/{f}'
            svg = recolor(open(p).read())
            open(p, 'w').write(svg)
    frames = json.load(open(f'{d}/metadata.json'))
    images = []
    for size in SIZES:
        for fr in frames:
            svg = f'{d}/{fr["filename"]}'
            svg_w = float(re.search(r'<svg[^>]*\bwidth="([\d.]+)', open(svg).read()).group(1))
            scale = size / fr['nominal_size']
            w, h, rgba = render(svg, round(svg_w * scale))
            images.append((size, w, h, round(fr['hotspot_x'] * scale), round(fr['hotspot_y'] * scale),
                           fr.get('delay', 0), argb_premul(rgba)))
    write_xcursor(f'{DST}/cursors/{name}', images)
    print(name, len(images), file=sys.stderr)

open(f'{DST}/index.theme', 'w').write(
    f'[Icon Theme]\nName=Catppuccin {NAME} Breeze\n'
    f'Comment=KDE Breeze cursors recolored with Catppuccin {NAME}\nInherits=breeze_cursors\n')
