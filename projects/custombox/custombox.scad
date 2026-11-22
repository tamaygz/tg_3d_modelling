// Custom box: a fully configurable container, from square and modern to round and flowing
// Walls, floor and lid each take any pattern from lib/patterns.scad; the outline, the corners, the rim (slopes and
// waves) and the mounting are all settings. Built with lib/shell.scad, lib/patterns.scad and lib/attach.scad.
include <../../lib/core.scad>
use <../../lib/shell.scad>
use <../../lib/patterns.scad>
use <../../lib/attach.scad>
use <../../lib/container.scad>
use <../../lib/strings.scad>

part = "all";                    // which part to export ("all" = assembly); set by the build tools

/* [Size] */
// outer width (x, left to right) in mm
width = 120; // [30:1:250]
// outer depth (y, front to back) in mm
depth = 90; // [30:1:250]
// height of the rim (mm) before slopes, waves and notches
height = 60; // [15:1:250]

/* [Outline] */
// box = straight sides with the corners below; ellipse and squircle = round, flowing outlines
shape = "box"; // [box, ellipse, squircle]
// corners of the box shape
corners = "round"; // [round, chamfer, square]
// corner radius / chamfer size (mm)
corner_r = 16; // [1:0.5:100]
// squircle: 2 = ellipse, 4 = soft box, 8 = nearly square
squareness = 4; // [2:0.5:10]
// waves in the outline itself: how far the walls swing in and out (0 = straight walls)
side_wave = 0; // [0:0.25:10]
// number of those waves round the box
side_wave_count = 8; // [2:1:40]

/* [Rim: slopes and waves] */
// raise (+) or lower (-) the front wall's rim (mm). Each wall's raise slopes back to 0 at the opposite wall, and they add up: back 20 + right 10 = the back right corner 30 mm higher
rise_front = 0; // [-150:1:150]
// raise (+) or lower (-) the back wall's rim (mm)
rise_back = 0; // [-150:1:150]
// raise (+) or lower (-) the left wall's rim (mm)
rise_left = 0; // [-150:1:150]
// raise (+) or lower (-) the right wall's rim (mm)
rise_right = 0; // [-150:1:150]
// rim waves along the front and back: amplitude = how far the rim rises and falls (mm; 0 = no waves)
rim_wave_x_amp = 0; // [0:0.5:40]
// number of those waves across the width (any amplitude above 0 is needed to see them)
rim_wave_x_count = 1; // [0.5:0.5:8]
// rim waves along the left and right sides: amplitude (mm; 0 = no waves)
rim_wave_y_amp = 0; // [0:0.5:40]
// number of those waves across the depth
rim_wave_y_count = 1; // [0.5:0.5:8]
// shifts the waves (degrees; 180 turns crests into troughs)
rim_wave_phase = 0; // [0:15:345]

/* [Rim: notches] */
// notch (dip) in the front wall's rim, e.g. a grip or a pouring lip: depth (mm; 0 = none)
notch_front = 0; // [0:1:150]
// front notch: width at half its depth (mm)
notch_front_w = 40; // [10:1:250]
// notch in the back wall's rim: depth (mm; 0 = none)
notch_back = 0; // [0:1:150]
// back notch: width at half its depth (mm)
notch_back_w = 40; // [10:1:250]
// notch in the left wall's rim: depth (mm; 0 = none)
notch_left = 0; // [0:1:150]
// left notch: width at half its depth (mm)
notch_left_w = 40; // [10:1:250]
// notch in the right wall's rim: depth (mm; 0 = none)
notch_right = 0; // [0:1:150]
// right notch: width at half its depth (mm)
notch_right_w = 40; // [10:1:250]

/* [Compartments] */
// rows of compartments (front to back) in the plain grid
compart_rows = 1; // [1:1:12]
// columns of compartments (left to right) in the plain grid
compart_cols = 1; // [1:1:12]
// your own layout instead of the grid: one group per row, the sizes of its compartments in %, groups separated
// by "/". "33,33,33 / 50,50 / 100" = three equal compartments in the front row, two in the middle, one at the back
compart_layout = "";
// the rows' own depths in % from front to back, e.g. "50, 25, 25" (empty = equal)
compart_sizes = "";
// rows = groups are rows split left to right; columns = groups are columns (left to right) split front to back
compart_order = "rows"; // [rows, columns]
// divider thickness (mm; 0 = same as the walls)
divider_t = 0; // [0:0.2:8]
// how much lower than the rim the dividers are (mm; 0 = as high as the rim)
divider_drop = 0; // [0:0.5:150]
// finger notch in the middle of every divider: depth (mm; 0 = none)
divider_notch = 0; // [0:1:100]
// divider finger notch: width at half its depth (mm)
divider_notch_w = 30; // [10:1:120]
// divider pattern: match = like the walls they run along (front / back for dividers along x, the sides for
// dividers along y), solid = no pattern, or a pattern of their own
divider_pattern = "match"; // [match, solid, hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the divider pattern is applied (match = like those walls)
divider_mode = "match"; // [match, solid, through_cut, open_lattice, raised, recessed, overlay]

/* [Walls] */
// wall thickness (woven open lattice: total height of the weave)
wall_t = 2.4; // [1.2:0.2:8]
// pattern on the walls
wall_pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the pattern is applied
wall_mode = "through_cut"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// pattern repeat size in mm (0 = the pattern's default)
wall_cell = 0; // [0:0.5:60]
// rib / strip / line width in mm (0 = the pattern's default)
wall_strut = 0; // [0:0.1:12]
// rotation of the pattern (degrees)
wall_angle = 0; // [-90:5:90]
// seed for Voronoi and Truchet
wall_seed = 1; // [1:1:999]
// relief height (raised), engraving depth (recessed), lining thickness (overlay)
wall_relief = 0.8; // [0.2:0.1:3]
// plain band under the rim (mm)
rim_band = 4; // [0:0.5:30]
// plain band above the floor (mm)
base_band = 4; // [0:0.5:30]
// corners: pattern = the pattern runs round the corners; solid = plain corners, every wall is its own panel
corner_fill = "pattern"; // [pattern, solid]
// plain strip at both ends of each wall panel (solid corners) (mm)
post_w = 3; // [0:0.5:20]
// adjust the pattern slightly so it closes round the box without a seam (pattern corners only): cell size for
// lattices, wavelength for waves, and Voronoi / Truchet are made to repeat after one round
fit_cells = true;
// pattern on the front wall (box shape with solid corners; same = like the other walls)
front_pattern = "same"; // [same, hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the front pattern is applied
front_mode = "raised"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// pattern on the back wall (box shape with solid corners; same = like the other walls)
back_pattern = "same"; // [same, hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the back pattern is applied
back_mode = "solid"; // [solid, through_cut, open_lattice, raised, recessed, overlay]

/* [Floor] */
// floor thickness = strength (mm)
floor_t = 2; // [0.8:0.2:8]
// pattern on the floor
floor_pattern = "concentric_ripples"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the floor pattern is applied
floor_mode = "solid"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// floor pattern repeat size in mm (0 = the pattern's default)
floor_cell = 0; // [0:0.5:60]
// floor rib width in mm (0 = the pattern's default)
floor_strut = 0; // [0:0.1:12]
// rotation of the floor pattern (degrees)
floor_angle = 0; // [-90:5:90]
// relief height / engraving depth on the floor
floor_relief = 0.6; // [0.2:0.1:3]
// plain margin between the walls and the floor pattern
floor_margin = 3; // [0:0.5:30]

/* [Lid] */
// inset = a lid that drops into the box onto a ledge (flat rims only)
lid = "none"; // [none, inset]
// lid thickness (mm)
lid_t = 2; // [1:0.2:6]
// pattern on the lid
lid_pattern = "girih_star_cross"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the lid pattern is applied
lid_mode = "recessed"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// lid pattern repeat size in mm (0 = default)
lid_cell = 0; // [0:0.5:60]
// lid rib width in mm (0 = default)
lid_strut = 0; // [0:0.1:12]
// how to lift the lid
lid_grip = "hole"; // [none, hole, knob]
// how far the lid sits below the rim (mm)
lid_drop = 1; // [0:0.5:20]
// lid play in the box per side (mm)
lid_clearance = 0.3; // [0.1:0.05:1]

/* [Mounting] */
// mount the box: snap-in plates in a solid zone of the back wall (box shape only), or fin = a blade under the
// floor (any shape); none = free-standing
attach_type = "none"; // [none, wall, keyhole, skadis, hook, magnet, flat, roof, slide, fin, clamp, pipe]
// plate size: S 30 x 30, M 45 x 40, L 60 x 50 mm (a smaller one is used if it does not fit)
attach_size = "S"; // [S, M, L]
// number of plates side by side (fewer are used if they do not fit)
attach_count = 1; // [1:1:4]
// ball joint between the box and the plate: turn and tilt it freely, the lock ring clamps it
attach_joint = "none"; // [none, ball]
// slide: the track runs horizontally (slide the box along it) or vertically (drop it onto the track)
slide_axis = "horizontal"; // [horizontal, vertical]
// fin: a blade under the box that anchors it, e.g. between two sofa cushions: how far down it reaches (mm)
fin_len = 120; // [30:5:250]
// fin: width of the blade (mm)
fin_w = 80; // [30:5:240]
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
// weaves: strand cross-section
strand_style = "flat"; // [flat, rounded]
// Voronoi: corner radius of the cells
voronoi_round = 0.8; // [0:0.1:4]
// honeycomb: corners or flats pointing up
hex_orient = "pointy"; // [pointy, flat]
// cube rosette: one hexagon in three a cube (sparse), two in three (dense), all (tumbling blocks) or none
cube_density = "sparse"; // [sparse, dense, all, none]
// fluted: convex half-round ribs (reeded), concave grooves (fluted) or flat ribs
flute_style = "reeded"; // [reeded, fluted, ribbed]
// fluted: ribs upright (vertical) or lying (horizontal)
flute_orient = "vertical"; // [vertical, horizontal]
// flowing waves: wave height (mm)
wave_amplitude = 3; // [0:0.5:20]
// flowing waves: wavelength (mm)
wave_length = 30; // [8:1:120]
// ripples: radial bars tying the rings together (needed for cut-through and open lattice)
ripple_spokes = 6; // [0:1:16]
// smallest printable rib (mm; 0 = no check)
min_strut = 0.8; // [0:0.1:3]
// smallest printable opening (mm; 0 = no check)
min_opening = 1; // [0:0.1:5]
// curved walls are built from flat facets this long (mm; smaller = smoother and slower)
facet = 6; // [2:0.5:20]

/* [Hidden] */
$fn = 48;
size = [width, depth];
boxy = shape == "box";
split = boxy && corner_fill == "solid";               // every wall its own panel, plain corners
round_fn = max(3, ceil(corner_r*PI/2/facet));         // facets per round corner
on_back = attach_face(attach_type) == "back";
want_att = attach_type != "none" && boxy && on_back && side_wave == 0;  // mounting on the back needs one straight back facet
side_n = side_wave > 0 ? max(2, ceil(max(width, depth)/facet)) : (split || want_att ? 1 : 2);
n_curve = max(24, ceil(PI*(width + depth)/2/facet/4)*4);

// ---------- outline ----------
runs = shell_rect_runs(size, corners, corner_r, round_fn, side_n);
run_edges = shell_runs_edges(runs);
base_pts = !boxy ? (shape == "ellipse" ? shell_ellipse_pts(size, n_curve) : shell_squircle_pts(size, squareness, n_curve))
         : split ? shell_runs_pts(runs)
         : want_att ? container_box_pts(runs)                                                        // mounted: seam in the back left corner
         : shell_start_at(shell_runs_pts(runs), shell_run(run_edges, "back")[1] + floor(side_n/2));   // seam in the middle of the back
pts = shell_wavy_pts(base_pts, side_wave, side_wave_count);
perimeter = shell_len(pts);

// ---------- rim ----------
raise = [rise_front, rise_back, rise_left, rise_right];
waves = [[rim_wave_x_amp, rim_wave_x_count], [rim_wave_y_amp, rim_wave_y_count]];
min_wall_h = floor_t + base_band + rim_band + 3;                                     // lowest a wall or divider may get
rng0 = shell_rim_range(size, height, raise, waves);                                 // without notches
notch_max = max(0, rng0[0] - min_wall_h);                                            // deepest notch that still leaves a wall
notch_ask = [["front", notch_front, notch_front_w], ["back", notch_back, notch_back_w],
             ["left", notch_left, notch_left_w], ["right", notch_right, notch_right_w]];
notches = [for (n=notch_ask) if (n[1] > 0) [n[0], min(n[1], notch_max), n[2]]];
notch_note = len([for (n=notch_ask) if (n[1] > notch_max + 0.01) 1]) > 0 ? str("rim notches limited to ", notch_max, " mm deep: deeper ones would cut into the floor and bands") : "";
rim = function(p) shell_rim(p, size, height, raise, waves, rim_wave_phase, notches);
rng = shell_rim_range(size, height, raise, waves, notches);
h_ref = rng[1];                                     // nothing is higher than this
h_low = rng[0];                                     // nothing is lower than this
rim_flat = rng[0] == rng[1];
assert(h_low >= floor_t + base_band + rim_band + 3, str("the rim dips to ", h_low, " mm: too low for the floor (", floor_t,
    ") plus the bands (", base_band, " + ", rim_band, "). Raise the height or reduce the slope / waves."));

// ---------- patterns ----------
function opts_for(name, h) =
    name == "hex_honeycomb" ? [["orient", hex_orient]] :
    name == "basket_weave" || name == "tri_weave" ? [["style", strand_style]] :
    name == "voronoi" ? [["round", voronoi_round]] :
    name == "flowing_waves" ? [["amplitude", wave_amplitude], ["wavelength", wave_length]] :
    name == "concentric_ripples" ? [["spokes", ripple_spokes]] :
    name == "cube_rosette" ? [["cubes", cube_density]] :
    name == "fluted" ? [["style", flute_style], ["orient", flute_orient]] : [];
function spec_for(name, c, st, ang, seed, h) =
    pattern_sized(name, 1, c, st, ang, seed, opts_for(name, h), min_strut=min_strut, min_opening=min_opening);
function safe_mode(m, s) = container_safe_mode(m, s);     // a pattern that would fall apart when cut through is raised instead

wall_spec0 = spec_for(wall_pattern, wall_cell, wall_strut, wall_angle, wall_seed, wall_t);
wall_spec = !split && fit_cells ? pattern_wrapped(wall_spec0, perimeter) : wall_spec0;      // closes without a seam (the library does the same)
front_name = front_pattern == "same" ? wall_pattern : front_pattern;
back_name = back_pattern == "same" ? wall_pattern : back_pattern;
function side_spec(name) = spec_for(name, wall_cell, wall_strut, wall_angle, wall_seed, wall_t);
function side_name(run) = run == "front" ? front_name : run == "back" ? back_name : wall_pattern;
function side_mode(run) = run == "front" && front_pattern != "same" ? front_mode : run == "back" && back_pattern != "same" ? back_mode : wall_mode;
floor_spec = spec_for(floor_pattern, floor_cell, floor_strut, floor_angle, wall_seed, floor_t);
lid_spec = spec_for(lid_pattern, lid_cell, lid_strut, 0, wall_seed, lid_t);
bb = shell_bounds(pts);
plan = [2*max(abs(bb[0][0]), abs(bb[1][0])) + 2, 2*max(abs(bb[0][1]), abs(bb[1][1])) + 2];   // covers the outline, centred

// ---------- lid ----------
has_lid = lid == "inset" && rim_flat;
ledge_w = 1.6;                                        // ledge the lid rests on (printed as a 45 degree step)
lid_z = height - lid_drop - lid_t;                    // underside of the lid

// ---------- compartments ----------
layout = container_layout(compart_layout, compart_rows, compart_cols, compart_sizes);
dt = divider_t > 0 ? divider_t : wall_t;
grid = container_grid(pts, wall_t, layout[0], layout[1], compart_order, dt);
has_div = len(grid[1]) > 0;
drop_max = max(0, h_low - min_wall_h);                                       // dividers keep at least the bands
drop = min(divider_drop, drop_max);
div_top = has_lid ? lid_z - 0.4 : 1e4;                                       // under the lid
div_hf = function(p) min(rim(p) - drop, div_top);
div_notes = [for (x=[layout[2], grid[2], divider_drop > drop_max + 0.01 ? str("dividers lowered by ", drop, " mm instead of ", divider_drop, ": they keep the floor and bands") : ""]) if (x != "") x];
div_note = len(div_notes) == 0 ? "" : str(div_notes[0], len(div_notes) > 1 ? str("; ", div_notes[1]) : "", len(div_notes) > 2 ? str("; ", div_notes[2]) : "");
function div_style(run) = let(                                               // [pattern, mode] of the dividers along a wall
    wn = split ? side_name(run) : wall_pattern, wm = split ? side_mode(run) : wall_mode,
    name = divider_pattern == "match" || divider_pattern == "solid" ? wn : divider_pattern,
    mode = divider_pattern == "solid" ? "solid" : divider_mode == "match" ? wm : divider_mode,
    sp = side_spec(name))
    [sp, safe_mode(mode, sp)];
div_plain = has_div ? container_grid_plain(pts, grid, dt, post_w) : [];

// ---------- mounting ----------
a_opts = attach_opts(roof_gap=10, slide_axis=slide_axis, fin_len=fin_len, fin_w=fin_w, fin_t=fin_t,
                     clamp_gap=clamp_gap, clamp_reach=clamp_reach, clamp_screw=clamp_screw, pipe_d=pipe_d, pipe_axis=pipe_axis);
mount = want_att || (attach_type != "none" && !on_back) ? container_mount(pts, attach_type, attach_size, attach_count, rim, wall_t, [base_band + floor_t, rim_band], floor_t) : undef;   // solid zone + sockets in the back wall
has_att = !is_undef(mount);
mount_note = attach_type != "none" && on_back && !boxy ? "mounting left out: plates on the back need the box shape (use fin, or shape = box)"
           : container_mount_note(mount, attach_type, attach_size, attach_count);    // "" or what had to be reduced / left out

// tables read by the tools
feat = pattern_features(split ? side_spec(wall_pattern) : wall_spec);
parts = [
  ["box", "Box", "PLA / PETG", [0,0,0], COL_TAN],
  ["lid", "Lid", "PLA / PETG", [0,0,30], COL_BRASS],
  each container_attach_rows(attach_type, mount, attach_joint, opts=a_opts)
];
checks = concat(has_lid ? [["lid", "box", "clear"]] : [], has_att ? [["attach", "box", "clear"]] : []);
report = [["perimeter", perimeter], ["wall cell used", is_list(wall_spec[1]) ? wall_spec[1][0] : wall_spec[1]],
          ["wall rib width", feat[0]], ["wall opening", feat[1]], ["lowest rim", h_low], ["highest rim", h_ref],
          ["lid fitted", has_lid ? 1 : 0],
          ["wall pattern cut as asked", safe_mode(wall_mode, wall_spec) == wall_mode ? 1 : 0],
          ["mounting plates fitted", container_mount_count(mount)], ["mounting as asked", mount_note == "" ? 1 : 0],
          ["compartments", len(grid[0])], ["smallest compartment x", grid[3][0]], ["smallest compartment y", grid[3][1]],
          ["divider drop", drop], ["compartments as asked", div_note == "" ? 1 : 0], ["rim notches as asked", notch_note == "" ? 1 : 0]];

// ---------- 2D shapes ----------
module plan_2d() { polygon(pts); }
module inner_2d(extra=0) { offset(delta=-wall_t - extra) plan_2d(); }
module lid_2d() {
    difference() { inner_2d(lid_clearance); if (lid_grip == "hole") circle(d=min(22, min(width, depth)/3)); }
}

// ---------- solids ----------
// one stretch of wall (edges e0..e1 of the outline) as a patterned panel bent round the outline
module wall_run(e0, e1, spec, m, side_border) {
    mode = safe_mode(m, spec);
    container_wall(pts, e0, e1, wall_t, h_ref, rim, spec, mode, [side_border, base_band + floor_t, rim_band],
                   mode == "overlay" ? min(wall_relief, 0.4) : wall_relief, wall_relief, mount=mount, fit=fit_cells, plain=div_plain,
                   anchor=!split && want_att ? [0, -depth/2] : undef);
}
module walls() {
    if (split) for (r=run_edges) {
        if (container_is_corner(r[0])) wall_run(r[1], r[2], side_spec(wall_pattern), "solid", 0);
        else wall_run(r[1], r[2], side_spec(side_name(r[0])), side_mode(r[0]), post_w);
    }
    else wall_run(0, len(pts) - 1, wall_spec, wall_mode, 0);
}
module floor_plate() {
    container_floor(pts, floor_t, floor_spec, safe_mode(floor_mode, floor_spec), wall_t + floor_margin,
                    floor_mode == "overlay" ? min(floor_relief, 0.4) : floor_relief, floor_relief, mount=mount);
}
module box_body() {
    floor_plate();
    walls();
    if (has_lid) container_ledge(pts, wall_t, lid_z - 0.03, ledge_w);
    if (has_div) container_dividers(pts, grid, dt, h_ref, div_hf, [div_style("front"), div_style("left")],
        [base_band + floor_t, rim_band], post_w, wall_relief, wall_relief, [divider_notch, divider_notch_w], floor_t, mount);
}
module box_lid() {
    m = safe_mode(lid_mode, lid_spec);
    translate([0, 0, lid_z]) {
        pattern_panel(m, lid_spec, plan, t=lid_t, depth=m == "overlay" ? 0.4 : 0.6, border=3, lining_t=0.6) lid_2d();
        if (lid_grip == "knob") {
            linear_extrude(lid_t) circle(d=18);
            translate([0, 0, lid_t - 0.01]) { cylinder(d1=9, d2=14, h=8); translate([0, 0, 8]) cylinder(d=14, h=2); }
        }
    }
}

// ---------- assembly ----------
attach_note(mount_note);
attach_note(notch_note);
attach_note(div_note);
pick("box") box_body();
if (has_lid) pick("lid") box_lid();
container_attach(part, mount, a_opts, 0, h_ref, attach_joint);
