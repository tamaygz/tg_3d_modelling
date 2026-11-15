import _env
"""Render the rebuilt elements with OpenSCAD and score each against the exact artwork (IoU at 1 px)."""
import subprocess, numpy as np
from artfit import polys, mask_evenodd
from artfit import mask, iou
from bvdata import REG, LEAVES_L, LEAVES_R
PRJ=str(_env.LOGO)
SP=_env.TMP
CHK='''use <../../lib/emblem.scad>
include <../../lib/emblems/bolavuit_rebuilt.scad>
what = 0;
if (what == 0) translate([BVR_CENTER_X, 0]) ribbon_banner_2d(BVR_BANNER);
if (what == 1) translate(BVR_WREATH_C) laurel_wreath_2d(leaves=BVR_LEAVES);
if (what == 2) for (l=BVR_LETTERS) multmatrix([[l[1][0][0], l[1][0][1], 0, l[1][0][2]], [l[1][1][0], l[1][1][1], 0, l[1][1][2]], [0,0,1,0], [0,0,0,1]])
                 text(l[0], size=100, font=BVR_FONT, halign="left", valign="baseline");
'''
def render(w):
    open(f'{PRJ}/_chk.scad','w').write(CHK)
    subprocess.run(['openscad','-o',f'{SP}/chk{w}.svg','-D',f'what={w}',f'{PRJ}/_chk.scad'],capture_output=True)
    return polys(f'{SP}/chk{w}.svg')
def exact_white(regs, box):
    return mask([REG[i][0] for i in regs], box, 1.0, holes=[c for i in regs for c in REG[i][1:]])
if __name__ == '__main__':
    box=(60,80,1760,620)                                      # banner zone (below the ring)
    T=mask([REG[0][0]], box, 1.0, holes=REG[0][1:]); T[:int((620-600)),:]=False
    M=mask_evenodd(render(0), box, 1.0); M[:20,:]=False
    print(f"banner (white outlines + bow) IoU {iou(M,T):.3f}")
    box=(60,560,1780,1720)
    T=exact_white(LEAVES_L+LEAVES_R, box); M=mask_evenodd(render(1), box, 1.0)
    print(f"laurel IoU {iou(M,T):.3f}")
    box=(380,300,1460,600)
    T=exact_white([24,21,23,22,28,26], box); M=mask_evenodd(render(2), box, 1.0)
    print(f"lettering IoU {iou(M,T):.3f}")
    import os; os.remove(f'{PRJ}/_chk.scad')
