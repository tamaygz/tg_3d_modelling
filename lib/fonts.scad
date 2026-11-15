// Bundled fonts (Liberation; Source Serif 4 Bold; Lato Bold; all SIL OFL). `use <../../lib/fonts.scad>` registers them for every OpenSCAD build.
use <fonts/LiberationSerif-Regular.ttf>
use <fonts/LiberationSerif-Bold.ttf>
use <fonts/LiberationSans-Regular.ttf>
use <fonts/LiberationSans-Bold.ttf>
use <fonts/SourceSerif4-Bold.ttf>
use <fonts/Lato-Bold.ttf>

FONT_STYLES = ["serif", "serif bold", "sans", "sans bold", "book serif bold", "round sans bold"];   // choices for a font_style parameter

// font string for text(font=...) from a style name
function font_for(style) =
    style == "serif bold" ? "Liberation Serif:style=Bold" :
    style == "sans"       ? "Liberation Sans" :
    style == "sans bold"  ? "Liberation Sans:style=Bold" :
    style == "book serif bold" ? "Source Serif 4:style=Bold" :   // closest open match to the Bola Vuit lettering
    style == "round sans bold" ? "Lato:style=Bold" :            // closest open match to the Bola Vuit "8"
                            "Liberation Serif";
