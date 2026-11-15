import _env
import numpy as np, json, subprocess
from PIL import Image, ImageFont
from scipy.optimize import minimize
import fontaffine as FA
from artfit import iou
FONT=str(_env.FONTS / 'BookSerif-Bold.ttf'); FN="Book Serif:style=Bold"
font=ImageFont.truetype(FONT,200); S=FA.S
SP=_env.TMP
def scad_bbox(s):
    open(f'{SP}/g.scad','w').write(f'use <{FONT}>\nlinear_extrude(1) text("{s}", size=100, font="{FN}", halign="left", valign="baseline");\n')
    subprocess.run(['openscad','-o',f'{SP}/g.stl',f'{SP}/g.scad'],capture_output=True)
    xs=[];ys=[]
    for line in open(f'{SP}/g.stl'):
        t=line.split()
        if t and t[0]=='vertex': xs.append(float(t[1])); ys.append(float(t[2]))
    return min(xs),min(ys),max(xs),max(ys)
prev=json.load(open('letters_ss4.json'))
out={k:v for k,v in prev.items() if k not in ("LA","VU")}
for k,(box,T,pair,pmin,pmax) in enumerate(FA.TG):
    if pair not in ("LA","VU"): continue
    OW,OH=T.shape[1],T.shape[0]
    Wd=np.array([[1/S,0,box[0]],[0,-1/S,box[3]],[0,0,1]]); Wi=np.linalg.inv(Wd)
    # start: each letter takes its share of the pair's world matrix, offset by its position inside the pair (OpenSCAD units)
    A_pair=np.vstack([np.array(prev[pair]),[0,0,1]])
    bb_pair=scad_bbox(pair); glyphs=[]
    for ch in pair:
        im,_=FA.glyph(font,ch); arr=np.array(im)>127; yy,xx=np.where(arr); gb=(xx.min(),yy.min(),xx.max()+1,yy.max()+1)
        x0,y0,x1,y1=scad_bbox(ch)
        G=np.array([[(gb[2]-gb[0])/(x1-x0),0,gb[0]-x0*(gb[2]-gb[0])/(x1-x0)],[0,-(gb[3]-gb[1])/(y1-y0),gb[3]+y0*(gb[3]-gb[1])/(y1-y0)],[0,0,1]])
        glyphs.append((ch,im,G,(x0,y0,x1,y1)))
    # where each letter sits inside the pair string in OpenSCAD units: find by bbox of the pair and of the single glyph
    start=[]
    for idx,(ch,im,G,bb) in enumerate(glyphs):
        dx = bb_pair[0]-bb[0] if idx==0 else bb_pair[2]-bb[2]      # first letter: left edges align; second: right edges align
        A=A_pair@np.array([[1,0,dx],[0,1,0],[0,0,1]])
        start.append(A[:2].ravel())
    v0=np.concatenate(start)
    def r(v):
        acc=np.zeros((OH,OW),bool)
        for j,(ch,im,G,bb) in enumerate(glyphs):
            A=np.vstack([v[6*j:6*j+6].reshape(2,3),[0,0,1]])
            M=Wi@A@np.linalg.inv(G)                  # image pixel -> output pixel
            Mi=np.linalg.inv(M)
            acc|=np.array(im.transform((OW,OH),Image.AFFINE,data=tuple(Mi[:2].ravel()),resample=Image.BILINEAR))>127
        return acc
    f=lambda v:-iou(r(v),T)
    st=np.array([0.04,0.04,2,0.04,0.04,2]*2)*np.r_[[abs(v0[0])]*2+[1]+[abs(v0[4])]*2+[1]+[abs(v0[6])]*2+[1]+[abs(v0[10])]*2+[1]]
    sim=lambda x: np.vstack([x]+[x+np.eye(12)[i]*st[i] for i in range(12)])
    print(pair,"start IoU %.3f" % -f(v0), flush=True)
    b=minimize(f,v0,method='Nelder-Mead',options=dict(maxiter=8000,xatol=1e-6,fatol=1e-8,adaptive=True,initial_simplex=sim(v0)))
    for _ in range(2): b=minimize(f,b.x,method='Nelder-Mead',options=dict(maxiter=8000,xatol=1e-6,fatol=1e-8,adaptive=True,initial_simplex=sim(b.x)))
    print(pair,"split IoU %.3f" % -b.fun, flush=True)
    for j,(ch,_,_,_) in enumerate(glyphs): out[ch]=b.x[6*j:6*j+6].reshape(2,3).round(5).tolist()
order=["B","O","L","A","V","U","I","T"]
json.dump({k:out[k] for k in order if k in out}, open('letters_ss4_split.json','w'))
print(list(out))
