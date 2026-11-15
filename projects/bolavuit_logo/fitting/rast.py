import numpy as np
from PIL import Image, ImageDraw
def mask(polys, box, s=1.0, holes=()):
    """rasterise polygons (lists of (x,y), y up) inside box=(x0,y0,x1,y1) at scale s; holes XOR'd"""
    x0,y0,x1,y1 = box; W=int((x1-x0)*s)+1; H=int((y1-y0)*s)+1
    im = Image.new('L',(W,H),0); d = ImageDraw.Draw(im)
    for p in polys:
        if len(p) >= 3: d.polygon([((x-x0)*s, (y1-y)*s) for x,y in p], fill=255)
    for p in holes:
        if len(p) >= 3: d.polygon([((x-x0)*s, (y1-y)*s) for x,y in p], fill=0)
    return np.array(im) > 127
def iou(a,b): return (a&b).sum()/max(1,(a|b).sum())
