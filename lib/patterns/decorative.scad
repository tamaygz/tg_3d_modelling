// Decorative patterns: fish scales, Truchet arcs, Girih star & cross.
// Use:  use <../../lib/patterns.scad> and pattern_2d("fish_scales", ...), or use this file for the single generators.
// Frame: XY plane, anchored on the origin, covers `size` (centred) and a little more; not clipped.
// The *_2d modules return the MATERIAL of the line pattern (scale edges, arcs, straps).
use <tiling.scad>

TRUCHET_VARIATIONS = ["random", "alternate", "rows", "uniform"];
FISH_STEP_GAP = 0.03;          // mm the upper shingle steps are pulled in (keeps touching rims apart)

// ---------- fish scales ----------
// cell = [scale width, scale height]. Scales hang tip-down in rows; each row covers the top of the row below
// by `overlap` (share of the height). curvature 0.2..1 = share of the height taken by the round tip (1 = no
// straight sides). stagger shifts every other row (0.5 = classic).
function fish_scale_pts(w, h, curvature=0.7, grow=0, n=20) = let(he = h*curvature)
    concat([[-w/2 - grow, grow], [-w/2 - grow, -(h - he)]],
           [for (i=[1:n-1]) let(a = 180 + i*180/n) [(w/2 + grow)*cos(a), -(h - he) + (he + grow)*sin(a)]],
           [[w/2 + grow, -(h - he)], [w/2 + grow, grow]]);
function fish_row_pitch(cell, overlap=0.4) = pat_xy(cell)[1]*(1 - overlap);
// all scales of row j (their full shapes, grown by `grow`); shift moves them up
module fish_row_2d(size, j, cell, overlap=0.4, curvature=0.7, stagger=0.5, grow=0, shift=0, center=[0, 0]) {
    c = pat_xy(cell);
    for (i=[pat_i0(size[0], c[0], center[0]):pat_i1(size[0], c[0], center[0])]) translate([(i + (abs(j)%2)*stagger)*c[0], j*fish_row_pitch(cell, overlap) + c[1]/2 + shift])
        polygon(fish_scale_pts(c[0], c[1], curvature, grow));
}
// the part of row j that shows: its scales minus the rows above, which lie on top of it
module fish_visible_2d(size, j, cell, overlap=0.4, curvature=0.7, stagger=0.5, center=[0, 0]) {
    cover = ceil(1/(1 - overlap)) - 1;                    // how many rows above reach down onto this one
    difference() {
        fish_row_2d(size, j, cell, overlap, curvature, stagger, 0, 0, center);
        for (k=[1:1:cover]) fish_row_2d(size, j + k, cell, overlap, curvature, stagger, 0, 0, center);
    }
}
// line pattern: the visible edge of every scale, `strut` wide
module fish_scales_2d(size, cell=[12, 12], strut=0.8, overlap=0.4, curvature=0.7, stagger=0.5, center=[0, 0]) {
    rp = fish_row_pitch(cell, overlap);
    cover = ceil(1/(1 - overlap)) - 1;
    for (j=[pat_i0(size[1], rp, center[1], 2):pat_i1(size[1], rp, center[1], 2)]) difference() {
        fish_row_2d(size, j, cell, overlap, curvature, stagger, strut/2, 0, center);
        fish_row_2d(size, j, cell, overlap, curvature, stagger, -strut/2, 0, center);
        for (k=[1:1:cover]) fish_row_2d(size, j + k, cell, overlap, curvature, stagger, -strut/2, 0, center);
    }
}
// shingle relief, level k of `steps` (1 = lowest, covers everything): each scale rises towards its tip in steps.
// Extrude level k from 0 to k/steps of the relief height (lib/patterns.scad does this).
module fish_scales_level_2d(size, k, steps=3, cell=[12, 12], overlap=0.4, curvature=0.7, stagger=0.5, center=[0, 0]) {
    rp = fish_row_pitch(cell, overlap);
    d = fish_row_pitch(cell, overlap)*(steps - k + 1)/steps;      // the rim left at this level is this deep
    // the upper levels are pulled in by a hair: rims of neighbouring scales would otherwise touch in single
    // points, which is not a printable (manifold) solid
    offset(delta=k > 1 ? -FISH_STEP_GAP : 0) for (j=[pat_i0(size[1], rp, center[1], 2):pat_i1(size[1], rp, center[1], 2)]) difference() {
        fish_visible_2d(size, j, cell, overlap, curvature, stagger, center);
        if (k > 1) fish_row_2d(size, j, cell, overlap, curvature, stagger, 0, d, center);
    }
}

// ---------- Truchet arcs ----------
// Square tiles of `cell`, each with two quarter rings (width `strut`) around opposite corners. The rings end on
// the middle of the tile edges, so neighbouring tiles always join into continuous paths.
// variation: "random" (per tile from the seed; bias = share of tiles turned the other way), "alternate"
// (checkerboard: circles), "rows", "uniform" (diagonal waves).
function truchet_flip(i, j, variation="random", seed=1, bias=0.5) =
    variation == "alternate" ? (abs(i) + abs(j))%2 == 1 :
    variation == "rows" ? abs(j)%2 == 1 :
    variation == "uniform" ? false : pat_hash(i, j, seed, 2) < bias;
function _arc_band_pts(c, r, w, a0, a1, n=14) = concat(
    [for (i=[0:n]) c + (r + w/2)*[cos(a0 + (a1 - a0)*i/n), sin(a0 + (a1 - a0)*i/n)]],
    [for (i=[n:-1:0]) c + (r - w/2)*[cos(a0 + (a1 - a0)*i/n), sin(a0 + (a1 - a0)*i/n)]]);
module truchet_arcs_2d(size, cell=12, strut=1.6, variation="random", seed=1, bias=0.5, center=[0, 0]) {
    e = 0.3;                                                            // e: degrees of overlap between tiles
    for (j=[pat_i0(size[1], cell, center[1]):pat_i1(size[1], cell, center[1])])
    for (i=[pat_i0(size[0], cell, center[0]):pat_i1(size[0], cell, center[0])]) translate([i*cell, j*cell])
        for (q = truchet_flip(i, j, variation, seed, bias) ? [[-1, 1, 270], [1, -1, 90]] : [[-1, -1, 0], [1, 1, 180]])
            polygon(_arc_band_pts([q[0], q[1]]*cell/2, cell/2, strut, q[2] - e, q[2] + 90 + e));
}

// ---------- Girih star & cross ----------
// The classic star-and-cross strapwork: eight-point stars on a square grid of pitch `cell`, touching at their
// tips; the gaps between four stars are the four-armed crosses. The straps follow the star outlines, `strut` wide.
// star = star diameter tip to tip (default = cell: stars touch). With star < cell, straight straps join the tips.
// star_ratio = inner corner radius / tip radius (default 0.765 = two overlapping squares, the true 8/2 star).
GIRIH_RATIO = cos(45)/cos(22.5);
function girih_star_pts(R, ratio=GIRIH_RATIO) = [for (i=[0:15]) (i%2 == 0 ? R : R*ratio)*[cos(i*22.5), sin(i*22.5)]];
// distance of the star's edges from its centre: growing the star by d scales it by (edge + d)/edge
function girih_edge_dist(R, ratio=GIRIH_RATIO) = let(p = girih_star_pts(R, ratio)) abs(p[0][0]*p[1][1] - p[1][0]*p[0][1])/norm(p[1] - p[0]);
module girih_star_cross_2d(size, cell=24, strut=1.6, star, star_ratio, center=[0, 0]) {
    D = is_undef(star) ? cell : star; R = D/2;
    ratio = is_undef(star_ratio) ? GIRIH_RATIO : star_ratio;
    assert(D <= cell + 0.001, str("girih_star_cross: star ", D, " is larger than the repeat spacing ", cell));
    d = girih_edge_dist(R, ratio);
    for (j=[pat_i0(size[1], cell, center[1]):pat_i1(size[1], cell, center[1])])
    for (i=[pat_i0(size[0], cell, center[0]):pat_i1(size[0], cell, center[0])]) translate([i*cell, j*cell]) {
        polygon(concat(girih_star_pts(R*(d + strut/2)/d, ratio), girih_star_pts(R*(d - strut/2)/d, ratio)),
                [[for (k=[0:15]) k], [for (k=[16:31]) k]]);
        if (cell - D > 0.001) for (a=[0, 90]) rotate(a) translate([cell/2, 0]) square([cell - D + strut, strut], center=true);
    }
}
