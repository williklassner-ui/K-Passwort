#!/usr/bin/env python3
"""Pure-Python launcher icon generator for K-Passwort.

Draws an orange padlock on a dark gradient with a subtle accent glow
(matching the in-app lock screen) and writes:
  - legacy ic_launcher.png / ic_launcher_round.png for all densities
  - adaptive ic_launcher_foreground.png / ic_launcher_background.png
  - mipmap-anydpi-v26 adaptive XML
No third-party deps (manual PNG via zlib).
"""
import os, struct, zlib, math

RES = os.path.join(os.path.dirname(__file__), "res_out")

# ---- colors (0-255) ----
def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(len(a)))

BG_TOP = (26, 20, 13)      # warm near-black
BG_BOT = (0, 0, 0)
GLOW   = (255, 149, 0)     # orange accent
LOCK_TOP = (255, 176, 58)
LOCK_BOT = (255, 122, 0)
KEY    = (18, 13, 8)       # dark keyhole

def clamp(v, lo=0.0, hi=1.0):
    return lo if v < lo else hi if v > hi else v

def smoothstep(e0, e1, x):
    t = clamp((x - e0) / (e1 - e0)) if e1 != e0 else (0.0 if x < e0 else 1.0)
    return t * t * (3 - 2 * t)

# ---------- lock shape (normalized 0..1 over its own square) ----------
def _rrect(nx, ny, x0, y0, x1, y1, r):
    # signed distance to rounded rect (<=0 inside)
    cx = clamp(nx, x0 + r, x1 - r)
    cy = clamp(ny, y0 + r, y1 - r)
    dx, dy = nx - cx, ny - cy
    return math.hypot(dx, dy) - r if (nx < x0 + r or nx > x1 - r) and (ny < y0 + r or ny > y1 - r) else \
        max(x0 - nx, nx - x1, y0 - ny, ny - y1)

def lock_sample(nx, ny):
    """Return (r,g,b,a) for a point in the lock's unit square, or None for transparent."""
    # body
    in_body = (0.22 <= nx <= 0.78) and (0.46 <= ny <= 0.90)
    if in_body:
        # rounded corners
        rx = 0.09
        if nx < 0.22 + rx and ny < 0.46 + rx:
            in_body = math.hypot(nx-(0.22+rx), ny-(0.46+rx)) <= rx
        elif nx > 0.78 - rx and ny < 0.46 + rx:
            in_body = math.hypot(nx-(0.78-rx), ny-(0.46+rx)) <= rx
        elif nx < 0.22 + rx and ny > 0.90 - rx:
            in_body = math.hypot(nx-(0.22+rx), ny-(0.90-rx)) <= rx
        elif nx > 0.78 - rx and ny > 0.90 - rx:
            in_body = math.hypot(nx-(0.78-rx), ny-(0.90-rx)) <= rx
    # shackle ring (upper semicircle)
    d = math.hypot(nx - 0.5, ny - 0.40)
    in_ring = (0.125 <= d <= 0.20) and (ny <= 0.40)
    # legs connecting ring to body
    in_leg = (abs(abs(nx - 0.5) - 0.1625) <= 0.0375) and (0.40 <= ny <= 0.50)
    in_lock = in_body or in_ring or in_leg
    if not in_lock:
        return None
    # keyhole (only inside body)
    in_key = (math.hypot(nx - 0.5, ny - 0.60) <= 0.060) or \
             ((0.476 <= nx <= 0.524) and (0.60 <= ny <= 0.745))
    if in_key:
        return (KEY[0], KEY[1], KEY[2], 255)
    t = clamp((ny - 0.30) / 0.60)
    c = lerp(LOCK_TOP, LOCK_BOT, t)
    return (c[0], c[1], c[2], 255)

# ---------- compositing ----------
def over(dst, src):
    sa = src[3] / 255.0
    da = dst[3] / 255.0
    oa = sa + da * (1 - sa)
    if oa == 0:
        return (0, 0, 0, 0)
    out = tuple(int(round((src[i]*sa + dst[i]*da*(1-sa)) / oa)) for i in range(3))
    return (out[0], out[1], out[2], int(round(oa*255)))

SS = 3  # supersample grid per axis

def render(size, shape, draw_bg, draw_lock, lock_scale=0.72):
    px = bytearray()
    inv = 1.0 / size
    half = 0.5
    rad = 0.5  # for circle/roundsquare in normalized space
    for y in range(size):
        for x in range(size):
            ar = ag = ab = aa = 0.0
            for sy in range(SS):
                for sx in range(SS):
                    u = (x + (sx + 0.5) / SS) * inv
                    v = (y + (sy + 0.5) / SS) * inv
                    px_col = (0, 0, 0, 0)
                    # background
                    if draw_bg:
                        inside = True
                        if shape == "circle":
                            inside = math.hypot(u - half, v - half) <= rad
                        elif shape == "round":
                            rr = 0.20
                            inside = _inside_rrect(u, v, rr)
                        if inside:
                            base = lerp(BG_TOP, BG_BOT, v)
                            col = (base[0], base[1], base[2], 255)
                            gd = math.hypot(u - 0.5, v - 0.42)
                            g = clamp(1 - gd / 0.55)
                            g = g * g * 0.45
                            col = over(col, (GLOW[0], GLOW[1], GLOW[2], int(g*255)))
                            px_col = col
                    # lock
                    if draw_lock:
                        m = (1 - lock_scale) / 2
                        lx = (u - m) / lock_scale
                        ly = (v - m) / lock_scale
                        if 0 <= lx <= 1 and 0 <= ly <= 1:
                            ls = lock_sample(lx, ly)
                            if ls:
                                px_col = over(px_col, ls)
                    a = px_col[3] / 255.0
                    ar += px_col[0]*a; ag += px_col[1]*a; ab += px_col[2]*a; aa += a
            n = SS*SS
            if aa > 0:
                r = int(round(ar/aa)); g = int(round(ag/aa)); b = int(round(ab/aa))
            else:
                r = g = b = 0
            px += bytes((r, g, b, int(round(aa/n*255))))
    return _png(size, size, px)

def _inside_rrect(u, v, rr):
    x0, y0, x1, y1 = 0.0, 0.0, 1.0, 1.0
    cx = clamp(u, x0+rr, x1-rr); cy = clamp(v, y0+rr, y1-rr)
    if (u < x0+rr or u > x1-rr) and (v < y0+rr or v > y1-rr):
        return math.hypot(u-cx, v-cy) <= rr
    return True

def _png(w, h, rgba):
    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        return c + struct.pack(">I", zlib.crc32(typ + data) & 0xffffffff)
    raw = bytearray()
    stride = w * 4
    for y in range(h):
        raw.append(0)
        raw += rgba[y*stride:(y+1)*stride]
    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")

# legacy launcher sizes
LEGACY = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
# adaptive layer sizes (108dp)
ADAPT = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}

def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)
    print("wrote", path, len(data), "bytes")

for dens, s in LEGACY.items():
    d = os.path.join(RES, f"mipmap-{dens}")
    write(os.path.join(d, "ic_launcher.png"), render(s, "round", True, True, 0.72))
    write(os.path.join(d, "ic_launcher_round.png"), render(s, "circle", True, True, 0.72))

for dens, s in ADAPT.items():
    d = os.path.join(RES, f"mipmap-{dens}")
    # foreground: lock only, smaller (safe zone), transparent bg
    write(os.path.join(d, "ic_launcher_foreground.png"), render(s, "square", False, True, 0.50))
    # background: full-bleed gradient + glow
    write(os.path.join(d, "ic_launcher_background.png"), render(s, "square", True, False))

# adaptive XML
xml = ('<?xml version="1.0" encoding="utf-8"?>\n'
       '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
       '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
       '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
       '</adaptive-icon>\n')
anydpi = os.path.join(RES, "mipmap-anydpi-v26")
write(os.path.join(anydpi, "ic_launcher.xml"), xml.encode())
write(os.path.join(anydpi, "ic_launcher_round.xml"), xml.encode())
print("done")
