// Shared helpers for the pattern generators: deterministic random numbers, tiling ranges, polygon clipping.
// Use:  use <tiling.scad>   (from the other files in lib/patterns/)
// Frame: every generator works in the XY plane with the pattern anchored at the origin (a cell centre or a
// strand sits on [0, 0]) and covers at least the rectangle `size` centred on the origin. Generators do not
// clip; lib/patterns.scad rotates, shifts and clips them.

// number or [x, y] -> [x, y]
function pat_xy(v) = is_list(v) ? v : [v, v];

// deterministic pseudo-random number in [0, 1) from two integer indices, a seed and a channel k.
// Plain arithmetic (no rands()), so every OpenSCAD version and the browser engine give the same pattern.
function _pat_lcg(x) = (x*48271) % 2147483647;          // MINSTD; every product stays exact in double precision
function pat_hash(i, j, seed=0, k=0) =
    let(a = ((i*73856093 + j*19349663 + seed*83492791 + k*2654435) % 2147483647 + 2147483647) % 2147483647 + 1)
    _pat_lcg(_pat_lcg(_pat_lcg(_pat_lcg(a))))/2147483647;

// index range that covers `extent` (centred on 0) with cells of `pitch`, plus `extra` cells on both sides
function pat_n(extent, pitch, extra=1) = ceil(extent/2/pitch) + extra;

// regular polygon points: n corners on radius r, first corner at angle a0, centred on c
function pat_ngon_pts(n, r, a0=0, c=[0, 0]) = [for (i=[0:n-1]) c + r*[cos(a0 + i*360/n), sin(a0 + i*360/n)]];

// polygon area (signed, counter-clockwise positive)
function pat_area(p) = let(n = len(p)) n < 3 ? 0 : sum([for (i=[0:n-1]) p[i][0]*p[(i+1)%n][1] - p[(i+1)%n][0]*p[i][1]])/2;
function sum(v, i=0) = i >= len(v) ? 0 : v[i] + sum(v, i + 1);

// clip a convex polygon to the half-plane (x - m)·n <= 0 (Sutherland-Hodgman); n need not be unit length
function pat_clip_halfplane(poly, m, n) = let(c = len(poly)) c < 3 ? [] : [
    for (i=[0:c-1]) let(a = poly[i], b = poly[(i+1)%c], da = (a - m)*n, db = (b - m)*n)
        for (p = da <= 0 ? (db <= 0 ? [b] : [a + (b - a)*da/(da - db)])
                         : (db <= 0 ? [a + (b - a)*da/(da - db), b] : [])) p];

// a plate covering `size` (centred) with the listed polygons cut out: the body of every lattice pattern.
// Cutting holes from one plate gives a connected network with the same rib width everywhere.
module pat_plate_with_holes(size, holes) {
    difference() {
        square(size, center=true);
        for (h=holes) if (len(h) >= 3) polygon(h);
    }
}
