import _env
import numpy as np, math, json
from scipy.optimize import minimize
from bvdata import REG, LEAVES_L
from artfit import mask, iou
from fitleaves_lib import leaf_pts, place
C=np.array([912.,959.])
box=(80,600,760,1700); S=0.5
T=mask([REG[i][0] for i in LEAVES_L], box, S)
# roles per group: [angle offset (deg, along the branch), radius offset, lean (+ out), length scale]
def branch(v, groups=3):
    a0, step, r, L0, grow, ratio, p = v[:7]
    roles = np.array(v[7:]).reshape(3,4)
    polys=[]
    for g in range(groups):
        for k in range(3):
            da, dr, lean, ls = roles[k]
            a = a0 - (g*step + da)                       # walk up the branch (angle decreasing on the left)
            t = (g*step + da)/(groups*step)
            bx,by = C+(r+dr)*np.array([math.cos(math.radians(a)),math.sin(math.radians(a))])
            L = L0*ls*(1+(grow-1)*t)
            polys.append(place(leaf_pts(L,ratio*L,p),bx,by,a-90+lean))
    return polys
x0=[210, 24, 595, 330, 0.88, 0.268, 0.62,
    0, -30, -25, 1.0,
    7, -10, 26, 0.98,
    18, 20, 13, 0.95]
f=lambda v: -iou(mask(branch(v),box,S),T)
best=None
for it in range(4):
    r=minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=6000, xatol=0.01, fatol=1e-7, adaptive=True))
    if best is None or r.fun<best.fun: best=r
    print(it, round(-r.fun,4), flush=True)
v=best.x
print("grouped branch IoU %.3f" % -best.fun)
print("a0 %.1f step %.1f r %.1f L0 %.1f grow %.3f ratio %.3f p %.2f" % tuple(v[:7]))
for name,row in zip(["inner","outer1","outer2"], np.array(v[7:]).reshape(3,4)): print(f"  {name}: offset {row[0]:.1f}deg  dr {row[1]:.1f}  lean {row[2]:.1f}  size {row[3]:.3f}")
json.dump(list(v), open('laurel_grouped.json','w'))
