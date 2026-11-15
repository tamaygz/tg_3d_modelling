import _env
import numpy as np, json
from scipy.optimize import minimize
from scipy.ndimage import binary_dilation
from bvdata import REG
from artfit import mask, iou
from banner_lib import band, tail2, X0
box=(100,80,1730,640); S=0.5; STROKE=13
H=np.array(REG[0][4])                                 # hole 3 = left tail interior
T=mask([H.tolist()], box, S)
bandv=json.load(open('band_fit.json'))
yy,xx=np.mgrid[-8:9,-8:9]; disk=(xx*xx+yy*yy)<= (STROKE*S)**2
BANDOFF=binary_dilation(mask([band(bandv)],box,S), disk)
i_t1=H[:,0].argmin(); i_t2=H[:,1].argmin(); i_a=H[:,1].argmax()
T1=H[i_t1]; T2=H[i_t2]; A=H[i_a]
# notch: the contour point between the tips that reaches furthest right
lo,hi=sorted([i_t1,i_t2]); seg=H[lo:hi+1] if hi-lo < len(H)/2 else np.r_[H[hi:],H[:lo+1]]
N=seg[seg[:,0].argmax()]
B=H[(H[:,0]-H[:,1]).argmax()]                        # lower right corner
print("start A",A,"T1",T1,"N",N,"T2",T2,"B",B)
v1=__import__('json').load(open('tail_fit.json'))
x0=v1+[(v1[4]+v1[6])/2,(v1[5]+v1[7])/2,(v1[6]+v1[8])/2,(v1[7]+v1[9])/2,(v1[12]+v1[0])/2,(v1[13]+v1[1])/2]
_unused=[A[0],A[1],(A[0]+T1[0])/2,(A[1]+T1[1])/2+10,T1[0],T1[1],N[0],N[1],T2[0],T2[1],(T2[0]+B[0])/2,(T2[1]+B[1])/2-10,B[0],B[1]]
def model(v): return mask([tail2(v)],box,S) & ~BANDOFF
f=lambda v: -iou(model(v),T)
best=None
for it in range(4):
    r=minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=6000, xatol=0.01, fatol=1e-7, adaptive=True))
    if best is None or r.fun<best.fun: best=r
    print(it, round(-r.fun,4), flush=True)
print("tail IoU %.4f" % -best.fun)
print([round(x,1) for x in best.x])
json.dump(list(best.x), open('tail2_fit.json','w'))
