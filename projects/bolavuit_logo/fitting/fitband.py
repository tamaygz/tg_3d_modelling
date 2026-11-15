import numpy as np, json
from scipy.optimize import minimize
from bvdata import REG
from rast import mask, iou
from banner_lib import band, X0
box=(100,80,1730,640); S=0.5
T=mask([REG[0][2]], box, S)          # hole 1 = band interior
x0=[668, 640, 585, 70, 360, 60, 20]
f=lambda v: -iou(mask([band(v)],box,S),T)
best=None
for it in range(3):
    r=minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=3000, xatol=0.01, fatol=1e-7, adaptive=True))
    if best is None or r.fun<best.fun: best=r
print("band IoU %.4f" % -best.fun); print("hwt %.1f hwb %.1f yt %.1f st %.1f yb %.1f sb %.1f bulge %.1f" % tuple(best.x))
json.dump(list(best.x), open('band_fit.json','w'))
