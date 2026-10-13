"""Procedural bitmap generator for Dragon Land.

Paints every background / terrain bitmap the game ships with. All artwork is
original and produced by this script (numpy + Pillow). Run from the project
root:

    python3 tool/gen_images.py

Characters, enemies, pickups and effects are vector-drawn at runtime by the
code in lib/art/, so they are not produced here.
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..')
OUT = os.path.join(ROOT, 'assets', 'images')
SS = 2  # supersampling factor


def save(img, name, size=None):
    os.makedirs(OUT, exist_ok=True)
    if size is not None:
        img = img.resize(size, Image.LANCZOS)
    img.save(os.path.join(OUT, name), optimize=True)
    print('wrote', name, img.size)


def hexc(h, a=255):
    h = h.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


def lerp(a, b, t):
    return a + (b - a) * t


def mix(c1, c2, t):
    return tuple(int(round(lerp(c1[i], c2[i], t))) for i in range(len(c1)))


# ------------------------------------------------------------------ noise
def tile_noise(w, h, cx, cy, seed):
    r = np.random.default_rng(seed)
    g = r.random((cy, cx))
    ys = np.arange(h) * cy / h
    xs = np.arange(w) * cx / w
    y0 = np.floor(ys).astype(int)
    x0 = np.floor(xs).astype(int)
    fy = ys - y0
    fx = xs - x0
    fy = fy * fy * (3 - 2 * fy)
    fx = fx * fx * (3 - 2 * fx)
    y1 = (y0 + 1) % cy
    x1 = (x0 + 1) % cx
    a = g[y0][:, x0]
    b = g[y0][:, x1]
    c = g[y1][:, x0]
    d = g[y1][:, x1]
    fx = fx[None, :]
    fy = fy[:, None]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def fbm(w, h, base, octaves, seed, pers=0.5, base_y=None):
    tot = np.zeros((h, w))
    amp, norm = 1.0, 0.0
    by = base if base_y is None else base_y
    for o in range(octaves):
        tot += tile_noise(w, h, base * 2 ** o, by * 2 ** o, seed + 31 * o) * amp
        norm += amp
        amp *= pers
    return tot / norm


def noise1d(n, cells, seed, octaves=4):
    """Periodic 1-D fractal noise in [0, 1] of length n."""
    return fbm(n, 1, cells, octaves, seed, base_y=1)[0]


def texture_layer(w, h, c_dark, c_light, base, seed, octaves=5):
    n = fbm(w, h, base, octaves, seed)
    n = (n - n.min()) / (n.max() - n.min() + 1e-9)
    a = np.array(c_dark[:3], dtype=float)
    b = np.array(c_light[:3], dtype=float)
    rgb = a[None, None, :] * (1 - n[..., None]) + b[None, None, :] * n[..., None]
    alpha = np.full((h, w, 1), 255.0)
    return Image.fromarray(np.concatenate([rgb, alpha], axis=2).astype(np.uint8), 'RGBA')


def vertical_gradient(w, h, stops):
    """stops: list of (t, rgba)."""
    ys = np.linspace(0, 1, h)
    out = np.zeros((h, 4))
    for i in range(4):
        out[:, i] = np.interp(ys, [s[0] for s in stops], [s[1][i] for s in stops])
    arr = np.repeat(out[:, None, :], w, axis=1)
    return Image.fromarray(arr.astype(np.uint8), 'RGBA')


def masked(tex, mask):
    """Use an 'L' mask as alpha for an RGBA texture."""
    t = tex.copy()
    t.putalpha(ImageChops.multiply(t.getchannel('A'), mask))
    return t


def wrap_offsets(w):
    return (-w, 0, w)


# --------------------------------------------------------------- primitives
def poly_mask(size, pts):
    m = Image.new('L', size, 0)
    ImageDraw.Draw(m).polygon(pts, fill=255)
    return m


def ridge_points(w, base_y, amp, cells, seed, step=4, sharp=1.0):
    n = noise1d(w, cells, seed, octaves=5)
    n = (n - n.min()) / (n.max() - n.min() + 1e-9)
    if sharp != 1.0:
        n = 1 - np.abs(n * 2 - 1) ** sharp
    pts = [(x, base_y - amp * n[x]) for x in range(0, w, step)]
    pts.append((w, base_y - amp * n[0]))
    return pts


def glow(img, radius, strength=1.0):
    g = img.filter(ImageFilter.GaussianBlur(radius))
    if strength != 1.0:
        a = g.getchannel('A').point(lambda v: min(255, int(v * strength)))
        g.putalpha(a)
    return g


def alpha_over(dst, src, pos=(0, 0)):
    dst.alpha_composite(src, dest=(int(pos[0]), int(pos[1])))


def paste_wrapped(dst, src, x, y):
    w = dst.width
    for o in wrap_offsets(w):
        xx = int(x + o)
        if xx + src.width < 0 or xx > w:
            continue
        # alpha_composite does not accept negative offsets, crop instead
        sx = max(0, -xx)
        crop = src.crop((sx, 0, src.width, src.height))
        dx = max(0, xx)
        if dx + crop.width > w:
            crop = crop.crop((0, 0, w - dx, crop.height))
        dst.alpha_composite(crop, dest=(dx, int(y)))


def ellipse(d, cx, cy, rx, ry, fill, outline=None, width=0):
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=fill, outline=outline, width=width)


# ------------------------------------------------------------------- sky
def make_sky():
    w, h = 256, 720
    img = vertical_gradient(w, h, [
        (0.0, hexc('#3FA3F5')),
        (0.35, hexc('#6CC6FF')),
        (0.7, hexc('#B8E9FF')),
        (0.88, hexc('#FFEFD2')),
        (1.0, hexc('#FFE1B8')),
    ])
    save(img, 'sky.png')


def make_sun():
    s = 512 * SS
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = s // 2
    for i in range(40, 0, -1):
        r = c * i / 40
        a = int(140 * (1 - i / 40) ** 2.2)
        ellipse(d, c, c, r, r, (255, 246, 210, a))
    ellipse(d, c, c, c * 0.18, c * 0.18, (255, 252, 236, 255))
    img = img.filter(ImageFilter.GaussianBlur(6 * SS))
    save(img, 'sun.png', (512, 512))


# ---------------------------------------------------------------- clouds
def cloud_image(seed, w=520, h=240):
    rng = np.random.default_rng(seed)
    W, H = w * SS, h * SS
    base = Image.new('RGBA', (W, H), (255, 255, 255, 0))
    shade = Image.new('RGBA', (W, H), (176, 205, 240, 0))
    d = ImageDraw.Draw(base)
    ds = ImageDraw.Draw(shade)
    puffs = []
    n = rng.integers(6, 9)
    for i in range(n):
        t = i / (n - 1)
        cx = W * (0.16 + 0.68 * t) + rng.uniform(-20, 20) * SS
        r = H * (0.2 + 0.17 * math.sin(math.pi * t)) * rng.uniform(0.9, 1.08)
        cy = max(r + 4 * SS, H * 0.6 - r * 0.4 + rng.uniform(-8, 8) * SS)
        puffs.append((cx, cy, r))
    d.rounded_rectangle((W * 0.12, H * 0.5, W * 0.88, H * 0.82), radius=int(H * 0.16), fill=(255, 255, 255, 255))
    for cx, cy, r in puffs:
        ellipse(d, cx, cy, r, r, (255, 255, 255, 255))
    for cx, cy, r in puffs:
        ellipse(ds, cx + r * 0.1, cy + r * 0.55, r * 0.95, r * 0.6, (190, 214, 245, 200))
    shade = shade.filter(ImageFilter.GaussianBlur(12 * SS))
    shade = masked(shade, base.getchannel('A'))
    out = Image.new('RGBA', (W, H), (255, 255, 255, 0))
    out.alpha_composite(base)
    out.alpha_composite(shade)
    # soft top highlight
    hl = Image.new('RGBA', (W, H), (255, 255, 255, 0))
    dh = ImageDraw.Draw(hl)
    for cx, cy, r in puffs:
        ellipse(dh, cx - r * 0.2, cy - r * 0.35, r * 0.55, r * 0.4, (255, 255, 255, 160))
    hl = hl.filter(ImageFilter.GaussianBlur(8 * SS))
    out.alpha_composite(masked(hl, base.getchannel('A')))
    return out.resize((w, h), Image.LANCZOS)


def make_clouds():
    for i in range(4):
        save(cloud_image(100 + i * 17, w=[520, 420, 600, 360][i], h=[240, 200, 260, 170][i]), f'cloud_{i + 1}.png')


# ------------------------------------------------------------ far mountains
def make_far_mountains():
    w, h = 2048 * SS, 720 * SS
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))

    def range_layer(base_y, amp, cells, seed, c_top, c_bot, snow=False, sharp=1.6):
        pts = ridge_points(w, base_y, amp, cells, seed, step=2 * SS, sharp=sharp)
        poly = pts + [(w, h), (0, h)]
        m = poly_mask((w, h), poly)
        tex = vertical_gradient(w, h, [(0, c_top), (base_y / h, mix(c_top, c_bot, 0.4)), (1, c_bot)])
        noise = texture_layer(w, h, (0, 0, 0, 255), (255, 255, 255, 255), 24, seed + 5, 4)
        tex = Image.blend(tex, ImageChops.multiply(tex, noise.convert('RGBA')), 0.12)
        layer = masked(tex, m)
        if snow:
            yy = np.arange(h)[:, None]
            edge = noise1d(w, 40, seed + 9, octaves=3)[None, :]
            line = base_y - amp * (0.62 + 0.1 * edge)
            snow_arr = (yy < line).astype(np.uint8) * 255
            snow_m = Image.fromarray(snow_arr, 'L').filter(ImageFilter.GaussianBlur(1.2 * SS))
            snow_m = ImageChops.multiply(snow_m, m)
            snow_img = vertical_gradient(w, h, [(0, hexc('#FFFFFF')), (1, hexc('#DCE6FF'))])
            layer.alpha_composite(masked(snow_img, snow_m))
        return layer

    # castle on the farthest range
    back = range_layer(470 * SS, 330 * SS, 5, 11, hexc('#A99BE3'), hexc('#C7D6F6'), snow=True, sharp=1.2)
    img.alpha_composite(back)
    castle = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dc = ImageDraw.Draw(castle)
    ccol = hexc('#8C7CCB')
    roof = hexc('#7A5FC0')
    cx0, cy0 = 1260 * SS, 300 * SS
    for (dx, tw, th) in [(-110, 46, 170), (-40, 60, 230), (40, 52, 190), (110, 40, 140)]:
        x = cx0 + dx * SS
        dc.rectangle((x - tw * SS / 2, cy0 - th * SS + 160 * SS, x + tw * SS / 2, cy0 + 200 * SS), fill=ccol)
        top = cy0 - th * SS + 160 * SS
        dc.polygon([(x - tw * SS * 0.62, top), (x + tw * SS * 0.62, top), (x, top - tw * SS * 1.2)], fill=roof)
        dc.line([(x, top - tw * SS * 1.2), (x, top - tw * SS * 1.2 - 30 * SS)], fill=roof, width=2 * SS)
        dc.polygon([(x, top - tw * SS * 1.2 - 30 * SS), (x + 22 * SS, top - tw * SS * 1.2 - 24 * SS),
                    (x, top - tw * SS * 1.2 - 17 * SS)], fill=hexc('#F27E9B'))
        for wy in range(int(top + 26 * SS), int(cy0 + 160 * SS), int(34 * SS)):
            dc.rounded_rectangle((x - 5 * SS, wy, x + 5 * SS, wy + 14 * SS), radius=4 * SS, fill=hexc('#FFE9A8'))
    dc.rectangle((cx0 - 140 * SS, cy0 + 90 * SS, cx0 + 140 * SS, cy0 + 220 * SS), fill=ccol)
    for i in range(-7, 8):
        dc.rectangle((cx0 + i * 20 * SS - 6 * SS, cy0 + 76 * SS, cx0 + i * 20 * SS + 6 * SS, cy0 + 92 * SS), fill=ccol)
    castle = castle.filter(ImageFilter.GaussianBlur(0.6 * SS))
    haze = Image.new('RGBA', (w, h), (205, 220, 250, 70))
    castle = masked(castle, castle.getchannel('A'))
    img.alpha_composite(castle)
    img.alpha_composite(masked(haze, castle.getchannel('A')))

    mid = range_layer(560 * SS, 260 * SS, 7, 23, hexc('#8FA8E8'), hexc('#B6D3F2'), snow=True, sharp=1.4)
    img.alpha_composite(mid)
    front = range_layer(640 * SS, 190 * SS, 9, 37, hexc('#7FB6D8'), hexc('#A6E0E6'), sharp=1.0)
    img.alpha_composite(front)

    # distance haze at the bottom
    fog = vertical_gradient(w, h, [(0, (255, 255, 255, 0)), (0.55, (255, 255, 255, 0)), (1, (232, 246, 255, 200))])
    img.alpha_composite(masked(fog, img.getchannel('A')))
    save(img, 'bg_far.png', (2048, 720))


# ------------------------------------------------------------ mid islands
def island_sprite(seed, width, height, waterfall=True, ruins=False, castle=False):
    rng = np.random.default_rng(seed)
    W, H = int(width * SS), int(height * SS)
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    top_y = int(H * 0.32)
    # rocky underside (inverted cone with bumpy outline)
    pts = []
    n = 40
    for i in range(n + 1):
        t = i / n
        x = W * (0.06 + 0.88 * t)
        depth = math.sin(math.pi * t) ** 1.3
        y = top_y + (H - top_y - 4) * depth * (0.82 + 0.18 * rng.random())
        pts.append((x, y))
    under = poly_mask((W, H), [(W * 0.06, top_y)] + pts + [(W * 0.94, top_y)])
    rock = texture_layer(W, H, hexc('#7E5B49'), hexc('#C58F67'), 10, seed + 3)
    shade = vertical_gradient(W, H, [(0, (255, 255, 255, 0)), (0.5, (60, 40, 70, 40)), (1, (60, 30, 80, 150))])
    rock.alpha_composite(shade)
    img.alpha_composite(masked(rock, under))
    # strata lines
    d = ImageDraw.Draw(img)
    lines = Image.new('RGBA', (W, H), (110, 76, 66, 0))
    dl = ImageDraw.Draw(lines)
    for k in range(4):
        yy = top_y + (k + 1) * (H - top_y) * 0.14
        pts_l = [(x, yy + 4 * SS * math.sin(x / W * 9 + k)) for x in range(0, W, 4 * SS)]
        dl.line(pts_l, fill=(110, 70, 62, 90), width=3 * SS)
    lines = lines.filter(ImageFilter.GaussianBlur(1.2 * SS))
    img.alpha_composite(masked(lines, under))
    # glowing crystals in the rock
    for k in range(rng.integers(2, 4)):
        cx = W * rng.uniform(0.3, 0.7)
        cy = top_y + (H - top_y) * rng.uniform(0.2, 0.45)
        col = [hexc('#5CF2E6'), hexc('#C792FF')][k % 2]
        cr = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        dcr = ImageDraw.Draw(cr)
        for j in range(3):
            ang = -0.6 + j * 0.6
            L = (22 + 10 * (j % 2)) * SS
            dcr.polygon([(cx + math.sin(ang) * L * 1.6, cy - math.cos(ang) * L * 1.6),
                         (cx + 5 * SS, cy), (cx - 5 * SS, cy)], fill=col)
        img.alpha_composite(masked(glow(cr, 6 * SS, 1.6), under))
        img.alpha_composite(masked(cr, under))
    # hanging roots
    for k in range(rng.integers(4, 8)):
        x = W * rng.uniform(0.15, 0.85)
        t = (x / W - 0.06) / 0.88
        y0 = top_y + (H - top_y) * math.sin(math.pi * t) ** 1.3 * 0.7
        L = rng.uniform(16, 40) * SS
        d.line([(x, y0 - 6 * SS), (x + rng.uniform(-6, 6) * SS, y0 + L)], fill=(92, 140, 70, 255), width=3 * SS)
    # grass cap
    cap_pts = []
    for i in range(61):
        t = i / 60
        x = W * (0.02 + 0.96 * t)
        y = top_y - 10 * SS * math.sin(math.pi * t) - 3 * SS * math.sin(t * 40)
        cap_pts.append((x, y))
    lip = []
    for i in range(61):
        t = 1 - i / 60
        x = W * (0.02 + 0.96 * t)
        y = top_y + 18 * SS + 6 * SS * math.sin(t * 23 + seed)
        lip.append((x, y))
    cap = poly_mask((W, H), cap_pts + lip)
    grass = vertical_gradient(W, H, [(0, hexc('#9BF07A')), ((top_y - 10 * SS) / H, hexc('#7FE36A')),
                                     ((top_y + 20 * SS) / H, hexc('#3FB55A')), (1, hexc('#2E8F4A'))])
    img.alpha_composite(masked(grass, cap))
    # waterfall
    if waterfall:
        x = W * rng.uniform(0.25, 0.7)
        fall = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        df = ImageDraw.Draw(fall)
        df.rectangle((x - 9 * SS, top_y + 4 * SS, x + 9 * SS, H), fill=(150, 236, 255, 220))
        for k in range(6):
            xx = x - 8 * SS + k * 3 * SS
            df.line([(xx, top_y + 4 * SS), (xx, H)], fill=(235, 252, 255, 200), width=SS)
        fall = fall.filter(ImageFilter.GaussianBlur(1.2 * SS))
        fade = vertical_gradient(W, H, [(0, (255, 255, 255, 255)), (0.7, (255, 255, 255, 255)), (1, (255, 255, 255, 0))])
        fall = masked(fall, fade.getchannel('A'))
        img.alpha_composite(fall)
        ellipse(d, x, top_y + 6 * SS, 16 * SS, 6 * SS, (210, 248, 255, 255))
    # trees / ruins / castle on top
    deco = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    dd = ImageDraw.Draw(deco)
    if ruins:
        for k in range(3):
            x = W * (0.25 + 0.2 * k)
            hh = (40 + 25 * (k % 2)) * SS
            dd.rectangle((x - 9 * SS, top_y - hh, x + 9 * SS, top_y + 4 * SS), fill=hexc('#E8DCC8'))
            dd.rectangle((x - 13 * SS, top_y - hh - 6 * SS, x + 13 * SS, top_y - hh), fill=hexc('#D4C4AA'))
            dd.line([(x - 4 * SS, top_y - hh + 6 * SS), (x - 4 * SS, top_y)], fill=hexc('#C9B79C'), width=2 * SS)
        dd.rectangle((W * 0.25 - 13 * SS, top_y - 71 * SS, W * 0.45 + 13 * SS, top_y - 63 * SS), fill=hexc('#D4C4AA'))
    if castle:
        x = W * 0.5
        dd.rectangle((x - 40 * SS, top_y - 70 * SS, x + 40 * SS, top_y + 4 * SS), fill=hexc('#F1E6FF'))
        for tx in (-40, 40):
            dd.rectangle((x + tx * SS - 14 * SS, top_y - 110 * SS, x + tx * SS + 14 * SS, top_y + 4 * SS), fill=hexc('#E6D8FA'))
            dd.polygon([(x + tx * SS - 20 * SS, top_y - 110 * SS), (x + tx * SS + 20 * SS, top_y - 110 * SS),
                        (x + tx * SS, top_y - 150 * SS)], fill=hexc('#8E6BE0'))
        dd.polygon([(x - 28 * SS, top_y - 70 * SS), (x + 28 * SS, top_y - 70 * SS), (x, top_y - 120 * SS)], fill=hexc('#A27FF0'))
        dd.rounded_rectangle((x - 10 * SS, top_y - 30 * SS, x + 10 * SS, top_y + 4 * SS), radius=10 * SS, fill=hexc('#6B4FB0'))
    n_trees = rng.integers(2, 5)
    for k in range(n_trees):
        x = W * rng.uniform(0.1, 0.9)
        if castle and abs(x - W * 0.5) < 70 * SS:
            continue
        r = rng.uniform(18, 30) * SS
        dd.rectangle((x - 4 * SS, top_y - r * 0.8, x + 4 * SS, top_y + 2 * SS), fill=hexc('#7A5236'))
        ellipse(dd, x, top_y - r * 1.2, r, r, hexc('#2FA650'))
        ellipse(dd, x - r * 0.25, top_y - r * 1.45, r * 0.55, r * 0.5, hexc('#5CD06A'))
    img.alpha_composite(deco)
    return img


def make_mid_islands():
    w, h = 2048 * SS, 720 * SS
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    specs = [
        (120, 170, 300, 230, dict(waterfall=True)),
        (560, 90, 380, 300, dict(waterfall=True, castle=True)),
        (1060, 210, 260, 200, dict(waterfall=False, ruins=True)),
        (1450, 120, 340, 270, dict(waterfall=True)),
        (1840, 250, 220, 170, dict(waterfall=False)),
    ]
    for i, (x, y, iw, ih, kw) in enumerate(specs):
        isl = island_sprite(500 + i * 13, iw, ih, **kw)
        # atmospheric tint so islands sit behind the play field
        tint = Image.new('RGBA', isl.size, (190, 220, 255, 60))
        isl.alpha_composite(masked(tint, isl.getchannel('A')))
        paste_wrapped(img, isl, x * SS, y * SS)
    save(img, 'bg_mid.png', (2048, 720))


# ------------------------------------------------------------- near hills
def round_tree(d, x, base, r, rng, dark=hexc('#1F8A45'), mid=hexc('#34B455'), light=hexc('#73DB72')):
    d.rectangle((x - r * 0.14, base - r * 1.1, x + r * 0.14, base), fill=hexc('#6B4630'))
    ellipse(d, x, base - r * 1.5, r * 1.05, r * 0.95, dark)
    ellipse(d, x - r * 0.1, base - r * 1.6, r * 0.9, r * 0.82, mid)
    ellipse(d, x - r * 0.35, base - r * 1.85, r * 0.42, r * 0.34, light)


def pine_tree(d, x, base, r):
    d.rectangle((x - r * 0.1, base - r * 0.6, x + r * 0.1, base), fill=hexc('#6B4630'))
    for k in range(3):
        yb = base - r * 0.4 - k * r * 0.55
        wdt = r * (0.9 - k * 0.22)
        d.polygon([(x - wdt, yb), (x + wdt, yb), (x, yb - r * 0.95)], fill=[hexc('#1E7A4A'), hexc('#25905A'), hexc('#2FA866')][k])


def make_near_hills():
    w, h = 2048 * SS, 720 * SS
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    rng = np.random.default_rng(77)
    # back hill line
    pts = ridge_points(w, 560 * SS, 150 * SS, 6, 91, step=2 * SS)
    m = poly_mask((w, h), pts + [(w, h), (0, h)])
    tex = vertical_gradient(w, h, [(0, hexc('#8EE07A')), (0.62, hexc('#5CC466')), (1, hexc('#3C9C5A'))])
    img.alpha_composite(masked(tex, m))
    # forest of trees on the back hill
    trees = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dt = ImageDraw.Draw(trees)
    ys = {int(p[0]): p[1] for p in pts}
    xs = sorted(ys)
    for i in range(55):
        x = rng.uniform(0, w)
        xi = min(xs, key=lambda v: abs(v - x))
        base = ys[xi] + rng.uniform(8, 40) * SS
        r = rng.uniform(16, 30) * SS
        for o in wrap_offsets(w):
            if rng.random() < 0.35:
                pine_tree(dt, x + o, base, r * 1.4)
            else:
                round_tree(dt, x + o, base, r, rng)
    tint = Image.new('RGBA', (w, h), (170, 225, 220, 70))
    trees.alpha_composite(masked(tint, trees.getchannel('A')))
    img.alpha_composite(trees)
    # river with sparkles through a valley
    river = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(river)
    for k in range(0, w, 3 * SS):
        yy = 655 * SS + 10 * SS * math.sin(k / w * math.pi * 6)
        dr.line([(k, yy), (k + 3 * SS, yy)], fill=hexc('#7FE3F5'), width=16 * SS)
    for i in range(80):
        x = rng.uniform(0, w)
        yy = 655 * SS + 10 * SS * math.sin(x / w * math.pi * 6) + rng.uniform(-5, 5) * SS
        dr.line([(x, yy), (x + rng.uniform(6, 14) * SS, yy)], fill=(240, 255, 255, 230), width=2 * SS)
    img.alpha_composite(river)
    # front hill line
    pts2 = ridge_points(w, 690 * SS, 90 * SS, 5, 113, step=2 * SS)
    m2 = poly_mask((w, h), pts2 + [(w, h), (0, h)])
    tex2 = vertical_gradient(w, h, [(0, hexc('#7BDB6A')), (0.85, hexc('#4DB85A')), (1, hexc('#3AA052'))])
    noise = texture_layer(w, h, (0, 0, 0, 255), (255, 255, 255, 255), 30, 7, 4)
    tex2 = Image.blend(tex2, ImageChops.multiply(tex2, noise), 0.08)
    img.alpha_composite(masked(tex2, m2))
    # bushes + glowing crystals on the front hill
    deco = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dd = ImageDraw.Draw(deco)
    ys2 = {int(p[0]): p[1] for p in pts2}
    xs2 = sorted(ys2)
    for i in range(26):
        x = rng.uniform(0, w)
        xi = min(xs2, key=lambda v: abs(v - x))
        base = ys2[xi] + 6 * SS
        for o in wrap_offsets(w):
            if i % 5 == 0:
                col = [hexc('#5CF2E6'), hexc('#C792FF'), hexc('#FFD45C')][i % 3]
                for j in range(3):
                    a = -0.5 + j * 0.5
                    L = (22 - 6 * abs(j - 1)) * SS
                    dd.polygon([(x + o + math.sin(a) * L * 1.5, base - math.cos(a) * L * 1.5),
                                (x + o + 5 * SS + j * 2 * SS, base), (x + o - 5 * SS + j * 2 * SS, base)], fill=col)
            else:
                r = rng.uniform(12, 22) * SS
                ellipse(dd, x + o, base - r * 0.5, r * 1.3, r * 0.8, hexc('#2E9E4C'))
                ellipse(dd, x + o - r * 0.3, base - r * 0.8, r * 0.6, r * 0.4, hexc('#63CF68'))
    img.alpha_composite(glow(deco, 5 * SS, 0.6))
    img.alpha_composite(deco)
    save(img, 'bg_near.png', (2048, 720))


# ----------------------------------------------------------------- ground
def make_ground():
    """Seamless ground strip: grass lip on top, layered soil and stones below."""
    w, h = 512 * SS, 200 * SS
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    soil = texture_layer(w, h, hexc('#8A5A3C'), hexc('#C98B5A'), 8, 41)
    strata = vertical_gradient(w, h, [(0, (255, 210, 150, 0)), (0.35, (120, 70, 50, 0)), (1, (70, 40, 60, 160))])
    soil.alpha_composite(strata)
    ds = ImageDraw.Draw(soil)
    rng = np.random.default_rng(5)
    for i in range(46):
        x = rng.uniform(0, w)
        y = rng.uniform(46, 190) * SS
        r = rng.uniform(5, 13) * SS
        for o in wrap_offsets(w):
            ellipse(ds, x + o, y, r * 1.3, r, (150, 120, 105, 255))
            ellipse(ds, x + o - r * 0.3, y - r * 0.3, r * 0.6, r * 0.4, (196, 170, 150, 255))
    for k in range(3):
        yy = (80 + k * 40) * SS
        pts = [(x, yy + 5 * SS * math.sin(x / w * math.pi * 2 * (k + 2))) for x in range(0, w + 1, 4 * SS)]
        ds.line(pts, fill=(140, 92, 64, 255), width=6 * SS)
    img.alpha_composite(soil.filter(ImageFilter.GaussianBlur(0.6 * SS)))
    # grass lip, periodic in x
    top = []
    for x in range(0, w + 1, 2 * SS):
        t = x / w * math.pi * 2
        y = 30 * SS + 5 * SS * math.sin(t * 3) + 3 * SS * math.sin(t * 7 + 1)
        top.append((x, y))
    lip = poly_mask((w, h), [(0, 0), (w, 0)] + list(reversed(top)))
    grass = vertical_gradient(w, h, [(0, hexc('#A6F27E')), (0.08, hexc('#7FE068')), (0.2, hexc('#46B85A'))])
    img.alpha_composite(masked(grass, lip))
    dg = ImageDraw.Draw(img)
    for i in range(140):
        x = rng.uniform(0, w)
        bl = rng.uniform(6, 14) * SS
        for o in wrap_offsets(w):
            yb = 30 * SS + 5 * SS * math.sin((x / w) * math.pi * 6) + 3 * SS * math.sin((x / w) * math.pi * 14 + 1)
            dg.polygon([(x + o - 3 * SS, yb), (x + o + 3 * SS, yb), (x + o + rng.uniform(-4, 4) * SS, yb + bl)],
                       fill=(64, 168, 80, 255))
    hl = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    dh = ImageDraw.Draw(hl)
    dh.line([(0, 3 * SS), (w, 3 * SS)], fill=(220, 255, 190, 200), width=4 * SS)
    hl = hl.filter(ImageFilter.GaussianBlur(2 * SS))
    img.alpha_composite(hl)
    save(img, 'ground.png', (512, 200))


def make_foreground():
    w, h = 2048 * SS, 140 * SS
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = np.random.default_rng(303)
    for i in range(30):
        x = rng.uniform(0, w)
        for o in wrap_offsets(w):
            kind = i % 3
            if kind == 0:  # grass tuft
                for j in range(7):
                    a = -0.9 + j * 0.3
                    L = rng.uniform(40, 80) * SS
                    d.polygon([(x + o - 5 * SS + j * 3 * SS, h), (x + o + 5 * SS + j * 3 * SS, h),
                               (x + o + j * 3 * SS + math.sin(a) * L, h - math.cos(a) * L)],
                              fill=[hexc('#2F9B4B'), hexc('#3FB55A'), hexc('#5CCB63')][j % 3])
            elif kind == 1:  # flowers
                for j in range(3):
                    fx = x + o + j * 16 * SS
                    fy = h - rng.uniform(40, 70) * SS
                    d.line([(fx, h), (fx, fy)], fill=hexc('#2F9B4B'), width=3 * SS)
                    col = [hexc('#FF7AB6'), hexc('#FFD45C'), hexc('#B98BFF')][j]
                    for k in range(5):
                        a = k / 5 * math.pi * 2
                        ellipse(d, fx + math.cos(a) * 7 * SS, fy + math.sin(a) * 7 * SS, 6 * SS, 6 * SS, col)
                    ellipse(d, fx, fy, 5 * SS, 5 * SS, hexc('#FFF4C2'))
            else:  # mushroom
                mx = x + o
                d.rounded_rectangle((mx - 7 * SS, h - 40 * SS, mx + 7 * SS, h), radius=5 * SS, fill=hexc('#FFF1DA'))
                d.pieslice((mx - 26 * SS, h - 66 * SS, mx + 26 * SS, h - 22 * SS), 180, 360, fill=hexc('#FF5E5E'))
                for k in range(3):
                    ellipse(d, mx - 12 * SS + k * 12 * SS, h - 52 * SS + (k % 2) * 6 * SS, 4 * SS, 4 * SS, (255, 255, 255, 255))
    save(img, 'foreground.png', (2048, 140))


def make_lobby_island():
    isl = island_sprite(9001, 760, 420, waterfall=True)
    W, H = isl.size
    # remove tree clutter in the middle area: paint fresh grass where the dragon stands
    d = ImageDraw.Draw(isl)
    top_y = int(H * 0.32)
    rng = np.random.default_rng(4)
    for i in range(30):
        x = W * rng.uniform(0.08, 0.92)
        d.polygon([(x - 3 * SS, top_y + 2 * SS), (x + 3 * SS, top_y + 2 * SS), (x, top_y - 12 * SS)], fill=hexc('#7FE36A'))
    save(isl, 'lobby_island.png', (760, 420))


if __name__ == '__main__':
    make_sky()
    make_sun()
    make_clouds()
    make_far_mountains()
    make_mid_islands()
    make_near_hills()
    make_ground()
    make_foreground()
    make_lobby_island()
