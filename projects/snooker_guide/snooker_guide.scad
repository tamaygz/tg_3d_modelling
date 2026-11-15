// Snooker Setup Guide: wall plaque showing the table, the ball positions and the points
// A multi-colour relief: every colour is its own part (one 3MF). Official geometry (WPBSA): playing area
// 3569 x 1778 mm, baulk line 737 mm from the baulk cushion, D radius 292 mm, blue on the centre spot, pink midway
// between centre spot and top cushion, black 324 mm from the top cushion, reds packed behind the pink.
use <../../lib/shapes.scad>
use <../../lib/attach.scad>
use <../../lib/fonts.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Size] */
// length of the playing area on the print (mm); everything else scales with it
table_len = 200; // [100:5:400]
// balls drawn bigger than true scale so they read from a distance (1 = true scale)
ball_scale = 1.6; // [1:0.1:2.5]
// baulk end of the table: left (like most diagrams) or right
baulk_side = "left"; // [left, right]

/* [Points] */
// show the point value next to each ball
show_points = true;
// size of the numbers (mm)
points_size = 5; // [2:0.5:12]
// colour of the numbers: white, black, gold, or each ball's own colour
points_color = "white"; // [white, black, gold, ball colour]
// where the numbers sit relative to their ball
points_pos = "right"; // [right, left, above, below]
// numbers raised on the cloth or inlaid flush
points_style = "raised"; // [raised, inlay]
// label the reds (1) and the cue ball (0)
points_reds = true;
points_cue = true;
// legend row under the table: every ball with its points, in potting order
show_legend = true;
// title above the table (empty = none)
title = "SNOOKER";
title_size = 9; // [4:1:20]

/* [Balls] */
// show the cue ball (in hand, inside the D)
show_cue = true;
// ball relief: dome (spherical cap), hemisphere, flat (disc with a chamfered top)
ball_style = "dome"; // [dome, hemisphere, flat]
// dome / flat ball height (mm)
ball_h = 1.6;

/* [Table depth] */
// table body: base thickness (mm)
table_base_t = 3;
// rails above the cloth (mm)
rail_h = 1.6;
// cushions above the cloth (mm)
cushion_h = 0.8;
// cloth layer thickness (mm, its own colour)
cloth_t = 0.8;
// rail and cushion widths (mm)
rail_w = 8;
cushion_w = 3;
// outline corner radius of the table (mm)
table_corner_r = 6;
// top edge of the rails
table_edge = "roundover"; // [flat, roundover, chamfer, cove, ogee]
table_edge_r = 1.2;
// bottom finish of the table body (rounded = rounded underside edge, like the real table's apron)
table_bottom = "roundover"; // [flat, roundover, chamfer, cove, ogee]
table_bottom_r = 1.5;
// pockets: diameter (mm), and tan pocket rims
pocket_d = 7.5;
show_rims = true;
rim_w = 2.2;
// baulk line and D: line width (mm)
line_w = 0.6;

/* [Surround plate] */
// plate around the table (off = the table alone)
show_plate = true;
plate_shape = "rounded"; // [rect, rounded, chamfered, notched, arched, wave, scalloped]
// plate thickness (mm; 6 or more for attachment sockets)
plate_t = 6;
// margin around the table (mm), corner size, edge profile, decorative groove
plate_margin = 10;
plate_corner_r = 8;
plate_edge = "roundover"; // [flat, roundover, chamfer, cove, ogee]
plate_edge_r = 2;
plate_groove = "single"; // [none, single, double]
// height of the wave / arch / scallops for those shapes
plate_wave = 4;

/* [Attachment] */
// how it mounts (plates snap into sockets in the back): none, wall, keyhole, skadis, hook, magnet, stand, flat, roof
attach_type = "keyhole"; // [none, wall, keyhole, skadis, hook, magnet, stand, flat, roof]
attach_size = "M"; // [S, M, L]
attach_count = 2; // [1:1:4]
// roof: gap between the guide's top edge and the ceiling, and the angle between guide and ceiling (90 = straight down)
roof_gap = 10;
roof_angle = 90; // [45:5:135]
// stand: lean back from vertical (degrees)
stand_angle = 15; // [5:1:30]

/* [Hidden] */
$fn = 48;
REAL_L = 3569; REAL_W = 1778;                   // playing area (mm)
s   = table_len / REAL_L;                       // real mm -> print mm
Lc  = table_len; Wc = REAL_W*s;                 // cloth (playing area) size on the print
bd  = 52.5*s*ball_scale;                        // printed ball diameter
gap = 0.4;                                      // gap between touching balls (separate pieces)
sx  = baulk_side == "left" ? 1 : -1;            // mirror for a right-hand baulk
function P(rx, ry) = [sx*(-Lc/2 + rx*s), ry*s*sx];   // real position (from the baulk cushion, from the centre line)
BAULK = 737; DR = 292;
// [colour name, points, colour, positions]; yellow on the right of the D seen from the baulk end (= -y)
REDS  = let(d = bd + gap, apex = P(REAL_L*0.75, 0) + [sx*(bd + gap), 0])
        [for (k=[0:4], j=[0:k]) apex + [sx*k*d*sqrt(3)/2, (j - k/2)*d]];
BALLS = [
  ["red",    1, "#d81e1e", REDS],
  ["yellow", 2, "#f5c518", [P(BAULK, -DR)]],
  ["green",  3, "#0b7d4e", [P(BAULK,  DR)]],
  ["brown",  4, "#7a3e1d", [P(BAULK, 0)]],
  ["blue",   5, "#1a4fd6", [P(REAL_L/2, 0)]],
  ["pink",   6, "#f29bb5", [P(REAL_L*0.75, 0)]],
  ["black",  7, "#151515", [P(REAL_L - 324, 0)]],
  ["white",  0, "#f5f2ea", show_cue ? [P(BAULK - 0.55*DR, -0.45*DR)] : []]
];
LABEL_COL = points_color == "black" ? "#151515" : points_color == "gold" ? "#d9b98a" : "#ffffff";
TW = Lc + 2*(cushion_w + rail_w); TH = Wc + 2*(cushion_w + rail_w);   // table outline size
z0 = show_plate ? plate_t : 0;                  // table body bottom
zb = z0 + max(table_base_t, (!show_plate && attach_type != "none") ? attach_depth() + 1.5 : 0);   // cloth bottom
zc = zb + cloth_t;                              // cloth top
zr = zc + rail_h;                               // rail top
ttl = len(title) > 0;
legend = show_legend && show_plate;             // the legend sits on the surround plate
TITLE_H = ttl ? title_size + 8 : 0;             // band above the table for the title
LEG_H = legend ? max(bd, points_size) + 10 : 0;   // band below the table for the legend
PW = TW + 2*plate_margin; PH = TH + 2*plate_margin + TITLE_H + LEG_H;
PC = [0, (LEG_H - TITLE_H)/2];                  // plate centre relative to the table centre
corner_pockets = [for (a=[-1,1], b=[-1,1]) [a*(Lc/2 + cushion_w*0.45), b*(Wc/2 + cushion_w*0.45)]];
mid_pockets = [for (b=[-1,1]) [0, b*(Wc/2 + cushion_w*0.9)]];
POCKETS = concat(corner_pockets, mid_pockets);
LEGEND_Y = -TH/2 - plate_margin/2 - LEG_H/2;
LEGEND = [for (i=[0:6]) [BALLS[i][0], BALLS[i][1], [(i - 3)*max(bd + points_size*1.6, 14), LEGEND_Y]]];
function lbl_off(d) = points_pos == "left" ? [-(d/2 + 1.2), 0] : points_pos == "above" ? [0, d/2 + 1.2 + points_size/2]
                    : points_pos == "below" ? [0, -(d/2 + 1.2 + points_size/2)] : [d/2 + 1.2, 0];
function lbl_align() = points_pos == "left" ? "right" : points_pos == "right" ? "left" : "center";
n_lbl = show_points ? 6 + (points_reds ? 1 : 0) + (show_cue && points_cue ? 1 : 0) : 0;   // labels on the table
has_att = attach_type != "none";
A_W = attach_socket_w(attach_size); A_L = attach_socket_len(attach_size);
A_Y = show_plate ? PC[1] : 0;
H_TOP = show_plate ? PC[1] + PH/2 + ((plate_shape == "arched" || plate_shape == "wave" || plate_shape == "scalloped") ? plate_wave : 0) : TH/2;   // guide's top edge (y)
H_BOT = show_plate ? PC[1] - PH/2 - ((plate_shape == "arched" || plate_shape == "wave" || plate_shape == "scalloped") ? plate_wave : 0) : -TH/2;  // bottom edge
A_X = [for (i=[0:1:attach_count-1]) (i - (attach_count - 1)/2)*(attach_count > 1 ? 0.6*TW/(attach_count - 1) : 0)];
assert(!has_att || A_L <= (show_plate ? PH : TH) - 4, str("attach_size ", attach_size, " is too tall for this guide; choose a smaller size"));

parts = concat([
  ["plate",    "Surround plate", "PLA",           [0,0,-25], "#3a2418", "plate=guide", "mat=PLA dark wood"],
  ["wood",     "Table rails",    "PLA",           [0,0,-12], "#6b2f1a", "plate=guide", "mat=PLA brown"],
  ["cloth",    "Cloth",          "PLA",           [0,0,-4],  "#1f8a2e", "plate=guide", "mat=PLA green"],
  ["cushions", "Cushions",       "PLA",           [0,0,4],   "#2fae45", "pieces=6", "plate=guide", "mat=PLA light green"],
  ["pockets",  "Pockets",        "PLA",           [0,0,-8],  "#111111", "pieces=6", "plate=guide", "mat=PLA black"],
  ["rims",     "Pocket rims",    "PLA",           [0,0,8],   "#d9b98a", "pieces=6", "plate=guide", "mat=PLA tan"],
  ["markings", "Baulk line and D", "PLA",         [0,0,6],   "#f2f2f2", "plate=guide", "mat=PLA white"]],
  [for (b=BALLS) [str("ball_", b[0]), str(b[0], " ball", b[0] == "red" ? "s" : ""), "PLA", [0,0,14], b[2],
                  str("pieces=", len(b[3]) + (legend && b[0] != "white" ? 1 : 0)
                       + (points_color == "ball colour" ? (b[0] == "red" ? (points_reds ? 1 : 0) + (legend ? 1 : 0)
                          : b[0] == "white" ? (show_cue && points_cue ? 1 : 0) : 1 + (legend ? 1 : 0)) : 0)),
                  "plate=guide", str("mat=PLA ", b[0])]],
  [["labels",   "Point numbers",  "PLA",           [0,0,20],  LABEL_COL, str("pieces=", n_lbl + (legend ? 7 : 0)), "plate=guide", "mat=PLA label"],
   ["title",    "Title",          "PLA",           [0,0,20],  "#d9b98a", str("pieces=", len([for (c=title) if (c != " ") c])), "plate=guide", "mat=PLA tan"],
   ["attach",   "Attachment plate", "PLA",         [0,0,-45], "#4d6170", str("pieces=", attach_count), (attach_type == "skadis" || attach_type == "hook" || attach_type == "roof") ? "print=auto" : "print=x180"]]
);
report = [ ["guide width", show_plate ? PW : TW], ["guide height", show_plate ? PH : TH], ["ball diameter", bd], ["total height", zr] ];

module pick(n){ if (part=="all" || part==n) children(); }

// ---------- 2D shapes (table centre at the origin) ----------
module table_2d()   { offset(r=table_corner_r) offset(delta=-table_corner_r) square([TW, TH], center=true); }
module playfield_2d() { square([Lc + 2*cushion_w, Wc + 2*cushion_w], center=true); }   // cloth + cushions
module cloth_2d()   { square([Lc, Wc], center=true); }
module pockets_2d() { for (p=POCKETS) translate(p) circle(d=pocket_d); }
module rims_2d()    { intersection() { difference() { table_2d(); playfield_2d(); } for (p=POCKETS) translate(p) circle(d=pocket_d + 2*rim_w); } }
module markings_2d() {
  bx = P(BAULK, 0)[0];
  translate([bx, 0]) square([line_w, Wc], center=true);
  translate([bx, 0]) intersection() {
    difference() { circle(r=DR*s + line_w/2, $fn=96); circle(r=DR*s - line_w/2, $fn=96); }
    translate([sx < 0 ? 0 : -DR*s - 1, -DR*s - 1]) square([DR*s + 1, 2*DR*s + 2]);
  }
}
module plate_2d() { translate(PC) plaque_2d([PW, PH], plate_shape, r=plate_corner_r, amp=plate_wave, waves=2); }
module label_2d(v, at, size=points_size, al=undef) {
  translate(at) text(str(v), size=size, font=font_for("sans bold"), halign=is_undef(al) ? lbl_align() : al, valign="center");
}
// table labels: [ball index, text position]
// the reds almost touch the pink, so with numbers on the right the pink's goes above it; the reds' "1" sits
// above (or below) the triangle's back row, clear of the black
function off_above(d) = [0, d/2 + 1.2 + points_size/2];
function table_labels() = concat(
  [for (i=[1:6]) [i, BALLS[i][3][0] + (i == 5 && points_pos == (sx > 0 ? "right" : "left") ? off_above(bd) : lbl_off(bd))]],
  points_reds ? [[0, points_pos == "below" ? REDS[10] + lbl_off(bd) : REDS[14] + off_above(bd)]] : [],
  show_cue && points_cue ? [[7, BALLS[7][3][0] + lbl_off(bd)]] : []);
module labels_2d(idx=undef) {                   // numbers on the table; idx = only this ball's (ball-colour mode)
  if (show_points) for (l=table_labels()) if (is_undef(idx) || l[0] == idx) label_2d(BALLS[l[0]][1], l[1]);
}
module legend_labels_2d(idx=undef) {            // numbers in the legend row on the plate
  if (legend) for (i=[0:6]) if (is_undef(idx) || i == idx) label_2d(LEGEND[i][1], LEGEND[i][2] + [bd/2 + 1.2, 0], al="left");
}

// ---------- solids ----------
module slab(z1, z2) { translate([0, 0, z1]) linear_extrude(z2 - z1) children(); }
module ball(at) {
  translate([at[0], at[1], zc])
    if (ball_style == "hemisphere") intersection() { sphere(d=bd, $fn=36); translate([-bd, -bd, 0]) cube(2*bd); }
    else if (ball_style == "flat") { cylinder(d=bd, h=ball_h - 0.4, $fn=36); translate([0,0,ball_h - 0.41]) cylinder(d1=bd, d2=bd - 0.8, h=0.41, $fn=36); }
    else scale([1, 1, ball_h/(bd/2)]) intersection() { sphere(d=bd, $fn=36); translate([-bd, -bd, 0]) cube(2*bd); }
}
module legend_ball(at) { translate([0, 0, (show_plate ? plate_t : 0) - zc]) ball(at); }    // legend balls sit on the plate
module inlay_labels() { if (points_style == "inlay") slab(zc - 0.6, zc + 1) labels_2d(); }

module sockets() { if (has_att) for (x=A_X) translate([x, A_Y, 0]) attach_socket(attach_size); }

if (show_plate) pick("plate") difference() {
  union() {
    profiled_slab(plate_t, plate_edge, plate_edge_r) plate_2d();
  }
  outline_groove(plate_t, 3.5, 0.6, 0.6, plate_groove) plate_2d();
  if (points_style == "inlay") slab(plate_t - 0.6, plate_t + 1) legend_labels_2d();
  sockets();
}
pick("wood") difference() {
  translate([0, 0, z0]) profiled_slab2(zr - z0, table_edge, table_edge_r, table_bottom, table_bottom_r) table_2d();
  slab(zb, zr + 1) playfield_2d();                                  // the cloth and cushions sit in here
  slab(z0 + 1, zr + 1) pockets_2d();
  if (show_rims) slab(zr - 0.6, zr + 1) rims_2d();
  if (!show_plate) sockets();
}
pick("cloth") difference() {
  slab(zb, zc) cloth_2d();
  slab(z0 + 1, zr + 2) pockets_2d();
  slab(zc - 0.4, zc + 1) markings_2d();
  if (points_style == "inlay") slab(zc - 0.6, zc + 1) labels_2d();
}
pick("cushions") difference() {
  slab(zb, zc + cushion_h) difference() { playfield_2d(); cloth_2d(); }
  slab(z0 + 1, zr + 2) pockets_2d();
}
pick("pockets") slab(z0 + 1, zb - 0.4) pockets_2d();
if (show_rims) pick("rims") slab(zr - 0.6, zr) rims_2d();
pick("markings") difference() {
  slab(zc - 0.4, zc) markings_2d();
  slab(z0 + 1, zr + 2) pockets_2d();
  if (points_style == "inlay") slab(zc - 0.6, zc + 1) labels_2d();
}
for (i=[0:len(BALLS)-1]) pick(str("ball_", BALLS[i][0])) {
  for (p=BALLS[i][3]) ball(p);
  if (legend && i < 7) legend_ball(LEGEND[i][2]);
  if (points_color == "ball colour") {
    if (points_style == "inlay") { slab(zc - 0.6, zc) labels_2d(i); slab(plate_t - 0.6, plate_t) legend_labels_2d(i); }
    else { slab(zc, zc + 0.6) labels_2d(i); slab(plate_t, plate_t + 0.6) legend_labels_2d(i); }
  }
}
if (points_color != "ball colour") pick("labels") {
  if (points_style == "inlay") { slab(zc - 0.6, zc) labels_2d(); slab(plate_t - 0.6, plate_t) legend_labels_2d(); }
  else { slab(zc, zc + 0.6) labels_2d(); slab(plate_t, plate_t + 0.6) legend_labels_2d(); }
}
if (ttl && show_plate) pick("title") slab(plate_t, plate_t + 0.8)
  translate([0, TH/2 + plate_margin/2 + TITLE_H/2]) text(title, size=title_size, font=font_for("serif bold"), halign="center", valign="center", spacing=1.15);
if (has_att) for (x=A_X) translate([x, A_Y, 0]) pick("attach") attach_plate(attach_type, attach_size, stand_reach=A_Y - H_BOT, stand_angle=stand_angle,
                                                                        roof_reach=H_TOP - A_Y + roof_gap, roof_angle=roof_angle);
