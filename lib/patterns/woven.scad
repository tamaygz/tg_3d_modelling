// Woven patterns with real over-under geometry: basket weave (two directions) and tri-weave (three directions).
// Use:  use <../../lib/patterns.scad> and pattern_3d("basket_weave", ...), or use this file for the single generators.
// Frame: XY plane, a crossing on the origin, covers `size` (centred) and a little more; not clipped.
// Z: the weave stands on z = 0 and is `h` high in total. A strand is h - lift thick; where it passes under it
// lies flat on z = 0, where it passes over it climbs by `lift`. Because lift is less than the strand thickness,
// the two strands of a crossing share material and the weave is one solid. Printed flat it needs no supports:
// every raised stretch rests on the strand below it.
// The *_2d modules give the footprint (all strands seen from above) for cut-outs and engraving.
use <tiling.scad>

STRAND_STYLES = ["flat", "rounded"];

// share of a strand's thickness that crossing strands must have in common (the fused part of a crossing)
WEAVE_MIN_FUSE = 0.15;

function weave_lift(h, lift) = is_undef(lift) ? 0.375*h : lift;          // default: 0.6 x the strand thickness
function weave_ok(h, lift) = let(l = weave_lift(h, lift)) l > 0 && l <= (h - l)*(1 - WEAVE_MIN_FUSE);
function weave_msg(h, lift) = str("weave: lift ", weave_lift(h, lift), " must be above 0 and at most ",
    (1 - WEAVE_MIN_FUSE)*100, "% of the strand thickness (h - lift = ", h - weave_lift(h, lift), "), or crossing strands do not fuse");

// cross-section of a strand in (y, z), base on z = 0: flat = rectangle, rounded = rounded top edges
function strand_section(w, t, style="flat") = style == "rounded"
    ? let(r = min(t*0.8, w/2), n = 5) concat([[-w/2, 0], [w/2, 0]],
        [for (i=[0:n]) let(a = i*90/n) [w/2 - r + r*cos(a), t - r + r*sin(a)]],
        [for (i=[0:n]) let(a = 90 + i*90/n) [-w/2 + r + r*cos(a), t - r + r*sin(a)]])
    : [[-w/2, 0], [w/2, 0], [w/2, t], [-w/2, t]];

// height profile of a strand, 0 (under) .. 1 (over): period P, over at x0; flat on top of and under the
// crossing strand for the share `flat` of each half period, smooth ramps between
function weave_wave(x, P, x0=0, flat=0.25) = let(f = abs((((x - x0)/P)%1 + 1.5)%1 - 0.5)*2)
    f <= flat ? 1 : f >= 1 - flat ? 0 : (1 + cos(180*(f - flat)/(1 - 2*flat)))/2;

// one strand along +X, centred on the origin: length L, width w, thickness t, climbing by `lift` at every
// "over" crossing (period P along the strand, an over crossing at x0)
module weave_strand(L, w, t, lift, P, x0=0, style="flat", flat=0.25) {
    k = max(2, ceil(L/(P/12))) + 1;
    sc = strand_section(w, t, style); m = len(sc);
    pts = [for (i=[0:k-1]) let(x = -L/2 + i*L/(k-1)) for (p=sc) [x, p[0], p[1] + lift*weave_wave(x, P, x0, flat)]];
    faces = concat(
        [[for (j=[0:m-1]) j]], [[for (j=[m-1:-1:0]) (k-1)*m + j]],
        [for (i=[0:k-2]) for (j=[0:m-1]) each [[i*m + j, (i+1)*m + j, (i+1)*m + (j+1)%m],
                                                [i*m + j, (i+1)*m + (j+1)%m, i*m + (j+1)%m]]]);
    polyhedron(pts, faces, convexity=4);
}

// ---------- basket weave (plain weave, strips along X and Y) ----------
// cell = strip pitch (centre to centre), strip = strip width (cell - strip is the open gap; 0 = closed weave)
module basket_weave_3d(size, h=2.4, cell=10, strip=7, lift, style="flat") {
    assert(weave_ok(h, lift), weave_msg(h, lift));
    l = weave_lift(h, lift); t = h - l;
    nx = pat_n(size[0], cell); ny = pat_n(size[1], cell);
    Lx = (2*nx + 1)*cell; Ly = (2*ny + 1)*cell;
    for (j=[-ny:ny]) translate([0, j*cell, 0]) weave_strand(Lx, strip, t, l, 2*cell, (abs(j)%2)*cell, style);
    for (i=[-nx:nx]) translate([i*cell, 0, 0]) rotate(90) weave_strand(Ly, strip, t, l, 2*cell, (1 - abs(i)%2)*cell, style);
}
module basket_weave_2d(size, cell=10, strip=7) {
    nx = pat_n(size[0], cell); ny = pat_n(size[1], cell);
    for (j=[-ny:ny]) translate([0, j*cell]) square([(2*nx + 1)*cell, strip], center=true);
    for (i=[-nx:nx]) translate([i*cell, 0]) square([strip, (2*ny + 1)*cell], center=true);
}

// ---------- tri-weave (kagome: strands at 0, 60 and 120 degrees) ----------
// cell = distance between parallel strands, strand = strand width (must stay below cell/3 to leave the small
// triangles open). Every strand passes over the next family and under the one after: 0 over 60, 60 over 120,
// 120 over 0, which is the classic triaxial cane weave with hexagonal and triangular openings.
TRI_ANGLES = [0, 60, 120];
TRI_SHIFT  = [0, 0, 0.5];          // the third family is shifted half a cell, so only two strands meet at a point
function tri_weave_opening(cell, strand) = cell/3 - strand;     // width left of the small triangular openings
// position along strand m of family a where it crosses line 0 of family b
function _tri_cross(cell, a, m, b) = cell*(TRI_SHIFT[b] - (m + TRI_SHIFT[a])*cos(TRI_ANGLES[b] - TRI_ANGLES[a]))/sin(TRI_ANGLES[a] - TRI_ANGLES[b]);
module _tri_family(size, cell, a, w) {
    R = norm(size)/2 + cell; n = ceil(R/cell) + 1;
    for (m=[-n:n]) rotate(TRI_ANGLES[a]) translate([0, (m + TRI_SHIFT[a])*cell]) children();
}
module tri_weave_3d(size, h=2.4, cell=24, strand=3, lift, style="flat") {
    assert(weave_ok(h, lift), weave_msg(h, lift));
    l = weave_lift(h, lift); t = h - l;
    R = norm(size)/2 + cell; n = ceil(R/cell) + 1; P = cell/sin(60);
    for (a=[0:2]) for (m=[-n:n])
        rotate(TRI_ANGLES[a]) translate([0, (m + TRI_SHIFT[a])*cell, 0])
            weave_strand(2*R, strand, t, l, P, _tri_cross(cell, a, m, (a + 1)%3), style, 0.2);
}
module tri_weave_2d(size, cell=24, strand=3) {
    R = norm(size)/2 + cell; n = ceil(R/cell) + 1;
    for (a=[0:2]) for (m=[-n:n])
        rotate(TRI_ANGLES[a]) translate([0, (m + TRI_SHIFT[a])*cell]) square([2*R, strand], center=true);
}
