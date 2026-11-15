import _env
import numpy as np, math
import numpy as np, math, json
def leaf_pts(L, W, p=0.6, q=1.0, bend=0.0, n=48):
    hw=lambda t: W/2*np.sin(np.pi*t**q)**p
    bx=lambda t: bend*L*t*t
    R=[(bx(t)+hw(t), t*L) for t in np.linspace(0,1,n+1)]
    Lf=[(bx(t)-hw(t), t*L) for t in np.linspace(1,0,n+1)[1:-1]]
    return R+Lf
def place(pts, bx, by, ang):          # leaf points up (+y); rotate so +y -> ang
    a=math.radians(ang-90); c,s=math.cos(a),math.sin(a)
    return [(bx+c*x-s*y, by+s*x+c*y) for x,y in pts]
