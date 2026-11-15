#!/usr/bin/env python3
"""Compare OpenSCAD 2D output with reference artwork, and helpers for fitting shapes to artwork.

    python3 tools/artfit.py overlay exported.svg reference.png out.png [--threshold 128]

`overlay` rasterises an SVG exported by OpenSCAD (`openscad -o exported.svg model.scad`, drawn in the reference's
pixel frame, y up) at the reference image's size, prints the overlap (IoU) and writes a comparison picture:
white = both, red = model only, grey = reference only. Use it to verify a logo rebuild.

As a module (`import artfit`):
    mask(polys, box, s, holes)      rasterise polygons (y up) inside box = (x0, y0, x1, y1) at scale s
    mask_evenodd(polys, box, s)     the same with even-odd fill (for OpenSCAD SVG exports)
    polys(svgfile)                  polygons of an OpenSCAD SVG export, y up
    iou(a, b)                       overlap of two masks: intersection / union
Fit a shape by maximising iou(model_mask(params), target_mask) with scipy.optimize.minimize (Nelder-Mead; give
explicit initial steps for parameters that start at 0). Example: projects/bolavuit_logo/fitting/.
"""
import re, sys
import numpy as np
from PIL import Image, ImageDraw


def mask(polys, box, s=1.0, holes=()):
    x0, y0, x1, y1 = box; W = int((x1 - x0)*s) + 1; H = int((y1 - y0)*s) + 1
    im = Image.new('L', (W, H), 0); d = ImageDraw.Draw(im)
    for p in polys:
        if len(p) >= 3: d.polygon([((x - x0)*s, (y1 - y)*s) for x, y in p], fill=255)
    for p in holes:
        if len(p) >= 3: d.polygon([((x - x0)*s, (y1 - y)*s) for x, y in p], fill=0)
    return np.array(im) > 127


def mask_evenodd(P, box, S=1.0):
    x0, y0, x1, y1 = box; W = int((x1 - x0)*S) + 1; H = int((y1 - y0)*S) + 1; acc = np.zeros((H, W), bool)
    for p in P:
        im = Image.new('L', (W, H), 0); ImageDraw.Draw(im).polygon([((x - x0)*S, (y1 - y)*S) for x, y in p], fill=255)
        acc ^= np.array(im) > 127
    return acc


def polys(svgfile):
    s = open(svgfile).read(); out = []
    for d in re.findall(r'd="([^"]+)"', s):
        for sub in re.split(r'(?=M)', d):
            pts = [(float(a), -float(b)) for a, b in re.findall(r'(-?[\d.e+-]+),(-?[\d.e+-]+)', sub)]   # OpenSCAD svg: y negated
            if len(pts) >= 3: out.append(pts)
    return out


def iou(a, b):
    return (a & b).sum() / max(1, (a | b).sum())


def overlay(svg, ref_png, out_png, threshold=128):
    O = np.array(Image.open(ref_png).convert('L')) > threshold
    H, W = O.shape
    M = mask_evenodd(polys(svg), (0, 0, W, H), 1.0)[:H, :W]
    im = np.zeros(O.shape + (3,), np.uint8)
    im[O & ~M] = (150, 150, 150); im[M & ~O] = (230, 40, 40); im[M & O] = (255, 235, 235)
    Image.fromarray(im).save(out_png)
    score = iou(M, O)
    print(f"overlap (IoU) with {ref_png}: {score:.3f}")
    return score


if __name__ == "__main__":
    a = sys.argv[1:]
    if len(a) < 4 or a[0] != "overlay":
        sys.exit(__doc__)
    overlay(a[1], a[2], a[3], int(a[a.index("--threshold") + 1]) if "--threshold" in a else 128)
