// Sunglasses holder: a tray for folded glasses with nose support, grip cut-out and mounting
// Size presets (or your own), patterned walls from lib/patterns.scad, snap-in attachment plates from lib/attach.scad.
// Built with lib/container.scad on lib/shell.scad. Sister project of projects/earbuds.
include <../../lib/core.scad>
use <../../lib/shell.scad>
use <../../lib/patterns.scad>
use <../../lib/attach.scad>
use <../../lib/container.scad>

part = "all";                    // which part to export ("all" = assembly); set by the build tools

/* [Glasses] */
// size of the folded glasses (typical values: measure yours, or use custom)
preset = "standard"; // [standard, small, aviator, oversized, sport wrap, custom]
// custom: width, depth when folded, lens height (mm)
custom_size = [148, 48, 50];
// play around the glasses on every side (mm)
clearance = 2; // [0.5:0.5:10]
// how much of the lens height the walls cover
hold = 0.55; // [0.2:0.05:1.1]

/* [Nose support] */
// a ridge the bridge of the glasses rests on: keeps them centred and the lenses off the walls
nose = true;
// width at the top (the gap between the nose pads is 14-20 mm) and at the foot
nose_w = 13; // [6:0.5:30]
nose_foot = 24; // [8:1:60]
// height above the floor: the bridge height carries the glasses, less only centres them
nose_h = 26; // [5:1:80]
// length front to back, and distance from the front wall
nose_len = 16; // [4:1:60]
nose_setback = 5; // [0:0.5:40]
// slope of the front and the back face: how far the top is set in from the foot (mm; 0 = vertical).
// A sloped back lets the glasses slide up and off instead of hooking behind the ridge
nose_run_front = 2; // [0:0.5:30]
nose_run_back = 8; // [0:0.5:30]
// roundness of the top along its length: 0 = straight bar, 1 = fully domed
nose_crown = 0.6; // [0:0.05:1]

/* [Walls] */
// wall thickness (mm)
wall_t = 2.4; // [1.2:0.2:6]
// corners of the holder
corners = "round"; // [round, chamfer, square]
corner_r = 14; // [1:0.5:40]
// pattern on the walls and how it is applied
wall_pattern = "diamond_lattice"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
wall_mode = "through_cut"; // [solid, through_cut, open_lattice, raised, recessed, overlay]
// pattern repeat size and rib width in mm (0 = a size that suits the holder)
wall_cell = 0; // [0:0.5:40]
wall_strut = 0; // [0:0.1:8]
wall_angle = 0; // [-90:5:90]
wall_seed = 1; // [1:1:999]
// relief height / engraving depth / lining thickness
wall_relief = 0.6; // [0.2:0.1:2]
// plain band under the rim and above the floor (mm)
rim_band = 3; // [0:0.5:20]
base_band = 2; // [0:0.5:20]
// corners: pattern = the pattern runs round the corners; solid = plain corners
corner_fill = "pattern"; // [pattern, solid]
// how much higher the back wall is than the front (mm)
rise_back = 12; // [0:1:80]

/* [Front grip] */
// lower the front rim so the glasses are easy to take out
grip = true;
// width of the cut-out (at half its depth) and how far down it goes (mm); a narrow cut-out cannot be deep
grip_width = 70; // [10:1:200]
grip_depth = 14; // [2:1:80]

/* [Floor] */
floor_t = 2; // [1:0.2:8]
floor_pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
floor_mode = "solid"; // [solid, through_cut, raised, recessed]

/* [Mounting] */
// how it mounts: plates snap into a solid zone of the back wall (none = stands on a shelf)
attach_type = "none"; // [none, wall, keyhole, skadis, hook, magnet, flat, roof, slide, fin, clamp, pipe]
attach_size = "S"; // [S, M, L]
attach_count = 2; // [1:1:3]
// ball joint between the holder and the plate: turn and tilt it freely, the lock ring clamps it
attach_joint = "none"; // [none, ball]
// slide: the track runs horizontally (slide the holder along it) or vertically (drop it onto the track)
slide_axis = "horizontal"; // [horizontal, vertical]
// fin: a blade under the holder that anchors it, e.g. between two sofa cushions: how far down, how wide, how thick (mm)
fin_len = 100; // [30:5:250]
fin_w = 60; // [30:5:240]
fin_t = 4; // [2:0.5:10]
// clamp: opening between the jaws (thickest desk, shelf or bar), reach from the clamp's back to the screw hole (mm)
clamp_gap = 40; // [10:1:120]
clamp_reach = 25; // [5:1:120]
// clamp: printed screw size
clamp_screw = "M16"; // [M10, M12, M16, M20]
// pipe: outer diameter of the pipe, tube or rail the claw snaps onto (mm), and which way it runs
pipe_d = 20; // [6:0.5:60]
pipe_axis = "horizontal"; // [horizontal, vertical]

/* [Pattern details] */
// cube rosette: one hexagon in three a cube (sparse), two in three (dense), all (tumbling blocks) or none
cube_density = "sparse"; // [sparse, dense, all, none]
// fluted: convex half-round ribs (reeded), concave grooves (fluted) or flat ribs; ribs upright or lying
flute_style = "reeded"; // [reeded, fluted, ribbed]
flute_orient = "vertical"; // [vertical, horizontal]

/* [Hidden] */
$fn = 48;
ft = container_mount_floor(attach_type, floor_t);      // a mount under the floor needs a thicker floor (it stays flat inside)
// typical folded sizes [width, depth, lens height]
function preset_size(n) =
    n == "standard" ? [148, 48, 50] : n == "small" ? [130, 42, 42] : n == "aviator" ? [142, 46, 56] :
    n == "oversized" ? [156, 54, 62] : n == "sport wrap" ? [152, 64, 48] : custom_size;
gs = preset_size(preset);
inner = [gs[0] + 2*clearance, gs[1] + 2*clearance];
size = inner + [2*wall_t, 2*wall_t];
height = ft + max(8, gs[2]*hold);                // rim height at the front corners
split = corner_fill == "solid";
cr = min(corner_r, min(size)/2 - 0.5);
round_fn = max(3, ceil(cr*PI/2/5));

// ---------- outline and rim ----------
runs = shell_rect_runs(size, corners, cr, round_fn, 1);
run_edges = shell_runs_edges(runs);
pts = container_box_pts(runs, split);                 // one loop with its seam in the back left corner, or separate sides
grip_w = min(grip_width, (size[0] - 2*cr)/1.6);        // width at half depth; the shoulders need room on the straight front
dip = grip ? shell_rim_dip_depth(min(grip_depth, height - ft - 2), grip_w) : 0;
rim = function(p) shell_rim_height(p, size, height, [0, rise_back]) - shell_rim_dip(p, size, dip, grip_w, 0, "front", wall_t + 4);
h_ref = height + rise_back;

// ---------- patterns ----------
k_auto = max(0.5, min(1, min(size[0], height)/50));      // automatic pattern size: a few cells across the smaller wall dimension
function spec_for(name, ang=0) = pattern_sized(name, k_auto, wall_cell, wall_strut, ang, wall_seed, strut_min=1.2,
    opts=name == "concentric_ripples" ? [["spokes", 6]] : name == "voronoi" ? [["round", 0.8]] :
         name == "cube_rosette" ? [["cubes", cube_density]] : name == "fluted" ? [["style", flute_style], ["orient", flute_orient]] : []);
wall_spec = spec_for(wall_pattern, wall_angle);
floor_spec = spec_for(floor_pattern);
wmode = container_safe_mode(wall_mode, wall_spec);
fmode = container_safe_mode(floor_mode, floor_spec);

// ---------- nose support ----------
nose_y = -inner[1]/2 + nose_setback + nose_len/2;     // centre of the ridge, behind the front wall
assert(!nose || nose_setback + nose_len <= inner[1], str("nose support: setback ", nose_setback, " + length ", nose_len, " is more than the inside depth ", inner[1]));

// ---------- mounting ----------
a_opts = attach_opts(roof_gap=10, slide_axis=slide_axis, fin_len=fin_len, fin_w=fin_w, fin_t=fin_t,
                     clamp_gap=clamp_gap, clamp_reach=clamp_reach, clamp_screw=clamp_screw, pipe_d=pipe_d, pipe_axis=pipe_axis);
mount = container_mount(pts, attach_type, attach_size, attach_count, rim, wall_t, [base_band + ft, rim_band], ft);   // solid zone + sockets in the back wall (fin: in the floor)
has_att = !is_undef(mount);
h_back = height + rise_back;
mount_note = container_mount_note(mount, attach_type, attach_size, attach_count);    // "" or what had to be reduced / left out

// tables read by the tools
parts = [
  ["holder", "Sunglasses holder", "PLA / PETG", [0,0,0], COL_GREY_DARK],
  each container_attach_rows(attach_type, mount, attach_joint, opts=a_opts)
];
checks = has_att ? [["attach", "holder", "clear"]] : [];
report = [["glasses width", gs[0]], ["folded depth", gs[1]], ["lens height", gs[2]], ["outer width", size[0]], ["outer depth", size[1]],
          ["rim height front", height], ["rim height back", h_back], ["grip cut-out depth", dip],
          ["wall pattern cut as asked", wmode == wall_mode ? 1 : 0],
          ["mounting plates fitted", container_mount_count(mount)], ["mounting as asked", mount_note == "" ? 1 : 0]];

// ---------- solids ----------
// the nose ridge (lib/container.scad), kept inside the walls: it only grows up from the floor
module nose_support() {
    intersection() {
        translate([0, nose_y, ft - 0.2]) container_ridge(nose_w, nose_foot, nose_h + 0.2, nose_len, [nose_run_front, nose_run_back], nose_crown);
        translate([0, 0, ft - 0.3]) linear_extrude(nose_h + 1) offset(delta=-wall_t + 0.3) polygon(pts);
    }
}
module holder() {
    container_floor(pts, ft, floor_spec, fmode, wall_t + 3, 0.5, mount=mount);
    container_walls(pts, wall_t, h_ref, rim, wall_spec, wmode, [base_band + ft, rim_band],
                    wmode == "overlay" ? min(wall_relief, 0.4) : wall_relief, wall_relief, split ? run_edges : undef, 3, mount=mount, anchor=[0, -size[1]/2]);
    if (nose) {
        nose_support();
        if (fmode == "through_cut") linear_extrude(ft) intersection() {                                     // solid ground under the ridge
            translate([0, nose_y]) square([max(nose_foot, nose_w) + 4, nose_len + 4], center=true); offset(delta=-0.05) polygon(pts); }
    }
}

// ---------- assembly ----------
attach_note(mount_note);
pick("holder") holder();
container_attach(part, mount, a_opts, 0, h_ref, attach_joint);
