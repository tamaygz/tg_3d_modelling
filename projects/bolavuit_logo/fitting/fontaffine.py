import numpy as np, glob, os, sys, json
from PIL import Image, ImageDraw, ImageFont
from scipy.optimize import minimize
from bvdata import REG
from rast import mask, iou
GROUPS=[(24,"B"),(21,"O"),(23,"LA"),(22,"VU"),(28,"I"),(26,"T")]
S=0.5
TG=[]
for i,s in GROUPS:
    P=np.array([p for c in REG[i] for p in c]); x0,y0=P.min(0)-25; x1,y1=P.max(0)+25
    box=(x0,y0,x1,y1); TG.append((box, mask(REG[i][:1],box,S,holes=REG[i][1:]), s, P.min(0), P.max(0)))
def glyph(font, s):
    bb=font.getbbox(s, anchor="ls"); w=bb[2]-bb[0]+40; h=bb[3]-bb[1]+40
    im=Image.new('L',(w,h),0); ImageDraw.Draw(im).text((20-bb[0], 20-bb[1]), s, font=font, fill=255, anchor="ls")
    return im, (20, 20, 20+bb[2]-bb[0], 20+bb[3]-bb[1])   # glyph ink box in image pixels
def fit_group(im, gb, tgt):
    box,T,s,pmin,pmax=tgt; OW,OH=T.shape[1],T.shape[0]
    # init: map glyph ink box onto the target bbox (output pixels)
    tx0=(pmin[0]-box[0])*S; tx1=(pmax[0]-box[0])*S; ty0=(box[3]-pmax[1])*S; ty1=(box[3]-pmin[1])*S
    sx=(tx1-tx0)/(gb[2]-gb[0]); sy=(ty1-ty0)/(gb[3]-gb[1])
    v0=[sx,0,tx0-sx*gb[0], 0,sy,ty0-sy*gb[1]]
    def r(v):
        M=np.array([[v[0],v[1],v[2]],[v[3],v[4],v[5]],[0,0,1]]); Mi=np.linalg.inv(M)
        return np.array(im.transform((OW,OH),Image.AFFINE,data=tuple(Mi[:2].ravel()),resample=Image.BILINEAR))>127
    f=lambda v: -iou(r(v),T)
    def simplex(v):
        st=np.array([0.05*abs(v[0]), 0.06*abs(v[0]), 3, 0.06*abs(v[4]), 0.05*abs(v[4]), 3]); return np.vstack([v]+[v+np.eye(6)[i]*st[i] for i in range(6)])
    best=None
    for start in (v0, v0):
        x=start if best is None else best.x
        rr=minimize(f, x, method='Nelder-Mead', options=dict(maxiter=2500, xatol=1e-5, fatol=1e-7, adaptive=True, initial_simplex=simplex(np.array(x))))
        if best is None or rr.fun<best.fun: best=rr
    return -best.fun
if __name__ == '__main__':
  res=[]
  for p in sorted(sys.argv[1:] or glob.glob('../fonts/*.ttf')):
      if p.endswith('/t.ttf'): continue
      font=ImageFont.truetype(p, 200)
      sc=[fit_group(*glyph(font,t[2]), t) for t in TG]
      res.append((np.mean(sc), os.path.basename(p), sc))
      print(f"{np.mean(sc):.3f} {os.path.basename(p):28s} " + " ".join(f"{t[2]}:{x:.2f}" for t,x in zip(TG,sc)), flush=True)
  res.sort(reverse=True)
  print("TOP"); [print(f"{s:.3f} {n}") for s,n,_ in res[:10]]
  json.dump([(float(a),b,[float(x) for x in c]) for a,b,c in res], open('fontaffine.json','w'))
