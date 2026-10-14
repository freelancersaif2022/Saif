"""Launcher icon generator for Real Clash.

Draws a crossed-swords battle shield over a blue/red clash background and
writes legacy, round and adaptive (API 26+) launcher icons.
Run from the project root:
    python3 tool/gen_icon.py
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..')
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
S = 1024  # master canvas size

DENSITIES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def background(size):
    """Diagonal blue vs red clash with a bright seam."""
    img = Image.new('RGBA', (size, size))
    px = img.load()
    blue_a, blue_b = (63, 140, 255), (12, 34, 110)
    red_a, red_b = (255, 92, 72), (110, 14, 20)
    for y in range(size):
        for x in range(size):
            u, v = x / size, y / size
            d = (u - v)  # diagonal from top-left to bottom-right
            r = math.hypot(u - 0.5, v - 0.5) / 0.71
            if d < 0:
                c = lerp(blue_a, blue_b, min(1.0, r * 1.1))
            else:
                c = lerp(red_a, red_b, min(1.0, r * 1.1))
            glow = max(0.0, 1.0 - abs(d) * 9)
            c = lerp(c, (255, 236, 170), glow * 0.85)
            px[x, y] = c + (255,)
    return img


def shield_points(cx, cy, w, h):
    pts = []
    top = cy - h * 0.5
    for i in range(41):
        t = i / 40
        x = cx - w / 2 + w * t
        y = top + math.sin(t * math.pi) * -h * 0.04
        pts.append((x, y))
    for i in range(1, 41):
        t = i / 40
        ang = t * math.pi
        x = cx + (w / 2) * math.cos(ang)
        y = top + h * 0.42 + (h * 0.58) * math.sin(ang) ** 1.35
        pts.append((x, y))
    return pts


def sword(draw, cx, cy, length, angle, scale):
    ca, sa = math.cos(angle), math.sin(angle)

    def P(along, side):
        return (cx + ca * along - sa * side, cy + sa * along + ca * side)

    bw = 58 * scale
    tip = length * 0.5
    base = -length * 0.18
    blade = [P(base, -bw / 2), P(tip - bw, -bw / 2), P(tip, 0), P(tip - bw, bw / 2), P(base, bw / 2)]
    draw.polygon(blade, fill=(236, 242, 252, 255), outline=(40, 44, 60, 255))
    draw.line([P(base, 0), P(tip - bw * 0.6, 0)], fill=(160, 175, 200, 255), width=int(10 * scale))
    guard = [P(base - 10 * scale, -bw * 2.1), P(base + 10 * scale, -bw * 2.1),
             P(base + 10 * scale, bw * 2.1), P(base - 10 * scale, bw * 2.1)]
    draw.polygon(guard, fill=(255, 205, 70, 255), outline=(90, 60, 10, 255))
    grip_end = base - length * 0.22
    grip = [P(base - 10 * scale, -bw * 0.38), P(grip_end, -bw * 0.38),
            P(grip_end, bw * 0.38), P(base - 10 * scale, bw * 0.38)]
    draw.polygon(grip, fill=(110, 62, 30, 255), outline=(50, 26, 10, 255))
    r = bw * 0.62
    pc = P(grip_end - r * 0.6, 0)
    draw.ellipse([pc[0] - r, pc[1] - r, pc[0] + r, pc[1] + r], fill=(255, 205, 70, 255), outline=(90, 60, 10, 255))


def emblem(size, scale):
    """Shield + crossed swords, centered, occupying `scale` of the canvas."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    k = size / S * scale
    cx, cy = size / 2, size / 2 + 10 * k
    w, h = 560 * k, 660 * k

    shadow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).polygon(shield_points(cx + 14 * k, cy + 22 * k, w, h), fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(22 * k))
    img.alpha_composite(shadow)

    d = ImageDraw.Draw(img)
    d.polygon(shield_points(cx, cy, w + 44 * k, h + 44 * k), fill=(255, 205, 70, 255))
    d.polygon(shield_points(cx, cy, w + 12 * k, h + 12 * k), fill=(140, 90, 20, 255))
    inner = shield_points(cx, cy, w - 10 * k, h - 10 * k)

    face = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    fd = ImageDraw.Draw(face)
    fd.polygon([(0, 0), (0, size), (size, size)], fill=(42, 110, 240, 255))
    fd.polygon([(0, 0), (size, 0), (size, size)], fill=(214, 46, 52, 255))
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).polygon(inner, fill=255)
    hl = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    ImageDraw.Draw(hl).ellipse([cx - w * 0.6, cy - h * 0.95, cx + w * 0.4, cy - h * 0.05], fill=(255, 255, 255, 60))
    face.alpha_composite(hl)
    img.paste(face, (0, 0), mask)

    sd = ImageDraw.Draw(img)
    L = 760 * k
    sword(sd, cx, cy + 10 * k, L, math.radians(-125), k)
    sword(sd, cx, cy + 10 * k, L, math.radians(-55), k)

    # star on top
    r1, r2 = 62 * k, 26 * k
    scx, scy = cx, cy - h * 0.5 - 6 * k
    star = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        r = r1 if i % 2 == 0 else r2
        star.append((scx + r * math.cos(a), scy + r * math.sin(a)))
    sd.polygon(star, fill=(255, 225, 110, 255), outline=(120, 80, 10, 255))
    return img


def rounded_mask(size, radius_frac):
    m = Image.new('L', (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * radius_frac), fill=255)
    return m


def circle_mask(size):
    m = Image.new('L', (size, size), 0)
    ImageDraw.Draw(m).ellipse([0, 0, size - 1, size - 1], fill=255)
    return m


def save(img, path, px):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((px, px), Image.LANCZOS).save(path)


def main():
    bg = background(S)
    full = bg.copy()
    full.alpha_composite(emblem(S, 0.86))

    legacy = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    legacy.paste(full, (0, 0), rounded_mask(S, 0.22))
    rnd = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    rnd.paste(full, (0, 0), circle_mask(S))

    # Adaptive layers: 108dp canvas, emblem kept inside the 66dp safe zone.
    fg = emblem(S, 0.86 * 66 / 108)

    for name, f in DENSITIES.items():
        d = os.path.join(RES, 'mipmap-' + name)
        save(legacy, os.path.join(d, 'ic_launcher.png'), int(48 * f))
        save(rnd, os.path.join(d, 'ic_launcher_round.png'), int(48 * f))
        save(fg, os.path.join(d, 'ic_launcher_foreground.png'), int(108 * f))
        save(bg, os.path.join(d, 'ic_launcher_background.png'), int(108 * f))

    anydpi = os.path.join(RES, 'mipmap-anydpi-v26')
    os.makedirs(anydpi, exist_ok=True)
    xml = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
           '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
           '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
           '</adaptive-icon>\n')
    for n in ('ic_launcher.xml', 'ic_launcher_round.xml'):
        with open(os.path.join(anydpi, n), 'w') as fh:
            fh.write(xml)


if __name__ == '__main__':
    main()
