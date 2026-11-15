// Bundled fonts (Liberation; Source Serif 4 Bold; Lato Bold; all SIL OFL). `use <../../lib/fonts.scad>` registers them for every OpenSCAD build.
use <fonts/LiberationSerif-Regular.ttf>
use <fonts/LiberationSerif-Bold.ttf>
use <fonts/LiberationSans-Regular.ttf>
use <fonts/LiberationSans-Bold.ttf>
use <fonts/SourceSerif4-Bold.ttf>
use <fonts/Lato-Bold.ttf>
use <core.scad>

FONT_STYLES = ["serif", "serif bold", "sans", "sans bold", "book serif bold", "round sans bold"];   // choices for a font_style parameter

// font string for text(font=...) from a style name
function font_for(style) =
    style == "serif bold" ? "Liberation Serif:style=Bold" :
    style == "sans"       ? "Liberation Sans" :
    style == "sans bold"  ? "Liberation Sans:style=Bold" :
    style == "book serif bold" ? "Source Serif 4:style=Bold" :   // closest open match to the Bola Vuit lettering
    style == "round sans bold" ? "Lato:style=Bold" :            // closest open match to the Bola Vuit "8"
                            "Liberation Serif";

// ---------- text metrics (OpenSCAD 2021 has no textmetrics(); tables from tools/font_metrics.py) ----------
include <fonts_metrics.scad>
function _fm(font) = let(i = search([font], FONT_METRICS)[0]) is_num(i) ? FONT_METRICS[i] : FONT_METRICS[0];
// OpenSCAD units per em at size 1 (the scale OpenSCAD applies to `size`)
function font_em(font) = _fm(font)[1];
// capital letter height at size 1
function font_cap(font) = _fm(font)[2];
// advance width of one character in em (0.7 for characters outside ASCII 32-126)
function font_adv(font, ch) = let(m = _fm(font), i = search(ch, m[3])[0]) is_num(i) ? m[4][i] : 0.7;
// length of a string set on a straight line: size = text size, tracking = extra space per letter (em), width = x scale
function text_len(txt, size, font, tracking=0, width=1) =
    sum([for (i=[0:1:len(txt)-1]) (font_adv(font, txt[i]) + tracking)*font_em(font)*size*width]) - tracking*font_em(font)*size*width;
// size that makes a capital letter this tall (cap height h)
function size_for_cap(h, font) = h/font_cap(font);
