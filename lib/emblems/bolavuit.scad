// Bola Vuit logo, exact: every element taken from the original artwork (projects/bolavuit_logo/reference/
// bolavuit.svg, white artwork path) by tools/svg_to_scad.py. Union of all elements = the original, 1:1.
// Use:  use <../../lib/emblems/bolavuit.scad>
// Units: px of the original 1809 x 1716 frame, y up, origin = the frame's lower-left corner.
// Scale with scale(width_mm / BV_W) (BV_W, BV_H come from bolavuit_data.scad).
include <bolavuit_data.scad>

BV_BALL_C   = [912, 959];                          // ball centre
BV_DISC_C   = [913.9, 1045.5];                     // number disc centre
BV_DISC_R   = 220.5;
BV_LEAVES_L = [6, 7, 12, 15, 3, 10, 17, 13, 19];   // left branch, bottom to top (region numbers)
BV_LEAVES_R = [5, 8, 11, 16, 4, 9, 18, 14, 20];    // right branch, mirror partners of the left ones
BV_LETTERS  = [24, 21, 23, 22, 28, 26];            // B, O, LA, VU, I, T (L-A and V-U touch in the original)
BV_COUNTERS = [25, 27];                            // the 8's two counters (white, inside the black numeral)
BV_DISC = 1; BV_CRESCENT = 2; BV_FRAME = 0;        // BV_FRAME = ring + banner outline (one joined shape)

function bv_frame_w() = BV_W;
function bv_frame_h() = BV_H;
module _bv_ring_zone() { translate(BV_BALL_C) difference() { circle(r=480, $fn=180); circle(r=400, $fn=180); } }
module _bv_banner_zone() { translate([-10, -10]) square([BV_W + 20, 610]); }       // everything below the band top

// ---------- elements ----------
module bv_ball_ring()  { difference() { intersection() { BV_region(BV_FRAME); _bv_ring_zone(); } _bv_banner_zone(); } }
module bv_ball_disc()  { BV_region(BV_DISC); for (i=BV_COUNTERS) BV_region(i); }      // white disc with the 8 cut out
module bv_numeral()    { difference() { translate(BV_DISC_C) circle(r=BV_DISC_R - 1, $fn=180); bv_ball_disc(); } }  // the 8 itself
module bv_crescent()   { BV_region(BV_CRESCENT); }
module bv_ball()       { bv_ball_ring(); bv_ball_disc(); bv_crescent(); }            // white parts of the 8-ball
module bv_leaf(i, right=false) { BV_region(right ? BV_LEAVES_R[i] : BV_LEAVES_L[i]); }   // i = 0 (bottom) .. 8 (top)
module bv_laurel_left()  { for (i=BV_LEAVES_L) BV_region(i); }
module bv_laurel_right() { for (i=BV_LEAVES_R) BV_region(i); }
module bv_laurel()     { bv_laurel_left(); bv_laurel_right(); }
module bv_banner()     { difference() { BV_region(BV_FRAME); bv_ball_ring(); } }     // band, tails and bow (outlines)
module bv_letter(i)    { BV_region(BV_LETTERS[i]); }
module bv_text()       { for (i=BV_LETTERS) BV_region(i); }                         // "BOLA VUIT"
module bv_logo()       { BV_all(); }                                                 // everything, exactly
// solid areas, for backgrounds and inlays: inside of the ball and of the banner band (black in the original)
module bv_ball_body()  { translate(BV_BALL_C) circle(r=450, $fn=180); }
// the joined ring + banner shape with its holes filled: the logo's solid silhouette without the leaves
module bv_frame_fill() { polygon(BV_REGIONS[BV_FRAME][0], [BV_REGIONS[BV_FRAME][1][0]]); }
// width of the artwork itself (px): scale(w_mm / bv_art_w()) makes the printed logo w_mm wide
function bv_art_w() = BV_INFO[BV_FRAME][2];
function bv_art_x0() = let(p = BV_REGIONS[BV_FRAME][0]) min([for (q=p) q[0]]);
