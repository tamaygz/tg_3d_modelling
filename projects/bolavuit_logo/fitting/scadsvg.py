import re, numpy as np
from PIL import Image, ImageDraw
def polys(svgfile):
    s=open(svgfile).read(); out=[]
    for d in re.findall(r'd="([^"]+)"', s):
        for sub in re.split(r'(?=M)', d):
            pts=[(float(a), -float(b)) for a,b in re.findall(r'(-?[\d.e+-]+),(-?[\d.e+-]+)', sub)]   # OpenSCAD svg: y negated
            if len(pts)>=3: out.append(pts)
    return out
def mask_evenodd(P, box, S):
    x0,y0,x1,y1=box; W=int((x1-x0)*S)+1; H=int((y1-y0)*S)+1; acc=np.zeros((H,W),bool)
    for p in P:
        im=Image.new('L',(W,H),0); ImageDraw.Draw(im).polygon([((x-x0)*S,(y1-y)*S) for x,y in p], fill=255); acc^=np.array(im)>127
    return acc
