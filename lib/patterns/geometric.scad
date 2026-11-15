// Geometric lattices: hex honeycomb, square grid, diamond lattice, triangular lattice.
// Use:  use <../../lib/patterns.scad> and pattern_2d("hex_honeycomb", ...), or use this file for the single generators.
// Frame: XY plane, a cell centre on the origin, covers `size` (centred) and a little more; not clipped.
// Each generator returns the MATERIAL (the ribs) as one connected 2D shape: a plate with the cells cut out.
// `cell` is the repeat pitch (centre to centre), `strut` the rib width, so an opening is cell - strut wide.
use <tiling.scad>

HEX_ORIENTS = ["pointy", "flat"];
TRI_ORIENTS = ["up", "side"];

// ---------- hex honeycomb ----------
// cell = distance between the centres of neighbouring cells (= hexagon across flats + strut).
// orient: "pointy" = corners up (rows staggered), "flat" = flats up (columns staggered).
function hex_honeycomb_holes(size, cell=12, strut=1.5) = let(
    r = (cell - strut)/sqrt(3),                    // corner radius of an opening
    dy = cell*sqrt(3)/2, nx = pat_n(size[0], cell), ny = pat_n(size[1], dy))
    [for (j=[-ny:ny]) for (i=[-nx:nx]) pat_ngon_pts(6, r, 30, [(i + (abs(j)%2)/2)*cell, j*dy])];
module hex_honeycomb_2d(size, cell=12, strut=1.5, orient="pointy") {
    flat = orient == "flat";
    s = flat ? [size[1], size[0]] : size;
    rotate(flat ? 90 : 0) pat_plate_with_holes(s + [2*cell, 2*cell], hex_honeycomb_holes(s, cell, strut));
}

// ---------- square grid ----------
// cell = [pitch x, pitch y] (or one number), strut = [vertical rib width, horizontal rib width] (or one number).
// stagger = 0..0.5 shifts every other row by that share of a cell (0.5 = brick pattern).
function square_grid_holes(size, cell=10, strut=1.5, stagger=0) = let(
    c = pat_xy(cell), s = pat_xy(strut), w = c[0] - s[0], h = c[1] - s[1],
    nx = pat_n(size[0], c[0]), ny = pat_n(size[1], c[1]))
    [for (j=[-ny:ny]) for (i=[-nx:nx]) let(x = (i + (abs(j)%2)*stagger)*c[0], y = j*c[1])
        [[x - w/2, y - h/2], [x + w/2, y - h/2], [x + w/2, y + h/2], [x - w/2, y + h/2]]];
module square_grid_2d(size, cell=10, strut=1.5, stagger=0) {
    c = pat_xy(cell);
    pat_plate_with_holes(size + 2*c, square_grid_holes(size, cell, strut, stagger));
}

// ---------- diamond lattice ----------
// cell = [diamond width, diamond height] between rib centre lines (or one number for squares on their corner).
// The ribs run diagonally and all have the width `strut`.
function diamond_inset(cell, strut) = let(c = pat_xy(cell), d0 = c[0]*c[1]/4/norm(c/2)) (d0 - strut/2)/d0;   // scale of the opening
function diamond_lattice_holes(size, cell=[12, 18], strut=1.5) = let(
    c = pat_xy(cell), k = diamond_inset(cell, strut), a = k*c[0]/2, b = k*c[1]/2,
    nx = pat_n(size[0], c[0]), ny = pat_n(size[1], c[1]))
    [for (j=[-ny:ny]) for (i=[-nx:nx]) for (o=[0, 0.5]) let(x = (i + o)*c[0], y = (j + o)*c[1])
        [[x + a, y], [x, y + b], [x - a, y], [x, y - b]]];
module diamond_lattice_2d(size, cell=[12, 18], strut=1.5) {
    c = pat_xy(cell);
    pat_plate_with_holes(size + 2*c, diamond_lattice_holes(size, cell, strut));
}

// ---------- triangular lattice ----------
// cell = triangle side between rib centre lines. alternate=true opens the triangles pointing both ways (the full
// lattice); false opens only every other one, leaving solid triangles in between (stiffer, a staggered look).
// orient: "up" = a rib family along X, "side" = along Y.
function triangular_lattice_holes(size, cell=14, strut=1.5, alternate=true) = let(
    H = cell*sqrt(3)/2, rho = cell/(2*sqrt(3)), k = (rho - strut/2)/rho, r = k*cell/sqrt(3),
    nx = pat_n(size[0], cell, 2), ny = pat_n(size[1], H))
    [for (j=[-ny:ny]) for (i=[-nx:nx]) let(x0 = (i + (abs(j)%2)/2)*cell, y0 = j*H)
        for (t = alternate ? [0, 1] : [0])
            t == 0 ? pat_ngon_pts(3, r, 90, [x0 + cell/2, y0 + H/3])
                   : pat_ngon_pts(3, r, -90, [x0 + cell, y0 + 2*H/3])];
module triangular_lattice_2d(size, cell=14, strut=1.5, alternate=true, orient="up") {
    side = orient == "side";
    s = side ? [size[1], size[0]] : size;
    rotate(side ? 90 : 0) pat_plate_with_holes(s + [3*cell, 2*cell], triangular_lattice_holes(s, cell, strut, alternate));
}
