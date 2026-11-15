// Bola Vuit logo: 8-ball, laurel wreath, ribbon banner and lettering
// exact = the original artwork's elements, 1:1 (lib/emblems/bolavuit.scad);
// rebuilt = the same design from the generic, adjustable generators in lib/emblem.scad.
include <../../lib/core.scad>
use <../../lib/emblem.scad>
use <../../lib/emblems/bolavuit.scad>
use <../../lib/fonts.scad>
// fitted layout data for the rebuilt version
include <../../lib/emblems/bolavuit_rebuilt.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Logo] */
// width of the logo artwork (mm); a plaque adds its margin around it
logo_width = 120; // [30:5:400]
// exact = the original artwork, element by element; rebuilt = adjustable generic elements (settings below)
source = "exact"; // [exact, rebuilt]
// rebuilt only: banner text and ball number. The original text, font and size use the letter-by-letter fitted
// placement; anything else is set on the same curve by the generic text layout and condensed to fit the banner.
banner_text = "BOLA VUIT";
ball_number = 8;

/* [Elements] */
// show each element
show_ball = true;
show_wreath = true;
show_banner = true;
show_text = true;
// rebuilt only: leaf layout: fitted = the original's 9 leaves per side; generated = repeating leaf groups
leaf_layout = "fitted"; // [fitted, generated]
// generated layout: leaf groups per branch (3 leaves each) and leaf length (px of the 1809 px original)
leaf_groups = 3; // [1:1:6]
leaf_len = 324;
// leaf shape
leaf_style = "almond"; // [almond, pointed, round]
// banner drawn as an outline (like the original) or filled
banner_style = "outline"; // [outline, filled]
// bow under the banner, and the small ears at the band's top corners
banner_bow = true;
banner_ears = true;
// lettering font (the original "BOLA VUIT" uses Source Serif 4 Bold, the closest open match)
font_style = "book serif bold"; // [book serif bold, serif bold, serif, sans bold, sans, round sans bold]
// letter height, 1 = like the original; other values (and other text or fonts) use the generic layout below
text_size = 1; // [0.5:0.05:1.3]
// share of the banner's text space the text may use: longer text is condensed (then shrunk) to fit
text_fill = 1; // [0.4:0.05:1]

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
STROKE = BVR_BANNER[7];
// the original text, font and size use the fitted letter-by-letter placement; anything else the generic layout
FITTED_TEXT = banner_text == "BOLA VUIT" && font_style == "book serif bold" && text_size == 1 && text_fill == 1;                       // banner outline width (px)

parts = [
  ["base", "Base",    "PLA black", [0,0,-10], COL_BLACK],
  ["art",  "Artwork", "PLA white", [0,0,10],  COL_WHITE, str("pieces=", source == "exact" ? 29 : 32)]
];
report = [ ["artwork width", logo_width], ["artboard", PXW*k], ["thinnest line (mm)", STROKE*k] ];
if (STROKE*k < 0.8) echo(str("WARNING: at ", logo_width, " mm the banner outlines are ", STROKE*k, " mm wide; use at least ", ceil(0.8/STROKE*bv_art_w()), " mm for a 0.4 mm nozzle"));


// ---------- rebuilt artwork (px, y up) ----------
module band_area() { translate([BVR_CENTER_X, 0]) ribbon_banner_inside_2d(BVR_BANNER); }
module ball_px() {
  B = BVR_BALL;
  translate(BVR_BALL_C) pool_ball_2d(B[0], ball_number, ring_w=B[1], disc=B[2], disc_offset=B[3], font=BVR_NUMERAL_FONT,
                                     hl_center=B[4], hl_r=B[5], hl_from=B[6], hl_to=B[7], hl_mid=B[8], hl_w=B[9], numeral_matrix=BVR_NUMERAL);
}
module wreath_px() {
  translate(BVR_WREATH_C)
    if (leaf_layout == "fitted") laurel_wreath_2d(leaves=BVR_LEAVES, style=leaf_style);
    else laurel_wreath_2d(groups=leaf_groups, leaf_len=leaf_len, style=leaf_style);
}
module banner_px() { translate([BVR_CENTER_X, 0]) ribbon_banner_2d(BVR_BANNER, banner_style, banner_bow, banner_ears); }
module text_px() {
  if (FITTED_TEXT)
    for (l=BVR_LETTERS) affine2d(l[1]) text(l[0], size=100, font=BVR_FONT, halign="left", valign="baseline");
  else let(T = BVR_TEXT_ARC, f = font_for(font_style), span = text_len("BOLA VUIT", T[3], font_for("book serif bold"), T[5], T[4]))
    translate([T[0], T[1]]) arc_text_2d(banner_text, r=T[2], size=T[3]*text_size, font=f, at=T[8], tracking=T[5], width=T[4],
                                         fan=0, lean=[T[6], T[7]], max_len=span*text_fill);
}
module rebuilt_px() {
  difference() {
    union() { if (show_ball) ball_px(); if (show_wreath) wreath_px(); }
    if (show_banner) offset(r=STROKE, $fn=24) band_area();      // the banner sits in front
  }
  if (show_banner) banner_px();
  if (show_text) {
    if (show_banner && banner_style == "filled") difference() { band_area(); text_px(); }
    else text_px();
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
    else { if (show_banner) offset(r=STROKE) band_area(); if (show_ball) translate(BVR_BALL_C) circle(d=BVR_BALL[0], $fn=144); }
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
