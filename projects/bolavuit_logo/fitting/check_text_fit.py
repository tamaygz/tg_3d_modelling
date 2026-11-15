"""Check that text set by the rebuilt logo stays inside the banner band (2D, original pixel frame).
Run from results/:  python3 ../check_text_fit.py ["TEXT" ...] """
import _env, subprocess, sys
import numpy as np
from artfit import mask, mask_evenodd, polys, iou
from bvdata import REG
BOX = (60, 80, 1760, 640)
band = mask([REG[0][2]], BOX, 1.0)                        # interior of the banner band (hole 1 of the logo frame)
texts = sys.argv[1:] or ["BOLA VUIT", "BOLA VUIT2", "CLUB 147", "POOL", "THE BIG BREAK", "SNOOKER CLUB OF THE YEAR 2026", "I", "W W W W W W W W"]
worst = 0
for t in texts:
    for font in ("book serif bold", "sans bold", "serif"):
        f = _env.REPO / "projects" / "bolavuit_logo" / "bolavuit_logo.scad"
        out = _env.Path(_env.TMP) / "txt.svg"
        subprocess.run(["openscad", "-o", str(out), "-D", "probe=1", "-D", 'source="rebuilt"', "-D", f'banner_text="{t}"', "-D", f'font_style="{font}"',
                        "-D", "show_ball=false", "-D", "show_wreath=false", "-D", "show_banner=false", str(f)], capture_output=True)
        M = mask_evenodd(polys(str(out)), BOX, 1.0)
        outside = (M & ~band).sum(); ys, xs = np.where(M)
        extent = (xs.min() + BOX[0], xs.max() + BOX[0]) if len(xs) else (0, 0)
        frac = outside/max(1, M.sum()); worst = max(worst, frac)
        print(f"{t[:30]:30s} {font:16s} x {extent[0]:5d}..{extent[1]:5d}  outside the band: {100*frac:5.2f}% of the letters")
print("worst:", round(100*worst, 2), "%"); sys.exit(1 if worst > 0.02 else 0)
