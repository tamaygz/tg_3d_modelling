// Project template: a plaque with a raised title and attachment sockets
// Copy this folder to projects/<name>/, rename the files to <name>.*, and replace the model. See ../../README.md.
// Library files. Keep include/use lines free of trailing comments (the web export tool only reads bare lines).
// core: pick(), slab(), palette (include, because it reads `part` and `parts`); shapes: plaque outlines, routed
// edges, grooves; attach: snap-in mounting plates and sockets; fonts: bundled fonts, font_for("serif bold")
include <../../lib/core.scad>
use <../../lib/shapes.scad>
use <../../lib/attach.scad>
use <../../lib/fonts.scad>

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
attach_type = "keyhole"; // [none, wall, keyhole, skadis, hook, magnet, stand, flat, roof, slide, clamp, pipe]
attach_size = "S"; // [S, M, L]
attach_count = 2; // [1:1:4]
// ball joint between the host and the plate: turn and tilt it freely, the lock ring clamps it
attach_joint = "none"; // [none, ball]
// slide: the track runs horizontally (slide the host along it) or vertically (drop the host onto it)
slide_axis = "horizontal"; // [horizontal, vertical]
// clamp: opening between the jaws (thickest desk, shelf or bar), reach from the clamp's back to the screw hole (mm)
clamp_gap = 40; // [10:1:120]
clamp_reach = 25; // [5:1:120]
// clamp: printed screw size
clamp_screw = "M16"; // [M10, M12, M16, M20]
// pipe: outer diameter of the pipe, tube or rail the claw snaps onto (mm), and which way it runs
pipe_d = 20; // [6:0.5:60]
pipe_axis = "horizontal"; // [horizontal, vertical]

/* [Hidden] */
$fn = 48;
// derived values, one comment each
text_size = min(height*0.35, width/max(1, len(title))*1.1);   // title cap height
a_fit = attach_fit(attach_type, attach_size, height, thickness=thickness);   // what fits: [type, size, note] (smaller plate or none, with a note)
a_type = a_fit[0]; a_size = a_fit[1];
a_x = attach_xs(attach_count, width, a_type, size=a_size);   // socket x positions (fewer if they don't fit)
a_y = attach_y(0);                                            // plate centre y
a_opts = attach_opts(slide_axis=slide_axis, clamp_gap=clamp_gap, clamp_reach=clamp_reach, clamp_screw=clamp_screw, pipe_d=pipe_d, pipe_axis=pipe_axis);                  // per-type options, passed on to the plates

// tables read by the tools: parts (id, label, note, pull-apart, colour, tags), checks, report
parts = [
  ["plaque", "Plaque", "PLA", [0,0,-10], COL_WOOD],
  ["title",  "Title",  "PLA", [0,0,10],  COL_TAN, str("pieces=", len([for (c=title) if (c != " ") c])), "plate=plaque", "mat=PLA tan"],
  each attach_rows(a_type, len(a_x), attach_joint, opts=a_opts)
];
checks = a_type == "none" ? [] : [["attach", "plaque", "clear"]];
report = [["width", width], ["height", height], ["text size", text_size]];

// 2D shapes first, then solids, then the assembly at the bottom
module outline_2d() { plaque_2d([width, height], shape, r=6); }

pick("plaque") difference() {
  profiled_slab(thickness, edge, 2) outline_2d();
  outline_groove(thickness, 4, 0.6, 0.6, groove) outline_2d();
  attach_sockets(a_type, a_size, a_x, a_y);
}
pick("title") slab(thickness, thickness + 0.8)
  text(title, size=text_size, font=font_for(font_style), halign="center", valign="center");
attach_note(a_fit[2]);                                         // warn if the attachment was reduced or left out
attach_all(part, a_type, a_size, a_x, a_y, a_opts, -height/2, height/2, attach_joint);     // plates, tracks, ball joint: every attachment part
