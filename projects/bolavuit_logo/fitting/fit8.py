import _env
import numpy as np, glob, os, sys, json, math
from PIL import Image, ImageDraw, ImageFont
from scipy.optimize import minimize
from bvdata import REG
from artfit import mask, iou
S=1.0; box=(690,820,1140,1270)
def circ(c,r,n=360): return [(c[0]+r*math.cos(2*math.pi*i/n), c[1]+r*math.sin(2*math.pi*i/n)) for i in range(n)]
B=json.load(open('ball_fit.json'))['disc']
disc=mask([circ(B[:2],B[2]-3)],box,S)
white=mask([REG[1][0]],box,S,holes=REG[1][1:]) | mask([REG[25][0],REG[27][0]],box,S)
T=disc&~white                                   # the black "8"
ys,xs=np.where(T); pmin=(xs.min()/S+box[0], box[3]-ys.max()/S); pmax=(xs.max()/S+box[0], box[3]-ys.min()/S)
def fit(path):
    font=ImageFont.truetype(path,300); bb=font.getbbox("8",anchor="ls"); w=bb[2]-bb[0]+60; h=bb[3]-bb[1]+60
    im=Image.new('L',(w,h),0); ImageDraw.Draw(im).text((30-bb[0],30-bb[1]),"8",font=font,fill=255,anchor="ls")
    a=np.array(im)>127; gy,gx=np.where(a); gb=(gx.min(),gy.min(),gx.max()+1,gy.max()+1)
    OW,OH=T.shape[1],T.shape[0]
    tx0=(pmin[0]-box[0])*S; tx1=(pmax[0]-box[0])*S; ty0=(box[3]-pmax[1])*S; ty1=(box[3]-pmin[1])*S
    sx=(tx1-tx0)/(gb[2]-gb[0]); sy=(ty1-ty0)/(gb[3]-gb[1]); v0=np.array([sx,0,tx0-sx*gb[0],0,sy,ty0-sy*gb[1]])
    def r(v):
        M=np.array([[v[0],v[1],v[2]],[v[3],v[4],v[5]],[0,0,1]]); Mi=np.linalg.inv(M)
        return np.array(im.transform((OW,OH),Image.AFFINE,data=tuple(Mi[:2].ravel()),resample=Image.BILINEAR))>127
    f=lambda v:-iou(r(v),T)
    st=np.array([0.04*abs(v0[0]),0.04*abs(v0[0]),2,0.04*abs(v0[4]),0.04*abs(v0[4]),2])
    sim=lambda x: np.vstack([x]+[x+np.eye(6)[i]*st[i] for i in range(6)])
    b=minimize(f,v0,method='Nelder-Mead',options=dict(maxiter=3000,adaptive=True,xatol=1e-6,fatol=1e-8,initial_simplex=sim(v0)))
    b=minimize(f,b.x,method='Nelder-Mead',options=dict(maxiter=3000,adaptive=True,xatol=1e-6,fatol=1e-8,initial_simplex=sim(b.x)))
    return -b.fun, b.x, gb
if __name__=="__main__":
    res=[]
    for p in sys.argv[1:]:
        sc,v,gb=fit(p); res.append((sc,os.path.basename(p))); print(f"{sc:.3f} {os.path.basename(p)}", flush=True)
    res.sort(reverse=True); print("TOP", res[:6])
