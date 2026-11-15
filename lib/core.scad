// Core atoms shared by every project and library file.
// Projects:  include <../../lib/core.scad>   (include, not use: pick() reads the project's `part` variable and
//            the palette below are variables).   Library files: use <core.scad> for the modules and functions.

// ---------- project plumbing ----------
// render children only for the selected part ("all" = whole assembly); every part of a project goes through this
// and shows the part in its colour from the `parts` table (previews only; exports are unaffected)
function part_colour(n) = is_undef(parts) ? undef : let(r = [for (p=parts) if (p[0] == n && is_string(p[4]) && p[4][0] == "#") p[4]]) r[0];
module pick(n) {
    if (part == "all" || part == n) { c = part_colour(n); if (is_undef(c)) children(); else color(c) children(); }
}

// ---------- solids and transforms ----------
// extrude 2D children between two heights
module slab(z1, z2) { translate([0, 0, z1]) linear_extrude(z2 - z1) children(); }
// apply a 2x3 affine matrix [[a, b, tx], [c, d, ty]] to 2D children (fitted glyph / artwork placement)
module affine2d(m) { multmatrix([[m[0][0], m[0][1], 0, m[0][2]], [m[1][0], m[1][1], 0, m[1][2]], [0, 0, 1, 0], [0, 0, 0, 1]]) children(); }
// children plus their mirror image across the y axis
module mirror_pair() { children(); mirror([1, 0]) children(); }

// countersunk screw hole through a wall of thickness t (z=0..t), head sunk into the top face. Defaults: M3
module csk_hole(t, d=3.4, head_d=6.6, depth=1.55) {
    translate([0, 0, -1]) cylinder(d=d, h=t + 2, $fn=24);
    translate([0, 0, t - depth]) cylinder(d1=d, d2=head_d, h=depth + 0.01, $fn=32);
}

// ---------- 2D outline atoms ----------
// outline of children() as a band of width w, centred on the edge (or inside it with inside=true)
module stroke_2d(w=1, inside=false) {
    difference() { offset(delta=inside ? 0 : w/2) children(); offset(delta=inside ? -w : -w/2) children(); }
}
// band of width w set `inset` inside the edge of children() (borders, decorative grooves)
module border_2d(inset=0.9, w=0.5) { difference() { offset(delta=-inset) children(); offset(delta=-inset - w) children(); } }

// ---------- functions ----------
function sum(v, i=0) = i >= len(v) ? 0 : v[i] + sum(v, i + 1);
function polar(r, a) = [r*cos(a), r*sin(a)];
// quadratic Bezier p0 - c - p1 as n+1 points
function qbez(p0, c, p1, n=24) = [for (i=[0:n]) let(t=i/n) (1-t)*(1-t)*p0 + 2*(1-t)*t*c + t*t*p1];
// list without its first / without its first and last element (for joining curves)
function rest(l) = [for (i=[1:1:len(l)-1]) l[i]];
function inner(l) = [for (i=[1:1:len(l)-2]) l[i]];
// circle through three points -> [centre, radius]
function circle3(a, b, c) = let(
    d = 2*(a[0]*(b[1]-c[1]) + b[0]*(c[1]-a[1]) + c[0]*(a[1]-b[1])),
    ux = ((a*a)*(b[1]-c[1]) + (b*b)*(c[1]-a[1]) + (c*c)*(a[1]-b[1]))/d,
    uy = ((a*a)*(c[0]-b[0]) + (b*b)*(a[0]-c[0]) + (c*c)*(b[0]-a[0]))/d)
    [[ux, uy], norm(a - [ux, uy])];

// ---------- palette (viewer / 3MF colours; use these in `parts` tables so projects look alike) ----------
COL_WOOD      = "#7a2e1c";   // mahogany boards
COL_WOOD_DARK = "#3a2418";   // surround plates
COL_RAIL_WOOD = "#6b2f1a";
COL_BRASS     = "#c9a13b";   // rails
COL_GOLD      = "#e0b84a";   // sliders, highlights
COL_PLATE     = "#cdb87a";   // number plates
COL_TAN       = "#d9b98a";   // leather, titles
COL_SILVER    = "#b8b8b8";   // stoppers, hardware
COL_INK       = "#1a1a1a";   // black inlays, text
COL_BLACK     = "#151515";
COL_WHITE     = "#f2f2f2";
COL_GREY      = "#9aa4ad";   // utility parts
COL_GREY_DARK = "#3d4a54";
COL_FIXTURE   = "#4d6170";   // attachment plates
COL_CLEAR     = "#e9eef0";   // diffusers
