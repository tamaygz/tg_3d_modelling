"""Fit a text-on-arc model (circle, size, x scale, lean) to the eight fitted letters of the Bola Vuit lettering,
so lib/emblem.scad's arc_text_2d() can set ANY text on the same curve. Writes textarc_fit.json.
Run from results/:  python3 ../fit_textarc.py"""
import _env, json, math, subprocess, re
import numpy as np
from scipy.optimize import least_squares
FONT = "Book Serif:style=Bold"
EM, CAP = 1.35634, 0.9125                      # lib/fonts_metrics.scad (OpenSCAD units per size)
ADV = {}                                       # advances in em (read back from the generated metrics)
txt = (_env.REPO / "lib" / "fonts_metrics.scad").read_text()
m = re.search(r'\["Book Serif:style=Bold", [\d.]+, [\d.]+, "((?:[^"\\]|\\.)*)", \[([^\]]*)\]\]', txt)
chars = m.group(1).replace('\\"', '"').replace('\\\\', '\\'); advs = [float(v) for v in m.group(2).split(",")]
adv = lambda c: advs[chars.index(c)]
L = json.load(open("letters_ss4_split.json"))                  # letter -> [[a,b,tx],[c,d,ty]] for text(size=100)
rows = []
for ch in "BOLAVUIT":
    (a, b, tx), (c, d, ty) = L[ch]
    w = adv(ch)*EM*100                                         # advance in OpenSCAD units at size 100
    left = np.array([tx, ty]); right = left + w*np.array([a, c])
    rows.append(dict(ch=ch, left=left, right=right, xs=math.hypot(a, c), ys=math.hypot(b, d),
                     base_ang=math.degrees(math.atan2(c, a)), up_ang=math.degrees(math.atan2(-b, d))))
P = np.array([r[k] for r in rows for k in ("left", "right")])
def res(v): return np.hypot(P[:, 0] - v[0], P[:, 1] - v[1]) - v[2]
fit = least_squares(res, [913, -1500, 1900]).x
cx, cy, R = fit
print("baseline circle: centre (%.1f, %.1f) radius %.1f   residual max %.2f px" % (cx, cy, R, np.abs(res(fit)).max()))
for r in rows:
    ph = math.degrees(math.atan2(r["left"][1] - cy, r["left"][0] - cx))
    r["phi"] = ph
    r["rad_up"] = ph                                           # radial direction (deg from +x); up vector angle from vertical = ph - 90
    print(f'{r["ch"]}: phi {ph:6.2f}  baseline angle {r["base_ang"]:6.2f} (tangent {ph-90:6.2f})  up-vector lean {r["up_ang"]:6.2f} vs radial {ph-90:6.2f}  x scale {r["xs"]:.3f}  y scale {r["ys"]:.3f}')
phi = np.array([r["phi"] for r in rows]); lean = np.array([r["up_ang"] - (r["phi"] - 90) for r in rows])
k = np.polyfit(phi, lean, 1); print("lean relative to radial (deg) = %.3f * phi + %.2f ; residual max %.2f" % (k[0], k[1], np.abs(np.polyval(k, phi) - lean).max()))
xs = np.array([r["xs"] for r in rows]); ys = np.array([r["ys"] for r in rows])
out = dict(cx=cx, cy=cy, R=R, phi0=rows[0]["phi"], phi1=math.degrees(math.atan2(rows[-1]["right"][1] - cy, rows[-1]["right"][0] - cx)),
           lean=list(k), xscale=float(xs.mean()), yscale=float(ys.mean()), cap_px=float(ys.mean()*CAP*100))
print({k_: round(v, 3) if isinstance(v, float) else v for k_, v in out.items()})
json.dump(out, open("textarc_fit.json", "w"))
