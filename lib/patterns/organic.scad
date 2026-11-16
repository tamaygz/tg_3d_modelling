// Organic patterns: Voronoi cell network.
// Use:  use <../../lib/patterns.scad> and pattern_2d("voronoi", ...), or use this file for the single generator.
// Frame: XY plane, covers `size` (centred) and a little more; not clipped. Returns the MATERIAL (the cell walls).
//
// Method (deterministic and bounded): one site per square of a grid with pitch `cell`, moved by up to half a
// cell (`irregularity` 0 = square grid .. 1 = fully irregular). A site's Voronoi cell is cut from a square by the
// bisector to each of the 24 sites around it, which is exact for this kind of site set. Shifting every bisector
// by strut/2 gives all walls the same width, and cutting the cells out of one plate keeps the network connected.
// The pattern depends only on the grid indices and the seed: the same seed always gives the same geometry, and a
// larger `size` only adds cells around the same centre.
// Limits: cell sizes vary around `cell` (about 0.5x to 1.5x); there is no relaxation step, so high irregularity
// gives some small or slim cells. `min_cell` fills in cells that would be smaller (their area stays solid).
use <tiling.scad>

// wrap = n > 0 makes the pattern repeat every n cells along X (the random numbers are taken from column i mod n),
// so it closes without a seam on a wall that is n cells round.
function voronoi_site(i, j, cell, seed=1, irregularity=1, wrap=0) = let(k = wrap > 0 ? (i%wrap + wrap)%wrap : i)
    cell*[i + 0.5 + irregularity*(pat_hash(k, j, seed, 0) - 0.5), j + 0.5 + irregularity*(pat_hash(k, j, seed, 1) - 0.5)];
function _vor_clip(poly, s, nb, inset, k=0) = k >= len(nb) || len(poly) < 3 ? poly :
    let(d = nb[k] - s, n = d/norm(d)) _vor_clip(pat_clip_halfplane(poly, (s + nb[k])/2 - n*inset, n), s, nb, inset, k + 1);
// opening of cell (i, j): its Voronoi polygon moved in by strut/2 on every side ([] if nothing is left)
function voronoi_cell_pts(i, j, cell, strut, seed=1, irregularity=1, wrap=0) = let(
    s = voronoi_site(i, j, cell, seed, irregularity, wrap), q = 2.5*cell,
    nb = [for (dj=[-2:2]) for (di=[-2:2]) if (di != 0 || dj != 0) voronoi_site(i + di, j + dj, cell, seed, irregularity, wrap)])
    _vor_clip([s + [-q, -q], s + [q, -q], s + [q, q], s + [-q, q]], s, nb, strut/2);
function voronoi_holes(size, cell=14, strut=1.5, seed=1, irregularity=1, min_cell=0, center=[0, 0], wrap=0) = let(
    nx = pat_n(size[0], cell), ny = pat_n(size[1], cell), ic = floor(center[0]/cell), jc = floor(center[1]/cell))
    [for (j=[jc-ny:jc+ny]) for (i=[ic-nx:ic+nx]) let(p = voronoi_cell_pts(i, j, cell, strut, seed, irregularity, wrap))
        if (len(p) >= 3 && sqrt(abs(pat_area(p))) >= min_cell) p];
// round = corner radius of the openings (0 = sharp polygons)
module voronoi_2d(size, cell=14, strut=1.5, seed=1, irregularity=1, min_cell=0, round=0, center=[0, 0], wrap=0) {
    difference() {
        translate(center) square(size + [2*cell, 2*cell], center=true);
        for (h = voronoi_holes(size, cell, strut, seed, irregularity, min_cell, center, wrap))
            if (round > 0) offset(r=round, $fn=16) offset(delta=-round) polygon(h); else polygon(h);
    }
}
