// earbuds.scad with its library inlined into one file (tools/flatten_scad.py); do not edit:
// change projects/earbuds/earbuds.scad and lib/ in https://github.com/tamaygz/tg_3d_modelling and regenerate.
// Licence: CC BY-NC-SA 4.0 (see LICENSE in the repository).
// Earbuds holder: a dock for the charging case of your earbuds, with cable opening, grip cut-out and mounting
// Presets for popular cases (or your own size), patterned walls from lib/patterns.scad, snap-in attachment plates
// from lib/attach.scad. Built with lib/container.scad on lib/shell.scad.

part = "all";                    // which part to export ("all" = assembly); set by the build tools

/* [Earbuds case] */
// charging case model (sizes are the makers' figures: measure yours and adjust the clearance, or use custom)
preset = "Soundcore P31i"; // [Soundcore P31i, AirPods Pro 2, AirPods 4, AirPods 2, Galaxy Buds2 Pro / FE, Galaxy Buds3 Pro, Sony WF-1000XM5, Bose QC Ultra Earbuds, Pixel Buds Pro 2, Nothing Ear, custom]
// custom case: width, thickness, height as it stands with the lid up (mm)
custom_size = [58, 30, 58];
// how the case sits in the holder: upright (lid up), flat (lying on its back) or on its side
pose = "upright"; // [upright, flat, side]
// play around the case on every side (mm; add more for a silicone sleeve)
clearance = 0.6; // [0.2:0.1:4]
// how much of the case's height the walls cover (the rest sticks out to grab)
hold = 0.6; // [0.2:0.05:1.1]

/* [Walls] */
// wall thickness (mm)
wall_t = 2; // [1.2:0.2:6]
// corner shape of the holder
corners = "round"; // [round, chamfer, square]
// corner radius (mm)
corner_r = 8; // [1:0.5:40]
// pattern on the walls
wall_pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the wall pattern is applied
wall_mode = "through_cut"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// pattern repeat size in mm (0 = a size that suits the holder)
wall_cell = 0; // [0:0.5:40]
// rib width in mm (0 = a width that suits the holder)
wall_strut = 0; // [0:0.1:8]
// rotation of the wall pattern (degrees)
wall_angle = 0; // [-90:5:90]
// seed for Voronoi and Truchet
wall_seed = 1; // [1:1:999]
// relief height / engraving depth / lining thickness
wall_relief = 0.6; // [0.2:0.1:2]
// plain band under the rim (mm)
rim_band = 3; // [0:0.5:20]
// plain band above the floor (mm)
base_band = 2; // [0:0.5:20]
// corners: pattern = the pattern runs round the corners; solid = plain corners
corner_fill = "pattern"; // [pattern, solid]
// how much higher the back wall is than the front (mm)
rise_back = 0; // [0:1:80]

/* [Front grip] */
// lower the front rim so a finger can get under the case
grip = true;
// grip cut-out: width at half its depth (mm)
grip_width = 26; // [8:1:120]
// grip cut-out: how far down it goes (mm); a narrow cut-out cannot be deep
grip_depth = 14; // [2:1:80]

/* [Charging cable] */
// none, hole = the plug passes through, dock = the hole grips the plug so the case docks onto it
cable = "hole"; // [none, hole, dock]
// where the opening is: in the floor or in a wall
cable_on = "floor"; // [floor, back, front, left, right]
// position: along the floor / wall from its middle (mm)
cable_x = 0; // [-60:0.5:60]
// position: front (-) to back (+) on the floor, or height above the inside floor on a wall (mm)
cable_y = 0; // [-40:0.5:80]
// plug body (overmould) width and thickness (USB-C is about 12.5 x 6.5)
plug_size = [12.5, 6.5];
// cable diameter (for the slot)
cable_d = 4; // [2:0.5:8]
// slot from the opening to the edge, so the cable can be laid in without threading the plug
cable_slot = true;

/* [Floor] */
// floor thickness (5 or more for a dock, so the plug is held straight)
floor_t = 3; // [1:0.2:12]
// pattern on the floor
floor_pattern = "concentric_ripples"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the floor pattern is applied
floor_mode = "solid"; // [solid, through_cut, recessed]

/* [Mounting] */
// how it mounts: plates snap into a solid zone of the back wall (none = stands on a desk)
attach_type = "none"; // [none, wall, keyhole, skadis, hook, magnet, flat, roof, slide, fin, clamp, pipe]
// plate size: S 30 x 30, M 45 x 40, L 60 x 50 mm (a smaller one is used if it does not fit)
attach_size = "S"; // [S, M, L]
// number of plates side by side (fewer are used if they do not fit)
attach_count = 1; // [1:1:2]
// ball joint between the holder and the plate: turn and tilt it freely, the lock ring clamps it
attach_joint = "none"; // [none, ball]
// slide: the track runs horizontally (slide the holder along it) or vertically (drop it onto the track)
slide_axis = "horizontal"; // [horizontal, vertical]
// fin: a blade under the holder that anchors it, e.g. between two sofa cushions: how far down it reaches (mm)
fin_len = 100; // [30:5:250]
// fin: width of the blade (mm)
fin_w = 60; // [30:5:240]
// fin: thickness of the blade (mm)
fin_t = 4; // [2:0.5:10]
// clamp: opening between the jaws = the thickest desk, shelf or bar it grips (mm)
clamp_gap = 40; // [10:1:120]
// clamp: reach from the clamp's back to the edge of the screw hole (mm)
clamp_reach = 25; // [5:1:120]
// clamp: printed screw size
clamp_screw = "M16"; // [M10, M12, M16, M20]
// pipe: outer diameter of the pipe, tube or rail the claw snaps onto (mm)
pipe_d = 20; // [6:0.5:60]
// pipe: which way the pipe runs
pipe_axis = "horizontal"; // [horizontal, vertical]

/* [Pattern details] */
// cube rosette: one hexagon in three a cube (sparse), two in three (dense), all (tumbling blocks) or none
cube_density = "sparse"; // [sparse, dense, all, none]
// fluted: convex half-round ribs (reeded), concave grooves (fluted) or flat ribs
flute_style = "reeded"; // [reeded, fluted, ribbed]
// fluted: ribs upright (vertical) or lying (horizontal)
flute_orient = "vertical"; // [vertical, horizontal]

/* [Hidden] */

// ======================= library (inlined) =======================

// ----------------------- lib/core.scad -----------------------
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


// ----------------------- lib/shell.scad -----------------------
// Shells: thin walls that follow a closed outline. Boxes, baskets, bins, trays, lamp shades.
// Use:  use <../../lib/shell.scad>
//
// An outline is a closed list of [x, y] points, counter-clockwise, in the XY plane (the floor plane, z = 0).
// It is the OUTER face of the wall; the wall body lies inside it and rises along +Z.
//
// shell_wrap() bends a flat panel round the outline. Its child builds the panel in the "strip frame":
//     x = distance along the outline, 0 at the middle of the strip
//     y = height, 0 at mid-height (y = -h/2 is the floor plane z = 0, y = +h/2 is z = h)
//     z = thickness: z = 0 is the inner face, z = t the outer face (on the outline); relief goes beyond t
// which is exactly the frame of lib/patterns.scad with size = [strip length, h], so
//     shell_wrap(pts, t, h=60) pattern_panel("through_cut", "hex_honeycomb", [shell_len(pts), 60], t=t) polygon(shell_strip_pts(pts, hf=..., h=60));
// makes a patterned wall all round. The wall is built one flat facet per outline edge: shell_wrap sets
// $pat_window for each facet, the pattern modules build just that piece, and the facets overlap where they
// meet. Straight runs of the outline should therefore be ONE long edge (fast); curves need short edges.
// Other 2D content in the child must be clipped with shell_window_2d().
//
// The top edge can follow any height function hf(p) of the position p = [x, y] (slopes, waves):
// shell_strip_pts() turns it into the outline of the unrolled strip.

SHELL_CORNERS = ["round", "chamfer", "square"];
SHELL_LAP    = 0.1;     // mm a facet reaches past its joint, so neighbours overlap
SHELL_SHRINK = 0.04;    // mm every other facet is pulled in: identical cut-outs of two facets then cross cleanly
                        // at the joint instead of almost coinciding (which leaves slivers in the exported mesh)

// ---------- outlines ----------
// Box outline as named runs [[name, points], ...], counter-clockwise starting with the front side (y = -depth/2):
// "front", "corner_fr", "right", "corner_br", "back", "corner_bl", "left", "corner_fl" (no corner runs when
// square). corner: see SHELL_CORNERS, r = corner radius / chamfer size, fn = edges per round corner, side_n =
// edges per straight side (1 unless the outline is going to be waved or needs a vertex in the middle).
function shell_rect_runs(size, corner="round", r=10, fn=6, side_n=1) = let(
    W = size[0], D = size[1], rr = corner == "square" ? 0 : min(r, W/2 - 0.5, D/2 - 0.5),
    c = [[W/2 - rr, -D/2 + rr], [W/2 - rr, D/2 - rr], [-W/2 + rr, D/2 - rr], [-W/2 + rr, -D/2 + rr]],   // corner centres fr, br, bl, fl
    a0 = [-90, 0, 90, 180],
    ends = [for (k=[0:3]) [c[(k+3)%4] + rr*[cos(a0[k]), sin(a0[k])], c[k] + rr*[cos(a0[k]), sin(a0[k])]]],   // side k: start, end
    names = ["front", "right", "back", "left"], cn = ["corner_fr", "corner_br", "corner_bl", "corner_fl"],
    m = corner == "chamfer" ? 1 : fn)
    [for (k=[0:3]) each concat(
        [[names[k], [for (i=[0:side_n]) ends[k][0] + (ends[k][1] - ends[k][0])*i/side_n]]],
        rr > 0 ? [[cn[k], [for (i=[0:m]) c[k] + rr*[cos(a0[k] + 90*i/m), sin(a0[k] + 90*i/m)]]]] : [])];
// all points of a list of runs as one closed outline (shared end points once)
function shell_runs_pts(runs) = [for (r=runs) for (i=[0:len(r[1])-2]) r[1][i]];
// [[name, first edge, last edge], ...] of the runs within shell_runs_pts()
function shell_runs_edges(runs, k=0, e=0) = k >= len(runs) ? [] :
    concat([[runs[k][0], e, e + len(runs[k][1]) - 2]], shell_runs_edges(runs, k + 1, e + len(runs[k][1]) - 1));
function shell_run(edges, name) = [for (r=edges) if (r[0] == name) r][0];

// ellipse and superellipse ("squircle": e = 2 ellipse .. 4 soft box .. 8 nearly square) with n edges, starting at the back
function shell_ellipse_pts(size, n=48) = [for (i=[0:n-1]) let(a = 90 + i*360/n) [size[0]/2*cos(a), size[1]/2*sin(a)]];
function shell_squircle_pts(size, e=4, n=48) = [for (i=[0:n-1]) let(a = 90 + i*360/n, c = cos(a), s = sin(a))
    [size[0]/2*sign(c)*pow(abs(c), 2/e), size[1]/2*sign(s)*pow(abs(s), 2/e)]];

// the same outline starting at point k
function shell_start_at(pts, k) = let(n = len(pts)) [for (i=[0:n-1]) pts[(i + k)%n]];

// ---------- measuring ----------
function _sh_sum(v, n) = n <= 0 ? 0 : v[n-1] + _sh_sum(v, n - 1);
function shell_edge_lens(pts) = let(n = len(pts)) [for (i=[0:n-1]) norm(pts[(i+1)%n] - pts[i])];
// distance along the outline of every point; n + 1 values, the last is the perimeter
function shell_dists(pts) = let(l = shell_edge_lens(pts)) [for (i=[0:len(pts)]) _sh_sum(l, i)];
function shell_len(pts, e0=0, e1) = let(u = shell_dists(pts), b = is_undef(e1) ? len(pts) - 1 : e1) u[b + 1] - u[e0];
function shell_bounds(pts) = [[min([for (p=pts) p[0]]), min([for (p=pts) p[1]])], [max([for (p=pts) p[0]]), max([for (p=pts) p[1]])]];
// outward unit normal of edge i, and of point i (mean of its two edges)
function shell_edge_normal(pts, i) = let(d = pts[(i+1)%len(pts)] - pts[i]) [d[1], -d[0]]/norm(d);
function shell_point_normal(pts, i) = let(n = len(pts), v = shell_edge_normal(pts, i) + shell_edge_normal(pts, (i + n - 1)%n)) v/norm(v);

// wave the outline in plan: every point moves in or out by amp*sin(count waves round the outline).
// Needs short edges (side_n in shell_rect_runs, n in the ellipse functions).
function shell_wavy_pts(pts, amp=2, count=8, phase=0) = amp == 0 ? pts : let(u = shell_dists(pts), L = u[len(pts)])
    [for (i=[0:len(pts)-1]) pts[i] + shell_point_normal(pts, i)*amp*sin(360*count*u[i]/L + phase)];

// ---------- height field ----------
// A ready-made rim height for a box of `size`: base height at the front left, rising by rise = [to the right,
// to the back] across the box, plus cosine waves across the width and the depth:
// waves = [[amplitude, count], [amplitude, count]] (x, y), phase in degrees. (Older form of shell_rim() below.)
function shell_rim_height(p, size, base, rise=[0, 0], waves=[[0, 1], [0, 1]], phase=0) =
    shell_rim(p, size, base, [0, rise[1], 0, rise[0]], waves, phase);
// The same per side, for a box of plan `size` centred on the origin (front = -y, back = +y, left = -x, right = +x):
//   raise   = [front, back, left, right]: how much higher that wall's rim is (negative = lower). Each one slopes
//             to 0 at the opposite wall, and they add up (back 20 + right 10: the back right corner is 30 higher).
//   waves   = [[amplitude, count] along x (front and back), [amplitude, count] along y (left and right)]:
//             the rim rises and falls by `amplitude` mm, `count` waves over the width / depth
//   notches = [[side, depth, width, center], ...]: a dip in the rim of that wall (see shell_rim_dip: grip cut-outs,
//             pouring lips); `width` at half depth, `center` shifts it along the wall
function shell_rim(p, size, base, raise=[0, 0, 0, 0], waves=[[0, 1], [0, 1]], phase=0, notches=[]) =
    base + raise[0]*(0.5 - p[1]/size[1]) + raise[1]*(0.5 + p[1]/size[1])
         + raise[2]*(0.5 - p[0]/size[0]) + raise[3]*(0.5 + p[0]/size[0])
         + waves[0][0]*cos(360*waves[0][1]*p[0]/size[0] + phase) + waves[1][0]*cos(360*waves[1][1]*p[1]/size[1] + phase)
         - (len(notches) == 0 ? 0 : [for (n=notches) shell_rim_dip(p, size, n[1], n[2], is_undef(n[3]) ? 0 : n[3], n[0])]*[for (n=notches) 1]);
// [lowest, highest] the rim of shell_rim() can reach (corners of the slopes, wave amplitudes, deepest notch)
function shell_rim_range(size, base, raise=[0, 0, 0, 0], waves=[[0, 1], [0, 1]], notches=[]) = let(
    c = [for (sx=[-1, 1], sy=[-1, 1]) raise[0]*(0.5 - sy/2) + raise[1]*(0.5 + sy/2) + raise[2]*(0.5 - sx/2) + raise[3]*(0.5 + sx/2)],
    w = abs(waves[0][0]) + abs(waves[1][0]),
    d = len(notches) == 0 ? 0 : max([for (n=notches) shell_rim_dip_depth(n[1], n[2])]))
    [base + min(c) - w - d, base + max(c) + w];

// A dip in the rim (a grip cut-out, a pouring lip): subtract it from a rim height. The rim drops by `depth` in
// the middle of one side (side = "front" / "back" / "left" / "right", center = shift along that side) and fades
// out over `fade` mm away from that wall, so the other walls are not affected. `width` is the width of the dip at
// half its depth. The shoulders are never steeper than about 50 degrees (SHELL_DIP_RUN mm of run per mm of drop),
// so a rim band keeps its strength along them: a dip too narrow for its depth comes out shallower, and
// shell_rim_dip_depth() tells you how deep it really is.
SHELL_DIP_RUN = 1.2;
function _sh_ramp(x) = x <= 0 ? 1 : x >= 1 ? 0 : (1 + cos(180*x))/2;
function shell_rim_dip_depth(depth, width) = min(depth, width/SHELL_DIP_RUN);
function shell_rim_dip(p, size, depth=10, width=30, center=0, side="front", fade=8) = let(
    d = shell_rim_dip_depth(depth, width),
    along = side == "front" || side == "back" ? p[0] : p[1],
    away = side == "front" ? p[1] + size[1]/2 : side == "back" ? size[1]/2 - p[1] : side == "left" ? p[0] + size[0]/2 : size[0]/2 - p[0],
    shoulder = min(width, max(SHELL_DIP_RUN*d, 4)))
    d <= 0 ? 0 : d*_sh_ramp((abs(along - center) - (width - shoulder)/2)/shoulder)*_sh_ramp(away/fade - 0.5);

// distance along the outline of the point on it that is nearest to q (to place things on a wall from plan coordinates)
function shell_dist_at(pts, q) = let(u = shell_dists(pts), n = len(pts),
    c = [for (i=[0:n-1]) let(A = pts[i], d = pts[(i+1)%n] - A, t = max(0, min(1, (q - A)*d/(d*d)))) [norm(q - A - t*d), u[i] + t*norm(d)]],
    m = min([for (x=c) x[0]]))
    [for (x=c) if (x[0] == m) x[1]][0];

// ---------- unrolled strip ----------
// 2D outline of the wall strip over edges e0..e1 in the strip frame: bottom at y = -h/2, top edge at
// hf(p) - h/2, sampled every `step` mm. hf = function (p) -> height above the floor (default: h everywhere).
// h = the reference height (use the largest height of the wall); it only fixes where y = 0 is.
// The strip reaches `ext` beyond both ends, so neighbouring strips (and the two ends of a full loop) overlap
// instead of meeting face to face.
function shell_strip_pts(pts, e0=0, e1, hf, h, step=2, ext=0.3) = let(
    n = len(pts), b = is_undef(e1) ? n - 1 : e1, u = shell_dists(pts), uc = (u[e0] + u[b + 1])/2,
    top = [for (i=[e0:b]) let(A = pts[i], B = pts[(i+1)%n], m = max(1, ceil((u[i+1] - u[i])/step)))
        for (k=[0:(i == b ? m : m - 1)]) let(q = A + (B - A)*k/m) [u[i] + (u[i+1] - u[i])*k/m - uc, (is_undef(hf) ? h : hf(q)) - h/2]],
    m = len(top) - 1)
    concat([[u[e0] - uc - ext, -h/2], [u[b + 1] - uc + ext, -h/2], [top[m][0] + ext, top[m][1]]],
           [for (i=[m:-1:0]) top[i]], [[top[0][0] - ext, top[0][1]]]);

// ---------- wrapping ----------
// clip 2D content of a shell_wrap child to the facet being built (pattern modules do this themselves)
module shell_window_2d() {
    if (is_undef($pat_window)) children();
    else offset(delta=is_undef($pat_shrink) ? 0 : -$pat_shrink) intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
}
// Bend the child (a panel in the strip frame, see the top of this file) round the outline, over edges e0..e1
// (default: all the way round). t = wall thickness, h = reference height used for the strip frame.
// above = how far relief may stand out beyond t (only used to close the gaps at inward bends).
module shell_wrap(pts, t, e0=0, e1, h=50, above=0) {
    n = len(pts); b = is_undef(e1) ? n - 1 : e1;
    u = shell_dists(pts); uc = (u[e0] + u[b + 1])/2;
    for (i=[e0:b]) {
        A = pts[i]; B = pts[(i+1)%n]; d = (B - A)/norm(B - A); nr = [d[1], -d[0]];
        dp = pts[i] - pts[(i + n - 1)%n]; dn = pts[(i+2)%n] - B;
        // at an inward bend the facets part on the inside: lengthen them so they overlap; elsewhere SHELL_LAP is enough
        ta = dp[0]*d[1] - dp[1]*d[0]; tb = d[0]*dn[1] - d[1]*dn[0];                 // > 0: outward (convex) corner
        sh = SHELL_SHRINK*((i == n - 1 && n%2 == 1) ? 2 : i%2);                    // neighbouring facets differ
        ea = SHELL_LAP + sh + (ta < 0 ? (t + above)*tan(acos(max(-1, min(1, dp*d/norm(dp))))/2) : 0);
        eb = SHELL_LAP + sh + (tb < 0 ? (t + above)*tan(acos(max(-1, min(1, dn*d/norm(dn))))/2) : 0);
        xm = (u[i] + u[i+1])/2 - uc; M = (A + B)/2;
        $pat_shrink = sh;
        $pat_window = [[xm + (eb - ea)/2, 0], [u[i+1] - u[i] + ea + eb, h + 2]];
        // the pulled-in facets also sit that much further in, so faces of nearly straight neighbours do not coincide
        multmatrix([[d[0], 0, nr[0], M[0] - d[0]*xm - nr[0]*(t + sh)],
                    [d[1], 0, nr[1], M[1] - d[1]*xm - nr[1]*(t + sh)],
                    [0, 1, 0, h/2], [0, 0, 0, 1]]) children();
    }
}


// ----------------------- lib/patterns/tiling.scad -----------------------
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

// Every generator takes `center` = the point (in the pattern's own axes) around which it must cover `size`.
// The pattern itself stays anchored at the origin: a window somewhere else shows exactly that part of it.
// first and last index of the cells of `pitch` needed to cover `extent` around coordinate c
function pat_i0(extent, pitch, c=0, extra=1) = round(c/pitch) - pat_n(extent, pitch, extra);
function pat_i1(extent, pitch, c=0, extra=1) = round(c/pitch) + pat_n(extent, pitch, extra);
function pat_rot(p, a) = [p[0]*cos(a) - p[1]*sin(a), p[0]*sin(a) + p[1]*cos(a)];

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

// a triangle moved in by d on every side (scaled about its incentre; [] if nothing is left)
function pat_inset_tri(p, d) = let(
    a = norm(p[1] - p[2]), b = norm(p[0] - p[2]), c = norm(p[0] - p[1]), per = a + b + c,
    I = (a*p[0] + b*p[1] + c*p[2])/per,
    r = abs((p[1][0] - p[0][0])*(p[2][1] - p[0][1]) - (p[2][0] - p[0][0])*(p[1][1] - p[0][1]))/per)
    r <= d ? [] : [for (q=p) I + (q - I)*(r - d)/r];
// a rhombus (or any polygon with an incircle around centre c of radius r) moved in by d
function pat_inset_about(p, c, r, d) = r <= d ? [] : [for (q=p) c + (q - c)*(r - d)/r];

// a plate covering `size` (centred) with the listed polygons cut out: the body of every lattice pattern.
// Cutting holes from one plate gives a connected network with the same rib width everywhere.
module pat_plate_with_holes(size, holes, center=[0, 0]) {
    difference() {
        translate(center) square(size, center=true);
        for (h=holes) if (len(h) >= 3) polygon(h);
    }
}


// ----------------------- lib/patterns/geometric.scad -----------------------
// Geometric lattices: hex honeycomb, square grid, diamond lattice, triangular lattice, cube rosette.
// Use:  use <../../lib/patterns.scad> and pattern_2d("hex_honeycomb", ...), or use this file for the single generators.
// Frame: XY plane, a cell centre on the origin, covers `size` (centred) and a little more; not clipped.
// Each generator returns the MATERIAL (the ribs) as one connected 2D shape: a plate with the cells cut out.
// `cell` is the repeat pitch (centre to centre), `strut` the rib width, so an opening is cell - strut wide.

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


// ----------------------- lib/patterns/woven.scad -----------------------
// Woven patterns with real over-under geometry: basket weave (two directions) and tri-weave (three directions).
// Use:  use <../../lib/patterns.scad> and pattern_3d("basket_weave", ...), or use this file for the single generators.
// Frame: XY plane, a crossing on the origin, covers `size` (centred) and a little more; not clipped.
// Z: the weave stands on z = 0 and is `h` high in total. A strand is h - lift thick; where it passes under it
// lies flat on z = 0, where it passes over it climbs by `lift`. Because lift is less than the strand thickness,
// the two strands of a crossing share material and the weave is one solid. Printed flat it needs no supports:
// every raised stretch rests on the strand below it.
// The *_2d modules give the footprint (all strands seen from above) for cut-outs and engraving.

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
module basket_weave_3d(size, h=2.4, cell=10, strip=7, lift, style="flat", center=[0, 0]) {
    assert(weave_ok(h, lift), weave_msg(h, lift));
    l = weave_lift(h, lift); t = h - l;
    nx = pat_n(size[0], cell); ny = pat_n(size[1], cell);
    Lx = (2*nx + 1)*cell; Ly = (2*ny + 1)*cell;
    ic = round(center[0]/cell); jc = round(center[1]/cell);      // the strands are built around this crossing
    for (j=[jc-ny:jc+ny]) translate([ic*cell, j*cell, 0]) weave_strand(Lx, strip, t, l, 2*cell, (abs(j)%2 - ic)*cell, style);
    for (i=[ic-nx:ic+nx]) translate([i*cell, jc*cell, 0]) rotate(90) weave_strand(Ly, strip, t, l, 2*cell, (1 - abs(i)%2 - jc)*cell, style);
}
module basket_weave_2d(size, cell=10, strip=7, center=[0, 0]) {
    nx = pat_n(size[0], cell); ny = pat_n(size[1], cell);
    ic = round(center[0]/cell); jc = round(center[1]/cell);
    for (j=[jc-ny:jc+ny]) translate([ic*cell, j*cell]) square([(2*nx + 1)*cell, strip], center=true);
    for (i=[ic-nx:ic+nx]) translate([i*cell, jc*cell]) square([strip, (2*ny + 1)*cell], center=true);
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
module tri_weave_3d(size, h=2.4, cell=24, strand=3, lift, style="flat", center=[0, 0]) {
    assert(weave_ok(h, lift), weave_msg(h, lift));
    l = weave_lift(h, lift); t = h - l;
    R = norm(size)/2 + cell; n = ceil(R/cell) + 1; P = cell/sin(60);
    for (a=[0:2]) let(c = pat_rot(center, -TRI_ANGLES[a]), mc = round(c[1]/cell)) for (m=[mc-n:mc+n])
        rotate(TRI_ANGLES[a]) translate([c[0], (m + TRI_SHIFT[a])*cell, 0])
            weave_strand(2*R, strand, t, l, P, _tri_cross(cell, a, m, (a + 1)%3) - c[0], style, 0.2);
}
module tri_weave_2d(size, cell=24, strand=3, center=[0, 0]) {
    R = norm(size)/2 + cell; n = ceil(R/cell) + 1;
    for (a=[0:2]) let(c = pat_rot(center, -TRI_ANGLES[a]), mc = round(c[1]/cell)) for (m=[mc-n:mc+n])
        rotate(TRI_ANGLES[a]) translate([c[0], (m + TRI_SHIFT[a])*cell]) square([2*R, strand], center=true);
}


// ----------------------- lib/patterns/organic.scad -----------------------
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


// ----------------------- lib/patterns/decorative.scad -----------------------
// Decorative patterns: fish scales, Truchet arcs, Girih star & cross, asanoha.
// Use:  use <../../lib/patterns.scad> and pattern_2d("fish_scales", ...), or use this file for the single generators.
// Frame: XY plane, anchored on the origin, covers `size` (centred) and a little more; not clipped.
// The *_2d modules return the MATERIAL of the line pattern (scale edges, arcs, straps).

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
    // closing by a hair: where two outlines meet in a single point the gap between them would pinch to nothing
    offset(delta=-FISH_STEP_GAP) offset(delta=FISH_STEP_GAP)
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
// wrap = n > 0: the tiles repeat every n columns (for a wall that is n tiles round; use an even n)
function truchet_flip(i0, j, variation="random", seed=1, bias=0.5, wrap=0) = let(i = wrap > 0 ? (i0%wrap + wrap)%wrap : i0)
    variation == "alternate" ? (abs(i) + abs(j))%2 == 1 :
    variation == "rows" ? abs(j)%2 == 1 :
    variation == "uniform" ? false : pat_hash(i, j, seed, 2) < bias;
function _arc_band_pts(c, r, w, a0, a1, n=14) = concat(
    [for (i=[0:n]) c + (r + w/2)*[cos(a0 + (a1 - a0)*i/n), sin(a0 + (a1 - a0)*i/n)]],
    [for (i=[n:-1:0]) c + (r - w/2)*[cos(a0 + (a1 - a0)*i/n), sin(a0 + (a1 - a0)*i/n)]]);
module truchet_arcs_2d(size, cell=12, strut=1.6, variation="random", seed=1, bias=0.5, center=[0, 0], wrap=0) {
    e = 0.3;                                                            // e: degrees of overlap between tiles
    for (j=[pat_i0(size[1], cell, center[1]):pat_i1(size[1], cell, center[1])])
    for (i=[pat_i0(size[0], cell, center[0]):pat_i1(size[0], cell, center[0])]) translate([i*cell, j*cell])
        for (q = truchet_flip(i, j, variation, seed, bias, wrap) ? [[-1, 1, 270], [1, -1, 90]] : [[-1, -1, 0], [1, 1, 180]])
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

// ---------- asanoha (hemp leaf) ----------
// The Japanese hemp-leaf pattern: a grid of equilateral triangles (side `cell`) in which every triangle is split by
// lines from its centre to its three corners, so that six-pointed stars form around every grid point.
// The openings are the 3 slim triangles of each grid triangle. orient: "up" = a family of grid lines along X,
// "side" = along Y (the stars then point up and down).
function asanoha_opening(cell, strut) = 2*(cell*(sqrt(3)/6)/(1 + 2/sqrt(3)) - strut/2);   // width of the slim triangles
function asanoha_holes(size, cell=18, strut=1.2, center=[0, 0]) = let(H = cell*sqrt(3)/2)
    [for (j=[pat_i0(size[1], H, center[1], 2):pat_i1(size[1], H, center[1], 2)])
     for (i=[pat_i0(size[0], cell, center[0] - j*cell/2, 2):pat_i1(size[0], cell, center[0] - j*cell/2, 2)])
        let(p0 = [i*cell + j*cell/2, j*H])
        for (t=[[p0, p0 + [cell, 0], p0 + [cell/2, H]], [p0 + [cell, 0], p0 + [cell*3/2, H], p0 + [cell/2, H]]])
            let(g = (t[0] + t[1] + t[2])/3)
            for (k=[0:2]) pat_inset_tri([t[k], t[(k + 1)%3], g], strut/2)];
module asanoha_2d(size, cell=18, strut=1.2, orient="up", center=[0, 0]) {
    side = orient == "side";
    s = side ? [size[1], size[0]] : size;
    c = side ? pat_rot(center, -90) : center;
    rotate(side ? 90 : 0) pat_plate_with_holes(s + [3*cell, 2*cell], asanoha_holes(s, cell, strut, c), c);
}


// ----------------------- lib/patterns/relief.scad -----------------------
// Surface relief patterns: flowing waves, concentric ripples, fluted / reeded ribs.
// Use:  use <../../lib/patterns.scad> and pattern_2d("flowing_waves", ...), or use this file for the single generators.
// Frame: XY plane, anchored on the origin, covers `size` (centred) and a little more; not clipped.
// The *_2d modules return the MATERIAL (ribs, rings).

// ---------- flowing waves ----------
// Parallel ribs along X that follow a sine wave. cell = rib pitch (centre to centre), strut = rib width
// (measured across the rib, the same everywhere), amplitude and wavelength of the wave, phase (degrees) of the
// first rib, shift (degrees) added from rib to rib (0 = ribs run parallel, 180 = neighbours mirror each other).
// The wave repeats every `wavelength`, so panels cut at multiples of it join without a visible seam.
function wave_max_slope(amplitude, wavelength) = amplitude*2*PI/wavelength;
function wave_min_radius(amplitude, wavelength) = amplitude == 0 ? 1e9 : pow(wavelength/(2*PI), 2)/amplitude;    // tightest bend of the centre line
// smallest gap between two neighbouring ribs (they come closest where the wave is steepest; exact for shift = 0)
function wave_gap(cell, strut, amplitude, wavelength, shift=0) = let(v = cell - 2*amplitude*abs(sin(shift/2)))
    v/sqrt(1 + pow(wave_max_slope(amplitude, wavelength), 2)) - strut;
function wave_rib_pts(L, y0, strut, amplitude, wavelength, phase, n, xc=0) = let(
    k = 360/wavelength,
    c = [for (i=[0:n]) let(x = xc - L/2 + i*L/n, s = amplitude*k*PI/180*cos(k*x + phase), u = [-s, 1]/norm([s, 1]))
        [[x, y0 + amplitude*sin(k*x + phase)], u*strut/2]])
    concat([for (p=c) p[0] + p[1]], [for (i=[n:-1:0]) c[i][0] - c[i][1]]);
// ties > 0 joins every rib to the next with a short bar, `ties` wavelengths apart, so the ribs form one network
// that prints and stays stiff when the pattern is cut through. The bars sit where two ribs come closest
// (shift != 0), or alternately on the crests and in the troughs (parallel ribs), like the bonds of brickwork.
function wave_tie_x(j, wavelength, phase=0, shift=0) = let(
    target = shift == 0 ? (abs(j)%2 == 0 ? 90 : 270) : (sin(shift/2) > 0 ? 180 : 0))
    (target - phase - j*shift - shift/2)*wavelength/360;
module flowing_waves_2d(size, cell=8, strut=2.4, amplitude=3, wavelength=30, phase=0, shift=0, center=[0, 0], ties=0) {
    assert(wave_min_radius(amplitude, wavelength) > strut/2, str("flowing_waves: the wave bends tighter (radius ",
        wave_min_radius(amplitude, wavelength), ") than half the rib width ", strut/2, ": lower the amplitude or raise the wavelength"));
    L = size[0] + 2*cell; n = max(8, ceil(L/wavelength*32));
    for (j=[pat_i0(size[1] + 2*amplitude, cell, center[1]):pat_i1(size[1] + 2*amplitude, cell, center[1])])
        polygon(wave_rib_pts(L, j*cell, strut, amplitude, wavelength, phase + j*shift, n, center[0]));
    if (ties > 0) for (j=[pat_i0(size[1] + 2*amplitude, cell, center[1]):pat_i1(size[1] + 2*amplitude, cell, center[1])]) {
        P = wavelength*ties; x0 = wave_tie_x(j, wavelength, phase, shift);
        for (m=[floor((center[0] - L/2 - x0)/P):ceil((center[0] + L/2 - x0)/P)]) let(x = x0 + m*P,
            ya = j*cell + amplitude*sin(360*x/wavelength + phase + j*shift),
            yb = (j + 1)*cell + amplitude*sin(360*x/wavelength + phase + (j + 1)*shift))
            translate([x - strut/2, ya]) square([strut, yb - ya]);
    }
}

// ---------- concentric ripples ----------
// Rings around one or more centres. cell = ring spacing, strut = ring width, rings = number of rings per centre
// (0 = as many as needed to fill `size`), first = radius of the first ring (default = cell), centers = list of
// [x, y]. spokes > 0 adds that many radial bars per centre, which ties the rings into one connected web (needed
// for cut-through and open-lattice use; plain rings are loose).
function ripple_count(size, cell, rings=0, first, centers=[[0, 0]]) = rings > 0 ? rings :
    ceil((norm(size)/2 + max([for (c=centers) norm(c)]) - (is_undef(first) ? cell : first))/cell) + 1;
function ripple_radius(i, cell, first) = (is_undef(first) ? cell : first) + (i - 1)*cell;      // ring i = 1..n
module ripple_rings_2d(i0, i1, cell=6, strut=2, first, centers=[[0, 0]], spokes=0) {
    for (c=centers) translate(c) {
        for (i=[i0:1:i1]) let(r = ripple_radius(i, cell, first), fn = max(32, min(180, ceil(r*2.5))))
            difference() { circle(r=r + strut/2, $fn=fn); if (r > strut/2) circle(r=r - strut/2, $fn=fn); }
        if (spokes > 0 && i1 > i0) for (a=[0:spokes-1]) rotate(a*360/spokes)
            translate([ripple_radius(i0, cell, first), -strut/2]) square([ripple_radius(i1, cell, first) - ripple_radius(i0, cell, first), strut]);
    }
}
// (rings always start at their centre, so a window far from it still needs every ring up to there)
module concentric_ripples_2d(size, cell=6, strut=2, rings=0, first, centers=[[0, 0]], spokes=0, center=[0, 0]) {
    ripple_rings_2d(1, ripple_count(size + 2*[abs(center[0]), abs(center[1])], cell, rings, first, centers), cell, strut, first, centers, spokes);
}
// relief with falloff, level k of `steps` (1 = lowest, all rings): the inner rings rise higher than the outer ones
module concentric_ripples_level_2d(size, k, steps=4, cell=6, strut=2, rings=0, first, centers=[[0, 0]], spokes=0, center=[0, 0]) {
    n = ripple_count(size + 2*[abs(center[0]), abs(center[1])], cell, rings, first, centers);
    ripple_rings_2d(1, ceil(n*(steps - k + 1)/steps), cell, strut, first, centers, spokes);
}

// ---------- fluted / reeded ribs ----------
// Parallel straight ribs, like a fluted column or a reeded vase. cell = rib pitch, strut = rib width (reeded) or
// groove width (fluted); strut = cell makes them touch, as on most reeded vases. orient: "vertical" = ribs along
// Y (upright on a wall built with lib/shell.scad), "horizontal" = along X.
// Its natural 3D form (see fluted_level_2d) has a rounded profile:
//   style "reeded"  convex half-round ribs standing on the surface
//   style "fluted"  concave half-round grooves sunk into a band of the relief height
//   style "ribbed"  flat-topped ribs (a plain extrusion)
// Cut through, the ribs are tied like flowing waves (ties every tie_pitch, staggered like brick bonds).
FLUTE_STYLES = ["reeded", "fluted", "ribbed"];
FLUTE_ORIENTS = ["vertical", "horizontal"];
FLUTE_FLOOR = 0.25;      // fluted style: groove bottoms stay this share of the relief height above the surface
module _flute_turn(orient, size, center) {
    if (orient == "vertical") rotate(90) children(); else children();
}
module fluted_2d(size, cell=6, strut=6, orient="vertical", tie_pitch=0, ties=0, center=[0, 0]) {
    v = orient == "vertical";
    s = v ? [size[1], size[0]] : size; c = v ? pat_rot(center, -90) : center;
    rotate(v ? 90 : 0) flowing_waves_2d(s, cell, min(strut, cell), 0, tie_pitch > 0 ? tie_pitch : 4*cell, 0, 0, c, ties);
}
// level k of `steps` of the rounded relief (extrude level k from 0 to k/steps of the relief height)
module fluted_level_2d(size, k, steps=6, cell=6, strut=6, style="reeded", orient="vertical", center=[0, 0]) {
    v = orient == "vertical";
    s = v ? [size[1], size[0]] : size; c = v ? pat_rot(center, -90) : center;
    t = (k - 0.5)/steps;                                          // height share this level stands for
    w = min(strut, cell);
    L = s[0] + 2*cell;
    rows = [pat_i0(s[1], cell, c[1], 2):pat_i1(s[1], cell, c[1], 2)];
    rotate(v ? 90 : 0) {
        if (style == "fluted") difference() {                     // concave grooves: the band minus each groove's
            translate(c) square([L, s[1] + 4*cell], center=true);   // width at this height; the grooves keep a floor of
            if (t > FLUTE_FLOOR) for (j=rows)                       // FLUTE_FLOOR x the relief height, so the band is one piece
                translate([c[0], j*cell]) square([L + 1, w*sqrt(1 - pow(1 - (t - FLUTE_FLOOR)/(1 - FLUTE_FLOOR), 2))], center=true);
        }
        else for (j=rows) translate([c[0], j*cell])                // convex ribs: narrower towards the top
            square([L, style == "ribbed" ? w : w*sqrt(1 - t*t)], center=true);
    }
}


// ----------------------- lib/patterns.scad -----------------------
// Parametric patterns for any flat surface: walls, floors, roofs, lids, panels, inserts.
// Use:  use <../../lib/patterns.scad>
//
// Three layers, so a project only picks a pattern by name and says how to apply it:
//   1. pattern engine      pattern_2d() / pattern_3d(): the bare pattern (generators in lib/patterns/*.scad)
//   2. surface application pattern_cutout_2d(), pattern_panel_2d(), pattern_relief(), pattern_cutter(),
//                          pattern_lining(), and pattern_panel(mode, ...) which builds a whole decorated panel
//   3. project geometry    the project places the result with ordinary translate() / rotate()
//
// Frame (every module here): the pattern lies in the XY plane, centred on the origin, inside the rectangle
// `size` = [x, y]. The decorated surface is the plane z = 0 with its outside towards +Z:
//   pattern_3d / pattern_relief   stand on z = 0 and rise to z = h
//   pattern_cutter                reaches from z = 0 down to z = -depth (subtract it from the host)
//   pattern_lining                lies on z = 0, t thick
//   pattern_panel                 is a slab from z = 0 to z = t with the decorated face on top (relief above t)
// To decorate a vertical wall, a sloped roof or any other flat face, build in this frame and then move it:
// e.g. rotate([90, 0, 0]) for a wall facing -Y. Nothing in here assumes a horizontal surface.
//
// Children: the modules take the surface outline as a 2D child (any shape inside `size`); without a child
// the outline is the rectangle `size`. pattern_2d / pattern_3d use the child only to clip the pattern.
//
// A pattern is described by a name or by a spec (one spec, many uses):
//   p = pattern_spec("hex_honeycomb", cell=12, strut=1.5, angle=15);
//   pattern_2d(p, [100, 80]);            pattern_2d("voronoi", [100, 80], cell=10, seed=7);

// ---------- option lists ----------
PATTERNS = ["hex_honeycomb", "square_grid", "diamond_lattice", "triangular_lattice",     // geometric lattices
            "cube_rosette",
            "basket_weave", "tri_weave",                                                  // woven (3D)
            "voronoi",                                                                    // organic
            "fish_scales", "truchet_arcs", "girih_star_cross", "asanoha",                 // decorative
            "flowing_waves", "concentric_ripples", "fluted"];                             // surface relief
PATTERN_MODES   = ["solid", "through_cut", "open_lattice", "raised", "recessed", "overlay"];   // pattern_panel(mode)
PATTERN_CUTS    = ["cells", "lines"];              // what a cut removes: the openings between the pattern, or the pattern itself
RELIEF_PROFILES = ["flat", "round"];               // top of raised elements
LINING_MODES    = ["through_cut", "raised", "recessed"];
LINING_EDGES    = ["square", "chamfer"];

// smallest printable rib and opening (mm); change them per spec with pattern_spec(min_strut=, min_opening=)
PAT_MIN_STRUT   = 0.8;
PAT_MIN_OPENING = 1.0;
PAT_EPS = 0.01;                                    // overlap between stacked layers, so they fuse

// ---------- pattern spec ----------
// [cell, strut] defaults: cell = repeat pitch, strut = rib / strip / line width (see lib/README.md for each pattern)
function pattern_default(name) =
    name == "hex_honeycomb" ? [12, 1.5] : name == "square_grid" ? [10, 1.5] :
    name == "diamond_lattice" ? [[12, 18], 1.5] : name == "triangular_lattice" ? [14, 1.5] :
    name == "basket_weave" ? [10, 7] : name == "tri_weave" ? [24, 3] :
    name == "voronoi" ? [14, 1.5] : name == "fish_scales" ? [[12, 12], 0.8] :
    name == "truchet_arcs" ? [12, 1.6] : name == "girih_star_cross" ? [24, 1.6] :
    name == "flowing_waves" ? [8, 2.4] : name == "concentric_ripples" ? [6, 2] :
    name == "cube_rosette" ? [10, 2] : name == "asanoha" ? [18, 1.2] : name == "fluted" ? [6, 6] : undef;
function pattern_known(name) = !is_undef(pattern_default(name));

// name      one of PATTERNS
// cell      repeat pitch, number or [x, y]          strut    rib / strip / line width, number or [a, b]
// angle     rotation of the pattern (degrees)       offset   [x, y] shift of the pattern (phase), in its own axes
// density   >1 = more, smaller cells (pitch = cell/density; strut unchanged)
// seed      for the patterns with random variation  scale    [x, y] stretch of the finished pattern (also stretches ribs)
// opts      pattern-specific settings as [["key", value], ...] (see pattern_opt_keys())
// min_strut, min_opening   printability limits checked by every module (0 = no check)
function pattern_spec(name, cell, strut, angle=0, offset=[0, 0], density=1, seed=1, scale=[1, 1], opts=[],
                      min_strut=PAT_MIN_STRUT, min_opening=PAT_MIN_OPENING) =
    assert(pattern_known(name), str("unknown pattern \"", name, "\"; choose one of ", PATTERNS))
    assert(density > 0, "pattern density must be above 0")
    [name, is_undef(cell) ? pattern_default(name)[0] : cell, is_undef(strut) ? pattern_default(name)[1] : strut,
     angle, offset, density, seed, pat_xy(scale), opts, min_strut, min_opening];
// A spec sized from the pattern's defaults, for projects that let the user leave sizes at 0 ("automatic"):
// k scales the default cell and rib together; cell > 0 sets the cell (two-size cells keep their proportion);
// strut > 0 sets the rib width, otherwise it is the scaled default but not below strut_min.
function pattern_sized(name, k=1, cell=0, strut=0, angle=0, seed=1, opts=[], strut_min=0,
                       min_strut=PAT_MIN_STRUT, min_opening=PAT_MIN_OPENING) = let(
    d = pattern_default(name), d0 = is_list(d[0]) ? d[0][0] : d[0], kc = cell > 0 ? cell/d0 : k)
    pattern_spec(name, is_list(d[0]) ? [for (x=d[0]) x*kc] : d[0]*kc,
                 strut > 0 ? strut : name == "basket_weave" ? d[1]*k : max(strut_min, d[1]*k),
                 angle, seed=seed, opts=opts, min_strut=min_strut, min_opening=min_opening);
// settings each pattern reads from opts (anything else is ignored)
function pattern_opt_keys(name) =
    name == "hex_honeycomb" ? ["orient"] : name == "square_grid" ? ["stagger"] :
    name == "triangular_lattice" ? ["alternate", "orient"] :
    name == "basket_weave" || name == "tri_weave" ? ["lift", "style"] :
    name == "voronoi" ? ["irregularity", "min_cell", "round"] :
    name == "fish_scales" ? ["overlap", "curvature", "stagger", "shingle", "steps"] :
    name == "truchet_arcs" ? ["variation", "bias"] : name == "girih_star_cross" ? ["star", "star_ratio"] :
    name == "flowing_waves" ? ["amplitude", "wavelength", "phase", "shift", "ties"] :
    name == "concentric_ripples" ? ["rings", "first", "centers", "spokes", "falloff", "steps"] :
    name == "cube_rosette" ? ["cubes"] : name == "asanoha" ? ["orient"] :
    name == "fluted" ? ["style", "orient", "steps", "tie_pitch", "ties"] : [];
function pat_opt(opts, key, default) = let(r = [for (e=opts) if (e[0] == key) e[1]]) len(r) > 0 ? r[0] : default;

// a name (plus the common settings given as arguments) or a ready spec -> spec
function _ps(p, cell, strut, angle, seed, opts) = is_string(p)
    ? pattern_spec(p, cell, strut, is_undef(angle) ? 0 : angle, seed=is_undef(seed) ? 1 : seed, opts=is_undef(opts) ? [] : opts) : p;
function _pc(s) = s[1]/s[5];                                   // effective cell
function _po(s, key, default) = pat_opt(s[8], key, default);

function pattern_is_3d(p) = let(n = is_string(p) ? p : p[0]) n == "basket_weave" || n == "tri_weave";
// true if the pattern's material forms one network that reaches the edge of any outline (so it can stand
// alone as an open lattice or stay in one piece when its cells are cut through)
function pattern_is_connected(p) = let(s = _ps(p), n = s[0])
    n == "truchet_arcs" ? false : n == "concentric_ripples" ? let(sp = _po(s, "spokes", undef)) is_undef(sp) || sp > 0 :
    n == "fluted" ? let(t = _po(s, "ties", undef)) is_undef(t) || t > 0 : true;
// Line patterns need ties when they are cut through: without them the lines only hang on the frame (they
// would print as long bridges and flex). Wherever the cells are cut out, a spec that does not say otherwise gets
// them: flowing_waves ties = 1 (a bar between neighbouring ribs every wavelength), fluted ties = 1 (every
// tie_pitch, default 4 ribs), concentric_ripples spokes = 6.
// Set opts ["ties", 0] / ["spokes", 0] to switch them off, or a number to choose. Reliefs are left as they are.
function pattern_tied(p) = let(s = _ps(p), add =
    (s[0] == "flowing_waves" || s[0] == "fluted") && is_undef(_po(s, "ties", undef)) ? [["ties", 1]] :
    s[0] == "concentric_ripples" && is_undef(_po(s, "spokes", undef)) ? [["spokes", 6]] : [])
    len(add) == 0 ? s : [for (i=[0:len(s)-1]) i == 8 ? concat(s[8], add) : s[i]];
// Wrapping a pattern round a closed wall: it only closes without a seam if it repeats after exactly the length
// of the wall. pattern_period(p) = the length along X after which a pattern repeats (0 = it does not).
// pattern_wrapped(p, L) = the same pattern, adjusted as little as possible so that L is a whole number of
// repeats: the cell size is scaled by a few percent (rib widths stay), flowing waves get a fitting wavelength,
// and the random patterns (voronoi, truchet_arcs) are made to repeat after L. Rotated or stretched patterns and
// concentric ripples are returned unchanged (they cannot be made to repeat this way).
function pattern_period(p) = let(s = _ps(p), n = s[0], c = pat_xy(_pc(s))[0])
    n == "hex_honeycomb" ? (_po(s, "orient", "pointy") == "flat" ? c*sqrt(3) : c) :
    n == "triangular_lattice" ? (_po(s, "orient", "up") == "side" ? c*sqrt(3) : c) :
    n == "basket_weave" ? 2*c : n == "tri_weave" ? c/sin(60) :
    n == "truchet_arcs" ? 2*c :
    n == "flowing_waves" ? _po(s, "wavelength", 30) : n == "concentric_ripples" ? 0 :
    n == "cube_rosette" ? 3*sqrt(3)*c :                        // the cube / rosette colouring repeats every third hexagon
    n == "asanoha" ? (_po(s, "orient", "up") == "side" ? c*sqrt(3) : c) :
    n == "fluted" ? (_po(s, "orient", "vertical") == "vertical" ? c : 0) : c;
function pattern_wrapped(p, L) = let(s = _ps(p), per = pattern_period(s))
    s[3] != 0 || s[7] != [1, 1] || per <= 0 ? s : let(
        n = max(1, round(L/per)), k = L/(n*per),
        add = s[0] == "flowing_waves" ? [["wavelength", L/n]] :
              s[0] == "voronoi" ? [["wrap", n]] : s[0] == "truchet_arcs" ? [["wrap", 2*n]] : [],
        cell = s[0] == "flowing_waves" ? s[1] : is_list(s[1]) ? [for (x=s[1]) x*k] : s[1]*k,
        strut = s[0] == "fluted" && pat_xy(s[2])[0] >= pat_xy(s[1])[0] - 0.001 ? s[2]*k : s[2])   // touching ribs stay touching
        [for (i=[0:len(s)-1]) i == 1 ? cell : i == 2 ? strut : i == 8 ? concat(add, s[8]) : s[i]];
// the same pattern moved by d = [x, y] on the surface (the anchor of the pattern goes to d)
function pattern_shift(p, d) = let(s = _ps(p), q = pat_rot(d, -s[3])) [for (i=[0:len(s)-1]) i == 4 ? s[4] + q : s[i]];

// ---------- printability ----------
// [smallest rib width, smallest opening] of a spec
function pattern_features(p) = let(s = _ps(p), n = s[0], c = pat_xy(_pc(s)), st = pat_xy(s[2]))
    n == "hex_honeycomb" ? [st[0], c[0] - st[0]] :
    n == "square_grid" ? [min(st), min(c[0] - st[0], c[1] - st[1])] :
    n == "diamond_lattice" ? [st[0], 2*(c[0]*c[1]/4/norm(c/2) - st[0]/2)] :
    n == "triangular_lattice" ? [st[0], 2*(c[0]/(2*sqrt(3)) - st[0]/2)] :
    n == "basket_weave" ? [st[0], c[0] - st[0]] :
    n == "tri_weave" ? [st[0], tri_weave_opening(c[0], st[0])] :
    n == "voronoi" ? [st[0], c[0]/2 - st[0]] :
    n == "fish_scales" ? [st[0], min(c[0], fish_row_pitch(c, _po(s, "overlap", 0.4))) - st[0]] :
    n == "truchet_arcs" ? [st[0], c[0]/2 - st[0]] :
    n == "girih_star_cross" ? [st[0], 0.29*_po(s, "star", c[0]) - st[0]] :
    n == "flowing_waves" ? [st[0], wave_gap(c[0], st[0], _po(s, "amplitude", 3), _po(s, "wavelength", 30), _po(s, "shift", 0))] :
    n == "cube_rosette" ? [st[0], _po(s, "cubes", "sparse") == "all" ? 2*(c[0]*sin(60)/2 - st[0]/2) : 2*(c[0]/(2*sqrt(3)) - st[0]/2)] :
    n == "asanoha" ? [st[0], asanoha_opening(c[0], st[0])] :
    n == "fluted" ? [min(st[0], c[0]), c[0] - st[0]] :
    [st[0], c[0] - st[0]];
// "" if the spec is printable, otherwise what is wrong (use in an assert, or show it to the user)
function pattern_problem(p) = let(s = _ps(p), f = pattern_features(s), closed = (s[0] == "basket_weave" && f[1] < 0.001) || (s[0] == "fluted" && f[1] < s[10]))   // closed weave / touching ribs: fine
    s[9] > 0 && f[0] < s[9] - 0.001 ? str(s[0], ": rib/strip width ", f[0], " is below min_strut ", s[9]) :
    f[1] < -0.001 && !closed ? str(s[0], ": strut ", s[2], " does not fit into cell ", _pc(s), " (elements overlap)") :
    s[10] > 0 && !closed && f[1] < s[10] - 0.001 ? str(s[0], ": openings are about ", f[1], " wide, below min_opening ", s[10],
        " (larger cell, thinner strut, or lower density)") : "";

// ---------- layer 1: pattern engine ----------
// the bare 2D pattern (material), generated to cover `cover` around the origin, in the pattern's own axes
module _pat_gen_2d(s, cover, g=[0, 0]) {
    n = s[0]; c = _pc(s); st = s[2];
    if (n == "hex_honeycomb") hex_honeycomb_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "orient", "pointy"), center=g);
    else if (n == "square_grid") square_grid_2d(cover, c, st, _po(s, "stagger", 0), center=g);
    else if (n == "diamond_lattice") diamond_lattice_2d(cover, c, pat_xy(st)[0], center=g);
    else if (n == "triangular_lattice") triangular_lattice_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "alternate", true), _po(s, "orient", "up"), center=g);
    else if (n == "basket_weave") basket_weave_2d(cover, pat_xy(c)[0], pat_xy(st)[0], center=g);
    else if (n == "tri_weave") tri_weave_2d(cover, pat_xy(c)[0], pat_xy(st)[0], center=g);
    else if (n == "voronoi") voronoi_2d(cover, pat_xy(c)[0], pat_xy(st)[0], s[6], _po(s, "irregularity", 1), _po(s, "min_cell", 0), _po(s, "round", 0), center=g, wrap=_po(s, "wrap", 0));
    else if (n == "fish_scales") fish_scales_2d(cover, pat_xy(c), pat_xy(st)[0], _po(s, "overlap", 0.4), _po(s, "curvature", 0.7), _po(s, "stagger", 0.5), center=g);
    else if (n == "truchet_arcs") truchet_arcs_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "variation", "random"), s[6], _po(s, "bias", 0.5), center=g, wrap=_po(s, "wrap", 0));
    else if (n == "girih_star_cross") girih_star_cross_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "star", undef), _po(s, "star_ratio", undef), center=g);
    else if (n == "flowing_waves") flowing_waves_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "amplitude", 3), _po(s, "wavelength", 30), _po(s, "phase", 0), _po(s, "shift", 0), center=g, ties=_po(s, "ties", 0));
    else if (n == "cube_rosette") cube_rosette_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "cubes", "sparse"), center=g);
    else if (n == "asanoha") asanoha_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "orient", "up"), center=g);
    else if (n == "fluted") fluted_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "orient", "vertical"), _po(s, "tie_pitch", 0), _po(s, "ties", 0), center=g);
    else if (n == "concentric_ripples") concentric_ripples_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "rings", 0), _po(s, "first", undef), _po(s, "centers", [[0, 0]]), _po(s, "spokes", 0), center=g);
}
// relief levels: most patterns are one flat level; fish scales rise towards their tips, ripples fall off outwards,
// fluted / reeded ribs are round
function pattern_levels(p) = let(s = _ps(p), n = s[0])
    n == "fluted" && _po(s, "style", "reeded") != "ribbed" ? _po(s, "steps", 6) :
    n == "fish_scales" && _po(s, "shingle", true) ? _po(s, "steps", 3) :
    n == "concentric_ripples" && _po(s, "falloff", 0) > 0 ? _po(s, "steps", 4) : 1;
function _pat_level_top(s, k, K) = s[0] == "concentric_ripples" ? 1 - _po(s, "falloff", 0)*(K - k)/K : k/K;   // share of h
module _pat_level_2d(s, cover, k, K, g=[0, 0]) {
    n = s[0]; c = _pc(s); st = s[2];
    if (K == 1) _pat_gen_2d(s, cover, g);
    else if (n == "fluted") fluted_level_2d(cover, k, K, pat_xy(c)[0], pat_xy(st)[0], _po(s, "style", "reeded"), _po(s, "orient", "vertical"), center=g);
    else if (n == "fish_scales") fish_scales_level_2d(cover, k, K, pat_xy(c), _po(s, "overlap", 0.4), _po(s, "curvature", 0.7), _po(s, "stagger", 0.5), center=g);
    else concentric_ripples_level_2d(cover, k, K, pat_xy(c)[0], pat_xy(st)[0], _po(s, "rings", 0), _po(s, "first", undef), _po(s, "centers", [[0, 0]]), _po(s, "spokes", 0), center=g);
}
module _pat_weave_3d(s, cover, h, g=[0, 0]) {
    c = pat_xy(_pc(s))[0]; w = pat_xy(s[2])[0];
    if (s[0] == "basket_weave") basket_weave_3d(cover, h, c, w, _po(s, "lift", undef), _po(s, "style", "flat"), g);
    else tri_weave_3d(cover, h, c, w, _po(s, "lift", undef), _po(s, "style", "flat"), g);
}
// Window: set the special variable $pat_window = [[cx, cy], [w, h]] around any module of this file to build only
// that part of the surface. The result is exactly the piece of the full pattern, panel or lining inside the
// window (frames and outlines are still worked out on the whole surface). lib/shell.scad uses this to bend a
// panel round corners piece by piece; use it yourself to split a large panel into printable tiles.
function _pat_win(size) = is_undef($pat_window) ? [[0, 0], size] : $pat_window;
// area the generator must cover (in its own axes) to fill a window of `wsize`, and the point it must cover it around
function _pat_cover(s, wsize) = let(a = s[3]) [(abs(wsize[0]*cos(a)) + abs(wsize[1]*sin(a)))/s[7][0], (abs(wsize[0]*sin(a)) + abs(wsize[1]*cos(a)))/s[7][1]];
function _pat_gcenter(s, wc) = let(q = pat_rot(wc, -s[3]) - s[4]) [q[0]/s[7][0], q[1]/s[7][1]];
module _pat_place(s) { rotate(s[3]) translate(s[4]) scale(s[7]) children(); }
// the surface rectangle, cut down to the window
module _pat_rect(size) {
    if (is_undef($pat_window)) square(size, center=true);
    else intersection() { square(size, center=true); translate($pat_window[0]) square($pat_window[1], center=true); }
}
// clip finished 2D geometry to the window (nothing to do without one)
// $pat_shrink (optional, with a window) pulls the piece's material in by that much. Pieces that overlap at an
// angle (facets of a bent wall) get different values, so their surfaces cross cleanly instead of almost coinciding.
module _pat_w() {
    if (is_undef($pat_window)) children();
    else if (is_undef($pat_shrink) || $pat_shrink == 0) intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
    else offset(delta=-$pat_shrink) intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
}
// shrink only (for 2D that is already cut to the window)
module _pat_s() { if (is_undef($pat_window) || is_undef($pat_shrink) || $pat_shrink == 0) children(); else offset(delta=-$pat_shrink) children(); }
// clip only, no shrink: for shapes that are cut OUT of the material (their edges move with the material's)
module _pat_wc() {
    if (is_undef($pat_window)) children();
    else intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
}
// the placed pattern, generated for the window only
module _pat_field(s, size) { w = _pat_win(size); _pat_place(s) _pat_gen_2d(s, _pat_cover(s, w[1]), _pat_gcenter(s, w[0])); }
// inset of an outline: b = one distance all round, or [sides, bottom, top] / [x, y] for different frame widths
// (the list form moves the outline instead of offsetting it, so a wavy top edge keeps a band of constant height)
function _pat_b3(b) = is_list(b) ? (len(b) > 2 ? b : [b[0], b[1], b[1]]) : [b, b, b];
function _pat_badd(b, d) = is_list(b) ? [for (x=b) max(0, x + d)] : max(0, b + d);
module _pat_inset(b) {
    if (is_list(b)) { q = _pat_b3(b); intersection() { translate([q[0], 0]) children(); translate([-q[0], 0]) children(); translate([0, q[1]]) children(); translate([0, -q[2]]) children(); } }
    else if (b == 0) children();
    else offset(delta=-b) children();
}
module _pat_check(s, size) {
    assert(is_list(size) && len(size) == 2 && size[0] > 0 && size[1] > 0, "pattern: size must be [x, y]");
    assert(pattern_problem(s) == "", pattern_problem(s));
}

// 2D pattern (the material: ribs, lines, strands seen from above), clipped to `size` and to the child outline.
// Use it with linear_extrude(), difference(), intersection(), union() like any other 2D shape.
module pattern_2d(p, size, cell, strut, angle, seed, opts) {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_2d(s, size) children(); else _pattern_2d(s, size) square(size, center=true);
}
module _pattern_2d(s, size) {
    intersection() { _pat_rect(size); children(); _pat_field(s, size); }
}
module _pattern_level(s, size, k, K) {
    w = _pat_win(size);
    intersection() { _pat_rect(size); children(); _pat_place(s) _pat_level_2d(s, _pat_cover(s, w[1]), k, K, _pat_gcenter(s, w[0])); }
}

// 3D pattern in its natural form, standing on z = 0, h high in total, clipped like pattern_2d:
// woven patterns as real over-under strands, fish scales as stepped shingles, ripples with falloff, all others
// as a plain extrusion. profile "round" rounds the top of flat ribs in `steps` layers.
module pattern_3d(p, size, h=2, cell, strut, angle, seed, opts, profile="flat", steps=3) {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_3d(s, size, h, profile, steps) children();
    else _pattern_3d(s, size, h, profile, steps) square(size, center=true);
}
module _pattern_3d(s, size, h, profile="flat", steps=3) {
    K = pattern_levels(s);
    if (pattern_is_3d(s)) intersection() {
        w = _pat_win(size);
        _pat_place(s) _pat_weave_3d(s, _pat_cover(s, w[1]), h, _pat_gcenter(s, w[0]));
        translate([0, 0, -1]) linear_extrude(h + 2) intersection() { _pat_rect(size); children(); }
    }
    else if (K == 1 && profile == "round") {
        r = min(h, pat_xy(s[2])[0]/2);                                // rounding radius of the rib tops
        linear_extrude(h - r + PAT_EPS) _pat_s() _pattern_2d(s, size) children();
        for (i=[1:steps]) let(a = 90*i/steps, a0 = 90*(i - 1)/steps)
            linear_extrude(h - r + r*sin(a)) offset(delta=-r*(1 - cos(a0)) - (i == 1 ? 0 : PAT_EPS)) _pat_s() _pattern_2d(s, size) children();
    }
    else for (k=[1:K]) linear_extrude(h*_pat_level_top(s, k, K)) _pat_s() _pattern_level(s, size, k, K) children();
}

// ---------- layer 2: surface application ----------
module _pat_outline(size) { intersection() { square(size, center=true); children(); } }
// remove slivers narrower than e from a 2D shape (openings cut off by the edge of the surface)
module _pat_open(e) { if (e > 0) offset(delta=e/2) offset(delta=-e/2) children(); else children(); }

// 2D shape to cut out of a surface so the pattern stays: the openings between the pattern ("cells") or the
// pattern itself ("lines"), kept `inset` away from the edge of the outline. Openings narrower than the spec's
// min_opening (slivers at the edge) are left closed.
module pattern_cutout_2d(p, size, cell, strut, angle, seed, opts, inset=0, cut="cells") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_cutout_2d(s, size, inset, cut) children();
    else _pattern_cutout_2d(s, size, inset, cut) square(size, center=true);
}
module _pattern_cutout_2d(s, size, inset=0, cut="cells") {
    if (cut == "lines") _pat_wc() intersection() { _pat_inset(inset) _pat_outline(size) children(); _pat_field(s, size); }
    else _pat_wc() _pat_open(s[10]) difference() { _pat_inset(inset) _pat_outline(size) children(); _pat_field(pattern_tied(s), size); }
}
// 2D open lattice: the outline with the cells cut out, leaving the pattern and a closed frame `border` wide
module pattern_panel_2d(p, size, cell, strut, angle, seed, opts, border=2, cut="cells") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_panel_2d(s, size, border, cut) children();
    else _pattern_panel_2d(s, size, border, cut) square(size, center=true);
}
module _pattern_panel_2d(s, size, border=2, cut="cells") {
    _pat_w() difference() { _pat_outline(size) children(); _pattern_cutout_2d(s, size, border, cut) children(); }
}

// raised pattern to add on a surface at z = 0: h high, kept `pad` away from the edge of the outline.
// It starts a hair below z = 0 so it fuses with the host.
module pattern_relief(p, size, h=0.8, cell, strut, angle, seed, opts, pad=0, profile="flat", steps=3) {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_relief(s, size, h, pad, profile, steps) children();
    else _pattern_relief(s, size, h, pad, profile, steps) square(size, center=true);
}
module _pattern_relief(s, size, h, pad=0, profile="flat", steps=3) {
    translate([0, 0, -PAT_EPS]) _pattern_3d(s, size, h + PAT_EPS, profile, steps) _pat_inset(pad) children();
}

// cutter to subtract from a host whose surface is z = 0 (body below): engraves the pattern ("lines") or cuts
// its openings ("cells") `depth` deep; for a through-cut give the wall thickness or more.
module pattern_cutter(p, size, depth=0.6, cell, strut, angle, seed, opts, pad=0, cut="lines") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    translate([0, 0, -depth]) linear_extrude(depth + PAT_EPS)
        if ($children > 0) _pattern_cutout_2d(s, size, pad, cut) children();
        else _pattern_cutout_2d(s, size, pad, cut) square(size, center=true);
}

// lining / overlay: a separate decorative skin lying on a surface at z = 0.
// t = skin thickness, inset = distance from the edge of the surface to the edge of the skin, border = plain
// frame around the pattern, mode: "through_cut" = perforated skin (the cells are open, the host shows through),
// "raised" = closed skin with the pattern raised by `depth` on it, "recessed" = pattern engraved `depth` deep
// into the skin. edge "chamfer" steps the top edge in by t/2.
module pattern_lining(p, size, t=0.6, cell, strut, angle, seed, opts, mode="through_cut", depth=0.4, inset=1.5, border=1.5,
                      edge="square", profile="flat") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_lining(s, size, t, mode, depth, inset, border, edge, profile) children();
    else _pattern_lining(s, size, t, mode, depth, inset, border, edge, profile) square(size, center=true);
}
module _pattern_lining(s, size, t, mode, depth, inset, border, edge, profile) {
    assert(mode != "through_cut" || pattern_is_connected(s), str(s[0], " leaves loose pieces when cut through: use raised or recessed", s[0] == "concentric_ripples" ? ", or add spokes" : ""));
    assert(mode != "recessed" || depth < t, str("lining: recess depth ", depth, " must be less than the lining thickness ", t));
    ch = edge == "chamfer" ? t/2 : 0;                    // chamfer height = how far the top steps in
    cut_d = mode == "through_cut" ? t : mode == "recessed" ? depth : 0;
    zc = t - cut_d; zh = t - ch;                         // where the cut and the chamfer start
    zs = [0, min(zc, zh), max(zc, zh), t];               // layers: plain / cut and / or stepped in
    translate([0, 0, -PAT_EPS]) for (i=[0:2]) if (zs[i+1] - zs[i] > 0.001)
        translate([0, 0, zs[i]]) linear_extrude(zs[i+1] - zs[i] + PAT_EPS) _pat_w() difference() {
            offset(delta=-inset - (ch > 0 && zs[i] >= zh - 0.001 ? ch : 0)) _pat_outline(size) children();
            if (cut_d > 0 && zs[i] >= zc - 0.001) _pattern_cutout_2d(s, size, _pat_badd(border, inset), mode == "through_cut" ? "cells" : "lines") children();
        }
    if (mode == "raised") translate([0, 0, t]) _pattern_relief(s, size, depth, _pat_badd(border, inset), profile) children();
}

// a complete flat panel from an outline: slab z = 0..t, decorated face on top.
//   "solid"         plain slab
//   "through_cut"   the pattern's cells cut through the slab, `border` + `pad` of solid edge left
//   "open_lattice"  only the pattern and a frame `border` wide, no backing (woven patterns: real strands, t high)
//   "raised"        slab plus the pattern raised by `depth`, kept `border` + `pad` from the edge
//   "recessed"      the pattern engraved `depth` deep into the slab
//   "overlay"       slab plus a lining (lining_t thick; lining_mode, depth, inset = pad, border)
module pattern_panel(mode, p, size, t=2, cell, strut, angle, seed, opts, depth=0.8, border=2, pad=0, profile="flat",
                     lining_t=0.6, lining_mode="through_cut", lining_edge="square") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_panel(mode, s, size, t, depth, border, pad, profile, lining_t, lining_mode, lining_edge) children();
    else _pattern_panel(mode, s, size, t, depth, border, pad, profile, lining_t, lining_mode, lining_edge) square(size, center=true);
}
module _pattern_panel(mode, s, size, t, depth, border, pad, profile, lining_t, lining_mode, lining_edge) {
    assert(len([for (m=PATTERN_MODES) if (m == mode) m]) == 1, str("unknown pattern mode \"", mode, "\"; choose one of ", PATTERN_MODES));
    open = mode == "through_cut" || mode == "open_lattice";
    assert(!open || pattern_is_connected(s), str(s[0], " leaves loose pieces as ", mode, ": use raised, recessed or overlay", s[0] == "concentric_ripples" ? ", or add spokes" : ""));
    assert(mode != "recessed" || depth < t, str("panel: recess depth ", depth, " must be less than the thickness ", t));
    if (mode == "solid") linear_extrude(t) _pat_w() _pat_outline(size) children();
    else if (mode == "open_lattice" && pattern_is_3d(s)) {
        linear_extrude(t) _pat_w() difference() { _pat_outline(size) children(); _pat_inset(border) _pat_outline(size) children(); }
        _pattern_3d(s, size, t) _pat_inset(_pat_badd(_pat_badd(border, pad), -0.3)) children();     // strands reach 0.3 into the frame
    }
    else if (open) linear_extrude(t) _pattern_panel_2d(s, size, _pat_badd(border, pad)) children();
    else if (mode == "raised") {
        linear_extrude(t) _pat_w() _pat_outline(size) children();
        translate([0, 0, t]) _pattern_relief(s, size, depth, _pat_badd(border, pad), profile) children();
    }
    else if (mode == "recessed") {
        linear_extrude(t - depth) _pat_w() _pat_outline(size) children();
        translate([0, 0, t - depth - PAT_EPS]) linear_extrude(depth + PAT_EPS) _pat_w()
            difference() { _pat_outline(size) children(); _pattern_cutout_2d(s, size, _pat_badd(border, pad), "lines") children(); }
    }
    else {
        linear_extrude(t) _pat_w() _pat_outline(size) children();
        translate([0, 0, t]) _pattern_lining(s, size, lining_t, lining_mode, depth, pad, border, lining_edge, profile) children();
    }
}


// ----------------------- lib/thread.scad -----------------------
// Printable screw threads, nuts and knobs: clamp screws, lids, adjusters, levelling feet.
// Use:  use <../../lib/thread.scad>
// Frame: the thread's axis is +Z, it starts at z = 0 and runs up to z = len.
//
// Metric threads with the ISO coarse pitch (THREAD_ISO), a 60 degree profile with flat crests and roots. Printed
// threads need play: the rod is made `clr` smaller and the hole (thread_cutter) `clr` larger on the radius.
// Print rods standing (axis vertical); a threaded hole prints best with its axis vertical too. Below about M8,
// printed threads are weak: use a real bolt and a captive nut (thread_nut_trap) instead.
//
// The thread is built as one surface whose radius follows the helical profile, so it is always a single closed,
// manifold solid and renders fast in OpenSCAD 2021.

// [name, diameter, pitch] (ISO 261 coarse series)
THREAD_ISO = [["M6", 6, 1], ["M8", 8, 1.25], ["M10", 10, 1.5], ["M12", 12, 1.75], ["M16", 16, 2],
              ["M20", 20, 2.5], ["M24", 24, 3], ["M30", 30, 3.5]];
THREAD_SIZES = ["M6", "M8", "M10", "M12", "M16", "M20", "M24", "M30"];
THREAD_CLR = 0.25;          // play per side between a printed rod and a printed hole
function thread_clr() = THREAD_CLR;      // (for files that `use` this one: they cannot see its variables)
KNOB_STYLES = ["wave", "knurl", "round"];

function thread_spec(name) = let(r = [for (t=THREAD_ISO) if (t[0] == name) t]) len(r) > 0 ? r[0] : THREAD_ISO[4];
function thread_d(name) = thread_spec(name)[1];
function thread_pitch(name) = thread_spec(name)[2];
function thread_depth(pitch) = 0.5413*pitch;          // ISO basic profile: 5/8 of the fundamental triangle height

// radius of the threaded surface at angle a (degrees) and height z: crest share 1/8, root share 1/4 of the pitch
function _thr_r(d, p, a, z) = let(f = ((z/p - a/360)%1 + 1)%1, h = thread_depth(p),
    t = f < 0.125 ? 1 : f < 0.5 ? 1 - (f - 0.125)/0.375 : f < 0.75 ? 0 : (f - 0.75)/0.25)
    d/2 - h + h*t;
// the threaded solid: rod of nominal diameter d (minus 2*clr), pitch p, length len; chamfer = 45 degree lead-in at
// both ends (0 = none). grow > 0 makes a cutter for a threaded hole (the same surface, larger).
module thread_solid(d, p, len, grow=0, chamfer=true, fn=48) {
    n = fn; k = max(2, ceil(len/(p/8)));
    ch = chamfer ? thread_depth(p) : 0;
    pts = concat(
        [for (j=[0:k]) let(z = len*j/k) for (i=[0:n-1]) let(a = 360*i/n,
            r = _thr_r(d, p, a, z) + grow,
            cut = d/2 + grow - (ch > 0 ? max(0, ch - min(z, len - z)) : 0))   // chamfered ends: the crest is cut down
            [min(r, cut)*cos(a), min(r, cut)*sin(a), z]],
        [[0, 0, 0], [0, 0, len]]);
    c0 = (k + 1)*n; c1 = c0 + 1;
    faces = concat(
        [for (j=[0:k-1]) for (i=[0:n-1]) each [[j*n + i, (j+1)*n + (i+1)%n, j*n + (i+1)%n], [j*n + i, (j+1)*n + i, (j+1)*n + (i+1)%n]]],
        [for (i=[0:n-1]) [c0, i, (i+1)%n]],
        [for (i=[0:n-1]) [c1, k*n + (i+1)%n, k*n + i]]);
    polyhedron(pts, faces, convexity=4);
}
// a printed threaded rod of size `name` (THREAD_SIZES), `len` long
module thread_rod(name="M16", len=30, clr=THREAD_CLR) {
    thread_solid(thread_d(name) - 2*clr, thread_pitch(name), len);
}
// cutter for a threaded hole of size `name`, `len` deep (reaches 0.01 past both ends); countersink = lead-in cone
module thread_cutter(name="M16", len=20, clr=THREAD_CLR, countersink=true) {
    d = thread_d(name); p = thread_pitch(name);
    translate([0, 0, -0.01]) thread_solid(d, p, len + 0.02, grow=clr, chamfer=false);
    if (countersink) for (z=[0, len]) translate([0, 0, z]) cylinder(d1=z == 0 ? d + 2*clr + 1 : d - 2*thread_depth(p), d2=z == 0 ? d - 2*thread_depth(p) : d + 2*clr + 1,
        h=(1 + 2*clr + 2*thread_depth(p))/2, center=true, $fn=61);   // 61: no vertex in line with the thread's 48
}
// pocket for a real hex nut (across flats s, height h), axis +Z from z = 0 (cutter)
module thread_nut_trap(s=13, h=6.5, clr=0.2) { cylinder(d=(s + 2*clr)/cos(30), h=h + clr, $fn=6); }

// grip knob, axis +Z from z = 0: "wave" = wavy rim (as on many printed clamps), "knurl" = straight ridges,
// "round" = plain with a rounded top edge
module thread_knob(d=30, h=12, style="wave", waves=8) {
    if (style == "round") hull() { cylinder(d=d, h=h - 1.5, $fn=72); cylinder(d=d - 3, h=h, $fn=72); }
    else if (style == "knurl") linear_extrude(h) polygon([for (i=[0:71]) let(a = i*5, r = d/2 - (i%3 == 0 ? 1.2 : 0)) r*[cos(a), sin(a)]]);
    else for (s=[0, 1]) translate([0, 0, s*h/2]) linear_extrude(h/2 + (s == 0 ? 0.01 : 0), twist=(s == 0 ? 1 : -1)*180/waves, slices=8)
        rotate(s == 0 ? 0 : -180/waves) polygon([for (i=[0:143]) let(a = i*2.5) (d/2 - 1.2 + 1.2*cos(a*waves))*[cos(a), sin(a)]]);
}


// ----------------------- lib/attach.scad -----------------------
// Universal attachment plates: one socket in a host's back, many interchangeable plates.
// Use:  use <../../lib/attach.scad>
//
// How it works: push the plate straight into the socket and it snaps in. Each end of the plate (top and
// bottom) has two flexible arms with a bump on a 45° lead-in. The bumps bend the arms inward through the
// socket mouth and click into grooves in the socket's end walls. The plate's solid corners carry the load,
// not the arms, so hanging or standing cannot unsnap it. To remove it, lever it out with a flat
// screwdriver in the notch below the plate.
//
// Conventions (host frame): the host's back face is z=0 and its body is z>0. The plate is drawn seated,
// centred on the origin; it fills z=0..ATTACH_T and its features point to -z (the wall). +Y is up when the
// host hangs. The socket reaches from y=-l/2-ATTACH_NOTCH (pry notch) to y=+l/2.


ATTACH_TYPES = ["none", "wall", "keyhole", "skadis", "hook", "magnet", "stand", "flat", "roof", "slide", "fin", "clamp", "pipe"];
PIPE_AXES = ["horizontal", "vertical"];
ATTACH_JOINTS = ["none", "ball"];        // optional ball joint between the host and the plate (any type)
SLIDE_AXES    = ["horizontal", "vertical"];
ATTACH_SIZES = ["S", "M", "L"];
ATTACH_T     = 4.0;   // socket depth = plate core thickness (the snap grooves reach 3.5 mm deep; 0.5 mm above them)
ATTACH_BACK  = 1.2;   // closed host wall behind a socket (3 perimeters): a host needs ATTACH_T + ATTACH_BACK = 5.2 mm
ATTACH_CLR   = 0.2;   // plate-to-socket clearance per face
ATTACH_NOTCH = 3;     // pry notch below the plate
SNAP_LIP     = 1.5;   // socket mouth wall above the groove
SNAP_B       = 0.8;   // bump height (arm deflection on the way in = SNAP_B - ATTACH_CLR)
SNAP_ARM     = 1.2;   // arm thickness
SNAP_GAP     = 1.0;   // slot behind each arm
SNAP_CORNER  = 4;     // solid corners at each end of the arms (they carry the load)
SNAP_BUMP    = 6;     // bump length along each arm, at its free tip

function attach_dims(size) = size == "S" ? [30, 30] : size == "L" ? [60, 50] : [45, 40];   // [w (x), l (y)]
function attach_socket_len(size) = attach_dims(size)[1] + ATTACH_NOTCH;                   // socket length (y)
function attach_socket_w(size) = attach_dims(size)[0];                                     // socket width (x)
function attach_depth() = ATTACH_T;
function attach_host_t() = ATTACH_T + ATTACH_BACK;          // host thickness a socket needs (socket + closed back)
function attach_strip() = ATTACH_CLR + SNAP_ARM + SNAP_GAP;    // end strips taken by the snap arms (keep features out)
// bump profile, (y outward, z): retention ramp, flat top, 45° lead-in towards +z (the way in)
function snap_z0() = SNAP_LIP + 0.05 + 0.35*SNAP_B;   // ramp foot just inside the groove: no preload when seated
function snap_z1() = snap_z0() + 0.35*SNAP_B + 0.4 + SNAP_B;
function snap_groove() = [SNAP_LIP, snap_z1() + ATTACH_CLR];   // groove z range in the socket

// ---------- host side ----------
// cutter for the host: subtract it from the host body (back face z=0)
module attach_socket(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; g = snap_groove();
    translate([-w/2, -l/2, -1]) cube([w, l, ATTACH_T + 1]);                                   // pocket
    for (s=[-1,1]) translate([-w/2 + SNAP_CORNER - 0.5, s > 0 ? l/2 - 0.01 : -l/2 - SNAP_B - 0.01, g[0]])
        cube([w - 2*SNAP_CORNER + 1, SNAP_B + 0.02, g[1] - g[0]]);                            // snap grooves
    translate([-4, -l/2 - ATTACH_NOTCH, -1]) cube([8, ATTACH_NOTCH + 0.01, 2 + 1]);         // pry notch
}

// ---------- plates ----------
// the interface every plate shares: core with snap arms, seated position
module attach_core(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    ya = l/2 - c;                                    // arm outer face
    xa = w/2 - SNAP_CORNER;                          // arms reach from the corners (x=±xa) to the centre
    difference() {
        translate([-w/2 + c, -l/2 + c, 0]) cube([w - 2*c, l - 2*c, ATTACH_T - c]);
        for (s=[-1,1]) mirror([0, s > 0 ? 0 : 1, 0]) {
            translate([-xa, ya - SNAP_ARM - SNAP_GAP, -1]) cube([2*xa, SNAP_GAP, ATTACH_T + 2]);   // slot behind the arms
            translate([-SNAP_GAP/2, ya - SNAP_ARM - SNAP_GAP, -1]) cube([SNAP_GAP, SNAP_ARM + SNAP_GAP + 1, ATTACH_T + 2]);  // split at the tips
        }
    }
    for (s=[-1,1], sx=[-1,1]) mirror([0, s > 0 ? 0 : 1, 0]) mirror([sx > 0 ? 0 : 1, 0, 0])
        translate([SNAP_GAP/2 + 0.3, ya - 0.01, 0]) rotate([90,0,90]) linear_extrude(min(SNAP_BUMP, xa - SNAP_GAP/2 - 2))
            polygon([[0, snap_z0() - 0.35*SNAP_B], [SNAP_B, snap_z0()], [SNAP_B, snap_z1() - SNAP_B], [0, snap_z1()]]);
}

// type: see ATTACH_TYPES.  Options:
//   screw_d / head_d   wall: wood-screw clearance hole and countersunk head (90°)
//   magnet = [d, h]     magnet: round magnets glued into pockets from the wall side
//   hook_gap           hook: thickness of the rod, rail, wire or door the hook goes over
//   stand_reach        stand: distance from the plate centre down to the host's bottom edge (+ = below)
//   stand_angle        stand: how far the host leans back from vertical
//   stand_depth        stand: how far behind the host the foot rests
//   roof_reach         roof: plate centre up to the ceiling (must clear the host's top edge)
//   roof_angle         roof: angle between the host and the ceiling (90 = hangs straight down)
//   roof_depth         roof: ceiling flange depth (front to back)
//   clamp_gap          clamp: opening between the jaws = thickest desk top, shelf or bar it grips
//   clamp_reach        clamp: from the clamp's back (spine) to the edge of the screw hole = how far it grips in
//   clamp_screw        clamp: printed screw size (THREAD_SIZES in thread.scad; M10..M20 are sensible)
//   pipe_d             pipe: outer diameter of the pipe, tube, rail or conduit the claw snaps onto
//   pipe_axis          pipe: the pipe runs "horizontal" (along the plate's width) or "vertical"
module attach_plate(type="wall", size="M", screw_d=4.5, head_d=8.5, magnet=[8, 2], magnet_clr=0.15,
                    hook_gap=6, stand_reach=40, stand_angle=15, stand_depth=40, skadis_t=5,
                    roof_reach=60, roof_angle=90, roof_depth=40, slide_axis="horizontal",
                    clamp_gap=40, clamp_reach=25, clamp_screw="M16", pipe_d=20, pipe_axis="horizontal") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    if (type == "slide" || type == "fin") slide_plate(size, type == "fin" ? "horizontal" : slide_axis);
    else if (type == "clamp") { attach_core(size); clamp_frame(size, clamp_gap, clamp_reach, clamp_screw); }
    else if (type == "pipe") { attach_core(size); pipe_claw(size, pipe_d, pipe_axis); }
    else difference() {
        union() {
            attach_core(size);
            if (type == "skadis") for (x=skadis_x(w)) translate([x, 0, 0]) skadis_hook(skadis_t);
            if (type == "hook") translate([0, l/2 - attach_strip(), 0]) rail_hook(w - 2*c, hook_gap);
            if (type == "stand") for (s=[-1,1]) translate([s*(w/2 - c - 1.6), 0, 0])        // in the solid corners
                stand_fin(l - 2*c, stand_reach, stand_angle, stand_depth);
            if (type == "roof") roof_bracket(w - 2*c, l, roof_reach, roof_angle, roof_depth, screw_d, head_d);
        }
        if (type == "wall") for (y=[-l/4, l/4]) translate([0, y, 0]) {
            translate([0,0,-1]) cylinder(d=screw_d, h=ATTACH_T + 2, $fn=32);
            translate([0,0,ATTACH_T - c - (head_d - screw_d)/2]) cylinder(d1=screw_d, d2=head_d + 0.4, h=(head_d - screw_d)/2 + 0.2 + 0.01, $fn=48);
            translate([0,0,ATTACH_T - c - 0.01]) cylinder(d=head_d + 0.4, h=1, $fn=48);
        }
        if (type == "keyhole") translate([0, -min(8, l/4), 0])
            keyhole_cut(head_d=9, neck_d=4.5, travel=min(10, l/2 - 4), neck_t=1.6, depth=ATTACH_T - c - 0.6);
        if (type == "magnet") for (p=magnet_xy(w, l, magnet[0])) translate([p[0], p[1], -1])
            cylinder(d=magnet[0] + 2*magnet_clr, h=magnet[1] + 1, $fn=48);
        if (type == "flat") for (i=[-3:3]) {
            translate([i*w/7 - 0.4, -l/2, -1]) cube([0.8, l, 1.5]);
            translate([-w/2, i*l/7 - 0.4, -1]) cube([w, 0.8, 1.5]);
        }
    }
}

// ---------- host helpers (use these in a project instead of placing sockets by hand) ----------
// per-type options as one list, so hosts can pass them on: build it with attach_opts(...)
function attach_opts(screw_d=4.5, head_d=8.5, magnet=[8, 2], hook_gap=6, stand_angle=15, stand_depth=40,
                     roof_gap=10, roof_angle=90, roof_depth=40,
                     slide_axis="horizontal", track_len=0, fin_len=120, fin_w=80, fin_t=4, ball_d=16,
                     clamp_gap=40, clamp_reach=25, clamp_screw="M16", pipe_d=20, pipe_axis="horizontal") =
    [screw_d, head_d, magnet, hook_gap, stand_angle, stand_depth, roof_gap, roof_angle, roof_depth,
     slide_axis, track_len, fin_len, fin_w, fin_t, ball_d, clamp_gap, clamp_reach, clamp_screw, pipe_d, pipe_axis];
// which face of the host a type mounts on: the fin hangs under the host, everything else is on its back
function attach_face(type) = type == "fin" ? "bottom" : "back";
// x positions for up to `count` sockets spread over 60% of `span` around `centre`. Skådis plates stay on the 40 mm
// grid. With `size` given, sockets keep 6 mm between them and the count drops to what fits the span, so use
// len(attach_xs(...)) as the real count. avoid = [x, half width]: shift the row so no socket centre lies in that zone.
function attach_xs(count, span, type="wall", centre=0, avoid=undef, size=undef) = let(
    pitch = is_undef(size) ? 0 : attach_socket_w(size) + 6,
    n   = is_undef(size) ? count : max(1, min(count, floor((span - 6)/pitch))),
    sp0 = n > 1 ? max(pitch, 0.6*span/(n - 1)) : 0,
    sp1 = type == "skadis" ? max(40, round(sp0/40)*40) : sp0,
    sp  = n > 1 && !is_undef(size) ? min(sp1, (span - pitch)/(n - 1)) : sp1,
    x0  = [for (i=[0:1:n-1]) centre + (i - (n - 1)/2)*sp],
    sh  = is_undef(avoid) ? [] : [for (x=x0) if (abs(x - avoid[0]) < avoid[1]) (x >= avoid[0] ? 1 : -1)*(avoid[1] - abs(x - avoid[0]))])
    [for (x=x0) x + (len(sh) > 0 ? sh[0] : 0)];
// plate centre y that centres socket + pry notch on a host whose middle is y_mid
function attach_y(y_mid) = y_mid + ATTACH_NOTCH/2;
// does a socket of this size fit a host `height` tall?
// thickness (optional) = host thickness behind the socket: needs the socket depth plus ATTACH_BACK of closed wall
function attach_fits(size, height, margin=3, thickness=undef) =
    attach_socket_len(size) <= height - margin + 0.001 && (is_undef(thickness) || thickness >= attach_host_t() - 0.001);
// What actually fits: the type and size asked for if the host is large enough, otherwise the next smaller plate
// size, otherwise no attachment at all. Returns [type, size, note]; note is "" or a sentence saying what was
// changed. Use the returned type and size everywhere, and show the note with attach_note(). A host should never
// stop with an error because an attachment does not fit.
function attach_smaller(size) = size == "L" ? "M" : size == "M" ? "S" : "";
function attach_fit(type, size, height, margin=3, thickness=undef) =
    type == "none" ? ["none", size, ""] :
    !is_undef(thickness) && thickness < attach_host_t() - 0.001 ?
        ["none", size, str("attachment left out: sockets need a host at least ", attach_host_t(), " mm thick, this one is ", thickness, " mm")] :
    attach_fits(size, height, margin) ? [type, size, ""] :
    attach_smaller(size) == "" ?
        ["none", size, str("attachment left out: even the smallest plate (S) needs ", attach_socket_len("S") + margin, " mm of height, this host has ", height, " mm")] :
    let(r = attach_fit(type, attach_smaller(size), height, margin, thickness))
        [r[0], r[1], r[0] == "none" ? r[2] : str("attachment plate size reduced from ", size, " to ", r[1], " to fit a height of ", height, " mm")];
// prints a note as a warning in the render log (nothing if the note is empty)
module attach_note(note) { if (note != "") echo(str("WARNING: ", note)); }
function attach_fit_msg(size, height, thickness=undef) =
    !is_undef(thickness) && thickness < attach_host_t()
        ? str("attachment sockets need a host at least ", attach_host_t(), " mm thick; this one is ", thickness, " mm. Make it thicker or set attach_type to none.")
        : str("attach_size ", size, " needs ", attach_socket_len(size), " mm of height; this host has ", height, " mm. Choose a smaller size.");
// row for the project's `parts` table
function attach_print_tag(type) = (type == "skadis" || type == "hook" || type == "roof") ? "print=auto" : "print=x180";
// cutter: all sockets of a host (subtract from the host; back face z=0)
module attach_sockets(type, size, xs, y) { if (type != "none") for (x=xs) translate([x, y, 0]) attach_socket(size); }
// all plates of a host, seated. y_bottom / y_top = the host's lowest / highest edge (for stand and roof plates)
module attach_plates(type, size, xs, y, opts=undef, y_bottom=undef, y_top=undef) {
    o = is_undef(opts) ? attach_opts() : opts;
    if (type != "none") for (x=xs) translate([x, y, 0])
        attach_plate(type, size, screw_d=o[0], head_d=o[1], magnet=o[2], hook_gap=o[3],
                     stand_reach=is_undef(y_bottom) ? 40 : y - y_bottom, stand_angle=o[4], stand_depth=o[5],
                     roof_reach=is_undef(y_top) ? 60 : y_top - y + o[6], roof_angle=o[7], roof_depth=o[8], slide_axis=o[9],
                     clamp_gap=o[15], clamp_reach=o[16], clamp_screw=o[17], pipe_d=o[18], pipe_axis=o[19]);
}

// ---------- everything that hangs on the sockets, in one call ----------
// Part ids (all optional except "attach"): "attach" plates, "attach_track" slide track or fin, and with a ball
// joint "attach_ball" ball plates, "attach_joint" cup adapters, "attach_ring" lock rings.
// attach_rows() gives their rows for the `parts` table: use  parts = concat([... your rows ...], attach_rows(...));
// Rows of parts that only exist with some settings (track, fin, ball joint) are left out when they are not used;
// the build tools set $all_parts = true to get every row, so the configurators can offer and draw them.
// frame = "flat" for a host modelled lying on its back (plaques; also a socket under a floor), "back" for a host
// modelled upright with the sockets in a vertical back wall (containers): it only sets the print orientation.
function attach_rows(type, count, joint="none", pull=[0, 0, -50], colour="#4d6170", frame="flat", opts=undef) = let(
    o = is_undef(opts) ? attach_opts() : opts,
    up = frame == "back" ? "print=x90" : "print=x180",                  // wall side up
    down = frame == "back" ? "print=x270" : "print=x0",                 // wall side on the bed
    plate_tag = (type == "skadis" || type == "hook" || type == "roof" || type == "clamp" || type == "pipe") ? "print=auto" : up,
    n_track = type == "fin" || (type == "slide" && o[9] == "horizontal") ? 1 : count,
    all = !is_undef($all_parts) && $all_parts)          // the tools ask for every part a model can have
    concat(
        [["attach", "Attachment plate", "PLA", pull, colour, str("pieces=", count), plate_tag]],
        type == "slide" || (all && type != "fin") ? [["attach_track", type == "slide" ? "Slide track" : "Slide track / fin", "PLA / PETG", pull*1.5, "#6f8494", str("pieces=", n_track), down]] : [],
        type == "fin" ? [["attach_track", "Fin with slide track", "PETG", pull*1.5, "#6f8494", "pieces=1", "print=auto"]] : [],
        type == "clamp" || all ? [["attach_screw", "Clamp screw", "PETG", pull*1.2, "#2f3a44", str("pieces=", count), "print=auto"]] : [],
        (type != "none" && joint == "ball") || all ? [
            ["attach_ball", "Ball plate", "PETG", pull*0.3, "#8fa3b0", str("pieces=", count), up],
            ["attach_joint", "Ball joint adapter", "PETG", pull*0.6, "#5b7282", str("pieces=", count), down],
            ["attach_ring", "Ball joint lock ring", "PETG", pull*0.45, "#c9a13b", str("pieces=", count), "print=auto"]] : []);
// Draws all of it, seated on a host whose back face is z = 0 (sockets at xs, y). `part` = the project's part
// variable ("all" or one id): only that part is drawn, so a project needs just this one line.
module attach_all(part, type, size, xs, y, opts=undef, y_bottom=undef, y_top=undef, joint="none", skip_plates=false) {
    o = is_undef(opts) ? attach_opts() : opts;
    ball = joint == "ball" && type != "none";
    zj = ball ? ball_joint_back(size, o[14]) : 0;                       // the plates sit on the adapters instead of the host
    module sel(id, col) { if (part == "all" || part == id) color(col) children(); }
    if (type != "none") {
        if (!skip_plates) sel("attach", "#4d6170") translate([0, 0, zj]) attach_plates(type, size, xs, y, o, y_bottom, y_top);
        if (type == "clamp") sel("attach_screw", "#2f3a44") translate([0, 0, zj]) for (x=xs) translate([x, y, 0]) clamp_screw_seated(size, o[15], o[16], o[17]);
        if (type == "slide") sel("attach_track", "#6f8494") translate([0, 0, zj]) slide_tracks(size, xs, y, o[9], o[10], o[0], o[1]);
        if (type == "fin") sel("attach_track", "#6f8494") translate([(min(xs) + max(xs))/2, y, zj]) slide_fin(o[12], o[11], o[13]);
        if (ball) for (x=xs) translate([x, y, 0]) {
            sel("attach_ball", "#8fa3b0") ball_plate(size, o[14]);
            sel("attach_joint", "#5b7282") ball_adapter(size, o[14]);
            sel("attach_ring", "#c9a13b") ball_ring(size, o[14]);
        }
    }
}

// a box with all its edges chamfered by c (parts that stand out from a host: no sharp corners, easier to print)
module attach_chamfer_box(size, c=1) {
    hull() {
        translate([c, c, 0]) cube(size - [2*c, 2*c, 0]);
        translate([c, 0, c]) cube(size - [2*c, 0, 2*c]);
        translate([0, c, c]) cube(size - [0, 2*c, 2*c]);
    }
}

// ---------- slide track ----------
// A dovetail track with rounded edges is screwed to the wall; the plate has the matching channel and the host
// slides onto the track. horizontal: the channel runs through the plate from side to side, one long track carries
// all plates and the host can be slid along it. vertical: the channel is open at the bottom and closed at the top,
// the host is dropped onto a short track per plate and hangs on its upper end.
// The same plate rides on the fin (type "fin"): a track with a long blade, for a host that is anchored from below
// (the blade goes between two sofa cushions, into a slot, into the ground).
SLIDE_W   = 16;      // track width on the host side (the wide side of the dovetail)
SLIDE_N   = 10;      // track width on the wall
SLIDE_H   = 4.5;     // track height
SLIDE_R   = 0.8;     // rounding of the track's edges
SLIDE_CLR = 0.25;    // play between track and channel, per side
SLIDE_GAP = 0.5;     // air between the plate and the wall
function slide_standoff() = SLIDE_H + SLIDE_GAP;                         // wall plane below the host's back face
// cross-section, wall on y = 0, track up to y = SLIDE_H; grow = play (for the channel)
module slide_profile_2d(grow=0) {
    offset(r=SLIDE_R, $fn=24) offset(delta=-SLIDE_R + grow)
        polygon([[-SLIDE_N/2, 0], [SLIDE_N/2, 0], [SLIDE_W/2, SLIDE_H], [-SLIDE_W/2, SLIDE_H]]);
}
module slide_plate(size="M", axis="horizontal") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR; sp = attach_strip();
    zw = -slide_standoff();                                              // wall plane
    bw = w - 2*c; bl = l - 2*sp - 1;                                     // carriage block, clear of the snap arms
    assert(axis == "horizontal" ? bl >= SLIDE_W + 2*SLIDE_CLR + 5 : bw >= SLIDE_W + 2*SLIDE_CLR + 5, "slide plate: this plate size is too small for the track");
    attach_core(size);
    difference() {
        translate([-bw/2, -bl/2, zw + 0.2]) attach_chamfer_box([bw, bl, -zw - 0.2 + 1.2], 1);        // chamfered; its top is inside the core
        if (axis == "horizontal") translate([0, 0, zw]) rotate([90, 0, 90]) linear_extrude(w + 2, center=true) union() {
            slide_profile_2d(SLIDE_CLR); translate([-SLIDE_N/2 - SLIDE_CLR, -1]) square([SLIDE_N + 2*SLIDE_CLR, 1 + SLIDE_R]);
        }
        else translate([0, slide_stop_y(size), zw]) rotate([90, 0, 0]) linear_extrude(l) union() {     // open at the bottom, closed at the top
            slide_profile_2d(SLIDE_CLR); translate([-SLIDE_N/2 - SLIDE_CLR, -1]) square([SLIDE_N + 2*SLIDE_CLR, 1 + SLIDE_R]);
        }
    }
}
function slide_stop_y(size) = attach_dims(size)[1]/2 - attach_strip() - 4;        // upper end of a vertical channel
// a track of length L along X, wall face on z = 0, with countersunk screw holes
module slide_track(L, screw_d=4.5, head_d=8.5) {
    n = max(2, floor(L/60) + 1); e = min(12, L/4);
    difference() {
        intersection() {
            rotate([90, 0, 90]) linear_extrude(L, center=true) slide_profile_2d();
            linear_extrude(SLIDE_H + 1) offset(r=2.5, $fn=24) square([L - 5, SLIDE_W - 5], center=true);     // rounded ends
        }
        for (i=[0:n-1]) translate([-L/2 + e + i*(L - 2*e)/(n - 1), 0, 0]) {
            translate([0, 0, -1]) cylinder(d=screw_d, h=SLIDE_H + 2, $fn=32);
            translate([0, 0, SLIDE_H - (head_d - screw_d)/2]) cylinder(d1=screw_d, d2=head_d + 0.4, h=(head_d - screw_d)/2 + 0.01, $fn=48);
        }
    }
}
function slide_track_len(size, xs, axis, track_len) = track_len > 0 ? track_len :
    axis == "horizontal" ? max(xs) - min(xs) + attach_dims(size)[0] + 60 : attach_dims(size)[1] + 20;
// the track(s) of a host, seated in its plates (host back face z = 0)
module slide_tracks(size, xs, y, axis="horizontal", track_len=0, screw_d=4.5, head_d=8.5) {
    L = slide_track_len(size, xs, axis, track_len);
    if (axis == "horizontal") translate([(min(xs) + max(xs))/2, y, -slide_standoff()]) slide_track(L, screw_d, head_d);
    else for (x=xs) translate([x, y + slide_stop_y(size) - SLIDE_CLR - L/2, -slide_standoff()]) rotate(90) slide_track(L, screw_d, head_d);
}
// fin: a track of length w with a blade `len` long and t thick standing on its wall side. Drawn seated: the
// track's wall plane at z = -slide_standoff(), the blade pointing to -z (away from the host).
module slide_fin(w=80, len=120, t=4, base=3) {
    z0 = -slide_standoff();
    translate([0, 0, z0]) slide_track_plain(w);
    translate([-w/2, -(SLIDE_N + 8)/2, z0 - base]) attach_chamfer_box([w, SLIDE_N + 8, base + 0.01], 0.8);   // the host rests on this
    hull() {                                                                                          // blade with rounded lower corners
        translate([-w/2, -t/2, z0 - base - 1]) cube([w, t, 1]);
        for (s=[-1, 1]) translate([s*(w/2 - 8), 0, z0 - base - len + 8]) rotate([90, 0, 0]) cylinder(r=8, h=t, center=true, $fn=32);
    }
    for (s=[-1, 1]) hull() {                                                                          // fillets blade / base
        translate([-w/2, s*(SLIDE_N + 8)/2 - (s > 0 ? 0.5 : 0), z0 - base]) cube([w, 0.5, 0.01]);
        translate([-w/2, -0.25, z0 - base - (SLIDE_N + 8)/2 + t/2]) cube([w, 0.5, 0.01]);
    }
}
module slide_track_plain(L) {
    intersection() {
        rotate([90, 0, 90]) linear_extrude(L, center=true) slide_profile_2d();
        linear_extrude(SLIDE_H + 1) offset(r=2.5, $fn=24) square([L - 5, SLIDE_W - 5], center=true);
    }
}

// ---------- ball joint ----------
// For any attachment type: the host carries a ball (a plate with a ball on a neck in its socket), the plate of
// the chosen type snaps into an adapter that grips the ball with a slotted cup. The host can be turned and tilted
// freely; pushing the lock ring down the tapered cup clamps it in place.
// Assembly: ring over the ball onto the neck, press the ball into the cup, push the ring towards the adapter.
BALL_LAT    = 20;      // the cup closes this many degrees past the ball's equator (what holds the ball)
BALL_WALL   = 1.5;     // cup wall at the equator
BALL_PETALS = 6;       // slots in the cup
BALL_SLOT   = 1.2;     // slot width
BALL_TAPER  = 0.6;     // the cup's outside grows by this much from its mouth to its foot (the ring wedges on it)
BALL_MAX_STRAIN = 0.02;
function ball_neck_d(d) = d*0.5;
function ball_centre_z(d) = -(d/2 + 6);                                   // ball centre below the host's back face
function ball_cup_foot_z(d) = ball_centre_z(d) - d/2 - 1.5;               // top of the adapter block (z)
function ball_joint_back(size, d) = ball_cup_foot_z(d) - (ATTACH_T + 1.5); // the adapter's back face = new mounting plane
// how far the petals bend when the ball is pressed in, their length and the strain that causes (must stay under 2%)
function ball_petal_bend(d) = d/2*(1 - cos(BALL_LAT));
function ball_petal_len(d) = d/2*(sin(BALL_LAT) + 0.85);                  // from the mouth down to the end of the slots
function ball_strain(d) = 1.5*(BALL_WALL + 0.25)*ball_petal_bend(d)/pow(ball_petal_len(d), 2);
// largest tilt from straight before the neck touches the cup's mouth
function ball_tilt(d) = 90 - BALL_LAT - asin(ball_neck_d(d)/d) - 3;
module ball_plate(size="M", d=16) {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; nd = ball_neck_d(d); zc = ball_centre_z(d);
    root = min(w, l) - 2*attach_strip() - 6;                              // foot of the neck, clear of the snap arms
    attach_core(size);
    hull() { translate([0, 0, -0.6]) cylinder(d=root, h=0.61, $fn=48); translate([0, 0, -3]) cylinder(d=nd, h=0.1, $fn=48); }
    translate([0, 0, zc]) cylinder(d=nd, h=-zc - 2.9, $fn=48);
    translate([0, 0, zc]) sphere(d=d, $fn=64);
    translate([0, 0, zc]) cylinder(d1=d*cos(45), d2=nd, h=d/2*sin(45) + (d*cos(45) - nd)/2, $fn=48);   // 45 degree shoulder: prints ball-up
}
function _ball_cup_r(d, z) = let(zm = ball_centre_z(d) + d/2*sin(BALL_LAT), zf = ball_cup_foot_z(d))          // outside radius of the cup at z
    d/2 + BALL_WALL + 0.4 + BALL_TAPER*(zm - z)/(zm - zf);
module ball_adapter(size="M", d=16) {
    assert(ball_strain(d) <= BALL_MAX_STRAIN, str("ball joint: a ", d, " mm ball would bend the cup by ", ball_strain(d)*100, "% (limit 2%)"));
    w = attach_dims(size)[0]; l = attach_dims(size)[1];
    zc = ball_centre_z(d); zf = ball_cup_foot_z(d); zm = zc + d/2*sin(BALL_LAT); zb = ball_joint_back(size, d);
    difference() {
        union() {
            translate([-w/2 - 4, -l/2 - ATTACH_NOTCH - 4, zb]) attach_chamfer_box([w + 8, l + ATTACH_NOTCH + 8, zf - zb], 1);    // block with the socket
            translate([0, 0, zf - 0.01]) cylinder(r1=_ball_cup_r(d, zf), r2=_ball_cup_r(d, zm), h=zm - zf + 0.01, $fn=72);
        }
        translate([0, 0, zc]) sphere(d=d + 0.1, $fn=64);
        for (i=[0:BALL_PETALS-1]) rotate(i*360/BALL_PETALS + 30) translate([0, -BALL_SLOT/2, zc - 0.85*d/2]) cube([d, BALL_SLOT, d]);
        translate([0, 0, zb]) attach_socket(size);
    }
}
// lock ring, drawn resting on the cup near its mouth, where it just touches: pushing it towards the adapter
// wedges it onto the taper and squeezes the cup (about 0.05 mm per mm of travel)
module ball_ring(size="M", d=16, h=5) {
    zc = ball_centre_z(d); zm = zc + d/2*sin(BALL_LAT); z1 = zm - 1; z0 = z1 - h;
    translate([0, 0, z0]) difference() {
        cylinder(r=_ball_cup_r(d, z0) + 2.4, h=h, $fn=72);
        translate([0, 0, -0.01]) cylinder(r1=_ball_cup_r(d, z0 - 0.01) + 0.02, r2=_ball_cup_r(d, z1 + 0.01) + 0.02, h=h + 0.02, $fn=72);
        for (i=[0:11]) rotate(i*30) translate([_ball_cup_r(d, z0) + 2.4, 0, -1]) cylinder(d=2, h=h + 2, $fn=16);   // grip
    }
}

// ---------- plate features ----------
// ceiling bracket: a stem rises behind the host from the plate to a ceiling flange (4 countersunk screws, room
// side). The stem joins only the plate's middle, with 0.6 mm clearance over the snap arms so they can flex.
// The flange top (ceiling contact) is at y = reach; `angle` is between the host and the ceiling.
module roof_bracket(w, l, reach=60, angle=90, depth=40, screw_d=4.5, head_d=8.5, st=5, ft=5, tab=10) {
    sp = attach_strip();
    jz = -0.6 - st/2;                                            // stem centre line (z)
    module at_joint() { translate([0, reach, jz]) rotate([90 - angle, 0, 0]) children(); }   // flange frame
    FW = w + 2*tab;
    translate([-w/2, -l/2 + sp + 0.5, -0.61]) cube([w, l - 2*sp - 1, 0.62]);                // pad onto the core
    translate([-w/2, -l/2 + sp + 0.5, -0.6 - st]) cube([w, reach - ft + l/2 - sp - 0.5 + 0.01, st]);  // stem
    difference() {
        at_joint() translate([-FW/2, -ft, -depth/2]) cube([FW, ft, depth]);                  // flange
        for (x=[-1,1], z=[-1,1]) at_joint() translate([x*(w/2 + tab/2), 0, z*(depth/2 - 6)]) rotate([90,0,0]) {
            translate([0,0,-1]) cylinder(d=screw_d, h=ft + 2, $fn=32);
            translate([0,0,ft - (head_d - screw_d)/2 - 0.01]) cylinder(d1=screw_d, d2=head_d + 0.4, h=(head_d - screw_d)/2 + 0.02, $fn=48);
        }
    }
    for (x=[-w/2, w/2 - 3]) hull() {                             // gussets, behind the stem only
        translate([x, reach - ft - 18, -0.6 - st]) cube([3, 18, st]);
        at_joint() translate([x, -ft, -depth/2 + 1]) cube([3, 0.01, depth/2 - 1 - st/2]);
    }
}

function skadis_x(w) = w >= 44 ? [-20, 20] : [0];          // hook columns 40 mm apart (same row)
function magnet_xy(w, l, d) = let(dx = w/2 - d/2 - 3, dy = l/2 - attach_strip() - d/2 - 1.5)
    (w >= 2*d + 10 && dy >= d/2 + 1) ? [[-dx,-dy],[dx,-dy],[-dx,dy],[dx,dy]] : [[-dx,0],[dx,0]];

// IKEA Skådis hook: 4.6 wide tab through a 5 x 15 slot, latch drops behind the 5 mm board
module skadis_hook(board_t=5) {
    g = board_t + 0.3;                                       // board + play
    translate([-2.3, 0, 0]) rotate([90,0,90]) linear_extrude(4.6)
        polygon([[-2, 0.01], [5, 0.01], [5, -g], [5 - 1.5, -g - 3], [-8, -g - 3], [-8, -g], [-2, -g]]);
}
// hook over a rod / rail / door of thickness `gap`: an arm runs out from the plate's top strip, and a lip
// drops down behind the rod. Profile in (y, z); y=0 is the plate's top edge.
module rail_hook(w, gap=6, t=4, lip=10) {
    translate([-w/2, 0, 0]) rotate([90,0,90]) linear_extrude(w)
        polygon([[0, 0.01], [0, -gap - t], [-lip, -gap - t], [-lip, -gap], [-t, -gap], [-t, 0.01]]);
}
// kickstand fin: from the plate down to a foot resting on the floor behind the host
module stand_fin(l, reach, angle, depth, t=3.2) {
    fy = -reach + depth*tan(angle);                          // foot height (y) in the host frame
    translate([-t/2, 0, 0]) rotate([90,0,90]) linear_extrude(t)
        hull() { translate([-l/2, -0.01]) square([l, 0.02]); translate([fy, -depth]) circle(r=2.5, $fn=24); }
}
// keyhole cut from the wall side (z=0) into a plate
module keyhole_cut(head_d=9, neck_d=4.5, travel=10, neck_t=2, depth=4) {
    translate([0,0,-1]) cylinder(d=head_d, h=depth + 1, $fn=48);
    translate([0,0,-1]) hull() { cylinder(d=neck_d, h=neck_t + 1, $fn=32); translate([0,travel,0]) cylinder(d=neck_d, h=neck_t + 1, $fn=32); }
    translate([0,0,neck_t]) hull() { cylinder(d=head_d, h=depth - neck_t, $fn=48); translate([0,travel,0]) cylinder(d=head_d, h=depth - neck_t, $fn=48); }
}

// ---------- clamp ----------
// A C-clamp behind the plate for desk tops, shelves, table edges and flat bars. The spine runs down from the plate's
// top edge; the upper jaw rests on the desk, the lower jaw carries a threaded boss with a printed screw (part
// attach_screw: grip knob below, pressure pad with a 45 degree underside on top). The spine joins only the plate's
// middle, 0.6 mm clear of the snap arms, like the roof bracket. All outer edges are chamfered.
// gap = opening between the jaws, reach = from the spine's inner face to the edge of the screw hole.
function clamp_jaw_t(screw) = max(7, 0.55*thread_d(screw));          // jaw thickness
function clamp_boss_h(screw) = max(clamp_jaw_t(screw), 1.3*thread_d(screw));   // threaded length in the lower jaw
function clamp_spine_t(size) = size == "S" ? 6 : size == "M" ? 7 : 8;
function clamp_axis_z(size, reach, screw) = -0.6 - clamp_spine_t(size) - reach - thread_d(screw)/2 - thread_clr();
function clamp_top_y(size) = attach_dims(size)[1]/2 - ATTACH_CLR;
function clamp_low_y(size, gap, screw) = clamp_top_y(size) - 2*clamp_jaw_t(screw) - gap;     // underside of the lower jaw
function clamp_pad_h(screw) = 3 + (thread_d(screw)/2 + 5 - (thread_d(screw)/2 - thread_depth(thread_pitch(screw))));   // pad: 45 degree cone + 3 mm disc
module clamp_frame(size="M", gap=40, reach=25, screw="M16") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR; sp = attach_strip();
    d = thread_d(screw); jt = clamp_jaw_t(screw); bh = clamp_boss_h(screw); st = clamp_spine_t(size);
    W = max(w - 2*c, d + 10);                                   // jaw width (at least the boss)
    zt = -0.6 - st;                                             // the spine's inner face (the clamped object stops here)
    za = clamp_axis_z(size, reach, screw);
    J = -za + d/2 + 6;                                          // jaw length from z = 0
    yt = clamp_top_y(size); yl = clamp_low_y(size, gap, screw);
    g = min(8, gap/4);                                          // 45 degree gusset in the inner corners
    assert(gap >= clamp_pad_h(screw) + 4, str("clamp: the opening must be at least ", clamp_pad_h(screw) + 4, " mm for the screw's pad"));
    translate([-w/2 + c, -l/2 + sp + 0.5, -0.61]) cube([w - 2*c, l - 2*sp - 1, 0.62]);              // joins the core's middle
    difference() {
        union() {
            translate([-W/2, yl, -0.6 - st]) attach_chamfer_box([W, yt - yl, st], 1);                    // spine
            for (y0=[yt - jt, yl]) translate([-W/2, y0, -J]) attach_chamfer_box([W, jt, J - 0.6 + 0.01 - 0.01], 1);   // jaws
            for (s=[1, -1]) let(y = s > 0 ? yt - jt : yl + jt)                                         // gussets
                translate([-W/2 + 1, y, zt + 0.01]) rotate([0, 90, 0]) linear_extrude(W - 2)
                    polygon([[0, 0], [g, 0], [0, -s*g]]);
            translate([0, yl + jt + 0.01, za]) rotate([90, 0, 0]) cylinder(r=d/2 + 5, h=bh, $fn=64);  // threaded boss
            translate([0, yl + jt + 0.01 - bh, za]) rotate([90, 0, 0]) cylinder(r1=d/2 + 5, r2=d/2 + 4, h=1, $fn=64);
        }
        translate([0, clamp_thread_y0(size, gap, screw), za]) rotate([-90, 0, 0]) thread_cutter(screw, bh + 1.05);   // same direction as the screw
    }
}
function clamp_thread_y0(size, gap, screw) = clamp_low_y(size, gap, screw) + clamp_jaw_t(screw) - clamp_boss_h(screw) - 1.03;   // start of the threaded hole
// the screw in its own frame: axis +Z, knob from z = 0, thread above it, pad on top
module clamp_screw(gap=40, screw="M16") {
    d = thread_d(screw); h = thread_depth(thread_pitch(screw)); bh = clamp_boss_h(screw);
    kh = 12; tl = gap + bh - clamp_pad_h(screw) + 2;            // the pad can close the full opening
    thread_knob(d + 16, kh, "wave");
    translate([0, 0, kh - 0.01]) thread_rod(screw, tl + 0.02);
    translate([0, 0, kh + tl]) {                                // pad: 45 degree cone (prints without support), then a disc
        cylinder(r1=d/2 - h, r2=d/2 + 5, h=d/2 + 5 - (d/2 - h), $fn=64);
        translate([0, 0, d/2 + 5 - (d/2 - h) - 0.01]) cylinder(r=d/2 + 5, h=3, $fn=64);
    }
}
// seated in the frame (host frame), half open
module clamp_screw_seated(size="M", gap=40, reach=25, screw="M16") {
    yl = clamp_low_y(size, gap, screw); bh = clamp_boss_h(screw);
    p = thread_pitch(screw);
    y_want = clamp_top_y(size) - clamp_jaw_t(screw) - gap/2 - clamp_pad_h(screw) - (gap + bh - clamp_pad_h(screw) + 2) - 12;   // pad half way up
    yh = clamp_thread_y0(size, gap, screw);                     // seat the thread a whole number of turns from the hole's
    y0 = yh + round((y_want + 12 - 0.01 - yh)/p)*p - 12 + 0.01;   // start, so screw and hole are in phase (as when screwed in)
    translate([0, y0, clamp_axis_z(size, reach, screw)]) rotate([-90, 0, 0]) clamp_screw(gap, screw);
}

// ---------- pipe claw ----------
// A rounded claw that snaps onto a pipe, tube, round bar or conduit of diameter d (like electrical conduit clips).
// The claw wraps the pipe; its opening is chosen so the claw bends by about 1.5% when it is pushed on (asserted
// under 2%: split-ring bending, strain = opening change * wall / (3 pi R^2)). The tips flare out at 45 degrees as a
// lead-in. axis "horizontal": the pipe runs along the plate's width; "vertical": along its length.
function pipe_wall(d) = max(2.2, 0.12*d);
function pipe_open(d) = let(t = pipe_wall(d), R = (d + t)/2) min(0.88, max(0.72, 1 - 0.015*3*PI*R*R/(t*d)));   // opening / d
function pipe_strain(d) = let(t = pipe_wall(d), R = (d + t)/2) d*(1 - pipe_open(d))*t/(3*PI*R*R);
PIPE_CLR = 0.2;
module pipe_claw_2d(d=20, base=4, base_w=20) {
    t = pipe_wall(d); ri = d/2 + PIPE_CLR; ro = ri + t; vc = 0.6 + base + ro;      // v = distance behind the plate
    a = pipe_open(d)*d/2; yc = sqrt(max(0, ri*ri - a*a));                         // opening half width, chord position
    offset(r=0.6, $fn=16) offset(delta=-0.6) difference() {
        union() {
            translate([0, vc]) circle(r=ro, $fn=96);
            translate([-base_w/2, 0.6 - 0.01]) square([base_w, vc - 0.6]);
        }
        translate([0, vc]) circle(r=ri, $fn=96);
        translate([0, vc]) polygon([[-a, yc], [a, yc], [a + 3*ro, yc + 3*ro], [-a - 3*ro, yc + 3*ro]]);   // opening + 45 degree lead-in
    }
}
module pipe_claw(size="M", d=20, axis="horizontal") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR; sp = attach_strip();
    assert(pipe_strain(d) <= 0.02, str("pipe claw: ", d, " mm would bend the claw by ", pipe_strain(d)*100, "% (limit 2%)"));
    mid = l - 2*sp - 1;                                          // the plate's middle, clear of the snap arms
    translate([-w/2 + c, -mid/2, -0.61]) cube([w - 2*c, mid, 0.62]);                // joins the core's middle
    if (axis == "vertical") translate([0, mid/2, 0]) rotate([90, 0, 0]) linear_extrude(mid)
        mirror([0, 1]) pipe_claw_2d(d, 4, min(w - 2*c, 0.8*d));
    else translate([-(w - 2*c)/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(w - 2*c)
        mirror([0, 1]) pipe_claw_2d(d, 4, min(mid, 0.8*d));
}


// ----------------------- lib/strings.scad -----------------------
// Reading numbers and lists out of text settings, so a Customizer field can hold a whole layout.
// Use:  use <../../lib/strings.scad>
//
// OpenSCAD has no string slicing or number parsing; these work with ord()/chr() and plain list comprehensions,
// the same in OpenSCAD 2021.01 and in the browser engine.
//
//   str_nums("33, 33 ,33")                 -> [33, 33, 33]       (spaces, commas, semicolons and % are separators)
//   str_groups("33,33,33 / 50,50 / 100")   -> [[33, 33, 33], [50, 50], [100]]     ("/" or "|" between groups)
//   str_num("-12.5")                       -> -12.5              (undef if it is not a number)

// the part of s from index a up to (not including) b
function str_sub(s, a, b) = b <= a ? "" : chr([for (i=[max(0, a):1:min(len(s), b) - 1]) ord(s[i])]);
// s cut at every character that appears in seps (empty pieces are kept)
function str_split(s, seps=",") = let(
    cut = [for (i=[0:1:len(s) - 1]) if (len(search(s[i], seps)) > 0) i],
    b = concat([-1], cut, [len(s)]))
    [for (k=[0:1:len(b) - 2]) str_sub(s, b[k] + 1, b[k + 1])];
// s without leading and trailing spaces
function str_trim(s) = let(k = [for (i=[0:1:len(s) - 1]) if (s[i] != " " && s[i] != "\t") i])
    len(k) == 0 ? "" : str_sub(s, k[0], k[len(k) - 1] + 1);
function _str_digit(c) = let(o = ord(c)) o >= 48 && o <= 57 ? o - 48 : undef;
// a decimal number ("12", "-3.5", "+0.25", "40%"), or undef
function str_num(s) = let(
    t = str_trim(s), c = [for (ch=t) if (ch != "%") ch],
    neg = len(c) > 0 && c[0] == "-", sg = len(c) > 0 && (c[0] == "-" || c[0] == "+") ? 1 : 0,
    d = [for (i=[sg:1:len(c) - 1]) c[i]],
    dots = [for (i=[0:1:len(d) - 1]) if (d[i] == ".") i],
    p = len(dots) > 0 ? dots[0] : len(d),
    v = [for (ch=d) if (ch != ".") _str_digit(ch)],
    ok = len(v) > 0 && len(dots) <= 1 && len([for (x=v) if (is_undef(x)) 1]) == 0)
    !ok ? undef : (neg ? -1 : 1)*(
        (p == 0 ? 0 : [for (i=[0:1:p - 1]) v[i]*pow(10, p - 1 - i)]*[for (i=[0:1:p - 1]) 1]) +
        (len(v) - p <= 0 ? 0 : [for (j=[p:1:len(v) - 1]) v[j]*pow(10, p - 1 - j)]*[for (j=[p:1:len(v) - 1]) 1]));
// all numbers in s (anything that is not a number is skipped)
function str_nums(s, seps=", ;\t") = [for (w=str_split(s, seps)) let(x = str_num(w)) if (!is_undef(x)) x];
// groups of numbers: "33,33,33 / 50,50 / 100"; empty groups are skipped
function str_groups(s, gseps="/|", seps=", ;\t") = [for (g=str_split(s, gseps)) let(n = str_nums(g, seps)) if (len(n) > 0) n];


// ----------------------- lib/container.scad -----------------------
// Containers: the parts of an open box built on a shell outline. Patterned walls with openings and plain areas,
// floor, lid ledge, ridge, compartments (divider walls), and a mounting zone for the attachment plates built into the back wall or the floor. Used by projects/custombox, projects/earbuds, projects/sunglasses.
// Use:  use <../../lib/container.scad>   (builds on shell.scad, patterns.scad, attach.scad)
//
// Frame: the outline `pts` (see shell.scad) is the outer face of the walls in the floor plane; the floor's
// underside is z = 0 and everything rises along +Z. "Front" is -Y, "back" is +Y.
// Openings (cable holes, slots) are 2D children:
//   container_walls / container_wall  in the wall's unrolled frame: x = distance along the outline measured from
//                                     the middle of the whole loop (use container_u() to get it from a plan
//                                     point), y = height above the floor plane minus h/2
//   container_floor                   in plan (x, y)
// Each opening gets a plain collar `frame` wide, so it never ends in the middle of a lattice.

// x in the loop's unrolled frame of the outline point nearest to plan point q; y of a height z
function container_u(pts, q) = shell_dist_at(pts, q) - shell_len(pts)/2;
function container_v(z, h) = z - h/2;

// ---------- outline ----------
// The outline of a box from its runs (shell_rect_runs). split = true: every side is its own panel, the outline
// starts at the front. Otherwise the wall is one loop, and its seam is put in the back left corner, where no
// opening, mount or grip ever sits.
function container_box_pts(runs, split=false) = let(e = shell_runs_edges(runs), p = shell_runs_pts(runs),
    c = [for (r=e) if (r[0] == "corner_bl") r])
    split ? p : shell_start_at(p, len(c) > 0 ? c[0][1] + floor((c[0][2] - c[0][1] + 1)/2) : shell_run(e, "left")[1]);

// ---------- walls ----------
// One stretch of wall over outline edges e0..e1 as a patterned panel bent round the outline.
// t = wall thickness, h = reference height (the highest point of the rim), hf = function (p) -> rim height,
// p / mode = pattern spec and how it is applied (PATTERN_MODES), border = [sides, bottom, top] plain bands,
// depth = relief height / engraving depth, lining_t = lining thickness in overlay mode.
// plain  = areas without pattern (solid wall): [[x, z, w, h], ...] centre x in the loop frame, bottom z, size
// mount  = a container_mount() spec: its solid zone and sockets are built into the wall where they belong
// anchor = plan point the pattern is centred on (default: the middle of the strip)
// The optional child cuts openings (loop frame, see the top of this file).
// fit    = on a wall that runs all the way round, adjust the pattern so it closes without a seam (pattern_wrapped)
module container_wall(pts, e0, e1, t, h, hf, p, mode="solid", border=[0, 4, 4], depth=0.8, lining_t=0.6, frame=2, plain=[], mount, anchor, fit=true) {
    q = fit && e0 == 0 && e1 == len(pts) - 1 ? pattern_wrapped(p, shell_len(pts)) : p;
    if ($children > 0) _container_wall(pts, e0, e1, t, h, hf, q, mode, border, depth, lining_t, frame, true, plain, mount, anchor) children();
    else _container_wall(pts, e0, e1, t, h, hf, q, mode, border, depth, lining_t, frame, false, plain, mount, anchor) square(1);
}
module _container_plain_2d(zones, h) { for (z=zones) translate([z[0] - z[2]/2, z[1] - h/2]) square([z[2], z[3]]); }
module _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, holes, plain, mount, anchor) {
    u = shell_dists(pts); L = u[e1 + 1] - u[e0];
    dx = u[len(pts)]/2 - (u[e0] + u[e1 + 1])/2;                 // loop frame -> this strip's frame
    strip = shell_strip_pts(pts, e0, e1, hf, h);
    // the mount belongs to the strip that holds the middle of its zone
    mx = is_undef(mount) || mount[16] != "back" ? undef : container_u(pts, mount[3] + [mount[11], 0]) + dx;
    has_m = !is_undef(mx) && mount[16] == "back" && abs(mx) < L/2;
    zones = concat([for (z=plain) [z[0] + dx, z[1], z[2], z[3]]], has_m ? _container_mount_plain(mount, mx, h) : []);
    pp = is_undef(anchor) ? p : pattern_shift(p, [container_u(pts, anchor) + dx, 0]);
    shell_wrap(pts, t, e0, e1, h=h, above=depth) {
        pattern_panel(mode, pp, [L + 1, h], t=t, depth=depth, border=border, lining_t=lining_t)
            difference() {
                polygon(strip);
                if (holes) translate([dx, 0]) children();
                offset(delta=-0.3) _container_plain_2d(zones, h);        // the pattern stops at the plain areas ...
            }
        // ... which are filled with solid wall (minus the mount's own block, which is thicker)
        if (len(zones) > 0) linear_extrude(t) shell_window_2d() difference() {
            intersection() { polygon(strip); _container_plain_2d(zones, h); }
            if (holes) translate([dx, 0]) children();
            if (has_m) offset(delta=-0.3) _container_plain_2d(_container_mount_zones(mount, mx), h);
        }
        if (holes && frame > 0) linear_extrude(t) shell_window_2d() intersection() {
            polygon(strip);
            difference() { offset(delta=frame) translate([dx, 0]) children(); translate([dx, 0]) children(); }
        }
        if (has_m) _container_mount_block(mount, mx, t, h);
    }
}
// All walls of a container. runs = undef: one panel all the way round (the pattern runs through the corners).
// runs = shell_runs_edges(...) of a box outline: every side is its own panel with `post_w` of plain wall at both
// ends, and the corner runs are plain. bands = [bottom, top] plain bands; plain, mount, anchor: see container_wall
// (anchor only matters for the single panel; separate sides are centred on themselves).
module container_walls(pts, t, h, hf, p, mode="solid", bands=[4, 4], depth=0.8, lining_t=0.6, runs, post_w=3, frame=2, plain=[], mount, anchor, fit=true) {
    if ($children > 0) _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, true, plain, mount, anchor, fit) children();
    else _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, false, plain, mount, anchor, fit) square(1);
}
module _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, holes, plain, mount, anchor, fit) {
    if (is_undef(runs)) {
        if (holes) container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame, plain, mount, anchor, fit) children();
        else container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame, plain, mount, anchor, fit);
    }
    else for (r=runs) {
        corner = container_is_corner(r[0]);
        if (holes) container_wall(pts, r[1], r[2], t, h, hf, p, corner ? "solid" : mode, [corner ? 0 : post_w, bands[0], bands[1]], depth, lining_t, frame, plain, mount) children();
        else container_wall(pts, r[1], r[2], t, h, hf, p, corner ? "solid" : mode, [corner ? 0 : post_w, bands[0], bands[1]], depth, lining_t, frame, plain, mount);
    }
}
function container_is_corner(name) = len(name) > 6 && name[0] == "c" && name[6] == "_";
// a pattern that would fall apart when cut through is raised instead
function container_safe_mode(mode, p) = (mode == "through_cut" || mode == "open_lattice") && !pattern_is_connected(p) ? "raised" : mode;

// ---------- floor ----------
// Floor plate z = 0..t on the outline (a hair inside it, so its edge does not lie in the walls' outer faces).
// border = plain margin from the outline to the pattern (wall thickness + what you want to see). Child: holes in plan.
// mount = a container_mount() spec: if it mounts under the floor, its solid zone and sockets are built in here.
module container_floor(pts, t, p, mode="solid", border=5, depth=0.6, lining_t=0.6, frame=2, mount) {
    if ($children > 0) _container_floor(pts, t, p, mode, border, depth, lining_t, frame, true, mount) children();
    else _container_floor(pts, t, p, mode, border, depth, lining_t, frame, false, mount) square(1);
}
module _container_floor_zones_2d(m, grow=0) { for (g=m[15]) translate(m[3] + [g[0], 0]) square([g[1] + 2*grow, m[6] + 2*grow], center=true); }
module _container_floor(pts, t, p, mode, border, depth, lining_t, frame, holes, mount) {
    has_m = !is_undef(mount) && mount[16] == "bottom";
    pattern_panel(mode, p, container_plan(pts), t=t, depth=depth, border=border, lining_t=lining_t)
        difference() {
            offset(delta=-0.05) polygon(pts);
            if (holes) children();
            if (has_m) _container_floor_zones_2d(mount, -0.3);          // the pattern stops at the mounting zone
        }
    if (holes && frame > 0) linear_extrude(t) intersection() {
        offset(delta=-0.05) polygon(pts);
        difference() { offset(delta=frame) children(); children(); }
    }
    // the zone itself: solid floor, thickened upwards (chamfered), sockets from below
    if (has_m) for (g=mount[15]) difference() {
        translate(concat(mount[3] + [g[0], 0], [0])) union() {
            translate([-g[1]/2, -mount[6]/2, 0]) cube([g[1], mount[6], t]);
            if (mount[8] > 0) hull() {
                translate([-g[1]/2, -mount[6]/2, t - 0.01]) cube([g[1], mount[6], 0.01]);
                translate([-g[1]/2 + mount[8], -mount[6]/2 + mount[8], t + mount[8] - 0.01]) cube([g[1] - 2*mount[8], mount[6] - 2*mount[8], 0.01]);
            }
        }
        translate([mount[3][0], 0, 0]) attach_sockets(mount[0], mount[1], g[2], attach_y(mount[3][1]));
    }
}
function container_plan(pts) = let(bb = shell_bounds(pts)) [2*max(abs(bb[0][0]), abs(bb[1][0])) + 2, 2*max(abs(bb[0][1]), abs(bb[1][1])) + 2];

// ---------- ridge ----------
// A rounded ridge standing on z = 0, centred on the origin, running along Y: a saddle that an item rests on or
// is centred by (the bridge of a pair of glasses, a bottle neck, a cable). It only ever rises from the floor:
// nothing reaches below z = 0, however wide and low it is.
//   w = width of the rounded top, foot = width on the floor, h = height, len = length on the floor (along Y)
//   run = [front, back]: how far the top is set in from the foot at the -Y and +Y end (0 = vertical face, more =
//         a gentler slope, so things slide over the ridge instead of catching behind it)
//   crown = 0..1: 0 = the top is a straight bar, 1 = fully domed along Y
module container_ridge(w=13, foot=24, h=26, len=12, run=[2, 6], crown=0.5) {
    r = min(w/2, h);                                       // top radius, never more than the height
    top = max(0.02, len - run[0] - run[1]);                // length of the top
    yc = (run[0] - run[1])/2;                              // the top sits towards the steeper end
    intersection() {
        hull() {
            translate([-max(foot, w)/2, -len/2, 0]) cube([max(foot, w), len, 0.01]);
            translate([0, yc, h - r]) rotate([90, 0, 0]) cylinder(r=r, h=max(0.02, top*(1 - crown)), center=true, $fn=48);
            if (crown > 0) translate([0, yc, h - r]) scale([1, max(0.02, top/2)/r, 1]) sphere(r=r, $fn=48);
        }
        translate([-max(foot, w), -len, 0]) cube([2*max(foot, w), 2*len, h + 1]);     // nothing below the floor
    }
}

// ---------- lid ledge ----------
// ring inside the walls with its top at z, `w` wide, growing out of the wall at 45 degrees (prints without support)
module container_ledge(pts, wall_t, z, w=1.6, steps=4) {
    for (k=[0:steps-1]) translate([0, 0, z - w*(k + 1)/steps]) linear_extrude(w/steps + 0.01) difference() {
        offset(delta=-wall_t + 0.1) polygon(pts);
        offset(delta=-wall_t - w*(steps - k)/steps) polygon(pts);
    }
}

// ---------- compartments ----------
// Divider walls that split the inside into compartments. The layout is a list of groups: rows (front to back)
// that are each split into compartments from left to right, or with order = "columns", columns (left to right)
// each split from front to back. Sizes are relative weights (percentages or any numbers): [[33, 33, 33], [50, 50],
// [100]] = a row of three, a row of two and one long compartment. The sizes are the compartments' own inside
// sizes: the divider thickness is taken off before sharing out the room.
//
//   g = container_layout(text, rows, cols, sizes_text);                 // from Customizer fields (see below)
//   grid = container_grid(pts, wall_t, g[0], g[1], order, divider_t);
//   container_walls(..., plain=container_grid_plain(pts, grid, post));  // solid joints in the outer walls
//   container_dividers(pts, grid, divider_t, h, hf, [px, mode_x], [py, mode_y], bands, ...);
//   grid[2] = notes ("" or what was changed), grid[3] = [smallest compartment x, y]
//
// Dividers along x (between rows) and along y (between columns) can carry different patterns (match them to the
// front / back and the side walls). They follow the rim height function hf (slopes, waves); lower them with an
// hf of their own. Their ends reach into the middle of the outer wall, where a plain joint keeps the pattern
// clear; a solid strip under each divider keeps a patterned floor closed under it.
CONTAINER_MIN_CELL = 8;      // narrowest compartment (mm); a layout that would go below it is thinned out
CONTAINER_DIV_FOOT = 2;      // solid floor strip on each side of a divider
// layout from text: "33,33,33 / 50,50 / 100" = one group per row (or column) with the compartments' sizes;
// empty = a plain grid of `rows` x `cols`. sizes_text = the rows' (columns') own sizes, empty = equal.
// Returns [groups, sizes, note]; weights of 0 or less are dropped.
function container_layout(text, rows=1, cols=1, sizes_text="") = let(
    g0 = [for (g=str_groups(text)) let(v = [for (x=g) if (x > 0) x]) if (len(v) > 0) v],
    groups = len(g0) > 0 ? g0 : [for (i=[1:1:max(1, rows)]) [for (j=[1:1:max(1, cols)]) 1]],
    s0 = [for (x=str_nums(sizes_text)) if (x > 0) x],
    sizes = len(s0) == len(groups) ? s0 : [for (g=groups) 1],
    off = [for (v=concat(len(g0) > 0 ? g0 : [], len(s0) == len(groups) ? [s0] : [])) let(t = v*[for (x=v) 1]) if (abs(t - 100) > 1.5 && len(v) > 1) 1])
    [groups, sizes, str(
        len(s0) > 0 && len(s0) != len(groups) ? str("compartments: ", len(s0), " row/column sizes given for ", len(groups), " rows/columns, using equal sizes") : "",
        len(s0) > 0 && len(s0) != len(groups) && len(off) > 0 ? "; " : "",
        len(off) > 0 ? "compartments: sizes that do not add up to 100 are scaled to fill the box" : "")];
// cells of span [a, b] for weights w with dividers t thick between them: [[start, end], ...]
function _ctr_cum(v, k) = k <= 0 ? 0 : _ctr_cum(v, k - 1) + v[k - 1];
function container_split(a, b, w, t) = let(n = len(w), s = w*[for (x=w) 1], avail = b - a - (n - 1)*t)
    [for (k=[0:1:n - 1]) let(c0 = a + avail*_ctr_cum(w, k)/s + k*t) [c0, c0 + avail*w[k]/s]];
// keep the groups and their compartments to what fits CONTAINER_MIN_CELL (the last ones are dropped)
function _ctr_fit(w, span, t) = len(w) <= 1 || (span - (len(w) - 1)*t)*min(w)/(w*[for (x=w) 1]) >= CONTAINER_MIN_CELL - 0.01 ? w
    : _ctr_fit([for (i=[0:1:len(w) - 2]) w[i]], span, t);
// where the line c + l*d leaves the outline: [l backwards (< 0), l forwards (> 0), cos of the angle at each wall]
function _ctr_hits(pts, c, d) = let(n = len(pts),
    h = [for (i=[0:n-1]) let(A = pts[i], B = pts[(i+1)%n], e = B - A, den = d[0]*e[1] - d[1]*e[0]) if (abs(den) > 1e-9)
        let(w = A - c, l = (w[0]*e[1] - w[1]*e[0])/den, m = (w[0]*d[1] - w[1]*d[0])/den) if (m >= -1e-6 && m <= 1 + 1e-6)
        [l, abs(d*[e[1], -e[0]])/norm(e)]],
    neg = [for (x=h) if (x[0] < 0) x], pos = [for (x=h) if (x[0] > 0) x],
    a = [for (x=neg) if (x[0] == max([for (y=neg) y[0]])) x][0], b = [for (x=pos) if (x[0] == min([for (y=pos) y[0]])) x][0])
    [a, b];
// how far in from the outer face (along the divider) its end must stop: the centre in the middle of the wall,
// both corners inside the outer face
function _ctr_inset(wall_t, t, cs) = let(c = max(0.5, cs), tn = sqrt(1 - c*c)/c) (wall_t/2 + t/2*tn)/c;
// The grid: [cells, dividers, notes, [smallest x, smallest y]]
//   cells    = [[x0, y0], [x1, y1]] inside each compartment
//   dividers = [A, B, axis ("x" = runs along x), junctions (distances from A where other dividers meet it), ends
//               in the outer wall [at A, at B]]
function container_grid(pts, wall_t, groups, sizes, order="rows", t=2) = let(
    bb = shell_bounds(pts), lo = bb[0] + [wall_t, wall_t], hi = bb[1] - [wall_t, wall_t],
    ax = order == "columns" ? 0 : 1, bx = 1 - ax,                       // groups are stacked along ax, split along bx
    P = function(a, b) ax == 1 ? [b, a] : [a, b],
    n0 = len(groups),
    sz = _ctr_fit(sizes, hi[ax] - lo[ax], t), n = len(sz),
    gr = [for (k=[0:1:n - 1]) _ctr_fit(groups[k], hi[bx] - lo[bx], t)],
    prim = container_split(lo[ax], hi[ax], sz, t),
    sec = [for (k=[0:1:n - 1]) container_split(lo[bx], hi[bx], gr[k], t)],
    cells = [for (k=[0:1:n - 1]) for (c=sec[k]) let(p0 = P(prim[k][0], c[0]), p1 = P(prim[k][1], c[1])) [p0, p1]],
    // dividers between groups: across the whole box, ends found on the outline
    mains = [for (k=[1:1:n - 1]) let(a = prim[k][0] - t/2, c = P(a, (lo[bx] + hi[bx])/2), d = P(0, 1), h = _ctr_hits(pts, c, d),
        A = c + d*(h[0][0] + _ctr_inset(wall_t, t, h[0][1])), B = c + d*(h[1][0] - _ctr_inset(wall_t, t, h[1][1])),
        js = [for (kk=[k - 1, k]) for (j=[1:1:len(sec[kk]) - 1]) (sec[kk][j][0] - t/2) - (c + d*(h[0][0] + _ctr_inset(wall_t, t, h[0][1])))[bx]])
        [A, B, ax == 1 ? "x" : "y", js, [true, true]]],
    // dividers inside a group: from divider to divider, or into the outer wall at the first and last group
    cross = [for (k=[0:1:n - 1]) for (j=[1:1:len(sec[k]) - 1]) let(b = sec[k][j][0] - t/2, c = P((prim[k][0] + prim[k][1])/2, b), d = P(1, 0),
        h = _ctr_hits(pts, c, d),
        a0 = k == 0 ? (c + d*(h[0][0] + _ctr_inset(wall_t, t, h[0][1])))[ax] : prim[k][0] - t/2,
        a1 = k == n - 1 ? (c + d*(h[1][0] - _ctr_inset(wall_t, t, h[1][1])))[ax] : prim[k][1] + t/2)
        [P(a0, b), P(a1, b), ax == 1 ? "y" : "x", [], [k == 0, k == n - 1]]],
    small = [min([for (c=cells) c[1][0] - c[0][0]]), min([for (c=cells) c[1][1] - c[0][1]])],
    cut = n < n0 || len([for (k=[0:1:n - 1]) if (len(gr[k]) < len(groups[k])) 1]) > 0)
    [cells, concat(mains, cross),
     cut ? str("compartments: fewer than asked, each needs at least ", CONTAINER_MIN_CELL, " mm inside") : "", small];
// plain (pattern-free) joints in the outer walls where the dividers meet them: pass as `plain` to container_walls
function container_grid_plain(pts, grid, t=2, post=3) = [for (dv=grid[1]) for (e=[0, 1]) if (dv[4][e])
    [container_u(pts, dv[e] + (dv[e] - dv[1 - e])/norm(dv[e] - dv[1 - e])*t), -1, t + 2*post, 1e4]];
// One divider wall from A to B (plan points), t thick, centred on the line. hf = top height function (plan point),
// h = reference height (the highest point), p / mode = pattern, border = [ends, bottom, top] plain bands,
// junctions = distances from A where other dividers meet it (kept plain), notch = [depth, width]: a finger notch
// in the middle of its top edge.
module container_divider(A, B, t, h, hf, p, mode="solid", border=[3, 4, 4], depth=0.8, lining_t=0.6, junctions=[], notch=[0, 30]) {
    L = norm(B - A); d = (B - A)/L; n = [d[1], -d[0]];
    q = [A + n*t/2, B + n*t/2];                                          // shell_wrap builds on the inner side of the line
    hn = function(x) is_undef(notch) || notch[0] <= 0 ? 0 : shell_rim_dip([(x - A)*d - L/2, -50], [L, 100], notch[0], notch[1], 0, "front");
    hfd = function(x) hf(x) - hn(x);
    jp = [for (s=junctions) [s - L, -1, t + 2*border[0], 1e4]];         // loop frame of a two-point outline
    container_wall(q, 0, 0, t, h, hfd, p, mode, border, depth, lining_t, 0, plain=jp, fit=false);
}
// all dividers of a grid. specs = [[pattern, mode] for dividers along x, [pattern, mode] along y]; bands = [bottom,
// top]; post = plain band at their ends and joints; floor_t = floor thickness (a solid strip under each divider)
// mount = the container_mount() spec: a mount under the floor keeps its sockets clear of the dividers
module container_dividers(pts, grid, t, h, hf, specs, bands=[4, 4], post=3, depth=0.8, lining_t=0.6, notch=[0, 30], floor_t=2, mount) {
    difference() {
        _container_dividers(grid, t, h, hf, specs, bands, post, depth, lining_t, notch, floor_t);
        if (!is_undef(mount) && mount[16] == "bottom") for (g=mount[15])
            translate([mount[3][0], 0, 0]) attach_sockets(mount[0], mount[1], g[2], attach_y(mount[3][1]));
    }
}
module _container_dividers(grid, t, h, hf, specs, bands, post, depth, lining_t, notch, floor_t) {
    for (dv=grid[1]) {
        s = dv[2] == "x" ? specs[0] : specs[1];
        container_divider(dv[0], dv[1], t, h, hf, s[0], s[1], [post, bands[0], bands[1]], depth, lining_t, dv[3], notch);
        L = norm(dv[1] - dv[0]);
        if (floor_t > 0) translate(dv[0]) rotate(atan2(dv[1][1] - dv[0][1], dv[1][0] - dv[0][0]))
            translate([0, -t/2 - CONTAINER_DIV_FOOT, 0]) cube([L, t + 2*CONTAINER_DIV_FOOT, floor_t]);
    }
}

// ---------- mounting ----------
// The snap-in attachment plates (attach.scad) need a socket ATTACH_T deep plus ATTACH_BACK of closed wall behind
// it (attach_host_t() = 5.2 mm), usually more than a wall is thick. So the back wall (the straight wall at the
// largest y) gets a solid zone that is part of the wall itself: the pattern stops at it and joins it. The zone is
// flush with the wall's INSIDE face (nothing stands into the container, its content keeps all its room) and uses
// the wall's own thickness; only what is missing (CONTAINER_BOSS_T - t) grows OUTWARDS, with 45 degree edges all
// round (a flat bottom where it stands on the floor), so it prints upright without support. The sockets are cut
// into it from behind and the plates sit flush with its outer face. Every plate type uses the same socket, so the
// plates stay interchangeable. If the rim band or the base band is close, the solid area of the wall runs on into
// it (following a sloped or wavy rim) instead of leaving a strip of pattern.
// Plates that sit close together share one zone; further apart, each gets its own and the pattern continues between.
//
//   m = container_mount(pts, attach_type, attach_size, attach_count, rim, wall_t, [bottom band, rim band]);
//   attach_note(container_mount_note(m, attach_type, attach_size, attach_count));   // warns if it had to be reduced or left out
//   container_walls(..., mount=m);                       // or container_wall(..., mount=m) for every run
//   container_floor(..., mount=m);                       // builds it instead when the type mounts under the floor
//   container_attach(part, m, attach_opts(), 0, h_top, attach_joint);     // plates, track / fin, ball joint parts
//   parts rows: each container_attach_rows(attach_type, m, attach_joint)
CONTAINER_BOSS_T = attach_host_t();   // wall thickness in the mounting zone: socket + closed back (5.2 mm)
CONTAINER_ZONE_M = 4;        // solid wall around the sockets
CONTAINER_MERGE  = 10;       // a strip of pattern narrower than this between the zone and a band is made solid too

// mount spec: [type, size, xs, back centre [x, y] (outer face of the wall), z0, total width, zone height, floating,
//              protrusion (how far the zone stands out behind the wall), t,
//              straight back length, centre x offset, lowest rim over the zones, merge up, merge down,
//              zones [[centre x offset, width, its plates' x], ...]]
// (undef for type "none"). hf = rim height function, t = wall thickness, bands = [bottom, top] plain bands.
// The mount is fitted to the container: if the plates asked for do not fit, fewer plates and then the next
// smaller plate size are tried; if nothing fits there is no mount (undef). container_mount_note() says what was
// changed, so a project can warn instead of stopping:  attach_note(container_mount_note(m, type, size, count));
function container_mount(pts, type, size, count, hf, t, bands=[4, 4], floor_t=2) =
    type == "none" ? undef : _container_mount_fit(pts, type, size, count, count, hf, t, bands, floor_t);
function _container_mount_fit(pts, type, size, count, count0, hf, t, bands, floor_t) =
    let(m = _container_mount_try(pts, type, size, count, hf, t, bands, floor_t))
    container_mount_problem(m) == "" ? m :
    count > 1 ? _container_mount_fit(pts, type, size, count - 1, count0, hf, t, bands, floor_t) :
    attach_smaller(size) != "" ? _container_mount_fit(pts, type, attach_smaller(size), count0, count0, hf, t, bands, floor_t) : undef;
function container_mount_note(m, type, size, count) =
    type == "none" ? "" :
    is_undef(m) ? str("mounting left out: not even one S plate fits this ", attach_face(type) == "bottom" ? "floor" : "back wall",
                      attach_face(type) == "bottom" ? " (it needs 38 x 41 mm of floor inside the walls)"
                                                    : " (it needs 41 mm of height and 38 mm of straight width: raise the back or the height)") :
    m[1] != size ? str("mounting: plate size reduced from ", size, " to ", m[1], ", ", len(m[2]), " plate(s), to fit the ", m[16] == "bottom" ? "floor" : "back wall") :
    len(m[2]) < count ? str("mounting: ", len(m[2]), " plate(s) instead of ", count, " fit the ", m[16] == "bottom" ? "floor" : "back wall") : "";
function _container_mount_try(pts, type, size, count, hf, t, bands, floor_t) =
    attach_face(type) == "bottom" ? _container_mount_bottom(pts, type, size, count, t, floor_t) : let(
    bb = shell_bounds(pts), yb = bb[1][1],
    bx = [for (q=pts) if (q[1] > yb - 0.01) q[0]],                      // the points of the straight back wall
    len = max(bx) - min(bx), cx = (max(bx) + min(bx))/2,
    prot = max(0, CONTAINER_BOSS_T - t),
    sw = attach_socket_w(size), sl = attach_socket_len(size),
    xs = attach_xs(count, max(1, len - sw - 2*CONTAINER_ZONE_M)/0.6, type, size=size),   // attach_xs spreads over 60% of its span
    xm = (max(xs) + min(xs))/2, zw = max(xs) - min(xs) + sw + 2*CONTAINER_ZONE_M,
    hmin = min([for (i=[0:8]) hf([cx + xm + (i/8 - 0.5)*zw, yb - 0.01])]),
    zh0 = sl + 2*CONTAINER_ZONE_M,
    z_mid = max(0, min(hmin - zh0, (hmin - zh0)/2)),                   // centred on the wall ...
    floating = z_mid - prot > bands[0] + 1,                            // ... unless that leaves it close to the floor
    zh = zh0 + (floating ? prot : 0),                                  // room for the pad's 45 degree underside
    z0 = floating ? max(0, min(hmin - zh, (hmin - zh)/2)) : 0,
    // plates close together share one zone; plates further apart get a zone each, with pattern between them
    gw = sw + 2*CONTAINER_ZONE_M,
    apart = len(xs) > 1 && xs[1] - xs[0] - gw >= CONTAINER_MERGE,
    groups = apart ? [for (x=xs) [x, gw, [x]]] : [[xm, zw, xs]])
    [type, size, xs, [cx, yb], z0, zw, zh, floating, prot, t, len, xm, hmin,
     hmin - bands[1] - (z0 + zh) < CONTAINER_MERGE, floating && z0 - bands[0] < CONTAINER_MERGE, groups, "back"];
// The same for a type that mounts under the host (attach_face(type) == "bottom", e.g. the fin): the zone is in
// the floor, in the middle of the plan, thickened upwards into the container; the sockets open downwards.
// Same layout; [3] = plan centre, [9] = floor thickness, [10] / [12] = room inside the walls in x / y.
function _container_mount_bottom(pts, type, size, count, t, floor_t) = let(
    bb = shell_bounds(pts), c = (bb[0] + bb[1])/2,
    room = bb[1] - bb[0] - 2*[t + 2, t + 2],
    sw = attach_socket_w(size), sl = attach_socket_len(size),
    xs = attach_xs(count, max(1, room[0] - sw - 2*CONTAINER_ZONE_M)/0.6, type, size=size),
    xm = (max(xs) + min(xs))/2, zw = max(xs) - min(xs) + sw + 2*CONTAINER_ZONE_M, gw = sw + 2*CONTAINER_ZONE_M,
    apart = len(xs) > 1 && xs[1] - xs[0] - gw >= CONTAINER_MERGE)
    [type, size, xs, c, 0, zw, sl + 2*CONTAINER_ZONE_M, false, max(0, CONTAINER_BOSS_T - floor_t), floor_t, room[0], xm, room[1],
     false, false, apart ? [for (x=xs) [x, gw, [x]]] : [[xm, zw, xs]], "bottom"];

function container_mount_count(m) = is_undef(m) ? 0 : len(m[2]);
// "" if the mount fits, otherwise what is wrong
function container_mount_problem(m) = is_undef(m) ? "" :
    m[16] == "bottom" ? (m[5] > m[10] + 0.01 || m[6] > m[12] + 0.01 ? str("mounting under the floor: ", len(m[2]), " plate(s) of size ", m[1], " need ", m[5], " x ", m[6],
        " mm of floor inside the walls, there is ", m[10], " x ", m[12], " mm.") : "") :
    m[12] < m[6] - 0.01 ? str("mounting: the back wall is ", m[12], " mm high at its lowest point, the ", m[1], " plate needs ", m[6], " mm. Use a smaller plate or a higher back.") :
    m[5] > m[10] + 0.01 ? str("mounting: ", len(m[2]), " plate(s) of size ", m[1], " need ", m[5], " mm of straight back wall, there is ", m[10], " mm.") : "";
// height of the plate centres above the floor plane
function container_mount_z(m) = m[4] + (m[7] ? m[8] : 0) + CONTAINER_ZONE_M + ATTACH_NOTCH_ + attach_dims(m[1])[1]/2;
ATTACH_NOTCH_ = attach_socket_len("S") - attach_dims("S")[1];          // pry notch below a plate
// the zones and the plain (pattern-free) areas of the wall, in the strip frame (mx = strip x of the mount's middle;
// along the back wall the strip's x runs against the plates' x)
function _container_mount_zones(m, mx) = [for (g=m[15]) [mx - (g[0] - m[11]), m[4], g[1], m[6]]];
function _container_mount_plain(m, mx, h) = [for (z=_container_mount_zones(m, mx)) each concat(
    [[z[0], z[1] - 2, z[2] + 4, z[3] + 4]],
    m[13] ? [[z[0], z[1], z[2] + 4, 2*h]] : [],                        // on up to the rim
    m[14] ? [[z[0], -h, z[2] + 4, z[1] + h + 1]] : [])];               // on down to the floor
// The thick parts, built in the strip frame of their facet (z = 0 inside face, z = t outside face). The zone is
// flush with the inside face; the thickness the sockets need beyond the wall (c = m[8]) stands out behind it as a
// pad with 45 degree edges (flat at the bottom when the zone stands on the floor). The sockets are cut in from
// the pad's outer face, leaving ATTACH_BACK of closed wall on the inside.
module _container_mount_block(m, mx, t, h) {
    for (g=m[15]) {
        gx = mx - (g[0] - m[11]); w = g[1];
        c = m[8] + (is_undef($pat_shrink) ? 0 : $pat_shrink);            // shell_wrap pulls some facets in a hair: the pad face stays on the plane
        inside = is_undef($pat_window) || abs($pat_window[0][0] - gx) < $pat_window[1][0]/2;    // only on the facet that holds it
        if (inside) translate([gx, 0, t + c]) rotate([0, 180, 0]) difference() {             // now z = 0 is the pad's outer face, +z into the container
            union() {
                translate([-w/2, m[4] - h/2, c - 0.01]) cube([w, m[6], t + 0.01]);                // the wall itself, solid
                if (c > 0) hull() {
                    translate([-w/2, m[4] - h/2, c - 0.01]) cube([w, m[6], 0.01]);
                    translate([-w/2 + c, m[4] - h/2 + (m[7] ? c : 0), 0]) cube([w - 2*c, m[6] - c - (m[7] ? c : 0), 0.01]);
                }
            }
            attach_sockets(m[0], m[1], [for (x=g[2]) x - g[0]], container_mount_z(m) - h/2);
        }
    }
}
// How thick a container's floor must be for a mount underneath (attach_face(type) == "bottom"): the whole floor
// gets that thickness, so it stays flat inside and the container still stands flat outside.
// How much deeper a container must be inside so that the pad of a back mount does not take room from its
// content, and how thick its floor must be for a mount underneath (the floor stays flat inside).
function container_mount_floor(type, floor_t) = type != "none" && attach_face(type) == "bottom" ? max(floor_t, CONTAINER_BOSS_T) : floor_t;
// Everything that hangs on the mount, seated: plates, slide track or fin, ball joint parts. `part` = the project's
// part variable: one line draws whichever of them is selected (see attach_all). z_bottom / z_top = lowest and
// highest point of the container (for roof plates).
module container_attach(part, m, opts, z_bottom=0, z_top=100, joint="none") {
    if (!is_undef(m)) {
        if (m[16] == "bottom") translate([m[3][0], 0, 0]) attach_all(part, m[0], m[1], m[2], attach_y(m[3][1]), opts, joint=joint);
        else translate([m[3][0], m[3][1] + m[8], container_mount_z(m)]) rotate([90, 0, 0])      // on the pad's outer face
            attach_all(part, m[0], m[1], m[2], 0, opts, z_bottom - container_mount_z(m), z_top - container_mount_z(m), joint);
    }
}
// rows for the project's `parts` table:  parts = [ ..., each container_attach_rows(attach_type, m, attach_joint) ];
function container_attach_rows(type, m, joint="none", pull=[0, 40, 0], opts=undef) =
    attach_rows(is_undef(m) ? "none" : type, container_mount_count(m), joint, is_undef(m) || m[16] == "back" ? pull : [0, 0, -40],
                frame=is_undef(m) || m[16] == "back" ? "back" : "flat", opts=opts);


// ======================= earbuds.scad: the rest =======================
/* [Hidden] */
$fn = 48;
ft = container_mount_floor(attach_type, floor_t);      // a mount under the floor needs a thicker floor (it stays flat inside)
// maker's sizes [width, thickness, height] of the closed case standing with its lid up
function preset_size(n) =
    n == "Soundcore P31i" ? [57.5, 29.3, 57.5] : n == "AirPods Pro 2" ? [60.6, 21.7, 45.2] :
    n == "AirPods 4" ? [50.1, 21.2, 46.2] : n == "AirPods 2" ? [44.3, 21.3, 53.5] :
    n == "Galaxy Buds2 Pro / FE" ? [50.1, 27.7, 50.2] : n == "Galaxy Buds3 Pro" ? [58.9, 24.4, 48.7] :
    n == "Sony WF-1000XM5" ? [64.6, 26.5, 40.0] : n == "Bose QC Ultra Earbuds" ? [59.4, 26.7, 66.3] :
    n == "Pixel Buds Pro 2" ? [65.0, 25.0, 49.9] : n == "Nothing Ear" ? [55.5, 22.0, 55.5] : custom_size;
cs = preset_size(preset);
item = pose == "flat" ? [cs[0], cs[2], cs[1]] : pose == "side" ? [cs[2], cs[1], cs[0]] : cs;   // [x, y, z] as it sits
inner = [item[0] + 2*clearance, item[1] + 2*clearance];
size = inner + [2*wall_t, 2*wall_t];
height = ft + max(6, item[2]*hold);              // rim height at the front corners
split = corner_fill == "solid";
cr = min(corner_r, min(size)/2 - 0.5);
round_fn = max(3, ceil(cr*PI/2/4));

// ---------- outline and rim ----------
runs = shell_rect_runs(size, corners, cr, round_fn, 1);
run_edges = shell_runs_edges(runs);
pts = container_box_pts(runs, split);                 // one loop with its seam in the back left corner, or separate sides
grip_w = min(grip_width, (size[0] - 2*cr)/1.6);        // width at half depth; the shoulders need room on the straight front
dip = grip ? shell_rim_dip_depth(min(grip_depth, height - ft - 2), grip_w) : 0;
rim = function(p) shell_rim_height(p, size, height, [0, rise_back]) - shell_rim_dip(p, size, dip, grip_w, 0, "front", wall_t + 4);
h_ref = height + rise_back;

// ---------- patterns ----------
k_auto = max(0.35, min(0.8, min(size[0], height)/70));      // automatic pattern size: a few cells across the smaller wall dimension
function spec_for(name, ang=0) = pattern_sized(name, k_auto, wall_cell, wall_strut, ang, wall_seed, strut_min=1,
    opts=name == "concentric_ripples" ? [["spokes", 6]] : name == "voronoi" ? [["round", 0.6]] :
         name == "cube_rosette" ? [["cubes", cube_density]] : name == "fluted" ? [["style", flute_style], ["orient", flute_orient]] : []);
wall_spec = spec_for(wall_pattern, wall_angle);
floor_spec = spec_for(floor_pattern);
wmode = container_safe_mode(wall_mode, wall_spec);
fmode = container_safe_mode(floor_mode, floor_spec);

// ---------- cable opening ----------
under = attach_face(attach_type) == "bottom" && attach_type != "none";     // the mounting zone is in the floor
behind = attach_type != "none" && !under;                 // the mounting zone is in the back wall
has_cable = cable != "none" && !(under && cable_on == "floor") && !(behind && cable_on == "back");
cable_note = cable == "none" || has_cable ? "" :
    under ? "cable opening left out: the floor holds the mounting zone of the fin; put the opening in a wall"
          : "cable opening left out: the back wall holds the mounting zone; put the opening in the floor or a side wall";
fit = cable == "dock" ? 0.15 : 1.0;                   // play round the plug: a dock grips it
hole = [plug_size[0] + 2*fit, plug_size[1] + 2*fit];
on_floor = cable_on == "floor";
// centre of the opening: on the floor in plan, on a wall as the plan point of the wall plus a height
wall_pt = cable_on == "back" ? [cable_x, size[1]/2] : cable_on == "front" ? [cable_x, -size[1]/2] :
          cable_on == "left" ? [-size[0]/2, cable_x] : [size[0]/2, cable_x];
cable_z = ft + hole[1]/2 + max(0, cable_y);      // height of a wall opening's centre
assert(!has_cable || on_floor || cable_z + hole[1]/2 < height - (cable_on == "front" ? dip : 0) + (cable_slot ? 100 : -1),
       "cable opening: too high for this wall; lower cable_y or use the slot");

// ---------- mounting ----------
a_opts = attach_opts(roof_gap=10, slide_axis=slide_axis, fin_len=fin_len, fin_w=fin_w, fin_t=fin_t,
                     clamp_gap=clamp_gap, clamp_reach=clamp_reach, clamp_screw=clamp_screw, pipe_d=pipe_d, pipe_axis=pipe_axis);
mount = container_mount(pts, attach_type, attach_size, attach_count, rim, wall_t, [base_band + ft, rim_band], ft);   // solid zone + sockets in the back wall (fin: in the floor)
has_att = !is_undef(mount);
mount_note = container_mount_note(mount, attach_type, attach_size, attach_count);    // "" or what had to be reduced / left out

// tables read by the tools
parts = [
  ["holder", "Earbuds holder", "PLA / PETG", [0,0,0], COL_GREY_DARK],
  each container_attach_rows(attach_type, mount, attach_joint, opts=a_opts),
  ["hw_case", "Charging case (reference)", "your earbuds", [0,0,40], COL_WHITE]
];
checks = concat([["hw_case", "holder", ">=", 0]], has_att ? [["attach", "holder", "clear"]] : []);
report = [["case width", cs[0]], ["case thickness", cs[1]], ["case height", cs[2]], ["outer width", size[0]], ["outer depth", size[1]],
          ["rim height", height], ["grip cut-out depth", dip], ["case stands out above the rim", item[2] + ft - height],
          ["wall pattern cut as asked", wmode == wall_mode ? 1 : 0],
          ["mounting plates fitted", container_mount_count(mount)], ["mounting as asked", mount_note == "" ? 1 : 0]];

// ---------- 2D shapes ----------
module slot_2d(w, h) { hull() for (s=[-1, 1]) translate([s*max(0, w - h)/2, 0]) circle(d=min(w, h), $fn=32); }
// the opening in the floor (plan), with its slot running to the back edge
module floor_hole_2d() {
    translate([cable_x, cable_y]) slot_2d(hole[0], hole[1]);                       // under the case, which sits against the front
    if (cable_slot) translate([cable_x - (cable_d + 1)/2, cable_y]) square([cable_d + 1, size[1]]);
}
// openings in the walls, in the loop's unrolled frame
module wall_holes_2d() {
    if (!on_floor) translate([container_u(pts, wall_pt), container_v(cable_z, h_ref)]) {
        slot_2d(hole[0], hole[1]);
        if (cable_slot) translate([-(cable_d + 1)/2, 0]) square([cable_d + 1, h_ref]);            // up to the rim
    }
    // the floor slot leaves through the foot of the back wall
    if (on_floor && cable_slot) translate([container_u(pts, [cable_x, size[1]/2]) - (cable_d + 1)/2, container_v(-1, h_ref)])
        square([cable_d + 1, ft + 1]);
}

// ---------- solids ----------
module holder() {
    relief = wmode == "overlay" ? min(wall_relief, 0.4) : wall_relief;
    if (has_cable && on_floor) container_floor(pts, ft, floor_spec, fmode, wall_t + 2, 0.5) floor_hole_2d();
    else container_floor(pts, ft, floor_spec, fmode, wall_t + 2, 0.5, mount=mount);
    if (has_cable && (!on_floor || cable_slot))
        container_walls(pts, wall_t, h_ref, rim, wall_spec, wmode, [base_band + ft, rim_band], relief, wall_relief, split ? run_edges : undef, 2.5, mount=mount, anchor=[0, -size[1]/2]) wall_holes_2d();
    else container_walls(pts, wall_t, h_ref, rim, wall_spec, wmode, [base_band + ft, rim_band], relief, wall_relief, split ? run_edges : undef, 2.5, mount=mount, anchor=[0, -size[1]/2]);
}
// the charging case as a block, to check the fit
module case_ref() {
    r = min(item[0], item[1])*0.4;                    // cases are well rounded
    translate([0, 0, ft + item[2]/2]) hull() for (sx=[-1, 1], sy=[-1, 1]) translate([sx*(item[0]/2 - r), sy*(item[1]/2 - r), 0]) cylinder(r=r, h=item[2], center=true);
}

// ---------- assembly ----------
attach_note(mount_note);
attach_note(cable_note);
pick("holder") holder();
container_attach(part, mount, a_opts, 0, h_ref, attach_joint);
pick("hw_case") case_ref();

