import _env
import numpy as np, json, math
from scipy.optimize import minimize
from bvdata import REG
from artfit import mask, iou
def circ(c, r, n=360): return [(c[0]+r*math.cos(2*math.pi*i/n), c[1]+r*math.sin(2*math.pi*i/n)) for i in range(n)]
box=(440,490,1390,1440); S=0.5
# --- ring: exact = frame region inside an annulus, above the banner
W=mask([REG[0][0]],box,S,holes=REG[0][1:]); H,Wd=W.shape; yy,xx=np.mgrid[0:H,0:Wd]; X=xx/S+box[0]; Y=box[3]-yy/S
zone=(Y>612); Tr=W&(np.abs(np.hypot(X-912,Y-959)-440)<40)&zone
fr=lambda v: -iou((mask([circ((v[0],v[1]),v[2])],box,S,holes=[circ((v[0],v[1]),v[2]-v[3])]))&zone, Tr)
r=minimize(fr,[912,959,449,20],method='Nelder-Mead',options=dict(adaptive=True,maxiter=3000,xatol=0.01,fatol=1e-8))
ring=r.x; print("ring IoU %.3f  centre (%.2f, %.2f) R %.2f width %.2f" % (-r.fun,*ring))
# --- disc: least-squares circle through the outer contour of region 1
P=np.array(REG[1][0]); A=np.c_[2*P,np.ones(len(P))]; b=(P**2).sum(1); cx,cy,c=np.linalg.lstsq(A,b,rcond=None)[0]; dr=math.sqrt(c+cx*cx+cy*cy)
print("disc centre (%.2f, %.2f) r %.2f  (residual %.2f)" % (cx,cy,dr,np.abs(np.hypot(P[:,0]-cx,P[:,1]-cy)-dr).max()))
# --- crescent: outer circle (centre c0, radius ro) minus a circle through both tips and the thickest point
Tc=mask([REG[2][0]],box,S)
def crescent(v):
    c0=np.array(v[:2]); ro,fr_,to,mid,w=v[2:]
    p1=c0+ro*np.array([math.cos(math.radians(fr_)),math.sin(math.radians(fr_))]); p2=c0+ro*np.array([math.cos(math.radians(to)),math.sin(math.radians(to))])
    pm=c0+(ro-w)*np.array([math.cos(math.radians(mid)),math.sin(math.radians(mid))])
    a,b2,c3=p1,p2,pm; d=2*(a[0]*(b2[1]-c3[1])+b2[0]*(c3[1]-a[1])+c3[0]*(a[1]-b2[1]))
    ux=((a@a)*(b2[1]-c3[1])+(b2@b2)*(c3[1]-a[1])+(c3@c3)*(a[1]-b2[1]))/d; uy=((a@a)*(c3[0]-b2[0])+(b2@b2)*(a[0]-c3[0])+(c3@c3)*(b2[0]-a[0]))/d
    ci=np.array([ux,uy]); ri=np.linalg.norm(a-ci)
    wedge=[tuple(c0),tuple(c0+2*ro*np.array([math.cos(math.radians(fr_)),math.sin(math.radians(fr_))])),
           tuple(c0+2*ro*np.array([math.cos(math.radians(mid)),math.sin(math.radians(mid))])),tuple(c0+2*ro*np.array([math.cos(math.radians(to)),math.sin(math.radians(to))]))]
    return mask([circ(c0,ro)],box,S,holes=[circ(ci,ri)]) & mask([wedge],box,S)
fc=lambda v:-iou(crescent(v),Tc)
best=None
for x0 in ([912,959,378,20,-98,-70,74],[905,965,380,18,-97,-65,70],[915,955,375,22,-99,-75,78]):
    rr=minimize(fc,x0,method='Nelder-Mead',options=dict(adaptive=True,maxiter=4000,xatol=0.01,fatol=1e-8))
    if best is None or rr.fun<best.fun: best=rr
print("crescent IoU %.3f  params %s" % (-best.fun, [round(x,2) for x in best.x]))
json.dump(dict(ring=list(ring),disc=[cx,cy,dr],crescent=list(best.x)),open('ball_fit.json','w'))
