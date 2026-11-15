import _env
import numpy as np, json, subprocess, os
from PIL import Image, ImageFont
from scipy.optimize import minimize
import fontaffine as FA
from artfit import iou
FONT=str(_env.FONTS / 'BookSerif-Bold.ttf')
font=ImageFont.truetype(FONT,200); S=FA.S
SP=_env.TMP
def scad_bbox(s):
    open(f'{SP}/g.scad','w').write(f'use <{FONT}>\nlinear_extrude(1) text("{s}", size=100, font="Book Serif:style=Bold", halign="left", valign="baseline");\n')
    subprocess.run(['openscad','-o',f'{SP}/g.stl',f'{SP}/g.scad'],capture_output=True)
    xs=[];ys=[]
    for line in open(f'{SP}/g.stl'):
        t=line.split()
        if t and t[0]=='vertex': xs.append(float(t[1])); ys.append(float(t[2]))
    return min(xs),min(ys),max(xs),max(ys)
out={}
for k,(box,T,s,pmin,pmax) in enumerate(FA.TG):
    im,gb=FA.glyph(font,s); OW,OH=T.shape[1],T.shape[0]
    tx0=(pmin[0]-box[0])*S; tx1=(pmax[0]-box[0])*S; ty0=(box[3]-pmax[1])*S; ty1=(box[3]-pmin[1])*S
    sx=(tx1-tx0)/(gb[2]-gb[0]); sy=(ty1-ty0)/(gb[3]-gb[1]); v0=[sx,0,tx0-sx*gb[0],0,sy,ty0-sy*gb[1]]
    def r(v):
        M=np.array([[v[0],v[1],v[2]],[v[3],v[4],v[5]],[0,0,1]]); Mi=np.linalg.inv(M)
        return np.array(im.transform((OW,OH),Image.AFFINE,data=tuple(Mi[:2].ravel()),resample=Image.BILINEAR))>127
    f=lambda v:-iou(r(v),T)
    def simplex(v):
        st=np.array([0.05*abs(v[0]), 0.06*abs(v[0]), 3, 0.06*abs(v[4]), 0.05*abs(v[4]), 3]); return np.vstack([v]+[v+np.eye(6)[i]*st[i] for i in range(6)])
    b=minimize(f,v0,method='Nelder-Mead',options=dict(maxiter=4000,xatol=1e-5,fatol=1e-7,adaptive=True,initial_simplex=simplex(np.array(v0))))
    for _ in range(2): b=minimize(f,b.x,method='Nelder-Mead',options=dict(maxiter=4000,xatol=1e-5,fatol=1e-7,adaptive=True,initial_simplex=simplex(b.x)))
    v=b.x; M=np.array([[v[0],v[1],v[2]],[v[3],v[4],v[5]],[0,0,1]])
    # image pixels of the glyph ink box: gb = (x0, y0, x1, y1) with y down; OpenSCAD ink box (y up)
    arr=np.array(im)>127; yy,xx=np.where(arr); gb=(xx.min(), yy.min(), xx.max()+1, yy.max()+1)   # real ink box (pixels)
    x0,y0,x1,y1=scad_bbox(s)
    # OpenSCAD glyph (sx, sy) -> glyph image pixel: ink boxes matched (y flipped)
    G=np.array([[(gb[2]-gb[0])/(x1-x0),0,gb[0]-x0*(gb[2]-gb[0])/(x1-x0)],
                [0,-(gb[3]-gb[1])/(y1-y0),gb[3]+y0*(gb[3]-gb[1])/(y1-y0)],[0,0,1]])
    Wd=np.array([[1/S,0,box[0]],[0,-1/S,box[3]],[0,0,1]])      # output pixel -> world (px, y up)
    A=Wd@M@G
    out[s]=A[:2].round(5).tolist()
    print(f"{s:3s} IoU {-b.fun:.3f}  matrix {A[:2].round(4).tolist()}", flush=True)
json.dump(out,open('letters_ss4.json','w'))
