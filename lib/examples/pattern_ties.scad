// Ties in line patterns that are cut through, and a pattern closed round a loop (picture for lib/README.md)
use <../patterns.scad>
color("#9aa4ad") linear_extrude(2) pattern_panel_2d("flowing_waves", [90, 60], border=2.5);
translate([100, 0]) color("#d9b98a") linear_extrude(2) pattern_panel_2d(pattern_spec("flowing_waves", cell=12, opts=[["shift", 60], ["amplitude", 4]]), [90, 60], border=2.5);
translate([185, 0]) color("#c9a13b") linear_extrude(2) pattern_panel_2d("concentric_ripples", [70, 70], border=2.5) circle(d=64);
