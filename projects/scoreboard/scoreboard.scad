// Parametric sliding-pin scoreboard (pool / snooker style)
// Board + number plates + per-player rails, sliders (marker pins) and stopper pegs.
// Shapes, rails, pegs and number scales come from the shared library in ../../lib.
include <../../lib/core.scad>
include <../../lib/fits.scad>
use <../../lib/fonts.scad>
use <../../lib/shapes.scad>
use <../../lib/rail.scad>
use <../../lib/scale.scad>
use <../../lib/attach.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Scoring] */
// number of players = tracks (two tracks share one number plate)
players = 2; // [1:1:8]
// first number of the main range
base_min = 0;
// last number of the main range
base_max = 19;
// 2nd-dimension steps for counting beyond the main range; [] = none
steps = [20,40,60,80,100];
// put a "0" home position in front of the steps (ignored without steps)
zero_step = true;
// preview only: per player [main-range index, step index]
demo_scores = [[7,2],[15,4]];

/* [Style] */
// a preset overrides every style setting below; "custom" uses them as set
style_preset = "custom"; // [custom, classic, modern, victorian, pub, minimal]
// board outline
board_shape = "wave"; // [rect, rounded, chamfered, notched, arched, wave, scalloped]
// routed profile of the board's top edge
edge_profile = "roundover"; // [flat, roundover, chamfer, cove, ogee]
// decorative groove around the board face
groove_style = "single"; // [none, single, double]
// marker (slider) body
marker_style = "block"; // [block, rounded, arrow, knob]
// marker pointer (arrow markers have their own)
pointer_style = "triangle"; // [triangle, needle, none]
// stopper head
stopper_style = "screw"; // [screw, dome, flat, hex, ball]
// rail top
rail_style = "flat"; // [flat, rounded, beveled]
// numbers: 2-colour inlay, raised on the plate, or engraved (one colour)
plate_style = "inlay"; // [inlay, raised, engraved]
// number font
font_style = "serif"; // [serif, serif bold, sans, sans bold]
// separator between numbers
separator = "dot"; // [dot, bar, diamond, none]
// border line around the numbers
plate_border = true;

/* [Layout] */
// spacing of main-range numbers (mm)
pitch = 11; // [8:0.5:20]
// spacing of step numbers (mm)
step_pitch = 14; // [8:0.5:24]
// number cap height (mm)
text_size = 5.2; // [3:0.1:8]
// separator size
dot_d = 1.4;
// gap between slider edges of neighbouring plates
strip_gap = 9;

/* [Board] */
// board thickness
board_t = 12;
// board edge to rail end
margin_x = 14;
// board edge (deepest point) to slider edge
margin_y = 13;
// height of arched / wave / scalloped edges
wave_amp = 5;
// waves along the edge (wave), scallop density (scalloped)
waves = 2;
// corner radius / chamfer / notch size
corner_r = 8;
// size of the routed top edge
edge_r = 3;
// decorative groove: inset from edge
groove_in = 5.5;
// decorative groove width and depth
groove_w = 0.8;
// cut the board into two printable halves
split_board = true;
// alignment dowel diameter (split board)
dowel_d = 5;
// alignment dowel length
dowel_l = 20;

/* [Attachment] */
// how the board mounts: plates snap into sockets in its back (none = plain back)
attach_type = "keyhole"; // [none, wall, keyhole, skadis, hook, magnet, stand, flat, roof]
// plate size: S 30x30, M 45x40, L 60x50 mm
attach_size = "M"; // [S, M, L]
// number of sockets / plates across the back
attach_count = 2; // [1:1:4]
// wall: wood screw hole diameter
screw_d = 4.5;
// wall: countersunk screw head diameter
screw_head_d = 8.5;
// magnet: [diameter, height] of the round magnets
magnet = [10, 3];
// hook: thickness of the rod, rail or door it hangs on
hook_gap = 6;
// stand: lean back from vertical (degrees)
stand_angle = 15; // [5:1:30]
// stand: foot distance behind the board
stand_depth = 40;
// roof: gap between the board's top edge and the ceiling
roof_gap = 10;
// roof: angle between the board and the ceiling (90 = hangs straight down; less tilts the face down towards you)
roof_angle = 90; // [45:5:135]

/* [Number plate] */
// plate height (Y)
label_h = 10;
// plate thickness (sits flush in a pocket)
label_t = 2;
// pocket clearance per side
label_clr = 0.2;
// depth (inlay, engraved) or height (raised) of the numbers
text_depth = 0.6;
// border line inset
border_in = 0.9;
// border line width
border_w = 0.5;

/* [Rail and sliders] */
// rail top flange width
flange_w = 10;
// rail top flange thickness
flange_t = 2;
// rail web width
web_w = 5;
// rail web height (gap under flange)
web_h = 3.2;
// rail beyond the stopper-peg centre
rail_end = 4;
// slider-to-rail clearance per side
slide_clr = 0.25;
// slider length along the rail
slider_l = 10;
// slider side wall
slider_wall = 1.6;
// slider top plate
slider_top = 2;
// slider lip thickness (under the flange)
lip_t = 1.8;
// pointer reach towards the number plate
ptr_len = 3.5;
// pointer base width
ptr_w = 6;
// pointer thickness
ptr_t = 1.4;

/* [Stopper pegs] */
// peg shaft (press fit p6 into an H7 board hole)
peg_d = 3;
// clearance hole in the rail
peg_hole = 3.4;
// depth of the peg hole in the board
peg_depth = 6;
// stopper head diameter
head_d = 6.5;
// stopper head height above the rail
head_h = 2.5;
// divider pins at ±this from the rail joint
div_pin = 4;

/* [Hidden] */
$fn = 48;

// style presets: [shape, edge, groove, marker, pointer, stopper, rail, plate, font, separator]
PRESETS = [
  ["classic",   ["wave",      "roundover", "single", "block",   "triangle", "screw", "flat",    "inlay",    "serif",      "dot"]],
  ["modern",    ["rounded",   "chamfer",   "none",   "rounded", "needle",   "flat",  "rounded", "raised",   "sans",       "bar"]],
  ["victorian", ["notched",   "ogee",      "double", "arrow",   "none",     "ball",  "beveled", "inlay",    "serif bold", "diamond"]],
  ["pub",       ["scalloped", "cove",      "single", "knob",    "triangle", "dome",  "rounded", "inlay",    "serif",      "dot"]],
  ["minimal",   ["rect",      "flat",      "none",   "block",   "needle",   "hex",   "flat",    "engraved", "sans",       "none"]]
];
custom_style = [board_shape, edge_profile, groove_style, marker_style, pointer_style, stopper_style, rail_style, plate_style, font_style, separator];
pi_ = search([style_preset], PRESETS)[0];
ST = is_num(pi_) ? PRESETS[pi_][1] : custom_style;  // active style
s_shape = ST[0]; s_edge = ST[1]; s_groove = ST[2]; s_marker = ST[3]; s_pointer = ST[4];
s_stop = ST[5]; s_rail = ST[6]; s_plate = ST[7]; s_font = font_for(ST[8]); s_sep = ST[9];

// derived
RAIL    = [flange_w, flange_t, web_w, web_h];         // rail spec shared by rail, slider and pegs
nU      = base_max - base_min + 1;                    // main-range positions
has_steps = len(steps) > 0;                           // is there a second dimension at all
slabels = has_steps ? concat(zero_step ? [0] : [], steps) : [];  // step labels
nS      = len(slabels);                               // step positions
rh      = rail_h(RAIL);                               // rail height
sw      = slider_w(RAIL, slide_clr, slider_wall);     // slider width (Y)
s_top   = slider_top(RAIL, slide_clr, slider_top);    // slider top above board
div_hl  = div_pin + head_d/2;                         // divider head half length
xu      = [for (i=[0:1:nU-1]) i*pitch];               // main-range pointer x
ulabels = [for (i=[0:1:nU-1]) base_min + i];          // main-range labels
x_start = -(slider_l/2 + head_d/2);                   // start stopper x
x_div   = xu[nU-1] + slider_l/2 + div_hl;             // divider / rail joint x (only with steps)
xs      = [for (j=[0:1:nS-1]) x_div + div_hl + slider_l/2 + j*step_pitch]; // step pointer x
x_end   = (has_steps ? xs[nS-1] : xu[nU-1]) + slider_l/2 + head_d/2;  // end stopper x
ru0     = x_start - rail_end;                         // main rail start
ru1     = has_steps ? x_div : x_end + rail_end;       // main rail end
rs1     = x_end + rail_end;                           // step rail end
x_split = has_steps ? x_div : nU > 1 ? (xu[floor(nU/2)-1] + xu[floor(nU/2)])/2 : 0;  // board cut
bx0     = ru0 - margin_x;                             // board left
bx1     = rs1 + margin_x;                             // board right
rail_dy = label_h/2 + 1.5 + sw/2;                     // plate centre to rail centre
nStrip  = ceil(players/2);                            // number plates
strip_p = 2*rail_dy + sw + strip_gap;                 // plate-to-plate pitch
strip_y = [for (k=[0:nStrip-1]) -k*strip_p];          // plate centre y
track_y = [for (p=[0:players-1]) strip_y[floor(p/2)] + (p%2==0 ? rail_dy : -rail_dy)];
track_up= [for (p=[0:players-1]) p%2==0];             // true = pointer faces down onto the plate below
by1     = rail_dy + sw/2 + margin_y;                  // board top (deepest point of the edge)
by0     = strip_y[nStrip-1] - ((players%2==1) ? label_h/2 + 4 : rail_dy + sw/2) - margin_y; // board bottom
edge_amp= (s_shape == "arched" || s_shape == "wave" || s_shape == "scalloped") ? wave_amp : 0;  // extra edge height
function end_pad(label, p) = max(p/2, len(str(label))*0.39*text_size + (plate_border ? border_in + border_w : 0) + 0.6);  // half digit advance ≈ 0.39·size (widest bundled font)
pl_u    = [xu[0] - end_pad(ulabels[0], pitch), xu[nU-1] + end_pad(ulabels[nU-1], pitch)];  // main plate x span
pl_s    = has_steps ? [xs[0] - end_pad(slabels[0], step_pitch), xs[nS-1] + end_pad(slabels[nS-1], step_pitch)] : [0,0]; // step plate x span
peg_l   = rh + peg_depth - 0.5;                       // peg shaft length below the head
hole_b  = fit_mid("H7", peg_d);                       // board peg hole
shaft_d = fit_mid("p6", peg_d);                       // peg shaft
dw_hole = fit_mid("H7", dowel_d);                     // dowel hole
dw_d    = fit_mid("k6", dowel_d);                     // dowel shaft (H7/k6)
dz      = 5;                                          // dowel centre height
has_att = attach_type != "none";                      // any sockets at all
a_y     = attach_y((by0 + by1)/2);                    // plate centre y (socket + pry notch centred on the board)
a_keep  = split_board ? attach_socket_w(attach_size)/2 + dowel_l/2 + 2 : 0;   // keep sockets clear of the split dowels
a_x     = attach_xs(attach_count, bx1 - bx0, attach_type, (bx0 + bx1)/2, [x_split, a_keep]);   // socket x positions
a_opts  = attach_opts(screw_d, screw_head_d, magnet, hook_gap, stand_angle, stand_depth, roof_gap, roof_angle);
assert(!has_att || attach_fits(attach_size, by1 - by0), attach_fit_msg(attach_size, by1 - by0));
function art_pieces(labels) = len(labels) == 0 ? 0 :   // separate solids in one plate's artwork
  sum([for (v=labels) len(str(v))]) + (s_sep == "none" ? 0 : len(labels) - 1) + (plate_border ? 1 : 0);
n_txt_u = nStrip * art_pieces(ulabels);               // artwork pieces, main plates
n_txt_s = nStrip * art_pieces(slabels);               // artwork pieces, step plates

parts = [
  ["board_l",   "Board left",         "PLA wood / brown", [0,0,-30], COL_WOOD],
  ["board_r",   "Board right",        "PLA wood / brown", [30,0,-30], COL_WOOD],
  ["plate_u",   "Number plate main",  "PLA silk gold",    [0,0,20],  COL_PLATE, str("pieces=",nStrip), "plate=plates_u", "mat=PLA gold"],
  ["text_u",    "Numbers main",       "PLA black",        [0,0,26],  COL_INK, str("pieces=",n_txt_u), "plate=plates_u", "mat=PLA black"],
  ["plate_s",   "Number plate steps", "PLA silk gold",    [0,0,20],  COL_PLATE, str("pieces=",nStrip), "plate=plates_s", "mat=PLA gold"],
  ["text_s",    "Numbers steps",      "PLA black",        [0,0,26],  COL_INK, str("pieces=",n_txt_s), "plate=plates_s", "mat=PLA black"],
  ["rail_u",    "Rail main range",    "PLA silk gold",    [0,0,12],  COL_BRASS, str("pieces=",players), "print=x180"],
  ["rail_s",    "Rail steps",         "PLA silk gold",    [0,0,12],  COL_BRASS, str("pieces=",players), "print=x180"],
  ["slider",    "Marker slider",      "PLA silk gold",    [0,0,32],  COL_GOLD, str("pieces=",(has_steps ? 2 : 1)*players), "print=x180"],
  ["stop_end",  "End stopper",        "PLA silver",       [0,0,45],  COL_SILVER, str("pieces=",2*players), "print=x180"],
  ["stop_div",  "Column divider",     "PLA silver",       [0,0,45],  COL_SILVER, str("pieces=",players), "print=x180"],
  ["dowel",     "Alignment dowel",    "PLA",              [0,0,-30], "#555555", str("pieces=",nStrip), "print=x90"],
  attach_parts_row(attach_type, attach_count, [0,0,-55])
];
checks = concat([
  ["slider","rail_u","clear"], ["slider","rail_s","clear"],
  ["slider","stop_end",">=",0], ["slider","stop_div",">=",0],
  ["stop_end","rail_u","touch"], ["stop_div","rail_s","touch"]],
  has_att ? [["attach","board_l","clear"], ["attach","board_r","clear"]] : []
);
report = [
  ["board length", bx1 - bx0], ["board height", by1 - by0 + 2*edge_amp],
  ["main rail length", ru1 - ru0], ["step rail length", has_steps ? rs1 - x_div : 0],
  ["left half length", split_board ? x_split - bx0 : bx1 - bx0], ["right half length", split_board ? bx1 - x_split : 0],
  ["slider top above board", s_top]
];


// ---------------- board ----------------
module outline() {
  translate([(bx0 + bx1)/2, (by0 + by1)/2])
    plaque_2d([bx1 - bx0, by1 - by0], s_shape, r=corner_r, amp=wave_amp, waves=waves);
}
function peg_x() = has_steps ? [x_start, x_div - div_pin, x_div + div_pin, x_end] : [x_start, x_end];
module board() {
  difference() {
    profiled_slab(board_t, s_edge, edge_r) outline();
    outline_groove(board_t, groove_in, groove_w, groove_w, s_groove) outline();
    for (y=strip_y) translate([0,y,board_t - label_t]) linear_extrude(label_t + 1) {
      offset(delta=label_clr) scale_plate_2d(pl_u[0], pl_u[1], label_h);
      if (has_steps) offset(delta=label_clr) scale_plate_2d(pl_s[0], pl_s[1], label_h);
    }
    for (y=track_y, x=peg_x()) translate([x,y,board_t - peg_depth]) cylinder(d=hole_b, h=peg_depth + 1, $fn=32);
    if (split_board) for (y=strip_y) translate([x_split,y,dz]) rotate([0,90,0]) cylinder(d=dw_hole, h=dowel_l + 1, center=true, $fn=32);
    attach_sockets(attach_type, attach_size, a_x, a_y);
  }
}
module board_half(right) {
  intersection() {
    board();
    if (!split_board) translate([bx0-50, by0-50, -1]) cube([bx1-bx0+100, by1-by0+100, board_t+2]);
    else if (right) translate([x_split, by0-50, -1]) cube([bx1-x_split+50, by1-by0+100, board_t+2]);
    else translate([bx0-50, by0-50, -1]) cube([x_split-bx0+50, by1-by0+100, board_t+2]);
  }
}

// ---------------- number plates ----------------
module plate_outline(sp) { scale_plate_2d(sp[0], sp[1], label_h); }
module plate_artwork(sp, labels, xs_) {
  number_row_2d(labels, xs_, text_size, s_font, s_sep, dot_d);
  if (plate_border) border_2d(border_in, border_w) plate_outline(sp);
}
module num_plate(sp, labels, xs_) { plate_body(label_t, s_plate, text_depth) { plate_outline(sp); plate_artwork(sp, labels, xs_); } }
module num_text(sp, labels, xs_)  { plate_art(label_t, s_plate, text_depth)  { plate_outline(sp); plate_artwork(sp, labels, xs_); } }

// ---------------- assembly ----------------
module on_track(p) { translate([0, track_y[p], board_t]) rotate([0,0, track_up[p] ? 0 : 180]) children(); }
function tx(p,x) = track_up[p] ? x : -x;   // x in track frame (lower tracks are rotated 180°)
module marker() { rail_slider(RAIL, slider_l, slide_clr, slider_wall, slider_top, lip_t, s_marker, s_pointer, ptr_len, ptr_w, ptr_t); }

pick("board_l") board_half(false);
pick("board_r") if (split_board) board_half(true);
for (y=strip_y) translate([0,y,board_t - label_t]) {
  pick("plate_u") num_plate(pl_u, ulabels, xu);
  pick("text_u")  num_text(pl_u, ulabels, xu);
  if (has_steps) pick("plate_s") num_plate(pl_s, slabels, xs);
  if (has_steps) pick("text_s")  num_text(pl_s, slabels, xs);
}
for (p=[0:players-1]) {
  sc = p < len(demo_scores) ? demo_scores[p] : [0,0];
  translate([0, track_y[p], board_t]) {
    pick("rail_u") t_rail(ru0, ru1, RAIL, s_rail, [x_start, has_steps ? x_div - div_pin : x_end], peg_hole);
    if (has_steps) pick("rail_s") t_rail(x_div, rs1, RAIL, s_rail, [x_div + div_pin, x_end], peg_hole);
    pick("stop_end") for (x=[x_start, x_end]) translate([x,0,rh]) stop_peg(head_d, head_h, s_stop, shaft_d, peg_l);
    if (has_steps) pick("stop_div") translate([x_div,0,rh]) twin_peg(2*div_pin, head_d, head_h, s_stop, shaft_d, peg_l);
  }
  on_track(p) pick("slider") {
    translate([tx(p, xu[min(sc[0], nU-1)]), 0, 0]) marker();
    if (has_steps) translate([tx(p, xs[min(sc[1], nS-1)]), 0, 0]) marker();
  }
}
pick("attach") attach_plates(attach_type, attach_size, a_x, a_y, a_opts, by0 - edge_amp, by1 + edge_amp);
pick("dowel") if (split_board) for (y=strip_y) translate([x_split, y, dz]) rotate([0,90,0]) cylinder(d=dw_d, h=dowel_l - 1, center=true, $fn=32);
