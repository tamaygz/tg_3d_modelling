import numpy as np, math, json
from scipy.optimize import minimize
from bvdata import REG, LEAVES_L
from rast import mask, iou
from fitleaves_lib import leaf_pts, place
C=np.array([912.,959.])
box=(80,600,760,1700); S=0.5
T=mask([REG[i][0] for i in LEAVES_L], box, S)
PAT="ioo"
def branch(v, n=9):
    a0,a1,r,dro,dri,lo,li,L0,grow,ratio,p = v
    polys=[]
    for k in range(n):
        t=k/(n-1); a=a0+(a1-a0)*t; side=PAT[k%len(PAT)]
        rr=r+(dro if side=='o' else dri)
        bx,by=C+rr*np.array([math.cos(math.radians(a)),math.sin(math.radians(a))])
        tang=a-90; ang=tang+(lo if side=='o' else -li)
        L=L0*(1+(grow-1)*t)
        polys.append(place(leaf_pts(L,ratio*L,p),bx,by,ang))
    return polys
x0=[210,137,595,5,-15,22,25,320,0.87,0.27,0.62]
f=lambda v: -iou(mask(branch(v),box,S),T)
best=None
for it in range(3):
    r=minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=4000, xatol=0.01, fatol=1e-6, adaptive=True))
    if best is None or r.fun<best.fun: best=r
    print(it, -r.fun)
v=best.x
print("generic branch IoU %.3f" % -best.fun)
print("params a0 %.1f a1 %.1f r %.1f dr_out %.1f dr_in %.1f lean_out %.1f lean_in %.1f L0 %.1f grow %.3f ratio %.3f p %.2f" % tuple(v))
json.dump(list(v), open('laurel_generic.json','w'))
# explicit (per-leaf fitted) branch, for comparison
lf=json.load(open('leaves_fit.json'))
E=[place(leaf_pts(l[3],l[4],l[5],l[6],l[7]),l[0],l[1],l[2]) for l in lf]
print("explicit per-leaf branch IoU %.3f" % iou(mask(E,box,S),T))
