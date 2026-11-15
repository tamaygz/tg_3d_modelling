// Bola Vuit logo: 8-ball, laurel wreath, ribbon banner and lettering
// exact = the original artwork's elements, 1:1 (lib/emblems/bolavuit.scad);
// rebuilt = the same design from the generic, adjustable generators in lib/emblem.scad.
use <../../lib/emblem.scad>
use <../../lib/emblems/bolavuit.scad>
use <../../lib/fonts.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Logo] */
// width of the logo artwork (mm); a plaque adds its margin around it
logo_width = 120; // [30:5:400]
// exact = the original artwork, element by element; rebuilt = adjustable generic elements (settings below)
source = "exact"; // [exact, rebuilt]
// rebuilt only: banner text and ball number
banner_text = "BOLA VUIT";
ball_number = 8;

/* [Elements] */
// show each element
show_ball = true;
show_wreath = true;
show_banner = true;
show_text = true;
// rebuilt only: leaf pairs per branch (plus a tip leaf)
leaf_pairs = 6; // [3:1:10]
// leaf shape
leaf_style = "almond"; // [almond, pointed, round]
// leaf length and width (px of the 1809 px wide original)
leaf_len = 300;
leaf_w = 98;
// banner drawn as an outline (like the original) or filled
banner_style = "outline"; // [outline, filled]
// bow knot with loops under the banner
banner_bow = true;
// lettering font and how condensed it is (1 = normal width)
font_style = "serif bold"; // [serif, serif bold, sans, sans bold]
text_width = 0.7; // [0.4:0.05:1.2]

/* [Plaque] */
// background: square (like the original), round, silhouette (follows the outline), none (artwork only)
base_shape = "silhouette"; // [square, round, silhouette, none]
// base thickness (mm)
base_t = 2.4;
// artwork: raised above the base, or inlaid flush (2-colour print)
art_style = "raised"; // [raised, inlay]
// artwork height (raised) or inlay depth (mm)
art_h = 0.8;

/* [Hidden] */
probe = 0;                                    // 1 = export the 2D artwork only (for overlay checks)
PXW = 1809; PXH = 1716;                       // frame of the original artwork (px)
k = logo_width / bv_art_w();                  // px -> mm (artwork width = logo_width)
C = [910, 959];                               // ball centre (px, y up)
BALL_D = 894;                                 // ball ring outer diameter (px)
BAND = [907, 321];                            // banner origin: middle of the band's lower edge line at its ends
BAND_W = 1285; BAND_H = 220; BAND_SAG = 47; STROKE = 13;

parts = [
  ["base", "Base",    "PLA black", [0,0,-10], "#151515"],
  ["art",  "Artwork", "PLA white", [0,0,10],  "#f2f2f2", str("pieces=", source == "exact" ? 29 : 20)]
];
report = [ ["artwork width", logo_width], ["artboard", PXW*k], ["thinnest line (mm)", STROKE*k] ];
if (STROKE*k < 0.8) echo(str("WARNING: at ", logo_width, " mm the banner outlines are ", STROKE*k, " mm wide; use at least ", ceil(0.8/STROKE*bv_art_w()), " mm for a 0.4 mm nozzle"));

module pick(n){ if (part=="all" || part==n) children(); }

// ---------- rebuilt artwork (px, y up) ----------
module band_area() { translate(BAND) banner_band_2d(BAND_W, BAND_H, BAND_SAG); }
module ball_px() {
  translate(C) pool_ball_2d(BALL_D, ball_number, ring_w=20, disc=0.492, disc_offset=[-0.011, 0.095], numeral=0.285);
}
module wreath_px() {
  translate(C) laurel_wreath_2d(r=595, a0=236, a1=133, pairs=leaf_pairs, leaf_len=leaf_len, leaf_w=leaf_w,
                                out_angle=35, in_angle=22, grow=0.88, style=leaf_style, bend=0.08);
}
module banner_px() { translate(BAND) banner_2d(BAND_W, BAND_H, BAND_SAG, tail_len=125, tail_drop=125, tail_w=105, notch=55,
                                              bow=banner_bow, style=banner_style, stroke=STROKE); }
module text_px() {
  R = BAND_W*BAND_W/(8*BAND_SAG);             // radius of the band's arch
  translate([BAND[0] + 9, BAND[1] + 47 - R]) arc_text_2d(banner_text, r=R + BAND_SAG, size=190, font=font_for(font_style),
                                                    width=text_width, tracking=0.03);
}
module rebuilt_px() {
  difference() {
    union() { if (show_ball) ball_px(); if (show_wreath) wreath_px(); }
    if (show_banner) offset(delta=10) band_area();               // the band sits in front
  }
  if (show_banner) banner_px();
  if (show_text) {
    if (show_banner && banner_style == "filled") difference() { band_area(); text_px(); }
    else intersection() { text_px(); if (show_banner) offset(delta=-STROKE - 4) band_area(); else square(5000, center=true); }
  }
}
module exact_px() {
  if (show_ball) bv_ball();
  if (show_wreath) bv_laurel();
  if (show_banner) bv_banner();
  if (show_text) bv_text();
}
module art_px() { if (source == "exact") exact_px(); else rebuilt_px(); }

// ---------- plaque ----------
module art_2d()  { scale(k) art_px(); }
module base_2d() {
  if (base_shape == "square") square([PXW*k, PXH*k]);
  else if (base_shape == "round") translate([PXW*k/2, PXH*k/2]) circle(d=max(PXW, PXH)*k*1.02, $fn=180);
  else if (base_shape == "silhouette") offset(r=4) offset(delta=-1) offset(r=1) scale(k) union() {
    art_px();
    if (source == "exact") { if (show_ball || show_banner) bv_frame_fill(); }
    else { if (show_banner) band_area(); if (show_ball) translate(C) circle(d=BALL_D, $fn=144); }
  }
}

if (probe == 1) art_px();
else {
  if (base_shape != "none") pick("base") difference() {
    linear_extrude(base_t) base_2d();
    if (art_style == "inlay") translate([0, 0, base_t - art_h]) linear_extrude(art_h + 1) art_2d();
  }
  pick("art") translate([0, 0, art_style == "inlay" || base_shape == "none" ? (base_shape == "none" ? 0 : base_t - art_h) : base_t])
    linear_extrude(art_h) art_2d();
}
