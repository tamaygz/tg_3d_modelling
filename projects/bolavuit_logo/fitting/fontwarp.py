import numpy as np, glob, os, sys, json
from PIL import Image, ImageDraw, ImageFont
from scipy.optimize import minimize
from bvdata import REG
from rast import mask, iou
LET=[24,21,23,22,28,26]
box=(400,320,1450,590); S=0.4
T=mask([c for i in LET for c in REG[i][:1]], box, S, holes=[c for i in LET for c in REG[i][1:]])
TXT="BOLA VUIT"
OW,OH=T.shape[1],T.shape[0]
def env_pt(u, top, v):
    # u in [0,1] along the word; v: [xbl,xbr,yb,sb, xtl,xtr,yt,st]
    xl,xr,y0,s = (v[4],v[5],v[6],v[7]) if top else (v[0],v[1],v[2],v[3])
    x=xl+u*(xr-xl); m=(xl+xr)/2; hw=(xr-xl)/2
    return np.array([x, y0 - s*((x-m)/hw)**2])
class F:
    def __init__(s,path,size=200):
        s.f=ImageFont.truetype(path,size); s.cap=-s.f.getbbox("H",anchor="ls")[1]
        s.adv={c:s.f.getlength(c) for c in set(TXT)}
        s.img={}
        for c in set(TXT)-{" "}:
            bb=s.f.getbbox(c,anchor="ls"); w=int(s.adv[c]+abs(bb[0])+40); h=int(s.cap*1.4)
            im=Image.new('L',(w,h),0); ImageDraw.Draw(im).text((20,int(s.cap*1.2)),c,font=s.f,fill=255,anchor="ls")
            s.img[c]=(im,20,int(s.cap*1.2))     # origin (left, baseline) in pixels
def render(font, v):
    track=v[8]
    advs=[font.adv[c]+(track*font.cap if i<len(TXT)-1 else 0) for i,c in enumerate(TXT)]
    tot=sum(advs); out=np.zeros((OH,OW),bool); u=0
    for c,a in zip(TXT,advs):
        u0=u/tot; u1=(u+font.adv[c])/tot; u+=a
        if c==" ": continue
        BL=env_pt(u0,False,v); BR=env_pt(u1,False,v); TL=env_pt(u0,True,v); TR=env_pt(u1,True,v)
        # glyph coords (gx right, gy up from baseline; cap at gy=cap) -> world: least-squares affine through 4 corners
        G=np.array([[0,0,1],[font.adv[c],0,1],[0,font.cap,1],[font.adv[c],font.cap,1]])
        Wd=np.array([BL,BR,TL,TR]); A=np.linalg.lstsq(G,Wd,rcond=None)[0].T      # world = A @ [gx,gy,1]
        # to output pixels: px=(wx-box0)*S, py=(box3-wy)*S ; glyph image pixels: gx=ix-ox, gy=oy-iy
        im,ox,oy=font.img[c]
        M=np.array([[S,0,-box[0]*S],[0,-S,box[3]*S],[0,0,1]]) @ np.vstack([A,[0,0,1]]) @ np.array([[1,0,-ox],[0,-1,oy],[0,0,1]])
        Mi=np.linalg.inv(M)
        g=im.transform((OW,OH),Image.AFFINE,data=tuple(Mi[:2].ravel()),resample=Image.BILINEAR)
        out|=np.array(g)>127
    return out
x0=[432,1402,410,50, 440,1398,545,45, 0.02]   # baseline / cap line: x from-to, centre height, arch drop at the ends
def fit(path):
    font=F(path)
    f=lambda v: -iou(render(font,v),T)
    best=None
    for it in range(2):
        r=minimize(f, x0 if best is None else best.x, method='Nelder-Mead', options=dict(maxiter=1200, xatol=0.05, fatol=1e-6, adaptive=True))
        if best is None or r.fun<best.fun: best=r
    return -best.fun, best.x
if __name__=="__main__":
    files=sys.argv[1:] or sorted(glob.glob('../fonts/*.ttf'))
    res=[]
    for p in files:
        if p.endswith('t.ttf'): continue
        sc,v=fit(p); res.append((sc,os.path.basename(p),list(v)))
        print(f"{sc:.3f} {os.path.basename(p)}", flush=True)
    res.sort(reverse=True); json.dump(res,open('fontwarp_results.json','w'))
    print("TOP"); [print(f"{s:.3f} {n}") for s,n,_ in res[:10]]
