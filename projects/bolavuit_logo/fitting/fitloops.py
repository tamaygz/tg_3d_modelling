import _env
import numpy as np, json
from scipy.optimize import minimize
from scipy.ndimage import binary_erosion
from bvdata import REG
from artfit import mask, iou
from banner_lib import loops, X0
box=(560,230,1270,380); S=1.0
white=mask([REG[0][0]],box,S,holes=REG[0][1:])
yy,xx=np.mgrid[-7:8,-7:8]; disk=(xx*xx+yy*yy)<=49
T=binary_erosion(white,disk)
J=json.load(open('banner_joint.json')); lv0=J[7+20+16+8:7+20+16+8+7]
print("start loops", [round(x,2) for x in lv0])
f=lambda v: -iou(binary_erosion(mask(loops(v),box,S),disk), T)
best=None
for x0 in (lv0, [10,330,8,300,72,0.62,0.0], [15,325,5,310,60,0.62,0.0]):
    r=minimize(f,x0,method='Nelder-Mead',options=dict(maxiter=4000,adaptive=True,xatol=0.01,fatol=1e-8))
    if best is None or r.fun<best.fun: best=r
best=minimize(f,best.x,method='Nelder-Mead',options=dict(maxiter=4000,adaptive=True,xatol=0.01,fatol=1e-8))
print("loops IoU (solid cores) %.3f" % -best.fun, [round(x,3) for x in best.x])
J[7+20+16+8:7+20+16+8+7]=list(best.x); json.dump(J,open('banner_joint.json','w'))
