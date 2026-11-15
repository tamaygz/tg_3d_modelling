import numpy as np, json, math
from scipy.optimize import minimize
from scipy.ndimage import label
from bvdata import REG
from rast import mask, iou
from fitleaves_lib import leaf_pts, place
box=(150,560,913,900); S=1.0
W=mask([REG[0][0]],box,S,holes=REG[0][1:])
H=W.shape[0]; ys,xs=np.mgrid[0:H,0:W.shape[1]]
X=xs/S+box[0]; Y=box[3]-ys/S
ring=np.hypot(X-912,Y-959)<470
zone=(Y>603)&~ring                         # visible part above the banner, outside the ball ring
T=W&zone
lab,n=label(T); sizes=[(lab==k).sum() for k in range(1,n+1)]
print("blobs", sorted(sizes,reverse=True)[:5])
keep=np.zeros_like(T)
for k in range(1,n+1):
    if (lab==k).sum()>2000: keep|=lab==k
T=keep
for k in range(1,n+1):
    if (lab==k).sum()>2000:
        yy,xx=np.where(lab==k); print("blob x %.0f..%.0f y %.0f..%.0f" % (xx.min()/S+box[0], xx.max()/S+box[0], box[3]-yy.max()/S, box[3]-yy.min()/S))
def model(v):
    a=place(leaf_pts(v[3],v[4],0.62),v[0],v[1],v[2]); b=place(leaf_pts(v[8],v[9],0.62),v[5],v[6],v[7])
    return mask([a,b],box,S)&zone
best=None
for angA in (140,150,160):
    for angB in (60,75,90,105):
        x0=[470,560,angA,300,82, 520,540,angB,280,78]
        f=lambda v:-iou(model(v),T)
        r=minimize(f,x0,method='Nelder-Mead',options=dict(maxiter=4000,adaptive=True,xatol=0.01,fatol=1e-7))
        if best is None or r.fun<best.fun: best=r
for _ in range(2):
    best=minimize(lambda v:-iou(model(v),T),best.x,method='Nelder-Mead',options=dict(maxiter=4000,adaptive=True,xatol=0.01,fatol=1e-7))
v=best.x
print("bottom leaves IoU (visible part) %.3f" % -best.fun)
Cm=np.array([913.68,959.]); rows=[]
for j in (0,5):
    bx,by,ang,L,Wd=v[j:j+5]; d=np.array([bx,by])-Cm; r=float(np.hypot(*d)); a=math.degrees(math.atan2(d[1],d[0]))%360
    lean=(ang-(a-90)+540)%360-180; rows.append([round(a,2),round(r,1),round(lean,2),round(L,1),round(Wd,1)])
print(rows); json.dump(rows,open('low_leaves.json','w'))
