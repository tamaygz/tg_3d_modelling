// Earbuds holder: a dock for the charging case of your earbuds, with cable opening, grip cut-out and mounting
// Presets for popular cases (or your own size), patterned walls from lib/patterns.scad, snap-in attachment plates
// from lib/attach.scad. Built with lib/container.scad on lib/shell.scad.
include <../../lib/core.scad>
use <../../lib/shell.scad>
use <../../lib/patterns.scad>
use <../../lib/attach.scad>
use <../../lib/container.scad>

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
// corners of the holder
corners = "round"; // [round, chamfer, square]
corner_r = 8; // [1:0.5:40]
// pattern on the walls and how it is applied
wall_pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
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
rise_back = 0; // [0:1:80]

/* [Front grip] */
// lower the front rim so a finger can get under the case
grip = true;
// width of the cut-out (at half its depth) and how far down it goes (mm); a narrow cut-out cannot be deep
grip_width = 26; // [8:1:120]
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
floor_pattern = "concentric_ripples"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
floor_mode = "solid"; // [solid, through_cut, recessed]

/* [Mounting] */
// how it mounts: plates snap into a solid zone of the back wall (none = stands on a desk)
attach_type = "none"; // [none, wall, keyhole, skadis, hook, magnet, flat, roof, slide, fin, clamp, pipe]
attach_size = "S"; // [S, M, L]
attach_count = 1; // [1:1:2]
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
