// Project template: a plaque with a raised title and attachment sockets
// Copy this folder to projects/<name>/, rename the files to <name>.*, and replace the model. See ../../README.md.
include <../../lib/core.scad>      // pick(), slab(), palette ... (include: it reads `part`)
use <../../lib/shapes.scad>        // plaque outlines, routed edges, grooves
use <../../lib/attach.scad>        // snap-in mounting plates and their sockets
use <../../lib/fonts.scad>         // bundled fonts: font_for("serif bold") ...

part = "all";                    // which part to export ("all" = assembly); set by the build tools

/* [Size] */
// plaque width and height (mm)
width = 120; // [60:5:250]
height = 60; // [40:5:200]
// plaque thickness (mm; 6 or more for attachment sockets)
thickness = 6; // [3:0.5:12]

/* [Style] */
// outline
shape = "rounded"; // [rect, rounded, chamfered, notched, arched, wave, scalloped]
// routed top edge
edge = "roundover"; // [flat, roundover, chamfer, cove, ogee]
// decorative groove
groove = "single"; // [none, single, double]
// title text and its font
title = "TITLE";
font_style = "serif bold"; // [serif, serif bold, sans, sans bold, book serif bold, round sans bold]

/* [Attachment] */
// how it mounts: plates snap into sockets in the back (none = plain back)
attach_type = "keyhole"; // [none, wall, keyhole, skadis, hook, magnet, stand, flat, roof]
attach_size = "S"; // [S, M, L]
attach_count = 2; // [1:1:4]

/* [Hidden] */
$fn = 48;
// derived values, one comment each
text_size = min(height*0.35, width/max(1, len(title))*1.1);   // title cap height
a_x = attach_xs(attach_count, width, attach_type);            // socket x positions
a_y = attach_y(0);                                            // plate centre y
assert(attach_type == "none" || attach_fits(attach_size, height, thickness=thickness), attach_fit_msg(attach_size, height, thickness));

// tables read by the tools: parts (id, label, note, pull-apart, colour, tags), checks, report
parts = [
  ["plaque", "Plaque", "PLA", [0,0,-10], COL_WOOD],
  ["title",  "Title",  "PLA", [0,0,10],  COL_TAN, str("pieces=", len([for (c=title) if (c != " ") c])), "plate=plaque", "mat=PLA tan"],
  attach_parts_row(attach_type, attach_count)
];
checks = attach_type == "none" ? [] : [["attach", "plaque", "clear"]];
report = [["width", width], ["height", height], ["text size", text_size]];

// 2D shapes first, then solids, then the assembly at the bottom
module outline_2d() { plaque_2d([width, height], shape, r=6); }

pick("plaque") difference() {
  profiled_slab(thickness, edge, 2) outline_2d();
  outline_groove(thickness, 4, 0.6, 0.6, groove) outline_2d();
  attach_sockets(attach_type, attach_size, a_x, a_y);
}
pick("title") slab(thickness, thickness + 0.8)
  text(title, size=text_size, font=font_for(font_style), halign="center", valign="center");
pick("attach") attach_plates(attach_type, attach_size, a_x, a_y, y_bottom=-height/2, y_top=height/2);
