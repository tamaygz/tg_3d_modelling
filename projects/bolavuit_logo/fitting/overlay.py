import sys, numpy as np
from PIL import Image
from scadsvg import polys, mask_evenodd
SP='/tmp/claude-0/-home-user/01847bc7-7a3d-5b03-975c-4cb2e551f995/scratchpad'
M=mask_evenodd(polys(sys.argv[1]), (0,0,1809,1716), 1.0)[:1716,:1809]
O=np.array(Image.open('/home/user/tg_3d_modelling/projects/bolavuit_logo/reference/bolavuit.png').convert('L'))>128
im=np.zeros(O.shape+(3,),np.uint8)
im[O&~M]=(150,150,150); im[M&~O]=(230,40,40); im[M&O]=(255,235,235)
Image.fromarray(im).resize((904,858), Image.LANCZOS).save(sys.argv[2])
inter=(M&O).sum(); print("overall IoU vs original: %.3f" % (inter/(M|O).sum()))
