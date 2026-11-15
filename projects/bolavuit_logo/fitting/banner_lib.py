import _env
import numpy as np
X0 = 913.68                              # banner centre line (mirror axis)
def qbez(p0, c, p1, n=24):
    t = np.linspace(0, 1, n+1)[:, None]
    return ((1-t)**2*np.array(p0) + 2*(1-t)*t*np.array(c) + t*t*np.array(p1)).tolist()
def band(v, n=40):
    hwt, hwb, yt, st, yb, sb, bulge = v
    top = [(X0 + x, yt - st*(x/hwt)**2) for x in np.linspace(-hwt, hwt, n)]
    rend = qbez((X0+hwt, yt-st), (X0 + (hwt+hwb)/2 + bulge, (yt-st+yb-sb)/2), (X0+hwb, yb-sb))[1:-1]
    bot = [(X0 + x, yb - sb*(x/hwb)**2) for x in np.linspace(hwb, -hwb, n)]
    lend = qbez((X0-hwb, yb-sb), (X0 - (hwt+hwb)/2 - bulge, (yt-st+yb-sb)/2), (X0-hwt, yt-st))[1:-1]
    return top + rend + bot + lend
def mirror(poly): return [(2*X0 - x, y) for x, y in poly][::-1]
def tail(v):             # left tail interior: A -(c1)-> T1 -> N -> T2 -(c2)-> B
    Ax,Ay,c1x,c1y,T1x,T1y,Nx,Ny,T2x,T2y,c2x,c2y,Bx,By = v
    return qbez((Ax,Ay),(c1x,c1y),(T1x,T1y)) + [(Nx,Ny)] + qbez((T2x,T2y),(c2x,c2y),(Bx,By))
def tail2(v):            # all five edges quadratic: A-c1-T1-c3-N-c4-T2-c2-B-c5-A
    Ax,Ay,c1x,c1y,T1x,T1y,Nx,Ny,T2x,T2y,c2x,c2y,Bx,By,c3x,c3y,c4x,c4y,c5x,c5y = v
    return (qbez((Ax,Ay),(c1x,c1y),(T1x,T1y)) + qbez((T1x,T1y),(c3x,c3y),(Nx,Ny))[1:] +
            qbez((Nx,Ny),(c4x,c4y),(T2x,T2y))[1:] + qbez((T2x,T2y),(c2x,c2y),(Bx,By))[1:] + qbez((Bx,By),(c5x,c5y),(Ax,Ay))[1:-1])
def leaf(L, W, p=0.62, bend=0.0, n=40):
    t = np.linspace(0, 1, n+1)
    hw = W/2*np.sin(np.pi*t)**p; bx = bend*L*t*t
    return [(bx[i]+hw[i], t[i]*L) for i in range(n+1)] + [(bx[i]-hw[i], t[i]*L) for i in range(n-1, 0, -1)]
def place(pts, x, y, ang):
    a = np.radians(ang-90); c, s = np.cos(a), np.sin(a)
    return [(x+c*px-s*py, y+s*px+c*py) for px, py in pts]
def taper_ribbon(p0, c, p1, w0, w1, n=24):
    t = np.linspace(0, 1, n+1)[:, None]
    P = (1-t)**2*np.array(p0) + 2*(1-t)*t*np.array(c) + t*t*np.array(p1)
    D = np.gradient(P, axis=0); N = np.c_[-D[:,1], D[:,0]]; N /= np.linalg.norm(N, axis=1)[:, None]
    w = (w0 + (w1-w0)*t)/2
    return (P + N*w).tolist() + (P - N*w)[::-1].tolist()
def loops(v):   # [base x offset from centre, base y, angle (deg from +x, left loop), L, W, p, bend]
    bx, by, ang, L, W, p, bend = v
    left = place(leaf(L, W, p, bend), X0 - bx, by, 180 - ang)
    return [left, mirror(left)]
def legs(v):    # [top x off, top y, ctrl x off, ctrl y, foot x off, foot y, w0, w1] (left leg goes to the right foot: they cross)
    tx, ty, cx, cy, fx, fy, w0, w1 = v
    a = taper_ribbon((X0 - tx, ty), (X0 + cx, cy), (X0 + fx, fy), w0, w1)
    return [a, mirror(a)]
def qpoly(pts, ctrls):    # closed polygon, edge i from pts[i] to pts[i+1] with quadratic control ctrls[i]
    out = []
    for i in range(len(pts)):
        out += qbez(pts[i], ctrls[i], pts[(i+1) % len(pts)], 16)[:-1]
    return out
def fold(v):              # left fold piece: 4 corners + 4 controls
    P = np.array(v).reshape(8, 2)
    return qpoly(P[:4].tolist(), P[4:].tolist())
def strip(v):             # centre strip, symmetric: left end L, top middle, (mirror right end), bottom V middle
    a, y1, y2, y3, c1x, c1y, c2x, c2y = v
    L = (X0 - a, y1); Tm = (X0, y2); R = (X0 + a, y1); Bm = (X0, y3)
    return qpoly([L, Tm, R, Bm], [(X0 - c1x, c1y), (X0 + c1x, c1y), (X0 + c2x, c2y), (X0 - c2x, c2y)])
def ear(v):               # left ear: tip, upper base, lower base with controls on the two long edges
    tx, ty, ux, uy, lx, ly, c1x, c1y, c2x, c2y = v
    return qbez((tx, ty), (c1x, c1y), (ux, uy)) + [(lx, ly)] + qbez((lx, ly), (c2x, c2y), (tx, ty))[1:-1]
def region(v):            # rough area, trimmed later by the pieces in front: 4 corners
    return np.array(v).reshape(4, 2).tolist()
