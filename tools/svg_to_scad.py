#!/usr/bin/env python3
"""Convert SVG path artwork into exact OpenSCAD polygon data (no SVG import, no DPI guessing).

    python3 tools/svg_to_scad.py art.svg out.scad [--path ID] [--prefix NAME] [--tol 0.25]

Reads the path (or every path) of the SVG, flattens curves (cubic, quadratic, elliptical arcs) to within
`tol` px, and groups the subpaths into REGIONS: an outer contour plus the holes inside it (even-odd fill,
like the SVG). Coordinates stay in the SVG's px units with y flipped up (y = height - y_svg), so the
OpenSCAD drawing lines up with the original frame. The output file defines:

    <prefix>_W, <prefix>_H                    frame size (px)
    <prefix>_REGIONS = [[points, paths], ...]  one polygon per region
    <prefix>_INFO = [[cx, cy, w, h, area], ...] centroid, size, area per region (px, y up)
    module <prefix>_region(i)                 draw region i
    module <prefix>_all()                     draw everything
"""
import argparse, math, re, sys

TOKEN = re.compile(r"[AaCcHhLlMmQqSsTtVvZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")


def flatten_path(d, tol):
    toks = TOKEN.findall(d)
    i, cmd = 0, None
    subs, cur = [], []
    x = y = sx = sy = 0.0
    lc = None                                  # last control point (for S/T)
    def num():
        nonlocal i
        v = float(toks[i]); i += 1; return v
    def seg_n(length):
        return max(2, min(200, int(math.ceil(length / max(tol * 4, 0.5)))))
    while i < len(toks):
        if re.match(r"[A-Za-z]", toks[i]):
            cmd = toks[i]; i += 1
            if cmd in "Zz":
                if cur: subs.append(cur); cur = []
                x, y = sx, sy; lc = None
                continue
        rel = cmd.islower(); C = cmd.upper()
        ox, oy = (x, y) if rel else (0.0, 0.0)
        if C == "M":
            if cur: subs.append(cur)
            x, y = ox + num(), oy + num(); sx, sy = x, y; cur = [(x, y)]
            cmd = "l" if rel else "L"; lc = None
        elif C == "L":
            x, y = ox + num(), oy + num(); cur.append((x, y)); lc = None
        elif C == "H":
            x = (x if rel else 0) + num(); cur.append((x, y)); lc = None
        elif C == "V":
            y = (y if rel else 0) + num(); cur.append((x, y)); lc = None
        elif C in "CS":
            if C == "C":
                x1, y1 = ox + num(), oy + num()
            else:
                x1, y1 = (2*x - lc[0], 2*y - lc[1]) if lc and lc[2] == "C" else (x, y)
            x2, y2 = ox + num(), oy + num(); ex, ey = ox + num(), oy + num()
            n = seg_n(math.dist((x, y), (x1, y1)) + math.dist((x1, y1), (x2, y2)) + math.dist((x2, y2), (ex, ey)))
            for k in range(1, n + 1):
                t = k / n; u = 1 - t
                cur.append((u**3*x + 3*u*u*t*x1 + 3*u*t*t*x2 + t**3*ex, u**3*y + 3*u*u*t*y1 + 3*u*t*t*y2 + t**3*ey))
            lc = (x2, y2, "C"); x, y = ex, ey
        elif C in "QT":
            if C == "Q":
                x1, y1 = ox + num(), oy + num()
            else:
                x1, y1 = (2*x - lc[0], 2*y - lc[1]) if lc and lc[2] == "Q" else (x, y)
            ex, ey = ox + num(), oy + num()
            n = seg_n(math.dist((x, y), (x1, y1)) + math.dist((x1, y1), (ex, ey)))
            for k in range(1, n + 1):
                t = k / n; u = 1 - t
                cur.append((u*u*x + 2*u*t*x1 + t*t*ex, u*u*y + 2*u*t*y1 + t*t*ey))
            lc = (x1, y1, "Q"); x, y = ex, ey
        elif C == "A":
            rx, ry, phi = abs(num()), abs(num()), math.radians(num())
            large, sweep = int(num()), int(num())
            ex, ey = ox + num(), oy + num()
            cur.extend(arc_points(x, y, rx, ry, phi, large, sweep, ex, ey, tol))
            x, y = ex, ey; lc = None
        else:
            sys.exit(f"unsupported path command {cmd}")
    if cur: subs.append(cur)
    return subs


def arc_points(x1, y1, rx, ry, phi, fa, fs, x2, y2, tol):
    if rx == 0 or ry == 0:
        return [(x2, y2)]
    c, s = math.cos(phi), math.sin(phi)
    dx, dy = (x1 - x2) / 2, (y1 - y2) / 2
    x1p, y1p = c*dx + s*dy, -s*dx + c*dy
    lam = x1p**2/rx**2 + y1p**2/ry**2
    if lam > 1:
        rx *= math.sqrt(lam); ry *= math.sqrt(lam)
    num = rx*rx*ry*ry - rx*rx*y1p*y1p - ry*ry*x1p*x1p
    den = rx*rx*y1p*y1p + ry*ry*x1p*x1p
    co = math.sqrt(max(0, num/den)) * (-1 if fa == fs else 1)
    cxp, cyp = co*rx*y1p/ry, -co*ry*x1p/rx
    cx, cy = c*cxp - s*cyp + (x1 + x2)/2, s*cxp + c*cyp + (y1 + y2)/2
    def ang(u, v):
        a = math.atan2(u[0]*v[1] - u[1]*v[0], u[0]*v[0] + u[1]*v[1]); return a
    t1 = ang((1, 0), ((x1p - cxp)/rx, (y1p - cyp)/ry))
    dt = ang(((x1p - cxp)/rx, (y1p - cyp)/ry), ((-x1p - cxp)/rx, (-y1p - cyp)/ry))
    if not fs and dt > 0: dt -= 2*math.pi
    if fs and dt < 0: dt += 2*math.pi
    n = max(4, int(abs(dt) * max(rx, ry) / max(tol*4, 0.5)))
    pts = []
    for k in range(1, n + 1):
        t = t1 + dt*k/n
        pts.append((cx + rx*math.cos(t)*c - ry*math.sin(t)*s, cy + rx*math.cos(t)*s + ry*math.sin(t)*c))
    return pts


def area(p):
    return sum(p[i][0]*p[i-1][1] - p[i-1][0]*p[i][1] for i in range(len(p))) / 2


def inside(pt, poly):
    x, y = pt; c = False
    for i in range(len(poly)):
        x1, y1 = poly[i - 1]; x2, y2 = poly[i]
        if (y1 > y) != (y2 > y) and x < (x2 - x1)*(y - y1)/(y2 - y1) + x1:
            c = not c
    return c


def dedupe(p):
    out = []
    for q in p:
        if not out or math.dist(out[-1], q) > 1e-6:
            out.append(q)
    if len(out) > 1 and math.dist(out[0], out[-1]) < 1e-6:
        out.pop()
    return out


def regions(subs):
    subs = [s for s in (dedupe(s) for s in subs) if len(s) >= 3 and abs(area(s)) > 1e-3]
    order = sorted(range(len(subs)), key=lambda i: -abs(area(subs[i])))
    parent, depth = {}, {}
    for i in order:                                   # parent = smallest containing larger contour
        best = None
        for j in order:
            if j == i or abs(area(subs[j])) <= abs(area(subs[i])):
                continue
            if inside(subs[i][0], subs[j]) and (best is None or abs(area(subs[j])) < abs(area(subs[best]))):
                best = j
        parent[i] = best
    def dep(i): return 0 if parent[i] is None else 1 + dep(parent[i])
    outs = [i for i in order if dep(i) % 2 == 0]       # even depth = filled (even-odd rule)
    regs = []
    for o in outs:
        holes = [h for h in order if parent[h] == o]
        regs.append([subs[o]] + [subs[h] for h in holes])
    return regs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("svg"); ap.add_argument("out")
    ap.add_argument("--path", help="only the path with this id")
    ap.add_argument("--prefix", default="SVG")
    ap.add_argument("--tol", type=float, default=0.25)
    a = ap.parse_args()
    s = open(a.svg).read()
    W = float(re.search(r'<svg[^>]*\bwidth="([\d.]+)', s).group(1))
    H = float(re.search(r'<svg[^>]*\bheight="([\d.]+)', s).group(1))
    ds = [m.group(2) for m in re.finditer(r'<path\b[^>]*?(?:id="([^"]*)")?[^>]*?\bd="([^"]+)"', s)
          if not a.path or re.search(r'id="%s"' % re.escape(a.path), m.group(0))]
    subs = [sp for d in ds for sp in flatten_path(d, a.tol)]
    regs = regions(subs)
    P = a.prefix
    lines = [f"// generated by tools/svg_to_scad.py from {a.svg.split('/')[-1]}" + (f" (path {a.path})" if a.path else ""),
             "// px units, y up; do not edit by hand", f"{P}_W = {W:g};", f"{P}_H = {H:g};", f"{P}_REGIONS = ["]
    info = []
    for r in regs:
        pts, paths, k = [], [], 0
        for c in r:
            pts += [(round(x, 2), round(H - y, 2)) for x, y in c]
            paths.append(list(range(k, k + len(c)))); k += len(c)
        outer = [(x, H - y) for x, y in r[0]]
        ar = abs(area(outer)) - sum(abs(area(h)) for h in r[1:])
        xs = [p[0] for p in outer]; ys = [p[1] for p in outer]
        A = -area(outer)                    # area() is clockwise-positive; the centroid formula wants CCW
        cx = sum((outer[i-1][0] + outer[i][0])*(outer[i-1][0]*outer[i][1] - outer[i][0]*outer[i-1][1]) for i in range(len(outer))) / (6*A)
        cy = sum((outer[i-1][1] + outer[i][1])*(outer[i-1][0]*outer[i][1] - outer[i][0]*outer[i-1][1]) for i in range(len(outer))) / (6*A)
        info.append([round(cx, 1), round(cy, 1), round(max(xs) - min(xs), 1), round(max(ys) - min(ys), 1), round(ar)])
        lines.append("  [[" + ",".join(f"[{x:g},{y:g}]" for x, y in pts) + "],[" + ",".join("[" + ",".join(map(str, p)) + "]" for p in paths) + "]],")
    lines[-1] = lines[-1].rstrip(",")
    lines += ["];", f"{P}_INFO = [" + ",".join("[" + ",".join(f"{v:g}" for v in i) + "]" for i in info) + "];",
              f"module {P}_region(i) {{ polygon({P}_REGIONS[i][0], {P}_REGIONS[i][1]); }}",
              f"module {P}_all() {{ for (i=[0:len({P}_REGIONS)-1]) {P}_region(i); }}", ""]
    open(a.out, "w").write("\n".join(lines))
    print(f"{a.out}: {len(regs)} regions from {len(subs)} contours, {sum(len(c) for r in regs for c in r)} points")
    for n, i in enumerate(info):
        print(f"  {n:2d}: centre ({i[0]:7.1f},{i[1]:7.1f})  size {i[2]:6.1f} x {i[3]:6.1f}  area {i[4]:8.0f}")


if __name__ == "__main__":
    main()
