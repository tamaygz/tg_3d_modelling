import numpy as np, json, time
from scipy.optimize import minimize
from scipy.ndimage import binary_dilation
from bvdata import REG
from rast import mask, iou
from banner_lib import *
box=(90,70,1740,650); S=0.5
T=mask([REG[0][0]], box, S, holes=REG[0][1:])
T[: int((650-600)*S), :] = False                      # ignore the ring above y=600 (not part of the banner)
def disk(r):
    r=max(r,0.5); k=int(np.ceil(r)); yy,xx=np.mgrid[-k:k+1,-k:k+1]; return xx*xx+yy*yy<=r*r
J={k:json.load(open(f'{k}_fit.json')) for k in ['band','tail2','fold']}
names=[('band',7),('tail',20),('fold',16),('strip',8),('loops',7),('legs',8),('ear',10),('stroke',1)]
H6=np.array(REG[0][7])
x0=(J['band'] + J['tail2'] + J['fold'] +
    [X0-330, 372, X0+330, 372, X0+330, 300, X0-330, 300] +            # strip rough area (4 corners)
    [10, 326, 8, 300, 72, 0.62, 0.0] +                                 # loops
    [15, 335, 30, 270, 125, 205, 24, 14] +                             # legs
    [269, 539, 426, 552, 410, 502, 340, 552, 330, 515] +               # ear
    [13])
def split(v):
    out={}; i=0
    for n,k in names: out[n]=v[i:i+k]; i+=k
    return out
def model(v):
    p=split(v); st=p['stroke'][0]*S
    B=mask([band(p['band'])],box,S); D=disk(st)
    Bo=binary_dilation(B,D)
    t=tail2(p['tail']); Tl=mask([t,mirror(t)],box,S)&~Bo
    lo=loops(p['loops']); Lp=mask(lo,box,S)
    f=fold(p['fold']); F=mask([f,mirror(f)],box,S)&~Bo&~binary_dilation(Tl,D)&~Lp
    Sr=mask([region(p['strip'])],box,S)&~Bo&~Lp&~binary_dilation(F,D)
    inter=B|Tl|F|Sr
    white=(binary_dilation(inter,D)&~inter) | Lp | mask(legs(p['legs']),box,S)
    e=ear(p['ear']); white |= mask([e,mirror(e)],box,S)
    white[: int((650-600)*S), :] = False
    return white
f=lambda v: -iou(model(np.asarray(v)),T)
print("start IoU %.4f" % -f(x0), flush=True)
best=np.array(x0); bf=f(best); t0=time.time()
order=[('strip',8),('loops',7),('legs',8),('ear',10),('stroke',1),('loops',7),('legs',8),('strip',8),('tail',20),('fold',16),('band',7),('ear',10),('stroke',1)]
for rnd in range(1):
    for n,k in order:                                 # refine block by block (coordinate descent over pieces)
        i=sum(kk for nn,kk in names[:[m for m,_ in names].index(n)])
        def g(sub): v=best.copy(); v[i:i+k]=sub; return f(v)
        r=minimize(g, best[i:i+k], method='Nelder-Mead', options=dict(maxiter=1500 if k>8 else 800, xatol=0.05, fatol=1e-7, adaptive=True))
        if r.fun<bf: best[i:i+k]=r.x; bf=r.fun
        print(f"{n:6s} IoU {-bf:.4f}  ({time.time()-t0:.0f}s)", flush=True)
        json.dump(best.tolist(), open('banner_joint.json','w'))
json.dump(best.tolist(), open('banner_joint.json','w'))
from PIL import Image
m=model(best); im=np.zeros(m.shape+(3,),np.uint8); im[...,0]=T*255; im[...,1]=m*255; im[...,2]=m*255
Image.fromarray(im).save('banner_cmp.png')
