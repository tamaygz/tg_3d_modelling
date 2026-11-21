// Geometric lattices: hex honeycomb, square grid, diamond lattice, triangular lattice, cube rosette.
// Use:  use <../../lib/patterns.scad> and pattern_2d("hex_honeycomb", ...), or use this file for the single generators.
// Frame: XY plane, a cell centre on the origin, covers `size` (centred) and a little more; not clipped.
// Each generator returns the MATERIAL (the ribs) as one connected 2D shape: a plate with the cells cut out.
// `cell` is the repeat pitch (centre to centre), `strut` the rib width, so an opening is cell - strut wide.
use <tiling.scad>

HEX_ORIENTS = ["pointy", "flat"];
TRI_ORIENTS = ["up", "side"];
CUBE_DENSITIES = ["sparse", "dense", "all", "none"];

// ---------- hex honeycomb ----------
// cell = distance between the centres of neighbouring cells (= hexagon across flats + strut).
// orient: "pointy" = corners up (rows staggered), "flat" = flats up (columns staggered).
function hex_honeycomb_holes(size, cell=12, strut=1.5, center=[0, 0]) = let(
    r = (cell - strut)/sqrt(3),                    // corner radius of an opening
    dy = cell*sqrt(3)/2)
    [for (j=[pat_i0(size[1], dy, center[1]):pat_i1(size[1], dy, center[1])])
     for (i=[pat_i0(size[0], cell, center[0]):pat_i1(size[0], cell, center[0])]) pat_ngon_pts(6, r, 30, [(i + (abs(j)%2)/2)*cell, j*dy])];
module hex_honeycomb_2d(size, cell=12, strut=1.5, orient="pointy", center=[0, 0]) {
    flat = orient == "flat";
    s = flat ? [size[1], size[0]] : size;
    c = flat ? pat_rot(center, -90) : center;
    rotate(flat ? 90 : 0) pat_plate_with_holes(s + [2*cell, 2*cell], hex_honeycomb_holes(s, cell, strut, c), c);
}

// ---------- square grid ----------
// cell = [pitch x, pitch y] (or one number), strut = [vertical rib width, horizontal rib width] (or one number).
// stagger = 0..0.5 shifts every other row by that share of a cell (0.5 = brick pattern).
function square_grid_holes(size, cell=10, strut=1.5, stagger=0, center=[0, 0]) = let(
    c = pat_xy(cell), s = pat_xy(strut), w = c[0] - s[0], h = c[1] - s[1])
    [for (j=[pat_i0(size[1], c[1], center[1]):pat_i1(size[1], c[1], center[1])])
     for (i=[pat_i0(size[0], c[0], center[0]):pat_i1(size[0], c[0], center[0])]) let(x = (i + (abs(j)%2)*stagger)*c[0], y = j*c[1])
        [[x - w/2, y - h/2], [x + w/2, y - h/2], [x + w/2, y + h/2], [x - w/2, y + h/2]]];
module square_grid_2d(size, cell=10, strut=1.5, stagger=0, center=[0, 0]) {
    c = pat_xy(cell);
    pat_plate_with_holes(size + 2*c, square_grid_holes(size, cell, strut, stagger, center), center);
}

// ---------- diamond lattice ----------
// cell = [diamond width, diamond height] between rib centre lines (or one number for squares on their corner).
// The ribs run diagonally and all have the width `strut`.
function diamond_inset(cell, strut) = let(c = pat_xy(cell), d0 = c[0]*c[1]/4/norm(c/2)) (d0 - strut/2)/d0;   // scale of the opening
function diamond_lattice_holes(size, cell=[12, 18], strut=1.5, center=[0, 0]) = let(
    c = pat_xy(cell), k = diamond_inset(cell, strut), a = k*c[0]/2, b = k*c[1]/2)
    [for (j=[pat_i0(size[1], c[1], center[1]):pat_i1(size[1], c[1], center[1])])
     for (i=[pat_i0(size[0], c[0], center[0]):pat_i1(size[0], c[0], center[0])]) for (o=[0, 0.5]) let(x = (i + o)*c[0], y = (j + o)*c[1])
        [[x + a, y], [x, y + b], [x - a, y], [x, y - b]]];
module diamond_lattice_2d(size, cell=[12, 18], strut=1.5, center=[0, 0]) {
    c = pat_xy(cell);
    pat_plate_with_holes(size + 2*c, diamond_lattice_holes(size, cell, strut, center), center);
}

// ---------- triangular lattice ----------
// cell = triangle side between rib centre lines. alternate=true opens the triangles pointing both ways (the full
// lattice); false opens only every other one, leaving solid triangles in between (stiffer, a staggered look).
// orient: "up" = a rib family along X, "side" = along Y.
function triangular_lattice_holes(size, cell=14, strut=1.5, alternate=true, center=[0, 0]) = let(
    H = cell*sqrt(3)/2, rho = cell/(2*sqrt(3)), k = (rho - strut/2)/rho, r = k*cell/sqrt(3))
    [for (j=[pat_i0(size[1], H, center[1]):pat_i1(size[1], H, center[1])])
     for (i=[pat_i0(size[0], cell, center[0], 2):pat_i1(size[0], cell, center[0], 2)]) let(x0 = (i + (abs(j)%2)/2)*cell, y0 = j*H)
        for (t = alternate ? [0, 1] : [0])
            t == 0 ? pat_ngon_pts(3, r, 90, [x0 + cell/2, y0 + H/3])
                   : pat_ngon_pts(3, r, -90, [x0 + cell, y0 + 2*H/3])];
module triangular_lattice_2d(size, cell=14, strut=1.5, alternate=true, orient="up", center=[0, 0]) {
    side = orient == "side";
    s = side ? [size[1], size[0]] : size;
    c = side ? pat_rot(center, -90) : center;
    rotate(side ? 90 : 0) pat_plate_with_holes(s + [3*cell, 2*cell], triangular_lattice_holes(s, cell, strut, alternate, c), c);
}

// ---------- cube rosette ----------
// A kumiko-style lattice on a triangular grid (ribs vertical and at +-30 degrees). The grid's hexagons are either
// "cubes" (three rhombi: the isometric cube, top face wide) or "rosettes" (six small triangles around a point).
// cell = side of the small triangles = rhombus side. cubes: "sparse" = one hexagon in three is a cube, each
// surrounded by rosettes (the classic look); "dense" = two in three; "all" = tumbling blocks (rhombille), no
// triangles; "none" = only rosettes (a plain triangular grid).
function _cube_v(c, R, k) = c + R*[cos(90 + 60*k), sin(90 + 60*k)];
function cube_rosette_is_cube(i, j, cubes) = let(col = ((i - j)%3 + 3)%3)
    cubes == "all" ? true : cubes == "none" ? false : cubes == "dense" ? col != 0 : col == 0;
function cube_rosette_holes(size, cell=10, strut=2, cubes="sparse", center=[0, 0]) = let(
    R = cell, D = sqrt(3)*R, dy = D*sqrt(3)/2, ri = R*sin(60)/2)
    [for (j=[pat_i0(size[1], dy, center[1], 2):pat_i1(size[1], dy, center[1], 2)])
     for (i=[pat_i0(size[0], D, center[0] - j*D/2, 2):pat_i1(size[0], D, center[0] - j*D/2, 2)])
        let(c = [i*D + j*D/2, j*dy])
        each (cube_rosette_is_cube(i, j, cubes)
            ? [for (k=[0:2]) let(q = [c, _cube_v(c, R, 2*k + 1), _cube_v(c, R, 2*k + 2), _cube_v(c, R, 2*k + 3)])
                  pat_inset_about(q, (q[0] + q[2])/2, ri, strut/2)]
            : [for (k=[0:5]) pat_inset_tri([c, _cube_v(c, R, k), _cube_v(c, R, k + 1)], strut/2)])];
module cube_rosette_2d(size, cell=10, strut=2, cubes="sparse", center=[0, 0]) {
    pat_plate_with_holes(size + [3*cell, 3*cell], cube_rosette_holes(size, cell, strut, cubes, center), center);
}
