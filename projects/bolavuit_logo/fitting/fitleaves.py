import _env
import numpy as np, math, json
from scipy.optimize import minimize
from bvdata import REG, LEAVES_L
from artfit import mask, iou
def leaf_pts(L, W, p=0.6, q=1.0, bend=0.0, n=48):
    hw=lambda t: W/2*np.sin(np.pi*t**q)**p
    bx=lambda t: bend*L*t*t
    R=[(bx(t)+hw(t), t*L) for t in np.linspace(0,1,n+1)]
    Lf=[(bx(t)-hw(t), t*L) for t in np.linspace(1,0,n+1)[1:-1]]
    return R+Lf
def place(pts, bx, by, ang):          # leaf points up (+y); rotate so +y -> ang
    a=math.radians(ang-90); c,s=math.cos(a),math.sin(a)
    return [(bx+c*x-s*y, by+s*x+c*y) for x,y in pts]
out=[]
for n,i in enumerate(LEAVES_L):
    P=np.array(REG[i][0]); box=(P[:,0].min()-40,P[:,1].min()-40,P[:,0].max()+40,P[:,1].max()+40)
    T=mask([REG[i][0]],box)
    D=((P[:,None,:]-P[None,:,:])**2).sum(-1); a,b=np.unravel_index(D.argmax(),D.shape)
    A,B=P[a],P[b]
    if A[1]<B[1]: A,B=B,A
    L=np.linalg.norm(A-B); ang=math.degrees(math.atan2(A[1]-B[1],A[0]-B[0]))
    x0=np.array([B[0],B[1],ang,L,0.26*L,0.6,1.0,0.0])
    f=lambda v: -iou(mask([place(leaf_pts(v[3],v[4],v[5],v[6],v[7]),v[0],v[1],v[2])],box),T)
    r=minimize(f,x0,method='Nelder-Mead',options=dict(maxiter=1500,xatol=0.05,fatol=1e-5,initial_simplex=None))
    v=r.x; out.append(v.tolist())
    print(f"leaf {n}: IoU {-r.fun:.3f}  base ({v[0]:.1f},{v[1]:.1f}) ang {v[2]:.1f} L {v[3]:.1f} W {v[4]:.1f} p {v[5]:.2f} q {v[6]:.2f} bend {v[7]:+.3f}")
json.dump(out,open('leaves_fit.json','w'))
