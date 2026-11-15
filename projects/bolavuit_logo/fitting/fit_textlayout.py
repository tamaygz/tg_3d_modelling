"""Fit lib/emblem.scad's arc_text_2d() layout parameters to the original "BOLA VUIT" lettering by maximising overlap
(IoU) with the exact letters; each evaluation renders the module in OpenSCAD. Writes textlayout_fit.json.
Run from results/:  python3 ../fit_textlayout.py"""
import _env, json, subprocess, sys
import numpy as np
from scipy.optimize import minimize
from artfit import mask, mask_evenodd, polys, iou
from bvdata import REG
LETTERS = [24, 21, 23, 22, 28, 26]
BOX = (380, 300, 1460, 600)
TARGET = mask([REG[i][0] for i in LETTERS], BOX, 1.0, holes=[c for i in LETTERS for c in REG[i][1:]])
SCAD = str(_env.REPO / "lib" / "emblem.scad").replace("emblem.scad", "")
NAMES = ["cx", "cy", "r", "size", "width", "tracking", "lean0", "lean1", "at"]
START = [928.5, -1638.0, 2051.0, 144.8, 0.92, 0.0, 3.5, 0.5, 90.4]
STEP = [4.0, 30.0, 60.0, 3.0, 0.03, 0.015, 1.5, 1.0, 0.3]
n = [0]
def render(v):
    cx, cy, r, size, width, tracking, l0, l1, at = v
    src = (f'use <{SCAD}emblem.scad>\nuse <{SCAD}fonts.scad>\ntranslate([{cx}, {cy}]) arc_text_2d("BOLA VUIT", r={r}, size={size}, '
           f'font=font_for("book serif bold"), at={at}, tracking={tracking}, width={width}, fan=0, lean=[{l0}, {l1}]);\n')
    f = _env.Path(_env.TMP) / "tl.scad"; f.write_text(src)
    subprocess.run(["openscad", "-o", str(f.with_suffix(".svg")), str(f)], capture_output=True)
    return mask_evenodd(polys(str(f.with_suffix(".svg"))), BOX, 1.0)
def loss(v):
    n[0] += 1
    s = iou(render(v), TARGET)
    if n[0] % 25 == 0: print(n[0], round(s, 4), [round(x, 3) for x in v], flush=True)
    return -s
print("start IoU %.3f" % -loss(START), flush=True)
sim = np.vstack([START] + [np.array(START) + np.eye(len(START))[i]*STEP[i] for i in range(len(START))])
best = minimize(loss, START, method="Nelder-Mead", options=dict(maxiter=600, xatol=0.01, fatol=1e-5, adaptive=True, initial_simplex=sim))
print("text layout IoU %.4f" % -best.fun); print(dict(zip(NAMES, [round(x, 4) for x in best.x])))
json.dump(dict(zip(NAMES, best.x)), open("textlayout_fit.json", "w"))
