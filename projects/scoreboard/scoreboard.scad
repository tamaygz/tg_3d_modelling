// Parametric sliding-pin scoreboard (pool / snooker style)
// Board + number plates + per-player rails, sliders (marker pins) and stopper pegs.
include <fits.scad>
use <LiberationSerif-Regular.ttf>   // bundled font so every OpenSCAD build finds it

part = "all";                    // which part to export ("all" = assembly)

// ---------------- scoring ----------------
players     = 2;                 // number of players = number of tracks (2 tracks share one number plate)
base_min    = 0;                 // first number of the main range
base_max    = 19;                // last number of the main range
steps       = [20,40,60,80,100]; // 2nd-dimension steps (counting beyond the main range)
zero_step   = true;              // put a "0" home position in front of the steps
demo_scores = [[7,2],[15,4]];    // per player [main-range index, step index] – only for the preview

// ---------------- layout ----------------
pitch       = 11;    // spacing of main-range numbers (mm)
step_pitch  = 14;    // spacing of step numbers (mm)
font        = "Liberation Serif";  // number font
text_size   = 5.2;   // number cap height (mm)
dot_d       = 1.4;   // separator dot diameter
strip_gap   = 9;     // gap between slider edges of neighbouring plates

// ---------------- board ----------------
board_t     = 12;    // board thickness
margin_x    = 14;    // board edge to rail end
margin_y    = 13;    // board edge (at deepest wave) to slider edge
wave_amp    = 5;     // height of the wavy top/bottom edge
waves       = 2;     // number of wave periods along the edge
corner_r    = 8;     // outline corner radius
edge_r      = 3;     // roundover of the top edge
groove_in   = 5.5;   // decorative groove: inset from edge
groove_w    = 0.8;   // decorative groove width / depth
split_board = true;  // cut the board at the divider into two printable halves
dowel_d     = 5;     // alignment dowel diameter (split board)
dowel_l     = 20;    // alignment dowel length
keyhole     = true;  // keyhole hanging slots in the back

// ---------------- number plate ----------------
label_h     = 10;    // plate height (Y)
label_t     = 2;     // plate thickness (sits flush in a pocket)
label_clr   = 0.2;   // pocket clearance per side
text_depth  = 0.6;   // depth of the inlaid numbers
border_in   = 0.9;   // inlaid border line inset
border_w    = 0.5;   // inlaid border line width

// ---------------- rail & sliders ----------------
flange_w    = 10;    // rail top flange width
flange_t    = 2;     // rail top flange thickness
web_w       = 5;     // rail web width
web_h       = 3.2;   // rail web height (gap under flange)
rail_end    = 4;     // rail beyond the stopper-peg centre
slide_clr   = 0.25;  // slider-to-rail clearance per side
slider_l    = 10;    // slider length along the rail
slider_wall = 1.6;   // slider side wall
slider_top  = 2;     // slider top plate
lip_t       = 1.8;   // slider lip thickness (under the flange)
ptr_len     = 3.5;   // pointer reach towards the number plate
ptr_w       = 6;     // pointer base width
ptr_t       = 1.4;   // pointer thickness

// ---------------- stopper pegs ----------------
peg_d       = 3;     // peg shaft (press fit p6 into H7 board hole)
peg_hole    = 3.4;   // clearance hole in the rail
peg_depth   = 6;     // depth of the peg hole in the board
head_d      = 6.5;   // stopper head diameter
head_h      = 2.5;   // stopper head height above the rail
div_pin     = 4;     // divider pins at ±this from the rail joint

$fn = 48;

// derived
nU      = base_max - base_min + 1;                    // main-range positions
slabels = concat(zero_step ? [0] : [], steps);        // step labels
nS      = len(slabels);                               // step positions
rail_h  = web_h + flange_t;                           // rail height
sw      = flange_w + 2*slide_clr + 2*slider_wall;     // slider width (Y)
s_top   = rail_h + slide_clr + slider_top;            // slider top above board
div_hl  = div_pin + head_d/2;                         // divider head half length
xu      = [for (i=[0:nU-1]) i*pitch];                 // main-range pointer x
x_start = -(slider_l/2 + head_d/2);                   // start stopper x
x_div   = xu[nU-1] + slider_l/2 + div_hl;             // divider / rail joint x
xs      = [for (j=[0:nS-1]) x_div + div_hl + slider_l/2 + j*step_pitch]; // step pointer x
x_end   = xs[nS-1] + slider_l/2 + head_d/2;           // end stopper x
ru0     = x_start - rail_end;                         // main rail start
rs1     = x_end + rail_end;                           // step rail end
bx0     = ru0 - margin_x;                             // board left
bx1     = rs1 + margin_x;                             // board right
rail_dy = label_h/2 + 1.5 + sw/2;                     // plate centre to rail centre
nStrip  = ceil(players/2);                            // number plates
strip_p = 2*rail_dy + sw + strip_gap;                 // plate-to-plate pitch
strip_y = [for (k=[0:nStrip-1]) -k*strip_p];          // plate centre y
track_y = [for (p=[0:players-1]) strip_y[floor(p/2)] + (p%2==0 ? rail_dy : -rail_dy)];
track_up= [for (p=[0:players-1]) p%2==0];             // true = pointer faces down onto the plate below
by1     = rail_dy + sw/2 + margin_y;                  // board top (wave trough)
by0     = strip_y[nStrip-1] - ((players%2==1) ? label_h/2 + 4 : rail_dy + sw/2) - margin_y; // board bottom
pl_u    = [xu[0] - pitch/2, xu[nU-1] + pitch/2];      // main plate x span
pl_s    = [xs[0] - step_pitch/2, xs[nS-1] + step_pitch/2]; // step plate x span
hole_b  = fit_mid("H7", peg_d);                       // board peg hole
shaft_d = fit_mid("p6", peg_d);                       // peg shaft
dw_hole = fit_mid("H7", dowel_d);                     // dowel hole
dw_d    = fit_mid("k6", dowel_d);                     // dowel shaft (H7/k6)
dz      = 5;                                          // dowel centre height
function sumv(v, i=0) = i >= len(v) ? 0 : v[i] + sumv(v, i+1);
n_txt_u = nStrip * (sumv([for (i=[0:nU-1]) len(str(base_min+i))]) + nU);    // inlay pieces: digits + dots + border
n_txt_s = nStrip * (sumv([for (v=slabels) len(str(v))]) + nS);

parts = [
  ["board_l",   "Board left",         "PLA wood / brown", [0,0,-30], "#7a2e1c"],
  ["board_r",   "Board right",        "PLA wood / brown", [30,0,-30], "#7a2e1c"],
  ["plate_u",   "Number plate main",  "PLA silk gold",    [0,0,20],  "#cdb87a", str("pieces=",nStrip), "plate=plates_u", "mat=PLA gold"],
  ["text_u",    "Numbers main",       "PLA black",        [0,0,26],  "#1a1a1a", str("pieces=",n_txt_u), "plate=plates_u", "mat=PLA black"],
  ["plate_s",   "Number plate steps", "PLA silk gold",    [0,0,20],  "#cdb87a", str("pieces=",nStrip), "plate=plates_s", "mat=PLA gold"],
  ["text_s",    "Numbers steps",      "PLA black",        [0,0,26],  "#1a1a1a", str("pieces=",n_txt_s), "plate=plates_s", "mat=PLA black"],
  ["rail_u",    "Rail main range",    "PLA silk gold",    [0,0,12],  "#c9a13b", str("pieces=",players), "print=x180"],
  ["rail_s",    "Rail steps",         "PLA silk gold",    [0,0,12],  "#c9a13b", str("pieces=",players), "print=x180"],
  ["slider",    "Marker slider",      "PLA silk gold",    [0,0,32],  "#e0b84a", str("pieces=",2*players), "print=x180"],
  ["stop_end",  "End stopper",        "PLA silver",       [0,0,45],  "#b8b8b8", str("pieces=",2*players), "print=x180"],
  ["stop_div",  "Column divider",     "PLA silver",       [0,0,45],  "#b8b8b8", str("pieces=",players), "print=x180"],
  ["dowel",     "Alignment dowel",    "PLA",              [0,0,-30], "#555555", str("pieces=",nStrip), "print=x90"]
];
checks = [
  ["slider","rail_u","clear"], ["slider","rail_s","clear"],
  ["slider","stop_end",">=",0], ["slider","stop_div",">=",0],
  ["stop_end","rail_u","touch"], ["stop_div","rail_s","touch"]
];
report = [
  ["board length", bx1 - bx0], ["board height", by1 + wave_amp - (by0 - wave_amp)],
  ["main rail length", x_div - ru0], ["step rail length", rs1 - x_div],
  ["left half length", x_div - bx0], ["right half length", bx1 - x_div],
  ["slider top above board", s_top]
];

module pick(n){ if (part=="all" || part==n) children(); }

// ---------------- board ----------------
function wv(t) = wave_amp * 0.5 * (1 + cos(360*waves*t));
module outline() {
  N = 160;
  top = [for (i=[0:N]) let(t=i/N) [bx0 + t*(bx1-bx0), by1 + wv(t)]];
  bot = [for (i=[N:-1:0]) let(t=i/N) [bx0 + t*(bx1-bx0), by0 - wv(t)]];
  offset(r=corner_r) offset(delta=-corner_r) polygon(concat(top, bot));
}
module board_blank() {
  n = 6;
  linear_extrude(board_t - edge_r) outline();
  for (k=[1:n]) translate([0,0,board_t - edge_r + (k-1)*edge_r/n])
    linear_extrude(edge_r/n + 0.01) offset(delta=-(edge_r - sqrt(edge_r*edge_r - pow(k*edge_r/n,2)))) outline();
}
module plate2d(sp) { offset(r=1) offset(delta=-1) translate([sp[0], -label_h/2]) square([sp[1]-sp[0], label_h]); }
module keyslot() {
  translate([0,0,-0.1]) { cylinder(d=9, h=6.1); hull() { cylinder(d=4.5, h=2.6); translate([0,10,0]) cylinder(d=4.5, h=2.6); } }
  translate([0,0,2.5]) hull() { cylinder(d=9, h=3.5); translate([0,10,0]) cylinder(d=9, h=3.5); }
}
function peg_x() = [x_start, x_div - div_pin, x_div + div_pin, x_end];
module board() {
  difference() {
    board_blank();
    translate([0,0,board_t - groove_w]) linear_extrude(1)
      difference() { offset(delta=-groove_in) outline(); offset(delta=-groove_in-groove_w) outline(); }
    for (y=strip_y) translate([0,y,board_t - label_t]) linear_extrude(label_t + 1) {
      offset(delta=label_clr) plate2d(pl_u);
      offset(delta=label_clr) plate2d(pl_s);
    }
    for (y=track_y, x=peg_x()) translate([x,y,board_t - peg_depth]) cylinder(d=hole_b, h=peg_depth + 1, $fn=32);
    if (split_board) for (y=strip_y) translate([x_div,y,dz]) rotate([0,90,0]) cylinder(d=dw_hole, h=dowel_l + 1, center=true, $fn=32);
    if (keyhole) for (x=[bx0 + 0.2*(bx1-bx0), bx0 + 0.8*(bx1-bx0)]) translate([x, by1 - 14, 0]) keyslot();
  }
}
module board_half(right) {
  intersection() {
    board();
    if (!split_board) translate([bx0-50, by0-50, -1]) cube([bx1-bx0+100, by1-by0+100, board_t+2]);
    else if (right) translate([x_div, by0-50, -1]) cube([bx1-x_div+50, by1-by0+100, board_t+2]);
    else translate([bx0-50, by0-50, -1]) cube([x_div-bx0+50, by1-by0+100, board_t+2]);
  }
}

// ---------------- number plates ----------------
module text_u2d() {
  for (i=[0:nU-1]) translate([xu[i],0]) text(str(base_min + i), size=text_size, font=font, halign="center", valign="center");
  for (i=[0:nU-2]) translate([(xu[i]+xu[i+1])/2, 0]) circle(d=dot_d, $fn=16);
}
module text_s2d() {
  for (j=[0:nS-1]) translate([xs[j],0]) text(str(slabels[j]), size=text_size, font=font, halign="center", valign="center");
  for (j=[0:nS-2]) translate([(xs[j]+xs[j+1])/2, 0]) circle(d=dot_d, $fn=16);
}
module border2d(sp) { difference() { offset(delta=-border_in) plate2d(sp); offset(delta=-border_in-border_w) plate2d(sp); } }
module inlay2d(sp) { if (sp==pl_u) text_u2d(); else text_s2d(); border2d(sp); }
module num_plate(sp) {
  difference() {
    linear_extrude(label_t) plate2d(sp);
    translate([0,0,label_t - text_depth]) linear_extrude(1) inlay2d(sp);
  }
}
module num_text(sp) { translate([0,0,label_t - text_depth]) linear_extrude(text_depth) intersection() { inlay2d(sp); offset(delta=-0.3) plate2d(sp); } }

// ---------------- rail ----------------
module rail_profile() {
  translate([-web_w/2, 0]) square([web_w, web_h + 0.01]);
  translate([-flange_w/2, web_h]) square([flange_w, flange_t]);
}
module rail(x0, x1, holes) {
  difference() {
    translate([x0,0,0]) rotate([90,0,90]) linear_extrude(x1 - x0) rail_profile();
    for (x=holes) translate([x,0,-1]) cylinder(d=peg_hole, h=rail_h + 2, $fn=32);
  }
}

// ---------------- slider (marker pin) ----------------
module slider() {
  c = slide_clr;
  zl = web_h - c - lip_t;
  difference() {
    union() {
      translate([-slider_l/2, -sw/2, zl]) cube([slider_l, sw, s_top - zl]);
      translate([0, -sw/2 + 0.01, s_top - ptr_t]) linear_extrude(ptr_t)
        polygon([[-ptr_w/2,0],[ptr_w/2,0],[0.4,-ptr_len],[-0.4,-ptr_len]]);
    }
    translate([-slider_l, -(flange_w/2 + c), web_h - c]) cube([2*slider_l, flange_w + 2*c, flange_t + 2*c]);
    translate([-slider_l, -(web_w/2 + c), -1]) cube([2*slider_l, web_w + 2*c, web_h + 1]);
    translate([0, 0, s_top + 2.4]) sphere(r=3, $fn=48);
  }
}

// ---------------- stopper pegs ----------------
module peg_head() {
  difference() {
    union() { cylinder(d=head_d, h=head_h - 0.8); translate([0,0,head_h - 0.8]) cylinder(d1=head_d, d2=head_d - 1.6, h=0.8); }
    translate([0,0,head_h - 0.6]) cube([head_d, 0.7, 1.4], center=true);
  }
}
module stop_end() {
  peg_head();
  translate([0,0,-(rail_h + peg_depth - 0.5)]) cylinder(d=shaft_d, h=rail_h + peg_depth - 0.5 + 0.01, $fn=32);
}
module stop_div() {
  hull() for (s=[-1,1]) translate([s*div_pin,0,0]) cylinder(d=head_d, h=head_h - 0.8);
  hull() for (s=[-1,1]) translate([s*div_pin,0,head_h - 0.8]) cylinder(d1=head_d, d2=head_d - 1.6, h=0.8);
  for (s=[-1,1]) translate([s*div_pin,0,-(rail_h + peg_depth - 0.5)]) cylinder(d=shaft_d, h=rail_h + peg_depth - 0.5 + 0.01, $fn=32);
}

// ---------------- assembly ----------------
module on_track(p) { translate([0, track_y[p], board_t]) rotate([0,0, track_up[p] ? 0 : 180]) children(); }
function tx(p,x) = track_up[p] ? x : -x;   // x in track frame (lower tracks are rotated 180°)

pick("board_l") board_half(false);
pick("board_r") if (split_board) board_half(true);
for (y=strip_y) translate([0,y,board_t - label_t]) {
  pick("plate_u") num_plate(pl_u);
  pick("text_u")  num_text(pl_u);
  pick("plate_s") num_plate(pl_s);
  pick("text_s")  num_text(pl_s);
}
for (p=[0:players-1]) {
  sc = p < len(demo_scores) ? demo_scores[p] : [0,0];
  translate([0, track_y[p], board_t]) {
    pick("rail_u") rail(ru0, x_div, [x_start, x_div - div_pin]);
    pick("rail_s") rail(x_div, rs1, [x_div + div_pin, x_end]);
    pick("stop_end") for (x=[x_start, x_end]) translate([x,0,rail_h]) stop_end();
    pick("stop_div") translate([x_div,0,rail_h]) stop_div();
  }
  on_track(p) pick("slider") {
    translate([tx(p, xu[min(sc[0], nU-1)]), 0, 0]) slider();
    translate([tx(p, xs[min(sc[1], nS-1)]), 0, 0]) slider();
  }
}
pick("dowel") if (split_board) for (y=strip_y) translate([x_div, y, dz]) rotate([0,90,0]) cylinder(d=dw_d, h=dowel_l - 1, center=true, $fn=32);
