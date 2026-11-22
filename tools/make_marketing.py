#!/usr/bin/env python3
"""Marketing pictures for MakerWorld / the README: renders the real models and lays them out with titles.

    python3 tools/make_marketing.py            # all pictures
    python3 tools/make_marketing.py cover      # one (names: see PAGES at the bottom)

Writes 1600 x 1200 PNGs (4:3, MakerWorld's cover ratio) into marketing/images/. Every model is rendered by
OpenSCAD's preview under xvfb at twice the size, its background keyed out, shrunk (anti-aliased) and tinted in a
filament colour, so the pictures always show the current models. Needs openscad, xvfb-run, Pillow and numpy.
The configurator screenshot (page "configurator") also needs Playwright and serves the project folder locally.
"""
import subprocess, sys, tempfile, math, time, os
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "marketing" / "images"
FONT = ROOT / "lib" / "fonts"
W, H = 1600, 1200
BG_TOP, BG_BOT = (24, 32, 42), (44, 58, 72)
ACCENT = (242, 165, 65)
INK, MUTED = (240, 238, 232), (170, 182, 194)
SITE = "tamaygz.github.io/tg_3d_modelling"
FIL = {   # filament-like tints
    "orange": (243, 146, 52), "teal": (38, 176, 160), "white": (226, 222, 212), "red": (214, 72, 72),
    "blue": (66, 128, 214), "green": (104, 186, 88), "yellow": (240, 196, 70), "purple": (146, 108, 214),
    "grey": (150, 160, 170), "wood": (176, 128, 80), "black": (70, 76, 84)}


def font(size, kind="bold"):
    name = {"bold": "Lato-Bold.ttf", "serif": "BookSerif-Bold.ttf", "regular": "LiberationSans-Regular.ttf",
            "sans": "LiberationSans-Bold.ttf"}[kind]
    return ImageFont.truetype(str(FONT / name), size)


# ---------- rendering ----------
def render(scad, defs=(), cam=(58, 28), px=1400, extra=""):
    """Render scad (a path, or source text when `extra` wraps it) and return an RGBA image without background."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        src = Path(scad)
        if extra:                       # a wrapper file that includes the model and adds geometry
            w = tmp / "wrap.scad"
            w.write_text(f"include <{src.resolve()}>\n{extra}\n")
            src = w
        img = tmp / "r.png"
        cmd = ["xvfb-run", "-a", "openscad", "-o", str(img), f"--imgsize={2*px},{2*px}", "--viewall", "--autocenter",
               f"--camera=0,0,0,{cam[0]},0,{cam[1]},0", "--colorscheme=DeepOcean"]
        for d in defs:
            cmd += ["-D", d]
        r = subprocess.run(cmd + [str(src)], cwd=src.parent, capture_output=True, text=True)
        if not img.exists():
            raise RuntimeError(f"render failed: {scad} {defs}: {r.stderr[-400:]}")
        a = np.asarray(Image.open(img).convert("RGB")).astype(np.int16)
    bg = a[2, 2]
    key = np.abs(a - bg).sum(axis=2) > 10
    rgba = np.dstack([a.astype(np.uint8), (key * 255).astype(np.uint8)])
    im = Image.fromarray(rgba, "RGBA")
    im = im.crop(im.getbbox())
    im = im.convert("RGBa").resize((max(1, im.width // 2), max(1, im.height // 2)), Image.LANCZOS).convert("RGBA")
    return im


def tint(im, colour, contrast=1.0):
    """Shade an RGBA render in one colour, keeping its light and shadow."""
    a = np.asarray(im).astype(np.float32)
    lum = (0.3*a[..., 0] + 0.59*a[..., 1] + 0.11*a[..., 2]) / 255.0
    m = a[..., 3] > 0
    if m.any():
        lo, hi = np.percentile(lum[m], 2), np.percentile(lum[m], 98)
        lum = np.clip((lum - lo) / max(1e-3, hi - lo), 0, 1) ** contrast
    c = np.array(colour, np.float32)
    dark, light = c*0.28, c*0.72 + 255*0.28
    rgb = dark + (light - dark)*lum[..., None]
    return Image.fromarray(np.dstack([np.clip(rgb, 0, 255), a[..., 3]]).astype(np.uint8), "RGBA")


# ---------- layout ----------
def canvas():
    y = np.linspace(0, 1, H)[:, None]
    base = np.array(BG_TOP)*(1 - y[..., None]) + np.array(BG_BOT)*y[..., None]
    img = np.repeat(base, W, axis=1)
    xx, yy = np.meshgrid(np.linspace(-1, 1, W), np.linspace(-1, 1, H))
    glow = np.exp(-((xx*0.9)**2 + (yy*1.2 - 0.15)**2)*1.6)[..., None]*18        # soft light in the middle
    return Image.fromarray(np.clip(img + glow, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def shadow(im, r=18, alpha=110):
    s = Image.new("RGBA", (im.width + 4*r, im.height + 4*r), (0, 0, 0, 0))
    mask = im.split()[3].point(lambda v: alpha if v > 0 else 0)
    s.paste((0, 0, 0, 255), (2*r, 2*r), mask)
    return s.filter(ImageFilter.GaussianBlur(r)), 2*r


def place(cv, im, box, drop=True):
    """Fit im into box = (x0, y0, x1, y1), centred, with a soft shadow below."""
    x0, y0, x1, y1 = box
    k = min((x1 - x0)/im.width, (y1 - y0)/im.height)
    im = im.resize((max(1, int(im.width*k)), max(1, int(im.height*k))), Image.LANCZOS)
    x = int(x0 + (x1 - x0 - im.width)/2); y = int(y0 + (y1 - y0 - im.height)/2)
    if drop:
        s, o = shadow(im)
        cv.alpha_composite(s, (x - o + 6, y - o + 14))
    cv.alpha_composite(im, (x, y))
    return (x, y, x + im.width, y + im.height)


def text(d, xy, s, size, kind="bold", fill=INK, anchor="la"):
    d.text(xy, s, font=font(size, kind), fill=fill, anchor=anchor)


def header(cv, title, sub, kicker=None):
    d = ImageDraw.Draw(cv)
    y = 54
    if kicker:
        text(d, (70, y), kicker.upper(), 26, "sans", ACCENT); y += 40
    text(d, (70, y), title, 64, "serif"); y += 84
    if sub:
        text(d, (72, y), sub, 30, "regular", MUTED)
    return d


def footer(cv, s=None):
    d = ImageDraw.Draw(cv)
    d.rectangle((0, H - 64, W, H), fill=(14, 19, 26, 255))
    text(d, (70, H - 32), s or "Free for personal use (CC BY-NC-SA) · OpenSCAD · customize in your browser", 24, "regular", MUTED, "lm")
    text(d, (W - 70, H - 32), SITE, 24, "sans", ACCENT, "rm")


def pill(d, cx, y, s, size=24, fill=(255, 255, 255, 28), ink=INK, kind="sans"):
    f = font(size, kind)
    w = d.textlength(s, font=f)
    d.rounded_rectangle((cx - w/2 - 16, y, cx + w/2 + 16, y + size + 16), radius=(size + 16)//2, fill=fill)
    d.text((cx, y + (size + 16)/2), s, font=f, fill=ink, anchor="mm")


def badge(d, x, y, n):
    d.ellipse((x, y, x + 46, y + 46), fill=ACCENT)
    d.text((x + 23, y + 23), str(n), font=font(26), fill=(24, 32, 42), anchor="mm")


def grid(n_cols, n_rows, top=230, bottom=H - 90, left=50, right=W - 50, label_h=60):
    cw = (right - left)/n_cols; ch = (bottom - top)/n_rows
    return [(left + c*cw, top + r*ch, left + (c + 1)*cw, top + (r + 1)*ch - label_h) for r in range(n_rows) for c in range(n_cols)]


BOX = ROOT / "projects" / "custombox" / "custombox.scad"
ATT = ROOT / "projects" / "attachments" / "attachments.scad"
GAL = ROOT / "projects" / "pattern_gallery" / "pattern_gallery.scad"


def box(defs, cam=(58, 28)):
    return render(BOX, ['part="box"'] + list(defs), cam)


# ---------- pages ----------
def page_cover():
    cv = canvas()
    looks = [  # (settings, colour)
        (['compart_layout="33,33,33 / 50,50 / 100"', 'height=50'], "orange"),
        (['shape="ellipse"', 'side_wave=2.5', 'side_wave_count=10', 'wall_pattern="voronoi"', 'rim_wave_x_amp=6', 'rim_wave_y_amp=6',
          'rim_wave_x_count=2', 'rim_wave_y_count=2'], "white"),
        (['corners="square"', 'corner_fill="solid"', 'wall_pattern="girih_star_cross"', 'wall_cell=26', 'lid="inset"', 'lid_grip="knob"',
          'part="all"'], "blue"),
        (['corner_fill="solid"', 'wall_pattern="basket_weave"', 'wall_mode="open_lattice"', 'corner_r=10'], "red"),
        (['compart_rows=2', 'compart_cols=3', 'rise_back=20', 'rim_wave_x_amp=5', 'rim_wave_x_count=1.5', 'divider_notch=14',
          'notch_front=14', 'wall_pattern="triangular_lattice"', 'width=160', 'depth=100'], "teal"),
        (['shape="squircle"', 'squareness=3', 'wall_pattern="cube_rosette"', 'rise_back=20', 'width=110', 'depth=80'], "green")]
    d = ImageDraw.Draw(cv)
    text(d, (W/2, 70), "ONE BOX TO RULE THEM ALL", 30, "sans", ACCENT, "ma")
    text(d, (W/2, 112), "The Box Generator", 92, "serif", INK, "ma")
    text(d, (W/2, 228), "Any size · 15 patterns · compartments · waves & notches · snap-in mounts", 32, "regular", MUTED, "ma")
    cells = grid(3, 2, top=290, bottom=H - 160, label_h=0)
    for (defs, col), c in zip(looks, cells):
        place(cv, tint(box(defs), FIL[col]), (c[0] + 24, c[1] + 12, c[2] - 24, c[3] - 12))
    d = ImageDraw.Draw(cv)
    pill(d, W/2, H - 148, "Customize it free in your browser  →  no install, no account", 28, fill=(*ACCENT, 255), ink=(24, 32, 42))
    footer(cv)
    return cv


def page_evolution():
    cv = canvas()
    header(cv, "From plain box to organizer", "Every step is a setting, not a new model", "One model, every container")
    steps = [
        (['corners="square"', 'corner_fill="solid"', 'wall_mode="solid"', 'back_mode="solid"', 'front_mode="solid"'], "1  Plain box", "size, corners, wall thickness", "white"),
        (['wall_pattern="hex_honeycomb"'], "2  Pattern", "15 patterns × 6 ways to apply them", "orange"),
        (['rise_back=25', 'rim_wave_x_amp=6', 'rim_wave_x_count=1.5'], "3  Slopes & waves", "raise any wall, wavy rim", "yellow"),
        (['rise_back=25', 'notch_front=16', 'notch_front_w=50', 'wall_pattern="triangular_lattice"'], "4  Notches", "grip or pour lip in any wall", "teal"),
        (['rise_back=25', 'notch_front=16', 'notch_front_w=50', 'wall_pattern="triangular_lattice"', 'compart_layout="33,33,33 / 50,50 / 100"',
          'divider_notch=10'], "5  Compartments", "grid or % layout per row", "blue"),
        (['attach_type="skadis"', 'attach_size="M"', 'height=80', 'wall_pattern="triangular_lattice"', 'part="all"', 'compart_rows=2'],
         "6  Mount it", "Skådis, wall, clamp, magnet…", "purple")]
    cells = grid(3, 2, top=250, label_h=90)
    d = ImageDraw.Draw(cv)
    for i, ((defs, title, sub, col), c) in enumerate(zip(steps, cells)):
        cam = (62, 150) if i == 5 else (58, 28)
        im = render(BOX, ['part="box"'] + defs, cam) if i < 5 else render(BOX, defs, cam)
        r = place(cv, tint(im, FIL[col]), (c[0] + 30, c[1] + 10, c[2] - 30, c[3] - 10))
        d = ImageDraw.Draw(cv)
        cx = (c[0] + c[2])/2
        text(d, (cx, c[3] + 10), title, 32, "bold", INK, "ma")
        text(d, (cx, c[3] + 50), sub, 24, "regular", MUTED, "ma")
        if i % 3 < 2:
            ax = c[2] - 6; ay = (c[1] + c[3])/2
            d.polygon([(ax - 14, ay - 16), (ax + 8, ay), (ax - 14, ay + 16)], fill=ACCENT)
    footer(cv)
    return cv


PATTERNS = ["hex_honeycomb", "square_grid", "diamond_lattice", "triangular_lattice", "cube_rosette", "basket_weave", "tri_weave",
            "voronoi", "fish_scales", "truchet_arcs", "girih_star_cross", "asanoha", "flowing_waves", "concentric_ripples", "fluted"]
NICE = {"hex_honeycomb": "Honeycomb", "square_grid": "Square grid", "diamond_lattice": "Diamond", "triangular_lattice": "Triangles",
        "cube_rosette": "Cube rosette", "basket_weave": "Basket weave", "tri_weave": "Kagome weave", "voronoi": "Voronoi",
        "fish_scales": "Fish scales", "truchet_arcs": "Truchet arcs", "girih_star_cross": "Girih stars", "asanoha": "Asanoha",
        "flowing_waves": "Waves", "concentric_ripples": "Ripples", "fluted": "Fluted / reeded"}


def page_patterns():
    cv = canvas()
    header(cv, "15 patterns, 6 ways to apply them", "cut through · open lattice · raised · recessed · overlay · solid — on walls, floors, lids",
           "Pattern library")
    cells = grid(5, 3, top=250, label_h=52)
    cols = ["orange", "teal", "white", "blue", "red", "yellow", "green", "purple", "orange", "teal", "white", "blue", "red", "yellow", "green"]
    for p, c, col in zip(PATTERNS, cells, cols):
        mode = {"truchet_arcs": "raised", "fluted": "raised", "flowing_waves": "through_cut", "basket_weave": "open_lattice",
                "tri_weave": "open_lattice"}.get(p, "through_cut")
        more = {"concentric_ripples": ["ripple_spokes=6"], "fluted": ["flute_style=\"fluted\"", "cell=8"],
                "flowing_waves": ["wave_amplitude=5"]}.get(p, [])
        im = render(GAL, ['view="sample"', f'pattern="{p}"', f'mode="{mode}"', 'sample_w=70', 'sample_h=70', 'sample_shape="rounded"'] + more,
                    (40, 8))
        place(cv, tint(im, FIL[col], 0.9), (c[0] + 18, c[1] + 6, c[2] - 18, c[3] - 6))
        d = ImageDraw.Draw(cv)
        text(d, ((c[0] + c[2])/2, c[3] + 8), NICE[p], 26, "bold", INK, "ma")
    footer(cv)
    return cv


def page_compartments():
    cv = canvas()
    header(cv, "Compartments, your way", "A grid, or type the sizes in % per row — dividers follow the rim and match the walls", "Organizers")
    looks = [(['compart_rows=2', 'compart_cols=3'], 'compart_rows = 2, compart_cols = 3', "teal"),
             (['compart_layout="33,33,33 / 50,50 / 100"'], '"33,33,33 / 50,50 / 100"', "orange"),
             (['compart_layout="50,50 / 25,25,25,25 / 100"', 'compart_order="columns"', 'width=150', 'divider_notch=12'],
              'columns: "50,50 / 25,25,25,25 / 100"', "blue"),
             (['shape="ellipse"', 'compart_layout="30,70 / 100"', 'compart_sizes="40,60"', 'divider_pattern="solid"', 'divider_drop=12',
               'wall_pattern="voronoi"'], '"30,70 / 100", sizes "40,60"', "white")]
    cells = grid(2, 2, top=250, label_h=70)
    for (defs, code, col), c in zip(looks, cells):
        place(cv, tint(box(['height=50'] + defs, (52, 25)), FIL[col]), (c[0] + 40, c[1] + 10, c[2] - 40, c[3] - 6))
        d = ImageDraw.Draw(cv)
        pill(d, (c[0] + c[2])/2, c[3] + 12, code, 24, fill=(0, 0, 0, 90), ink=ACCENT, kind="regular")
    footer(cv)
    return cv


ATT_TYPES = [("wall", "Wall", "2 countersunk screws"), ("keyhole", "Keyhole", "hang on one screw"),
             ("skadis", "Skådis", "IKEA pegboard"), ("hook", "Hook", "over a rail or door"),
             ("magnet", "Magnet", "8 × 2 mm magnets"), ("stand", "Stand", "lean on a desk"),
             ("flat", "Flat", "glue or tape"), ("roof", "Ceiling", "hang from above"),
             ("slide", "Slide track", "slide along a rail"), ("fin", "Fin", "push between cushions"),
             ("clamp", "Clamp", "desk edge, printed screw"), ("pipe", "Pipe claw", "snaps onto tubes")]


def page_attachments():
    cv = canvas()
    header(cv, "One socket. Twelve ways to mount.", "Every host has the same snap-in socket: swap the plate any time, no screws in the model",
           "Attachment system")
    cells = grid(4, 3, top=250, label_h=78)
    cols = ["grey", "grey", "white", "orange", "red", "teal", "yellow", "blue", "purple", "green", "black", "orange"]
    extra = 'plate(); attach_all("all", attach_type, attach_size, [0], 0, a_opts, joint=attach_joint, skip_plates=true);'
    for (t, name, sub), c, col in zip(ATT_TYPES, cells, cols):
        cam = (125, 35) if t in ("magnet", "keyhole", "flat") else (60, 35)       # their features face the wall: show that side
        im = render(ATT, [f'attach_type="{t}"', 'part="none"', 'attach_size="M"'], cam, extra=extra)
        place(cv, tint(im, FIL[col]), (c[0] + 30, c[1] + 6, c[2] - 30, c[3] - 4))
        d = ImageDraw.Draw(cv)
        cx = (c[0] + c[2])/2
        text(d, (cx, c[3] + 6), name, 28, "bold", INK, "ma")
        text(d, (cx, c[3] + 42), sub, 22, "regular", MUTED, "ma")
    footer(cv)
    return cv


def page_family():
    cv = canvas()
    header(cv, "Built on one shared library", "Holders, plaques, organizers and lights reuse the same patterns, walls and mounts",
           "More from the repo")
    P = ROOT / "projects"
    items = [(P/"earbuds"/"earbuds.scad", ['part="holder"', 'rise_back=10'], (62, 28), "Earbud case holder", "presets incl. Soundcore P31i", "white"),
             (P/"sunglasses"/"sunglasses.scad", ['part="holder"'], (62, 28), "Sunglasses tray", "with nose support", "teal"),
             (P/"scoreboard"/"scoreboard.scad", [], (40, 10), "Sliding scoreboard", "wall-mounted, styles & presets", "wood"),
             (P/"snooker_guide"/"snooker_guide.scad", [], (35, 5), "Snooker guide plaque", "multi-colour relief", "green"),
             (P/"led_kit"/"led_kit.scad", [], (55, 30), "LED strip kit", "tracks, diffusers, cable clips", "grey"),
             (P/"pattern_gallery"/"pattern_gallery.scad", ['view="box"'], (58, 28), "Pattern gallery", "test bench for every pattern", "orange")]
    cells = grid(3, 2, top=250, label_h=90)
    for (scad, defs, cam, title, sub, col), c in zip(items, cells):
        im = render(scad, defs, cam)
        if col in ("wood", "green"):
            im = im                                           # multi-colour models keep their own colours
        else:
            im = tint(im, FIL[col])
        place(cv, im, (c[0] + 30, c[1] + 10, c[2] - 30, c[3] - 10))
        d = ImageDraw.Draw(cv)
        cx = (c[0] + c[2])/2
        text(d, (cx, c[3] + 10), title, 30, "bold", INK, "ma")
        text(d, (cx, c[3] + 50), sub, 23, "regular", MUTED, "ma")
    footer(cv)
    return cv


def page_configurator():
    """Screenshot of the browser configurator with a compartment layout, framed."""
    import http.server, threading, functools
    folder = ROOT / "projects" / "custombox"
    class Quiet(http.server.SimpleHTTPRequestHandler):
        def log_message(self, *a):
            pass
    handler = functools.partial(Quiet, directory=str(folder))
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    shot = OUT / "_configurator_raw.png"
    js = f"""
const {{ chromium }} = require('playwright');
(async () => {{
  const b = await chromium.launch({{ args: ['--use-gl=swiftshader', '--enable-webgl', '--ignore-gpu-blocklist'] }});
  const p = await b.newPage({{ viewport: {{ width: 1440, height: 900 }}, deviceScaleFactor: 2 }});
  await p.goto('http://127.0.0.1:{srv.server_address[1]}/custombox_configurator.html');
  await p.waitForTimeout(2500);
  const sets = {{ compart_layout: '33,33,33 / 50,50 / 100', rise_back: '20', divider_notch: '10', notch_front: '12' }};
  for (const [k, v] of Object.entries(sets)) await p.fill('#p_' + k, v);
  await p.click('#gen');
  await p.waitForFunction(() => /Done|failed/.test(document.querySelector('#status').textContent), null, {{ timeout: 600000 }});
  await p.waitForTimeout(1200);
  await p.$eval('#p_compart_layout', e => e.scrollIntoView({{ block: 'center' }}));
  await p.waitForTimeout(300);
  await p.screenshot({{ path: '{shot}' }});
  await b.close();
}})();
"""
    with tempfile.NamedTemporaryFile("w", suffix=".js", delete=False) as f:
        f.write(js); jsf = f.name
    try:
        subprocess.run(["node", jsf], check=True, timeout=900)
    finally:
        srv.shutdown(); os.unlink(jsf)
    cv = canvas()
    header(cv, "Customize in your browser", "The real OpenSCAD runs on the page: change a setting, press Generate, download the STL",
           "No install · no account")
    sc = Image.open(shot).convert("RGBA")
    shot.unlink()
    box_ = (110, 260, W - 110, H - 110)
    k = min((box_[2] - box_[0])/sc.width, (box_[3] - box_[1])/sc.height)
    sc = sc.resize((int(sc.width*k), int(sc.height*k)), Image.LANCZOS)
    x = int((W - sc.width)/2); y = box_[1]
    frame = Image.new("RGBA", (sc.width + 16, sc.height + 16), (255, 255, 255, 0))
    ImageDraw.Draw(frame).rounded_rectangle((0, 0, frame.width - 1, frame.height - 1), 14, fill=(10, 14, 20, 255))
    s, o = shadow(frame, 24, 140)
    cv.alpha_composite(s, (x - 8 - o + 8, y - 8 - o + 18))
    cv.alpha_composite(frame, (x - 8, y - 8))
    m = Image.new("L", sc.size, 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, sc.width - 1, sc.height - 1), 8, fill=255)
    cv.paste(sc, (x, y), m)
    footer(cv)
    return cv


PAGES = {"cover": page_cover, "evolution": page_evolution, "patterns": page_patterns, "compartments": page_compartments,
         "attachments": page_attachments, "family": page_family, "configurator": page_configurator}
ORDER = ["cover", "evolution", "compartments", "patterns", "attachments", "configurator", "family"]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    names = sys.argv[1:] or ORDER
    for n in names:
        t = time.time()
        img = PAGES[n]().convert("RGB")
        path = OUT / f"{ORDER.index(n) + 1:02d}_{n}.png"
        img.save(path, optimize=True)
        print(f"{path.relative_to(ROOT)}  ({path.stat().st_size // 1024} kB, {time.time() - t:.0f} s)")


if __name__ == "__main__":
    main()
