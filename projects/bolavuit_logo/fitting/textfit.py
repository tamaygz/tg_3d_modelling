import numpy as np, json
from scipy.optimize import minimize
import fontwarp as FW
from rast import iou
FW.S=0.5
from fontwarp import F, env_pt, TXT
import fontwarp
# re-make the target at the new scale
from bvdata import REG
from rast import mask
LET=[24,21,23,22,28,26]; box=fontwarp.box
fontwarp.T=mask([c for i in LET for c in REG[i][:1]], box, 0.5, holes=[c for i in LET for c in REG[i][1:]])
fontwarp.OW,fontwarp.OH=fontwarp.T.shape[1],fontwarp.T.shape[0]
T=fontwarp.T
font=F('/home/user/tg_3d_modelling/lib/fonts/Eczar-Bold.ttf', 400)
def render(v):
    env=v[:8]; kern=list(v[8:])+[0]      # extra space after each character (in cap heights)
    advs=[font.adv[c]+kern[i]*font.cap for i,c in enumerate(TXT)]
    tot=sum(advs)-kern[-1]*font.cap; out=np.zeros(T.shape,bool); u=0
    from PIL import Image
    for i,(c,a) in enumerate(zip(TXT,advs)):
        u0=u/tot; u1=(u+font.adv[c])/tot; u+=a
        if c==" ": continue
        BL=env_pt(u0,False,env); BR=env_pt(u1,False,env); TL=env_pt(u0,True,env); TR=env_pt(u1,True,env)
        ad=font.adv[c]; cap=font.cap
        X=((BR-BL)+(TR-TL))/(2*ad); Y=((TL-BL)+(TR-BR))/(2*cap); T0=(BL+BR+TL+TR)/4 - X*ad/2 - Y*cap/2
        A=np.c_[X,Y,T0]
        im,ox,oy=font.img[c]; S=0.5
        M=np.array([[S,0,-box[0]*S],[0,-S,box[3]*S],[0,0,1]]) @ np.vstack([A,[0,0,1]]) @ np.array([[1,0,-ox],[0,-1,oy],[0,0,1]])
        Mi=np.linalg.inv(M)
        g=im.transform((T.shape[1],T.shape[0]),Image.AFFINE,data=tuple(Mi[:2].ravel()),resample=Image.BILINEAR)
        out|=np.array(g)>127
    return out
x0=[432,1402,410,50, 440,1398,545,45] + [0.03]*8
f=lambda v: -iou(render(v),T)
best=None
for it in range(5):
    r=minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=5000, xatol=0.01, fatol=1e-7, adaptive=True))
    if best is None or r.fun<best.fun: best=r
    print(it, round(-r.fun,4), flush=True)
print("text IoU %.4f" % -best.fun); print([round(x,3) for x in best.x])
json.dump(list(best.x), open('text_fit.json','w'))
print("advances (em):", {c: round(font.adv[c]/font.f.size,4) for c in sorted(set(TXT))}, "cap/em", round(font.cap/font.f.size,4))
