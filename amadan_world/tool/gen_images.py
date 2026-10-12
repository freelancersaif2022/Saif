"""Procedural image asset generator for Amadan World.

Regenerates every bitmap used by the game. Run from the project root:
    python3 tool/gen_images.py
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..')
A = os.path.join(ROOT, 'assets')


def out(rel):
    p = os.path.join(A, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    return p


# ---------------------------------------------------------------- noise utils
def tile_noise(w, h, cells_x, cells_y, seed):
    r = np.random.default_rng(seed)
    g = r.random((cells_y, cells_x))
    ys = np.arange(h) * cells_y / h
    xs = np.arange(w) * cells_x / w
    y0 = np.floor(ys).astype(int)
    x0 = np.floor(xs).astype(int)
    fy = ys - y0
    fx = xs - x0
    fy = fy * fy * (3 - 2 * fy)
    fx = fx * fx * (3 - 2 * fx)
    y1 = (y0 + 1) % cells_y
    x1 = (x0 + 1) % cells_x
    a = g[y0][:, x0]
    b = g[y0][:, x1]
    c = g[y1][:, x0]
    d = g[y1][:, x1]
    fx = fx[None, :]
    fy = fy[:, None]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def fbm(w, h, base, octaves, seed, persistence=0.5, base_y=None):
    total = np.zeros((h, w))
    amp = 1.0
    norm = 0.0
    by = base if base_y is None else base_y
    for o in range(octaves):
        total += tile_noise(w, h, base * (2 ** o), by * (2 ** o), seed + o * 101) * amp
        norm += amp
        amp *= persistence
    return total / norm


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)


def mix(c0, c1, t):
    c0 = np.array(c0, dtype=float)
    c1 = np.array(c1, dtype=float)
    t = t[..., None]
    return c0 * (1 - t) + c1 * t


def save_rgb(arr, path):
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), 'RGB').save(path, optimize=True)


def save_rgba(arr, path):
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), 'RGBA').save(path, optimize=True)


def radial(w, h, cx, cy, r):
    yy, xx = np.mgrid[0:h, 0:w]
    return np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / r


rng = np.random.default_rng(1234)


# ---------------------------------------------------------------- ground
def ground_dirt():
    s = 512
    n1 = fbm(s, s, 4, 6, 11)
    n2 = fbm(s, s, 6, 5, 23)
    n3 = fbm(s, s, 16, 3, 37)
    col = mix((46, 39, 32), (98, 82, 63), smoothstep(0.25, 0.75, n1))
    grass = smoothstep(0.56, 0.72, n2)
    col = col * (1 - grass[..., None] * 0.55) + np.array((70, 74, 44)) * grass[..., None] * 0.55
    dust = smoothstep(0.55, 0.8, n3)
    col = col * (1 - dust[..., None] * 0.35) + np.array((112, 104, 92)) * dust[..., None] * 0.35
    grain = rng.normal(0, 7, (s, s))[..., None]
    col = col + grain
    img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    r = np.random.default_rng(5)
    for _ in range(420):
        x, y = r.integers(0, s, 2)
        rad = r.uniform(1.0, 4.5)
        g = int(r.integers(70, 130))
        for ox in (-s, 0, s):
            for oy in (-s, 0, s):
                cx, cy = x + ox, y + oy
                d.ellipse((cx - rad + 1, cy - rad * 0.7 + 1, cx + rad + 1, cy + rad * 0.7 + 1), fill=(20, 16, 12, 120))
                d.ellipse((cx - rad, cy - rad * 0.7, cx + rad, cy + rad * 0.7), fill=(g, g - 6, g - 14, 255))
    for _ in range(260):
        x, y = r.integers(0, s, 2)
        L = r.uniform(3, 8)
        a = r.uniform(-1.9, -1.2)
        d.line((x, y, x + math.cos(a) * L, y + math.sin(a) * L), fill=(96, 92, 52, 170), width=1)
    img = img.filter(ImageFilter.SMOOTH)
    arr = np.array(img).astype(float) * 0.9
    save_rgb(arr, out('maps/ground_dirt.png'))
    return arr


def ground_road():
    s = 256
    n = fbm(s, s, 4, 6, 77)
    col = mix((40, 40, 42), (78, 77, 76), n)
    col += rng.normal(0, 6, (s, s))[..., None]
    edge = np.abs(np.arange(s) - s / 2) / (s / 2)
    dirt = smoothstep(0.82, 1.0, edge)[None, :] * (0.6 + 0.4 * fbm(s, s, 8, 3, 91))
    col = col * (1 - dirt[..., None]) + np.array((84, 70, 54)) * dirt[..., None]
    img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    r = np.random.default_rng(8)
    wear = fbm(s, s, 8, 4, 55)
    for y0, y1 in ((16, 104), (144, 232)):
        d.rectangle((s // 2 - 4, y0, s // 2 + 4, y1), fill=(176, 160, 112, 170))
    for _ in range(9):
        x, y = float(r.uniform(20, s - 20)), float(r.uniform(0, s))
        pts = [(x, y)]
        for _ in range(int(r.integers(6, 14))):
            x += r.uniform(-9, 9)
            y += r.uniform(-12, 12)
            pts.append((x, y))
        for oy in (-s, 0, s):
            d.line([(p[0], p[1] + oy) for p in pts], fill=(18, 18, 20, 220), width=int(r.integers(1, 3)))
    for _ in range(4):
        x, y = r.uniform(30, s - 30), r.uniform(20, s - 20)
        rw, rh = r.uniform(8, 18), r.uniform(6, 13)
        d.ellipse((x - rw - 2, y - rh - 2, x + rw + 2, y + rh + 2), fill=(96, 90, 80, 200))
        d.ellipse((x - rw, y - rh, x + rw, y + rh), fill=(22, 20, 19, 235))
    arr = np.array(img).astype(float)
    arr *= (0.85 + 0.15 * wear)[..., None]
    save_rgb(arr, out('maps/ground_road.png'))


def crater():
    s = 256
    rr = radial(s, s, s / 2, s / 2, s / 2)
    n = fbm(s, s, 6, 5, 202)
    rr2 = rr * (0.85 + 0.3 * n)
    alpha = 1 - smoothstep(0.72, 1.0, rr2)
    rim = np.exp(-((rr2 - 0.62) ** 2) / 0.01)
    center = 1 - smoothstep(0.0, 0.55, rr2)
    col = np.zeros((s, s, 3)) + np.array((52, 42, 34))
    col = col * (1 - center[..., None] * 0.8) + np.array((10, 9, 8)) * center[..., None] * 0.8
    col = col * (1 - rim[..., None] * 0.5) + np.array((112, 96, 76)) * rim[..., None] * 0.5
    yy, xx = np.mgrid[0:s, 0:s]
    ang = np.arctan2(yy - s / 2, xx - s / 2)
    streak = (np.sin(ang * 23 + n * 9) * 0.5 + 0.5) * smoothstep(0.3, 0.9, rr2) * (1 - smoothstep(0.85, 1.0, rr2))
    col = col * (1 - streak[..., None] * 0.35)
    col += rng.normal(0, 6, (s, s))[..., None]
    rgba = np.dstack([col, alpha * 235])
    save_rgba(rgba, out('effects/crater.png'))


# ---------------------------------------------------------------- materials
def wall_ruin():
    s = 256
    n = fbm(s, s, 4, 6, 301)
    streak = fbm(s, s, 24, 3, 302, base_y=2)
    col = mix((70, 66, 60), (132, 124, 112), n)
    col *= (0.75 + 0.3 * streak)[..., None]
    col += rng.normal(0, 5, (s, s))[..., None]
    img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    d.rectangle((0, 0, s, 16), fill=(64, 61, 58, 255))
    d.line((0, 17, s, 17), fill=(150, 144, 132, 200), width=2)
    d.rectangle((0, 0, 9, s), fill=(84, 80, 74, 230))
    d.rectangle((s - 10, 0, s, s), fill=(84, 80, 74, 230))
    r = np.random.default_rng(31)
    for wx0 in (34, 146):
        wx1 = wx0 + 76
        wy0, wy1 = 62, 172
        for k in range(26):
            a = k / 26
            d.rectangle((wx0 - 4, wy0 - 40 + k, wx1 + 4, wy0 - 39 + k), fill=(14, 12, 10, int(120 * a)))
        d.rectangle((wx0 - 5, wy0 - 5, wx1 + 5, wy1 + 7), fill=(150, 142, 128, 255))
        d.rectangle((wx0 - 5, wy1 + 2, wx1 + 5, wy1 + 9), fill=(104, 98, 90, 255))
        pts = []
        steps = 18
        for i in range(steps):
            t = i / steps
            pts.append((wx0 + t * (wx1 - wx0), wy0 + r.uniform(-4, 5)))
        for i in range(steps):
            t = i / steps
            pts.append((wx1 + r.uniform(-5, 4), wy0 + t * (wy1 - wy0)))
        for i in range(steps):
            t = i / steps
            pts.append((wx1 - t * (wx1 - wx0), wy1 + r.uniform(-5, 3)))
        for i in range(steps):
            t = i / steps
            pts.append((wx0 + r.uniform(-4, 5), wy1 - t * (wy1 - wy0)))
        d.polygon(pts, fill=(16, 14, 13, 255))
        d.rectangle((wx0 + 4, wy0 + 4, wx1 - 4, wy0 + 30), fill=(34, 26, 20, 140))
        d.line((wx0 + 10, wy0 + 6, wx0 + 22, wy1 - 8), fill=(60, 54, 48, 200), width=2)
    for _ in range(40):
        x, y = r.uniform(4, s - 4), r.uniform(22, s - 4)
        rad = r.uniform(1.2, 3.2)
        d.ellipse((x - rad - 1.4, y - rad - 1.4, x + rad + 1.4, y + rad + 1.4), fill=(150, 144, 134, 180))
        d.ellipse((x - rad, y - rad, x + rad, y + rad), fill=(18, 16, 14, 255))
    for _ in range(6):
        x, y = float(r.uniform(10, s - 10)), float(r.uniform(180, s))
        pts = [(x, y)]
        for _ in range(int(r.integers(5, 9))):
            x += r.uniform(-10, 10)
            y += r.uniform(-14, 6)
            pts.append((x, y))
        d.line(pts, fill=(30, 28, 26, 220), width=1)
    cx, cy = r.uniform(60, 200), 222
    pts = [(cx + math.cos(a) * r.uniform(14, 26), cy + math.sin(a) * r.uniform(10, 18)) for a in np.linspace(0, 2 * math.pi, 14, endpoint=False)]
    d.polygon(pts, fill=(28, 24, 22, 255))
    for k in range(4):
        d.line((cx - 18 + k * 11, cy - 14, cx - 14 + k * 11, cy + 14), fill=(96, 60, 40, 255), width=2)
    arr = np.array(img).astype(float)
    grime = fbm(s, s, 6, 4, 333)
    arr *= (0.7 + 0.35 * grime)[..., None]
    save_rgb(arr * 0.92, out('images/wall_ruin.png'))


def concrete():
    s = 128
    n = fbm(s, s, 4, 5, 401)
    col = mix((92, 90, 86), (150, 148, 140), n)
    col += rng.normal(0, 5, (s, s))[..., None]
    img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    r = np.random.default_rng(41)
    d.line((0, 1, s, 1), fill=(176, 172, 164, 200), width=2)
    for _ in range(5):
        x, y = float(r.uniform(0, s)), float(r.uniform(0, s))
        pts = [(x, y)]
        for _ in range(6):
            x += r.uniform(-8, 8)
            y += r.uniform(-8, 8)
            pts.append((x, y))
        d.line(pts, fill=(48, 46, 44, 200), width=1)
    for _ in range(14):
        x, y = r.uniform(0, s), r.uniform(0, s)
        rad = r.uniform(1, 2.5)
        d.ellipse((x - rad, y - rad, x + rad, y + rad), fill=(40, 38, 36, 230))
    stain = fbm(s, s, 3, 3, 404)
    arr = np.array(img).astype(float) * (0.8 + 0.25 * stain)[..., None]
    save_rgb(arr, out('images/concrete.png'))


def roof():
    s = 256
    n = fbm(s, s, 4, 6, 501)
    col = mix((56, 52, 48), (108, 100, 92), n)
    col += rng.normal(0, 6, (s, s))[..., None]
    img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    r = np.random.default_rng(51)
    for _ in range(120):
        x, y = r.uniform(0, s), r.uniform(0, s)
        rad = r.uniform(3, 11)
        pts = [(x + math.cos(a) * rad * r.uniform(0.6, 1.2), y + math.sin(a) * rad * r.uniform(0.6, 1.2)) for a in np.linspace(0, 2 * math.pi, 7, endpoint=False)]
        g = int(r.integers(80, 150))
        d.polygon([(p[0] + 2, p[1] + 2) for p in pts], fill=(20, 18, 16, 150))
        d.polygon(pts, fill=(g, g - 4, g - 10, 255))
    for _ in range(3):
        x, y = r.uniform(30, s - 30), r.uniform(30, s - 30)
        rad = r.uniform(16, 30)
        pts = [(x + math.cos(a) * rad * r.uniform(0.6, 1.1), y + math.sin(a) * rad * r.uniform(0.6, 1.1)) for a in np.linspace(0, 2 * math.pi, 11, endpoint=False)]
        d.polygon(pts, fill=(12, 10, 9, 255))
    save_rgb(np.array(img), out('images/roof.png'))


def sandbag():
    w, h = 128, 64
    base = np.zeros((h, w, 3)) + np.array((40, 34, 26))
    img = Image.fromarray(base.astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    r = np.random.default_rng(61)
    for row in range(2):
        y0 = row * 32
        off = 0 if row == 0 else 21
        for k in range(-1, 4):
            x0 = off + k * 42
            for ox in (-w, 0, w):
                bx = x0 + ox
                for i in range(12):
                    t = i / 11
                    c = (int(84 + 80 * t), int(72 + 70 * t), int(50 + 52 * t), 255)
                    inset = (1 - t) * 2 + t * 9
                    d.rounded_rectangle((bx + inset, y0 + 1 + inset * 0.6, bx + 41 - inset, y0 + 31 - inset * 0.9), radius=10, fill=c)
                d.line((bx + 8, y0 + 16 + r.uniform(-2, 2), bx + 34, y0 + 16 + r.uniform(-2, 2)), fill=(88, 76, 54, 160), width=1)
    arr = np.array(img).astype(float)
    arr *= (0.8 + 0.3 * fbm(w, h, 8, 3, 66, base_y=4))[..., None]
    arr += rng.normal(0, 6, (h, w))[..., None]
    save_rgb(arr, out('images/sandbag.png'))


def crate():
    s = 128
    n = fbm(s, s, 2, 5, 701, base_y=12)
    col = mix((50, 56, 34), (92, 98, 62), n)
    img = Image.fromarray(np.clip(col, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(img, 'RGBA')
    for k in range(1, 6):
        y = k * s / 6
        d.line((0, y, s, y), fill=(28, 30, 20, 255), width=2)
        d.line((0, y + 2, s, y + 2), fill=(110, 116, 78, 120), width=1)
    d.rectangle((0, 0, s - 1, s - 1), outline=(36, 38, 24, 255), width=12)
    d.rectangle((3, 3, s - 4, s - 4), outline=(104, 110, 74, 170), width=2)
    d.line((12, s - 12, s - 12, 12), fill=(40, 44, 28, 255), width=12)
    d.line((14, s - 14, s - 14, 14), fill=(98, 104, 68, 200), width=3)
    for x, y in ((6, 6), (s - 7, 6), (6, s - 7), (s - 7, s - 7)):
        d.ellipse((x - 2, y - 2, x + 2, y + 2), fill=(150, 150, 140, 255))
    d.polygon(((s / 2 - 10, 34), (s / 2 + 10, 34), (s / 2, 22)), fill=(170, 160, 120, 150))
    d.rectangle((s / 2 - 3, 34, s / 2 + 3, 46), fill=(170, 160, 120, 150))
    arr = np.array(img).astype(float)
    arr *= (0.8 + 0.3 * fbm(s, s, 5, 3, 707))[..., None]
    arr += rng.normal(0, 5, (s, s))[..., None]
    save_rgb(arr, out('images/crate.png'))


# ---------------------------------------------------------------- billboard sprites
def finish_sprite(img, size, path, tex_seed, grain=6):
    img = img.resize(size, Image.LANCZOS)
    arr = np.array(img).astype(float)
    n = fbm(size[0], size[1], 6, 4, tex_seed)
    arr[..., :3] *= (0.78 + 0.35 * n)[..., None]
    arr[..., :3] += rng.normal(0, grain, (size[1], size[0]))[..., None]
    save_rgba(arr, out(path))


def shade_poly(d, pts, base, light=1.0):
    c = tuple(int(min(255, v * light)) for v in base)
    d.polygon(pts, fill=c + (255,))


def tree():
    W, H = 512, 640
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = np.random.default_rng(81)
    d.polygon(((236, 640), (276, 640), (268, 330), (244, 330)), fill=(54, 42, 32, 255))
    d.polygon(((248, 640), (262, 640), (258, 330), (250, 330)), fill=(76, 60, 44, 255))

    def branch(x, y, ang, length, width, depth):
        if depth == 0 or length < 10:
            return
        x2 = x + math.cos(ang) * length
        y2 = y + math.sin(ang) * length
        d.line((x, y, x2, y2), fill=(50, 40, 30, 255), width=int(width))
        for s in (-1, 1):
            branch(x2, y2, ang + s * r.uniform(0.3, 0.7), length * r.uniform(0.62, 0.78), max(2, width * 0.66), depth - 1)

    branch(256, 360, -math.pi / 2, 120, 22, 5)
    blobs = []
    for _ in range(70):
        a = r.uniform(0, 2 * math.pi)
        rad = r.uniform(0, 1) ** 0.6
        cx = 256 + math.cos(a) * rad * 190
        cy = 230 + math.sin(a) * rad * 170
        blobs.append((cy, cx, r.uniform(34, 62)))
    blobs.sort()
    for cy, cx, br in blobs:
        shade = 0.7 + 0.5 * (1 - (cy - 60) / 360)
        base = np.array((52, 64, 34)) * shade
        d.ellipse((cx - br, cy - br * 0.9, cx + br, cy + br * 0.9), fill=tuple(int(v * 0.6) for v in base) + (255,))
        d.ellipse((cx - br * 0.85 - 6, cy - br * 0.8 - 8, cx + br * 0.7, cy + br * 0.6), fill=tuple(int(v) for v in base) + (255,))
        d.ellipse((cx - br * 0.6 - 10, cy - br * 0.65 - 12, cx + br * 0.2, cy + br * 0.1), fill=tuple(int(min(255, v * 1.3)) for v in base) + (255,))
    finish_sprite(img, (256, 320), 'sprites/tree.png', 811)


def tree_dead():
    W, H = 512, 640
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = np.random.default_rng(91)
    d.polygon(((232, 640), (282, 640), (270, 300), (248, 300)), fill=(30, 26, 22, 255))
    d.polygon(((250, 640), (262, 640), (258, 300), (252, 300)), fill=(56, 48, 40, 255))

    def branch(x, y, ang, length, width, depth):
        if depth == 0:
            return
        x2 = x + math.cos(ang) * length
        y2 = y + math.sin(ang) * length
        d.line((x, y, x2, y2), fill=(34, 30, 26, 255), width=int(width))
        d.line((x - 1, y - 1, x2 - 1, y2 - 1), fill=(64, 56, 46, 255), width=max(1, int(width * 0.35)))
        n = 2 if depth > 1 else 1
        for i in range(n):
            branch(x2, y2, ang + r.uniform(-0.75, 0.75), length * r.uniform(0.55, 0.8), max(2, width * 0.62), depth - 1)

    branch(258, 320, -math.pi / 2 - 0.1, 130, 24, 6)
    branch(255, 420, -math.pi / 2 + 0.9, 90, 14, 4)
    branch(260, 380, -math.pi / 2 - 0.95, 90, 14, 4)
    finish_sprite(img, (256, 320), 'sprites/tree_dead.png', 911)


def rock():
    W, H = 384, 256
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    outline = [(20, 250), (40, 150), (100, 80), (190, 40), (290, 70), (350, 140), (370, 250)]
    d.polygon(outline, fill=(70, 64, 58, 255))
    shade_poly(d, [(40, 150), (100, 80), (190, 40), (180, 140), (90, 180)], (126, 118, 106))
    shade_poly(d, [(190, 40), (290, 70), (260, 150), (180, 140)], (104, 98, 88))
    shade_poly(d, [(290, 70), (350, 140), (370, 250), (250, 250), (260, 150)], (66, 62, 56))
    shade_poly(d, [(20, 250), (40, 150), (90, 180), (130, 250)], (96, 90, 80))
    shade_poly(d, [(90, 180), (180, 140), (260, 150), (250, 250), (130, 250)], (84, 78, 70))
    finish_sprite(img, (192, 128), 'sprites/rock.png', 1011, grain=8)


def wheel(d, cx, cy, rad):
    d.ellipse((cx - rad, cy - rad, cx + rad, cy + rad), fill=(18, 18, 18, 255))
    d.ellipse((cx - rad * 0.55, cy - rad * 0.55, cx + rad * 0.55, cy + rad * 0.55), fill=(52, 50, 46, 255))
    d.ellipse((cx - rad * 0.2, cy - rad * 0.2, cx + rad * 0.2, cy + rad * 0.2), fill=(28, 26, 24, 255))


def tank_wreck():
    W, H = 768, 448
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((40, 290, 728, 420), radius=60, fill=(24, 24, 22, 255))
    for k in range(7):
        wheel(d, 110 + k * 92, 356, 46)
    for k in range(40):
        x = 50 + k * 17
        d.line((x, 292, x + 6, 300), fill=(56, 54, 50, 255), width=4)
    shade_poly(d, [(20, 300), (80, 200), (690, 200), (750, 300)], (74, 78, 52))
    shade_poly(d, [(80, 200), (690, 200), (660, 175), (110, 175)], (104, 108, 74))
    shade_poly(d, [(20, 300), (750, 300), (740, 322), (30, 322)], (44, 46, 32))
    shade_poly(d, [(230, 175), (260, 100), (500, 92), (560, 175)], (82, 86, 58))
    shade_poly(d, [(260, 100), (500, 92), (480, 74), (290, 80)], (112, 116, 80))
    d.polygon([(500, 120), (720, 170), (716, 186), (498, 146)], fill=(44, 46, 34, 255))
    d.line((500, 120, 716, 170), fill=(96, 98, 74, 255), width=3)
    d.ellipse((340, 70, 400, 92), fill=(40, 40, 32, 255))
    img_arr = np.array(img).astype(float)
    soot = fbm(W, H, 5, 5, 1111)
    burn = smoothstep(0.45, 0.75, soot)
    img_arr[..., :3] *= (1 - burn * 0.65)[..., None]
    rust = smoothstep(0.62, 0.8, fbm(W, H, 9, 3, 1112))
    img_arr[..., :3] = img_arr[..., :3] * (1 - rust[..., None] * 0.5) + np.array((110, 58, 30)) * rust[..., None] * 0.5
    img = Image.fromarray(np.clip(img_arr, 0, 255).astype(np.uint8), 'RGBA')
    finish_sprite(img, (384, 224), 'sprites/tank_wreck.png', 1113)


def truck_wreck():
    W, H = 768, 448
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    shade_poly(d, [(250, 330), (250, 140), (740, 140), (740, 330)], (66, 70, 50))
    for k in range(6):
        x = 280 + k * 80
        d.line((x, 140, x, 330), fill=(44, 46, 32, 255), width=8)
    d.arc((250, 40, 740, 240), 180, 360, fill=(52, 54, 40, 255), width=10)
    shade_poly(d, [(40, 330), (40, 240), (90, 230), (110, 120), (240, 110), (250, 330)], (78, 82, 58))
    shade_poly(d, [(118, 130), (234, 122), (236, 210), (104, 220)], (14, 16, 16))
    d.line((130, 140, 200, 200), fill=(120, 130, 130, 255), width=2)
    d.line((160, 130, 210, 170), fill=(120, 130, 130, 255), width=2)
    shade_poly(d, [(30, 330), (750, 330), (750, 352), (30, 352)], (30, 30, 26))
    for x in (120, 470, 640):
        wheel(d, x, 360, 62)
    img_arr = np.array(img).astype(float)
    soot = fbm(W, H, 5, 5, 1211)
    burn = smoothstep(0.42, 0.72, soot)
    img_arr[..., :3] *= (1 - burn * 0.7)[..., None]
    rust = smoothstep(0.6, 0.8, fbm(W, H, 9, 3, 1212))
    img_arr[..., :3] = img_arr[..., :3] * (1 - rust[..., None] * 0.55) + np.array((104, 54, 28)) * rust[..., None] * 0.55
    img = Image.fromarray(np.clip(img_arr, 0, 255).astype(np.uint8), 'RGBA')
    finish_sprite(img, (384, 224), 'sprites/truck_wreck.png', 1213)


def hedgehog():
    W, H = 320, 256
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    beams = [((40, 240), (280, 30)), ((280, 240), (40, 30)), ((160, 250), (160, 10))]
    for (x0, y0), (x1, y1) in beams:
        d.line((x0, y0, x1, y1), fill=(30, 26, 24, 255), width=26)
        d.line((x0, y0, x1, y1), fill=(84, 64, 50, 255), width=18)
        d.line((x0 - 4, y0 - 3, x1 - 4, y1 - 3), fill=(130, 100, 76, 255), width=5)
    finish_sprite(img, (160, 128), 'sprites/hedgehog.png', 1311)


def barrel():
    W, H = 128, 192
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    arr = np.zeros((H, W, 4))
    xs = np.linspace(-1, 1, W - 16)
    shade = 0.45 + 0.75 * np.sqrt(np.clip(1 - xs ** 2, 0, 1)) * (1 - 0.3 * xs)
    col = np.array((116, 44, 28))
    arr[10:H - 6, 8:W - 8, :3] = col * shade[None, :, None]
    arr[10:H - 6, 8:W - 8, 3] = 255
    for y in (40, 96, 150):
        arr[y:y + 6, 8:W - 8, :3] *= 0.55
        arr[y - 2:y, 8:W - 8, :3] *= 1.25
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), 'RGBA')
    d = ImageDraw.Draw(img)
    d.ellipse((8, 2, W - 8, 22), fill=(60, 30, 22, 255))
    d.ellipse((14, 5, W - 14, 19), fill=(94, 46, 32, 255))
    finish_sprite(img, (64, 96), 'sprites/barrel.png', 1411)


def debris():
    W, H = 384, 192
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = np.random.default_rng(1501)
    chunks = []
    for _ in range(26):
        cx = r.uniform(40, 344)
        cy = r.uniform(70, 175)
        h = 175 - cy
        cy = 175 - h * (1 - abs(cx - 192) / 200)
        chunks.append((cy, cx, r.uniform(16, 38)))
    chunks.sort()
    for i in range(6):
        x = r.uniform(60, 320)
        d.line((x, 170, x + r.uniform(-50, 50), r.uniform(40, 100)), fill=(70, 44, 30, 255), width=4)
    for cy, cx, rad in chunks:
        pts = [(cx + math.cos(a) * rad * r.uniform(0.6, 1.1), cy + math.sin(a) * rad * 0.7 * r.uniform(0.6, 1.1)) for a in np.linspace(0, 2 * math.pi, 7, endpoint=False)]
        g = int(r.integers(80, 140))
        d.polygon(pts, fill=(g, g - 4, g - 12, 255))
        top = [p for p in pts if p[1] <= cy]
        if len(top) >= 3:
            d.polygon(top, fill=(min(255, g + 40), min(255, g + 36), min(255, g + 26), 255))
    finish_sprite(img, (192, 96), 'sprites/debris.png', 1511)


# ---------------------------------------------------------------- camo
def camo(path, colors, seed):
    s = 64
    n1 = fbm(s, s, 3, 3, seed)
    n2 = fbm(s, s, 4, 3, seed + 7)
    n3 = fbm(s, s, 5, 2, seed + 13)
    col = np.zeros((s, s, 3)) + np.array(colors[0], dtype=float)
    for mask, c in ((n1 > 0.55, colors[1]), (n2 > 0.58, colors[2]), (n3 > 0.62, colors[3])):
        col[mask] = c
    col += rng.normal(0, 5, (s, s))[..., None]
    save_rgb(col, out(path))


# ---------------------------------------------------------------- effects atlas
def effects_atlas():
    C = 128
    atlas = np.zeros((C, C * 8, 4))
    yy, xx = np.mgrid[0:C, 0:C]
    rr = np.sqrt((xx - C / 2) ** 2 + (yy - C / 2) ** 2) / (C / 2)
    n = fbm(C, C, 4, 5, 2001)
    # 0 smoke
    a = np.clip(1 - rr * (0.75 + 0.5 * n), 0, 1) ** 1.6
    g = 190 + 60 * n
    atlas[:, 0:C] = np.dstack([g, g, g, a * 255])
    # 1 fire
    fx = (xx - C / 2) / (C / 2)
    fy = (yy - C * 0.62) / (C * 0.5)
    nf = fbm(C, C, 4, 4, 2002, base_y=6)
    shape = np.sqrt((fx / (0.55 * (1 - np.clip(-fy, 0, 1) * 0.75) + 1e-3)) ** 2 + np.where(fy > 0, (fy * 1.6) ** 2, (fy * 0.85) ** 2))
    shape = shape * (0.8 + 0.4 * nf)
    heat = np.clip(1 - shape, 0, 1)
    r_ = np.clip(heat * 3.0, 0, 1) * 255
    g_ = np.clip(heat * 2.0 - 0.25, 0, 1) * 235
    b_ = np.clip(heat * 2.5 - 1.5, 0, 1) * 200
    atlas[:, C:2 * C] = np.dstack([r_, g_, b_, np.clip(heat * 2.4, 0, 1) * 255])
    # 2 muzzle flash
    ang = np.arctan2(yy - C / 2, xx - C / 2)
    rays = (np.cos(ang * 6) * 0.5 + 0.5) ** 6
    fl = np.clip(1 - rr / (0.35 + 0.65 * rays), 0, 1)
    core = np.clip(1 - rr * 3.0, 0, 1)
    atlas[:, 2 * C:3 * C] = np.dstack([
        np.full((C, C), 255.0),
        np.clip(200 + 55 * core, 0, 255),
        np.clip(90 + 165 * core, 0, 255),
        np.clip(fl ** 1.3 + core, 0, 1) * 255])
    # 3 glow
    gl = np.clip(1 - rr, 0, 1) ** 2.2
    atlas[:, 3 * C:4 * C] = np.dstack([np.full((C, C), 255.0)] * 3 + [gl * 255])
    # 4 dust
    nd = fbm(C, C, 5, 5, 2004)
    ad = np.clip(1 - rr * (0.6 + 0.8 * nd), 0, 1) ** 1.3
    gd = 200 + 40 * nd
    atlas[:, 4 * C:5 * C] = np.dstack([gd, gd * 0.95, gd * 0.88, ad * 230])
    # 5 debris chunk
    chunk = Image.new('RGBA', (C, C), (0, 0, 0, 0))
    dd = ImageDraw.Draw(chunk)
    pts = [(64 + math.cos(t) * r_ * 40, 64 + math.sin(t) * r_ * 40) for t, r_ in zip(np.linspace(0, 2 * math.pi, 7, endpoint=False), (1, 0.7, 0.95, 0.6, 0.9, 0.75, 1.0))]
    dd.polygon(pts, fill=(150, 146, 138, 255))
    dd.polygon(pts[:4] + [(64, 64)], fill=(206, 202, 194, 255))
    atlas[:, 5 * C:6 * C] = np.array(chunk).astype(float)
    # 6 shock ring
    ring = np.exp(-((rr - 0.8) ** 2) / 0.006)
    atlas[:, 6 * C:7 * C] = np.dstack([np.full((C, C), 255.0)] * 3 + [ring * 255])
    # 7 impact streaks
    st = (np.cos(ang * 5 + 0.4) * 0.5 + 0.5) ** 14 * np.clip(1 - rr, 0, 1)
    st = np.clip(st * 1.8 + np.clip(1 - rr * 4, 0, 1), 0, 1)
    atlas[:, 7 * C:8 * C] = np.dstack([np.full((C, C), 255.0)] * 3 + [st * 255])
    save_rgba(atlas, out('effects/fx_atlas.png'))


# ---------------------------------------------------------------- skyline + backgrounds
def skyline_layer(w, h, seed, base_line, min_h, max_h, color):
    r = np.random.default_rng(seed)
    mask = Image.new('L', (w, h), 0)
    d = ImageDraw.Draw(mask)
    x = 0
    while x < w:
        bw = r.uniform(40, 150)
        bh = r.uniform(min_h, max_h)
        top = base_line - bh
        pts = [(x, base_line + 5), (x, top)]
        steps = int(r.integers(2, 6))
        for i in range(1, steps + 1):
            pts.append((x + bw * i / steps, top + r.uniform(-bh * 0.3, bh * 0.35) * (1 if r.random() < 0.6 else 0)))
        pts.append((x + bw, base_line + 5))
        for ox in (-w, 0, w):
            d.polygon([(p[0] + ox, p[1]) for p in pts], fill=255)
        if r.random() < 0.35:
            cx = x + bw * 0.5
            for ox in (-w, 0, w):
                d.line((cx + ox, top, cx + ox + r.uniform(-12, 12), top - r.uniform(20, 50)), fill=255, width=3)
        x += bw + r.uniform(-10, 30)
    m = np.array(mask).astype(float) / 255
    return m, np.array(color, dtype=float)


def skyline():
    w, h = 2048, 384
    base = 360
    img = np.zeros((h, w, 4))
    smoke = fbm(w, h, 16, 5, 3001, base_y=3)
    yy = np.arange(h)[:, None] / h
    for k, sx in enumerate((220, 760, 1300, 1820)):
        xs = np.arange(w)
        dx = np.minimum(np.abs(xs - sx), w - np.abs(xs - sx))
        width = 40 + (1 - yy) * 220
        col_mask = np.exp(-(dx[None, :] / width) ** 2) * smoothstep(0.0, 0.85, yy) * (0.5 + 0.7 * smoke)
        col_mask = np.clip(col_mask, 0, 1) * 0.85
        c = np.array((34, 30, 30))
        img[..., :3] = img[..., :3] * (1 - col_mask[..., None]) + c * col_mask[..., None]
        img[..., 3] = np.maximum(img[..., 3], col_mask * 255)
    for seed, bl, mn, mx, color in ((3002, base, 70, 190, (52, 40, 36)), (3003, base + 8, 40, 120, (28, 22, 22))):
        m, c = skyline_layer(w, h, seed, bl, mn, mx, color)
        tex = 0.8 + 0.3 * fbm(w, h, 64, 3, seed + 1, base_y=12)
        img[..., :3] = img[..., :3] * (1 - m[..., None]) + (c * tex[..., None]) * m[..., None]
        img[..., 3] = np.maximum(img[..., 3], m * 255)
    for fx in (120, 520, 980, 1440, 1700, 1960):
        g = np.exp(-(((np.arange(w)[None, :] - fx) / 60.0) ** 2 + ((np.arange(h)[:, None] - base) / 26.0) ** 2))
        img[..., 0] += g * 220
        img[..., 1] += g * 100
        img[..., 2] += g * 30
        img[..., 3] = np.maximum(img[..., 3], g * 255)
    r = np.random.default_rng(3010)
    for _ in range(90):
        x = int(r.integers(0, w))
        y = int(r.integers(base - 160, base - 20))
        if img[y, x, 3] > 200:
            img[y:y + 2, x:x + 2, :3] = (200, 150, 70) if r.random() < 0.6 else (90, 70, 50)
    save_rgba(img, out('backgrounds/skyline.png'))


def mode7_ground(w, h, horizon, tex, cam_h, focal, offx, offy, tex_scale):
    th, tw = tex.shape[:2]
    rows = np.arange(horizon + 1, h)
    f = cam_h * focal / (rows - horizon)
    xs = np.arange(w) - w / 2
    wx = xs[None, :] * f[:, None] / focal + offx
    wy = -f[:, None] + offy + np.zeros_like(wx)
    tx = (np.floor(wx * tex_scale).astype(int)) % tw
    ty = (np.floor(wy * tex_scale).astype(int)) % th
    g = tex[ty, tx]
    fog = np.clip((f - 300) / 2200, 0, 1)[:, None, None]
    return rows, g, fog


def background(path, seed, lobby):
    w, h = 1600, 900
    horizon = int(h * 0.5)
    img = np.zeros((h, w, 3))
    yy = np.arange(h)[:, None] / horizon
    sky_top = np.array((10, 10, 13))
    sky_mid = np.array((46, 30, 24))
    sky_hor = np.array((128, 66, 32))
    t = np.clip(yy, 0, 1)
    sky = np.where(t[..., None] < 0.6, sky_top + (sky_mid - sky_top) * (t[..., None] / 0.6), sky_mid + (sky_hor - sky_mid) * ((t[..., None] - 0.6) / 0.4))
    img[:horizon + 1] = np.broadcast_to(sky[:horizon + 1], (horizon + 1, w, 3))
    clouds = fbm(w, horizon + 1, 6, 6, seed, base_y=3)
    cmask = smoothstep(0.42, 0.75, clouds) * 0.85
    img[:horizon + 1] = img[:horizon + 1] * (1 - cmask[..., None]) + np.array((22, 20, 22)) * cmask[..., None]
    glow_x = (w * 0.68) if not lobby else (w * 0.3)
    g = np.exp(-(((np.arange(w)[None, :] - glow_x) / 420.0) ** 2 + ((np.arange(horizon + 1)[:, None] - horizon) / 140.0) ** 2))
    img[:horizon + 1] += g[..., None] * np.array((150, 60, 18))
    dirt = np.array(Image.open(out('maps/ground_dirt.png'))).astype(float)
    rows, gr, fog = mode7_ground(w, h, horizon, dirt, 120, 900, 0, 0, 1.2)
    haze = np.array((70, 44, 30))
    gr = gr * 0.75 * (1 - fog) + haze * fog
    img[rows] = gr
    sky_layers = [(seed + 1, 0.62, 120, 300, (40, 30, 28)), (seed + 2, 0.66, 70, 200, (22, 18, 18))]
    for sd, base_frac, mn, mx, colr in sky_layers:
        m, c = skyline_layer(w, h, sd, int(h * base_frac) - int(h * 0.12), mn, mx, colr)
        m[: int(h * 0.15)] = 0
        img = img * (1 - m[..., None]) + c * m[..., None]
    r = np.random.default_rng(seed + 9)
    for _ in range(5):
        fx = r.uniform(0.05, 0.95) * w
        fy = horizon + r.uniform(-30, 10)
        gg = np.exp(-(((np.arange(w)[None, :] - fx) / r.uniform(40, 90)) ** 2 + ((np.arange(h)[:, None] - fy) / 30.0) ** 2))
        img += gg[..., None] * np.array((255, 120, 36)) * r.uniform(0.6, 1.0)
        plume = fbm(w, h, 10, 5, int(r.integers(1, 9999)), base_y=6)
        xs = np.arange(w)
        width = 40 + (fy - np.arange(h)[:, None]).clip(0) * 0.7
        pm = np.exp(-((xs[None, :] - fx - (fy - np.arange(h)[:, None]).clip(0) * 0.3) / width) ** 2) * (np.arange(h)[:, None] < fy) * (0.4 + 0.8 * plume)
        pm = np.clip(pm, 0, 0.9)
        img = img * (1 - pm[..., None]) + np.array((26, 23, 24)) * pm[..., None]
    if lobby:
        cx, cy = w * 0.3, h * 0.82
        sp = np.exp(-(((np.arange(w)[None, :] - cx) / 380.0) ** 2 + ((np.arange(h)[:, None] - cy) / 120.0) ** 2))
        img += sp[..., None] * np.array((80, 60, 40))
    fg = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), 'RGB')
    d = ImageDraw.Draw(fg, 'RGBA')
    sb_y = h - 70
    bags = 14
    for row in range(3):
        for k in range(bags):
            bx = (w - 40 if not lobby else w * 0.62) + 0
            x0 = (k * 70 + (35 if row % 2 else 0)) + (w * 0.55 if not lobby else w * 0.56)
            y0 = sb_y + row * -34 + 40
            if x0 > w + 70:
                continue
            d.rounded_rectangle((x0, y0, x0 + 72, y0 + 38), radius=16, fill=(30, 26, 20, 255))
            d.rounded_rectangle((x0 + 6, y0 + 4, x0 + 62, y0 + 20), radius=10, fill=(58, 50, 38, 255))
    for k in range(9):
        x0 = k * 90 - 20
        d.rounded_rectangle((x0, h - 36, x0 + 92, h + 20), radius=16, fill=(24, 20, 16, 255))
        d.rounded_rectangle((x0 + 8, h - 30, x0 + 80, h - 18), radius=8, fill=(48, 42, 32, 255))
    img = np.array(fg).astype(float)
    for _ in range(160):
        x = int(r.integers(0, w))
        y = int(r.integers(int(h * 0.2), h))
        rad = r.uniform(0.8, 2.2)
        yy2, xx2 = np.ogrid[max(0, y - 4):min(h, y + 5), max(0, x - 4):min(w, x + 5)]
        gm = np.exp(-((xx2 - x) ** 2 + (yy2 - y) ** 2) / (rad * rad))
        img[max(0, y - 4):min(h, y + 5), max(0, x - 4):min(w, x + 5)] += gm[..., None] * np.array((255, 150, 60))
    vig = radial(w, h, w / 2, h / 2, math.hypot(w / 2, h / 2))
    img *= (1 - smoothstep(0.55, 1.05, vig) * 0.75)[..., None]
    img += rng.normal(0, 3, (h, w))[..., None]
    Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), 'RGB').save(out(path), quality=88)


# ---------------------------------------------------------------- weapons (side views)
def weapon_image(path, kind):
    W, H = 1024, 320
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    metal = (40, 42, 45, 255)
    dark = (24, 25, 27, 255)
    hl = (110, 114, 120, 255)
    if kind == 'ar':
        furn = (138, 118, 86, 255)
        d.polygon([(40, 120), (230, 110), (240, 150), (230, 190), (60, 210), (40, 200)], fill=furn)
        d.rectangle((230, 110, 560, 172), fill=metal)
        d.rectangle((560, 118, 820, 166), fill=furn)
        for k in range(14):
            d.rectangle((566 + k * 18, 112, 576 + k * 18, 120), fill=dark)
        d.rectangle((820, 132, 980, 148), fill=dark)
        d.rectangle((960, 126, 1000, 154), fill=metal)
        d.polygon([(420, 172), (480, 172), (510, 290), (450, 300)], fill=dark)
        d.polygon([(290, 172), (340, 172), (320, 270), (270, 262)], fill=furn)
        d.rectangle((300, 84, 460, 110), fill=dark)
        d.rectangle((380, 70, 440, 84), fill=metal)
        d.line((240, 112, 556, 112), fill=hl, width=3)
    elif kind == 'smg':
        d.polygon([(80, 130), (240, 120), (250, 150), (240, 168), (100, 190)], fill=dark)
        d.rectangle((240, 110, 640, 180), fill=metal)
        d.rectangle((640, 124, 780, 166), fill=dark)
        d.rectangle((780, 132, 900, 156), fill=metal)
        d.polygon([(470, 180), (530, 180), (540, 300), (480, 300)], fill=dark)
        d.polygon([(310, 180), (360, 180), (344, 270), (296, 262)], fill=dark)
        d.rectangle((300, 92, 420, 110), fill=dark)
        d.line((250, 112, 636, 112), fill=hl, width=3)
    elif kind == 'shotgun':
        wood = (96, 60, 38, 255)
        d.polygon([(30, 140), (260, 118), (270, 160), (250, 192), (50, 230), (30, 212)], fill=wood)
        d.rectangle((260, 116, 470, 176), fill=metal)
        d.rectangle((470, 124, 990, 146), fill=dark)
        d.rectangle((470, 150, 900, 170), fill=metal)
        d.rounded_rectangle((560, 146, 760, 184), radius=10, fill=wood)
        for k in range(8):
            d.line((574 + k * 22, 150, 574 + k * 22, 180), fill=(70, 44, 28, 255), width=4)
        d.polygon([(300, 176), (350, 176), (330, 262), (284, 254)], fill=wood)
        d.line((470, 125, 988, 125), fill=hl, width=3)
    else:
        olive = (70, 78, 56, 255)
        d.polygon([(20, 140), (220, 120), (240, 156), (220, 196), (60, 212), (20, 200)], fill=olive)
        d.rectangle((120, 196, 150, 240), fill=dark)
        d.rectangle((220, 118, 520, 176), fill=olive)
        d.rectangle((520, 130, 1010, 150), fill=dark)
        d.rectangle((990, 124, 1020, 156), fill=metal)
        d.polygon([(380, 176), (430, 176), (440, 262), (392, 262)], fill=dark)
        d.polygon([(250, 176), (300, 176), (286, 262), (238, 254)], fill=olive)
        d.rounded_rectangle((250, 56, 520, 96), radius=18, fill=dark)
        d.rectangle((230, 62, 260, 90), fill=metal)
        d.rectangle((510, 58, 540, 94), fill=metal)
        d.rectangle((330, 96, 350, 118), fill=dark)
        d.rectangle((430, 96, 450, 118), fill=dark)
        d.line((640, 150, 600, 270), fill=dark, width=10)
        d.line((660, 150, 700, 270), fill=dark, width=10)
        d.line((230, 120, 516, 120), fill=hl, width=3)
        d.line((260, 60, 510, 60), fill=(90, 96, 104, 255), width=3)
    img = img.resize((512, 160), Image.LANCZOS)
    arr = np.array(img).astype(float)
    grad = np.linspace(1.25, 0.7, 160)[:, None]
    arr[..., :3] *= grad[..., None]
    arr[..., :3] *= (0.85 + 0.25 * fbm(512, 160, 16, 3, {'ar': 71, 'smg': 72, 'shotgun': 73}.get(kind, 74), base_y=5))[..., None]
    save_rgba(arr, out(path))


# ---------------------------------------------------------------- UI icons
def icon(path, draw_fn):
    S = 512
    img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_fn(d, S)
    img = img.resize((128, 128), Image.LANCZOS)
    img.save(out(path), optimize=True)


def draw_fire(d, S):
    c = S / 2
    for dx in (-110, 0, 110):
        x = c + dx
        d.rounded_rectangle((x - 34, c - 60, x + 34, c + 150), radius=8, fill=(255, 255, 255, 255))
        d.ellipse((x - 34, c - 150, x + 34, c - 20), fill=(255, 255, 255, 255))
        d.rectangle((x - 40, c + 100, x + 40, c + 116), fill=(0, 0, 0, 0))


def draw_aim(d, S):
    c = S / 2
    d.ellipse((c - 170, c - 170, c + 170, c + 170), outline=(255, 255, 255, 255), width=30)
    for a in range(4):
        ang = a * math.pi / 2
        x0 = c + math.cos(ang) * 80
        y0 = c + math.sin(ang) * 80
        x1 = c + math.cos(ang) * 230
        y1 = c + math.sin(ang) * 230
        d.line((x0, y0, x1, y1), fill=(255, 255, 255, 255), width=30)
    d.ellipse((c - 24, c - 24, c + 24, c + 24), fill=(255, 255, 255, 255))


def draw_reload(d, S):
    c = S / 2
    d.arc((c - 170, c - 170, c + 170, c + 170), 200, 340, fill=(255, 255, 255, 255), width=40)
    d.arc((c - 170, c - 170, c + 170, c + 170), 20, 160, fill=(255, 255, 255, 255), width=40)
    for ang_deg, sgn in ((340, 1), (160, 1)):
        a = math.radians(ang_deg)
        px = c + math.cos(a) * 170
        py = c + math.sin(a) * 170
        tx, ty = -math.sin(a), math.cos(a)
        nx, ny = math.cos(a), math.sin(a)
        d.polygon([(px + tx * 80, py + ty * 80), (px + nx * 70, py + ny * 70), (px - nx * 70, py - ny * 70)], fill=(255, 255, 255, 255))


def draw_sprint(d, S):
    c = S / 2
    for oy in (-80, 60):
        d.line((c - 150, c + oy + 90, c, c + oy - 40, c + 150, c + oy + 90), fill=(255, 255, 255, 255), width=56, joint='curve')


def draw_pause(d, S):
    c = S / 2
    d.rounded_rectangle((c - 140, c - 170, c - 50, c + 170), radius=20, fill=(255, 255, 255, 255))
    d.rounded_rectangle((c + 50, c - 170, c + 140, c + 170), radius=20, fill=(255, 255, 255, 255))


def draw_emblem(d, S):
    c = S / 2
    d.ellipse((10, 10, S - 10, S - 10), fill=(26, 24, 22, 255))
    d.ellipse((40, 40, S - 40, S - 40), outline=(200, 90, 30, 255), width=26)
    for a in range(4):
        ang = a * math.pi / 2
        d.line((c + math.cos(ang) * 60, c + math.sin(ang) * 60, c + math.cos(ang) * 200, c + math.sin(ang) * 200), fill=(230, 220, 200, 255), width=26)
    d.polygon([(c, c - 120), (c + 100, c + 110), (c + 50, c + 110), (c, c - 10), (c - 50, c + 110), (c - 100, c + 110)], fill=(240, 120, 40, 255))


def launcher_icons():
    S = 512
    base = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    draw_emblem(ImageDraw.Draw(base), S)
    res = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
    for name, size in (('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)):
        p = os.path.join(res, 'mipmap-' + name)
        os.makedirs(p, exist_ok=True)
        base.resize((size, size), Image.LANCZOS).save(os.path.join(p, 'ic_launcher.png'), optimize=True)
    base.resize((256, 256), Image.LANCZOS).save(out('ui/emblem.png'), optimize=True)


def main():
    ground_dirt()
    ground_road()
    crater()
    wall_ruin()
    concrete()
    roof()
    sandbag()
    crate()
    tree()
    tree_dead()
    rock()
    tank_wreck()
    truck_wreck()
    hedgehog()
    barrel()
    debris()
    camo('characters/camo_player.png', [(62, 70, 46), (40, 46, 30), (92, 84, 60), (26, 26, 22)], 4001)
    camo('enemies/camo_desert.png', [(128, 110, 80), (100, 84, 60), (150, 134, 102), (70, 58, 44)], 4101)
    camo('enemies/camo_urban.png', [(70, 72, 76), (46, 48, 52), (100, 102, 106), (30, 30, 34)], 4201)
    camo('enemies/camo_dark.png', [(44, 40, 36), (30, 28, 26), (66, 58, 50), (20, 18, 18)], 4301)
    camo('enemies/camo_boss.png', [(48, 20, 18), (28, 14, 14), (80, 30, 24), (16, 10, 10)], 4401)
    effects_atlas()
    skyline()
    background('backgrounds/splash_bg.jpg', 5001, False)
    background('backgrounds/lobby_bg.jpg', 6001, True)
    weapon_image('weapons/assault_rifle.png', 'ar')
    weapon_image('weapons/smg.png', 'smg')
    weapon_image('weapons/shotgun.png', 'shotgun')
    weapon_image('weapons/sniper.png', 'sniper')
    icon('ui/icon_fire.png', draw_fire)
    icon('ui/icon_aim.png', draw_aim)
    icon('ui/icon_reload.png', draw_reload)
    icon('ui/icon_sprint.png', draw_sprint)
    icon('ui/icon_pause.png', draw_pause)
    launcher_icons()


if __name__ == '__main__':
    main()
