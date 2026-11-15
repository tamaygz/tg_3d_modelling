// LED strip tracks, diffusers, corners and cable parts
// A configurable kit built from lib/led.scad and lib/cable.scad: pick your strip, print what you need.
include <../../lib/core.scad>
use <../../lib/led.scad>
use <../../lib/cable.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Strip] */
// LED strip type (IP65 = silicone coated); check your strip's datasheet
strip_type = "10mm"; // [5mm, 8mm, 10mm, 12mm, 8mm IP65, 10mm IP65, custom]
// custom strip [width, thickness] (used when strip_type = custom)
custom_strip = [10, 2.5];

/* [Track] */
// track length (print bed permitting; join pieces with keys)
track_len = 200; // [40:10:1000]
// light distance to the diffuser: shallow = compact, deep = smoother light
track_style = "shallow"; // [shallow, deep]
// snap-in diffuser cover (print in clear or natural PETG)
diffuser = "flat"; // [flat, dome, none]
// mounting: adhesive tape or countersunk M3 screws
mount = "glue"; // [glue, screw]
// screw spacing
screw_pitch = 100;
// side opening for the wires at the start of the track
wire_exit = false;
// cable hole in the end cap (0 = closed cap)
cap_cable_d = 4;

/* [Corner] */
// corner piece: inward (inside edge), outward (outside edge), flat (turn in the mounting plane)
corner_type = "outward"; // [inward, outward, flat, none]
// corner radius (back of the track for outward, open face for inward, inner edge for flat)
corner_r = 6; // [2:1:30]

/* [Cables] */
// round cable diameter for the clips
cable_d = 5;
// flat cable width and thickness (e.g. the strip's own lead)
flat_w = 8;
flat_t = 2.5;
// clip mounting
cable_mount = "adhesive"; // [adhesive, screw]
// zip tie width
tie_w = 4.8;
// duct inner width, height, length
duct_w = 12;
duct_h = 8;
duct_len = 100;
// grommet: hole diameter and panel thickness
grommet_hole = 10;
panel_t = 12;

/* [Hidden] */
probe = 0;   // 1 = diffuser half pressed in, 2 = duct lid half pressed in (snap deflection checks)
strip = led_strip_dims(strip_type, custom_strip);
SP = led_spec(strip, track_style);
H = led_H(SP); W = led_W(SP);
ext = 12;                                     // straight ends on the corner piece
cy = -45;                                     // cable parts row

parts = [
  ["track",       "Track",            "PLA / PETG",        [0,0,-20], COL_GREY_DARK],
  ["diffuser",    "Diffuser",         "clear PETG",        [0,0,25],  COL_CLEAR, diffuser == "dome" ? "print=auto" : "print=x180"],
  ["end_cap",     "End cap",          "PLA",               [-15,0,0], COL_GREY_DARK, "print=auto"],
  ["key",         "Joiner key",       "PLA",               [0,0,-35], COL_BRASS],
  ["corner",      "Corner",           "PLA / PETG",        [25,0,0],  COL_GREY_DARK, "print=auto"],
  ["corner_diff", "Corner diffuser",  "clear PETG",        [25,0,25], COL_CLEAR, "print=auto"],
  ["clip",        "Cable clip",       "PLA",               [0,-10,0], COL_GREY],
  ["flat_clip",   "Flat cable clip",  "PLA",               [0,-10,0], COL_GREY, "print=auto"],
  ["tie_mount",   "Zip-tie mount",    "PLA",               [0,-10,0], COL_GREY],
  ["duct",        "Cable duct",       "PLA",               [0,-10,0], COL_GREY],
  ["duct_lid",    "Duct lid",         "PLA",               [0,-10,20],"#c5ccd1", "print=x180"],
  ["grommet",     "Grommet",          "TPU / PLA",         [0,-10,0], COL_GREY],
  ["hw_strip",    "LED strip (reference)", "bought",       [0,0,10],  "#fff3b0"]
];
checks = concat(
  [["hw_strip","track",">=",0], ["end_cap","track",">=",0], ["duct_lid","duct",">=",0]],
  diffuser != "none" ? [["diffuser","track",">=",0], ["hw_strip","diffuser",">=",0.2]] : [],
  corner_type != "none" ? [["key","track",">=",0], ["key","corner",">=",0]] : [],
  corner_type != "none" && diffuser != "none" ? [["corner_diff","corner",">=",0]] : []
);
report = [ ["track width", W], ["track height", H], ["strip", strip[0]], ["seat", SP[0]] ];

module duct_at() { translate([110, cy, 0]) children(); }

if (probe == 1) intersection() { led_track(40, SP); translate([0,0,1.4]) led_diffuser(40, SP, "flat"); }
else if (probe == 2) intersection() { cable_duct(40, duct_w, duct_h); translate([0,0,0.6]) cable_duct_lid(40, duct_w, duct_h); }
else {
  pick("track") led_track(track_len, SP, mount, screw_pitch, wire_exit);
  pick("hw_strip") translate([1, -strip[0]/2, 3.0]) cube([track_len - 2, strip[0], strip[1]]);
  pick("diffuser") led_diffuser(track_len, SP, diffuser);
  pick("end_cap") led_end_cap(SP, cap_cable_d);
  if (corner_type != "none") {
    pick("key") translate([track_len, 0, 0]) led_key();
    pick("corner") translate([track_len, 0, 0]) led_corner(corner_type, SP, corner_r, ext);
    pick("corner_diff") translate([track_len, 0, 0]) led_corner_diffuser(corner_type, SP, corner_r, ext, diffuser);
  }
  pick("clip") translate([0, cy, 0]) cable_clip(cable_d, cable_mount);
  pick("flat_clip") translate([25, cy, 0]) flat_cable_clip(flat_w, flat_t, cable_mount);
  pick("tie_mount") translate([55, cy, 0]) tie_mount(tie_w, cable_mount);
  pick("duct") duct_at() cable_duct(duct_len, duct_w, duct_h, mount=cable_mount);
  pick("duct_lid") duct_at() cable_duct_lid(duct_len, duct_w, duct_h);
  pick("grommet") translate([235, cy, 0]) cable_grommet(grommet_hole, cable_d, panel_t);
}
