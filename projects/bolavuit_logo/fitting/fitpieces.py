import _env
import numpy as np, json
from scipy.optimize import minimize
from bvdata import REG
from artfit import mask, iou
from banner_lib import fold, strip, X0
def fit(name, hole, fn, x0, box):
    T = mask([hole], box, 1.0)
    f = lambda v: -iou(mask([fn(v)], box, 1.0), T)
    best = None
    for it in range(4):
        r = minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=8000, xatol=0.01, fatol=1e-7, adaptive=True))
        if best is None or r.fun < best.fun: best = r
    print(f"{name} IoU {-best.fun:.4f}"); json.dump(list(best.x), open(f'{name}_fit.json', 'w')); return best.x
H5 = np.array(REG[0][6]); H6 = np.array(REG[0][7])
print("fold bbox", H5.min(0), H5.max(0)); print("strip bbox", H6.min(0), H6.max(0))
# fold corners: top-left, top-right, bottom-right, bottom-left (from the bbox), controls at edge midpoints
x0, y0 = H5.min(0); x1, y1 = H5.max(0)
c = [(x0+10, y1-30), (x0+120, y1), (x1, y0+40), (x0+60, y0)]
ctr = [((c[i][0]+c[(i+1)%4][0])/2, (c[i][1]+c[(i+1)%4][1])/2) for i in range(4)]
fit("fold", H5.tolist(), fold, np.array(c + ctr).ravel(), (x0-30, y0-30, x1+30, y1+30))
sx0, sy0 = H6.min(0); sx1, sy1 = H6.max(0)
fit("strip", H6.tolist(), strip, np.array([(sx1-sx0)/2, sy1-15, sy1, sy0, (sx1-sx0)/4, sy1+5, (sx1-sx0)/4, sy0+20]), (sx0-30, sy0-30, sx1+30, sy1+30))
