// Pattern gallery: catalogue and test bench for the 15 patterns in lib/patterns.scad
// Views: a tile of every pattern, one sample you can tune, one pattern in every application mode, and a small
// box whose walls, floor and lid each get their own pattern. See README.md.
include <../../lib/core.scad>
use <../../lib/shapes.scad>
use <../../lib/patterns.scad>

part = "all";                    // which part to export ("all" = assembly); set by the build tools

/* [View] */
// gallery = all 15 patterns, sample = one pattern in one mode, modes = one pattern in every mode, box = container demo
view = "gallery"; // [gallery, sample, modes, box]

/* [Pattern (sample and modes views)] */
// which pattern
pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how it is applied to the sample (sample view)
mode = "open_lattice"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// repeat size in mm (0 = the pattern's default)
cell = 0; // [0:0.5:60]
// repeat size in Y for patterns with two sizes: square grid, diamond, fish scales (0 = default proportion)
cell_y = 0; // [0:0.5:60]
// rib / strip / line width in mm (0 = the pattern's default)
strut = 0; // [0:0.1:12]
// rotation of the pattern (degrees)
angle = 0; // [-180:5:180]
// more, smaller cells (cell size divided by this; rib width stays)
density = 1; // [0.5:0.1:3]
// shift of the pattern (mm)
offset_x = 0; // [-30:0.5:30]
offset_y = 0; // [-30:0.5:30]
// seed for Voronoi and Truchet (same seed = same pattern)
seed = 1; // [1:1:999]
// smallest printable rib and opening (the model stops with a message below these; 0 = no check)
min_strut = 0.8; // [0:0.1:3]
min_opening = 1; // [0:0.1:5]

/* [Sample] */
// sample size (mm)
sample_w = 80; // [20:1:240]
sample_h = 60; // [20:1:240]
// outline of the sample
sample_shape = "rounded"; // [rect, rounded, chamfered, notched, arched, wave, scalloped, round, hexagon]
// panel thickness (open lattice of a woven pattern: total height of the weave)
thickness = 2.4; // [0.6:0.2:10]
// relief height (raised), engraving depth (recessed)
relief = 1; // [0.2:0.1:5]
// solid frame around the pattern
border = 2.5; // [0:0.5:15]
// extra plain margin inside the frame
pad = 0; // [0:0.5:15]
// top of raised ribs
relief_profile = "flat"; // [flat, round]

/* [Overlay / lining] */
// lining thickness
lining_t = 0.8; // [0.4:0.2:3]
// how the pattern shows on the lining
lining_mode = "through_cut"; // [through_cut, raised, recessed]
// distance from the panel edge to the lining
lining_inset = 1.5; // [0:0.5:10]
// top edge of the lining
lining_edge = "square"; // [square, chamfer]

/* [Pattern details] */
// honeycomb: corners or flats pointing up
hex_orient = "pointy"; // [pointy, flat]
// square grid: shift of every other row (0.5 = bricks)
grid_stagger = 0; // [0:0.05:0.5]
// triangular lattice: open every triangle, or only every other one
tri_alternate = true;
// weaves: strand cross-section
strand_style = "flat"; // [flat, rounded]
// weaves: how far a strand climbs over the one below, as a share of the strand thickness
weave_lift = 0.6; // [0.2:0.05:0.85]
// Voronoi: 0 = regular grid, 1 = fully irregular
voronoi_irregularity = 1; // [0:0.05:1]
// Voronoi: corner radius of the cells
voronoi_round = 0; // [0:0.1:4]
// Voronoi: fill cells smaller than this (mm)
voronoi_min_cell = 0; // [0:0.5:20]
// fish scales: share of a scale hidden under the row above
scale_overlap = 0.4; // [0:0.05:0.7]
// fish scales: roundness of the tip
scale_curvature = 0.7; // [0.2:0.05:1]
// fish scales: shift of every other row
scale_stagger = 0.5; // [0:0.05:0.5]
// fish scales: raised as stepped shingles (off = raised outlines only)
scale_shingle = true;
// Truchet: how the tiles are turned
truchet_variation = "random"; // [random, alternate, rows, uniform]
// Girih: star diameter as a share of the repeat (1 = stars touch)
girih_star = 1; // [0.6:0.05:1]
// cube rosette: one hexagon in three a cube (sparse), two in three (dense), all (tumbling blocks) or none
cube_density = "sparse"; // [sparse, dense, all, none]
// fluted / reeded: convex half-round ribs (reeded), concave grooves (fluted) or flat ribs; ribs upright or lying
flute_style = "reeded"; // [reeded, fluted, ribbed]
flute_orient = "vertical"; // [vertical, horizontal]
// asanoha: a family of grid lines lying (up) or standing (side)
asanoha_orient = "up"; // [up, side]
// waves: height of the wave and its length (mm)
wave_amplitude = 3; // [0:0.5:20]
wave_length = 30; // [8:1:120]
// waves: phase shift from rib to rib (degrees)
wave_shift = 0; // [0:5:180]
// ripples: number of rings (0 = fill the surface)
ripple_rings = 0; // [0:1:30]
// ripples: radial bars that tie the rings together (needed for cut-through and open lattice)
ripple_spokes = 0; // [0:1:16]
// ripples: how much lower the outer rings are (0 = all the same)
ripple_falloff = 0.6; // [0:0.05:0.9]
// ripples: second ripple centre (off = one centre)
ripple_two_centers = false;

/* [Gallery] */
// tile size (mm)
tile = 56; // [30:2:120]
// gap between tiles
tile_gap = 6; // [2:1:20]

/* [Box demo] */
// inner pattern choices for the four walls, the floor and the lid
wall_pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
wall_mode = "through_cut"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// the front wall can differ from the other three
front_pattern = "flowing_waves"; // [same, hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
front_mode = "raised"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
floor_pattern = "concentric_ripples"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
floor_mode = "raised"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
roof_pattern = "girih_star_cross"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
roof_mode = "through_cut"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// outer size of the box (mm)
box_w = 70; // [40:1:200]
box_d = 50; // [40:1:200]
box_h = 36; // [20:1:150]
// thicknesses
wall_t = 2.4; // [1.2:0.2:6]
floor_t = 2; // [1:0.2:6]
roof_t = 2; // [1:0.2:6]
// pattern size on the box surfaces, relative to each pattern's default
box_pattern_scale = 0.7; // [0.4:0.05:1.5]
// relief height / engraving depth on the box
box_relief = 0.6; // [0.2:0.1:2]

/* [Hidden] */
$fn = 48;
NAMES = ["hex_honeycomb", "square_grid", "diamond_lattice", "triangular_lattice", "cube_rosette",
         "basket_weave", "tri_weave", "voronoi", "fish_scales", "truchet_arcs",
         "girih_star_cross", "asanoha", "flowing_waves", "concentric_ripples", "fluted"];
LABELS = ["Hex honeycomb", "Square grid", "Diamond lattice", "Triangular lattice", "Cube rosette",
          "Basket weave", "Tri-weave", "Voronoi", "Fish scales", "Truchet arcs",
          "Girih star & cross", "Asanoha", "Flowing waves", "Concentric ripples", "Fluted"];
// how each pattern is shown in the gallery: its natural use
GALLERY_MODES = ["open_lattice", "open_lattice", "open_lattice", "open_lattice", "open_lattice",
                 "open_lattice", "open_lattice", "open_lattice", "raised", "recessed",
                 "overlay", "open_lattice", "raised", "raised", "raised"];
MODES = ["through_cut", "open_lattice", "raised", "recessed", "overlay"];

// pattern-specific settings from the Customizer, as the opts list of a spec
function opts_for(name, h) =
    name == "hex_honeycomb" ? [["orient", hex_orient]] :
    name == "square_grid" ? [["stagger", grid_stagger]] :
    name == "triangular_lattice" ? [["alternate", tri_alternate]] :
    name == "basket_weave" || name == "tri_weave" ? [["style", strand_style], ["lift", h*weave_lift/(1 + weave_lift)]] :
    name == "voronoi" ? [["irregularity", voronoi_irregularity], ["round", voronoi_round], ["min_cell", voronoi_min_cell]] :
    name == "fish_scales" ? [["overlap", scale_overlap], ["curvature", scale_curvature], ["stagger", scale_stagger], ["shingle", scale_shingle]] :
    name == "truchet_arcs" ? [["variation", truchet_variation]] :
    name == "girih_star_cross" ? [] :
    name == "cube_rosette" ? [["cubes", cube_density]] :
    name == "asanoha" ? [["orient", asanoha_orient]] :
    name == "fluted" ? [["style", flute_style], ["orient", flute_orient]] :
    name == "flowing_waves" ? [["amplitude", wave_amplitude], ["wavelength", wave_length], ["shift", wave_shift]] :
    [["rings", ripple_rings], ["spokes", ripple_spokes], ["falloff", ripple_falloff],
     ["centers", ripple_two_centers ? [[-sample_w/6, -sample_h/8], [sample_w/5, sample_h/6]] : [[0, 0]]]];
function scaled(v, k) = is_list(v) ? [for (x=v) x*k] : v*k;
// the user's cell: 0 = default; one number scales the default proportion; cell_y sets the second size
function user_cell(name) = let(d = pattern_default(name)[0])
    cell == 0 ? d : cell_y > 0 ? [cell, cell_y] : is_list(d) ? scaled(d, cell/d[0]) : cell;
// height of the strands in the chosen mode (the weave's lift is a share of it)
function weave_h(m) = m == "open_lattice" ? thickness : relief;
function girih_opts(name, c) = name == "girih_star_cross" && girih_star < 1 ? [["star", (is_list(c) ? c[0] : c)/density*girih_star]] : [];
function user_spec(m) = let(c = user_cell(pattern))
    pattern_spec(pattern, c, strut == 0 ? undef : strut, angle, [offset_x, offset_y], density, seed,
                 opts=concat(opts_for(pattern, weave_h(m)), girih_opts(pattern, c)), min_strut=min_strut, min_opening=min_opening);
// library defaults, scaled, for the box surfaces
function box_spec(name, h) = pattern_sized(name, box_pattern_scale, strut_min=0.8,
    opts=name == "concentric_ripples" ? [["spokes", 6], ["falloff", 0.5]] : []);

front = front_pattern == "same" ? wall_pattern : front_pattern;
front_m = front_pattern == "same" ? wall_mode : front_mode;
tp = tile + tile_gap;                                 // tile pitch
mp = sample_w + 8;                                    // pitch of the mode samples
post = 6;                                             // corner posts of the box (carry the lid pins)
pin_d = 3; pin_h = 2; pin_clr = 0.2;                  // lid pins on the posts
function tile_pos(i) = [(i%5 - 2)*tp, (1 - floor(i/5))*tp];      // 5 columns, 3 rows

feat = pattern_features(user_spec(mode));
parts = concat(
  [for (i=[0:len(NAMES)-1]) [str("g_", NAMES[i]), LABELS[i], "PLA", [0,0,0], i < 5 ? COL_GREY : i < 7 ? COL_TAN : i == 7 ? COL_FIXTURE : i < 12 ? COL_BRASS : COL_GREY_DARK]],
  [["sample", "Sample", "PLA", [0,0,0], COL_GOLD],
   ["m_flat", "Pattern alone", "PLA", [0,0,0], COL_GREY],
   ["m_through_cut", "Through-cut", "PLA", [0,0,0], COL_GREY],
   ["m_open_lattice", "Open lattice", "PLA", [0,0,0], COL_TAN],
   ["m_raised", "Raised", "PLA", [0,0,0], COL_BRASS],
   ["m_recessed", "Recessed", "PLA", [0,0,0], COL_FIXTURE],
   ["m_overlay", "Overlay", "PLA", [0,0,0], COL_GREY_DARK],
   ["box", "Box", "PLA", [0,0,0], COL_GREY],
   ["lid", "Lid", "PLA", [0,0,25], COL_BRASS]]);
checks = view == "box" ? [["lid", "box", ">=", 0]] : [];
report = [["pattern rib width", feat[0]], ["smallest opening", feat[1]], ["pattern is one network", pattern_is_connected(user_spec(mode)) ? 1 : 0]];

// ---------- 2D outlines ----------
module sample_2d(w=sample_w, h=sample_h, shape=sample_shape) {
    if (shape == "round") scale([w, h]/2) circle(r=1, $fn=96);
    else if (shape == "hexagon") scale([w/2, h/sqrt(3)]) circle(r=1, $fn=6);
    else plaque_2d([w, h], shape, r=min(w, h)*0.12);
}
function sample_size() = [sample_w, sample_h] + (has_edge_wave(sample_shape) ? [0, 20] : [0, 0]);    // room for the wavy edges

// ---------- solids ----------
// one pattern in one mode on the sample outline
module sample_panel(m, lm0=lining_mode) {
    lm = pattern_is_connected(user_spec(m)) || lm0 != "through_cut" ? lm0 : "raised";      // loose patterns cannot be a perforated lining
    pattern_panel(m, user_spec(m), sample_size(), t=thickness, depth=m == "overlay" && lm == "recessed" ? min(relief, lining_t/2) : relief,
                  border=border, pad=m == "overlay" ? lining_inset : pad, profile=relief_profile,
                  lining_t=lining_t, lining_mode=lm, lining_edge=lining_edge) sample_2d();
}
module gallery_tile(i) {
    n = NAMES[i]; m = GALLERY_MODES[i];
    k = tile/56*(n == "tri_weave" ? 0.7 : 1);          // patterns grow with the tile (tri-weave: more strands)
    s = pattern_sized(n, k, opts=n == "concentric_ripples" ? [["falloff", 0.6]] : n == "voronoi" ? [["round", 0.8*k]] : []);
    pattern_panel(m, s, [tile, tile], t=m == "open_lattice" ? 2.4 : 2, depth=m == "recessed" ? 0.8 : 1.2, border=2.5,
                  profile=n == "flowing_waves" ? "round" : "flat", lining_t=0.8) plaque_2d([tile, tile], "rounded", r=4);
}
// a wall / floor / roof panel of the box: any pattern, any mode, on a plain rectangle
module box_panel(name, m, size, t, edge) {
    ok = pattern_is_connected(box_spec(name, t)) || (m != "through_cut" && m != "open_lattice");
    pattern_panel(ok ? m : "raised", box_spec(name, t), size, t=t, depth=box_relief, border=edge, lining_t=0.6, lining_mode="through_cut")
        square(size, center=true);
}
module box_body() {
    iw = box_w - 2*wall_t; id = box_d - 2*wall_t;
    // floor: decorated face up (inside the box)
    box_panel(floor_pattern, floor_mode, [box_w, box_d], floor_t, wall_t + post);
    // walls: built flat with the decorated face up, then stood up with that face outwards
    translate([0, -box_d/2, box_h/2]) rotate([90, 0, 0]) translate([0, 0, -wall_t]) box_panel(front, front_m, [box_w, box_h], wall_t, wall_t + 1.5);
    translate([0, box_d/2, box_h/2]) rotate([90, 0, 180]) translate([0, 0, -wall_t]) box_panel(wall_pattern, wall_mode, [box_w, box_h], wall_t, wall_t + 1.5);
    for (s=[-1, 1]) translate([s*box_w/2, 0, box_h/2]) rotate([90, 0, s*90]) translate([0, 0, -wall_t]) box_panel(wall_pattern, wall_mode, [box_d, box_h], wall_t, wall_t + 1.5);
    // corner posts with pins for the lid
    for (sx=[-1, 1]) for (sy=[-1, 1]) translate([sx*(iw/2 - post/2 + 0.01), sy*(id/2 - post/2 + 0.01), 0]) {
        translate([-post/2, -post/2, 0]) cube([post, post, box_h]);
        translate([0, 0, box_h - 0.01]) cylinder(d=pin_d, h=pin_h + 0.01, $fn=24);
    }
}
module box_lid() {
    iw = box_w - 2*wall_t; id = box_d - 2*wall_t;
    translate([0, 0, box_h]) difference() {
        box_panel(roof_pattern, roof_mode, [box_w, box_d], roof_t, wall_t + post);
        for (sx=[-1, 1]) for (sy=[-1, 1]) translate([sx*(iw/2 - post/2 + 0.01), sy*(id/2 - post/2 + 0.01), -1])
            cylinder(d=pin_d + 2*pin_clr, h=pin_h + 1 + 0.4, $fn=24);
    }
}

// ---------- assembly ----------
if (view == "gallery") for (i=[0:len(NAMES)-1]) pick(str("g_", NAMES[i])) translate(tile_pos(i)) gallery_tile(i);

if (view == "sample") pick("sample") sample_panel(mode);

if (view == "modes") {
    can_open = pattern_is_connected(user_spec("open_lattice"));
    // the bare pattern: 2D patterns extruded, woven patterns as strands, in a thin frame
    pick("m_flat") translate([-2.5*mp, 0, 0]) {
        pattern_3d(user_spec("raised"), sample_size(), relief, profile=relief_profile) sample_2d();
        linear_extrude(relief) stroke_2d(1.6, inside=true) sample_2d();
    }
    for (i=[0:4]) if (i > 1 || can_open) pick(str("m_", MODES[i])) translate([(i - 1.5)*mp, 0, 0]) sample_panel(MODES[i]);
}

if (view == "box") {
    pick("box") box_body();
    pick("lid") box_lid();
}
