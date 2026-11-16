// A patterned wall bent round an outline, with a sloped and wavy rim (the example in lib/README.md)
use <../shell.scad>
use <../patterns.scad>
size = [120, 90]; t = 2.4; H = 70;
runs = shell_rect_runs(size, "round", 16, fn=6, side_n=2);
pts  = shell_start_at(shell_runs_pts(runs), shell_run(shell_runs_edges(runs), "back")[1] + 1);
rim  = function(p) shell_rim_height(p, size, 40, rise=[0, 22], waves=[[4, 2], [0, 1]]);
L = shell_len(pts);
color("#d9b98a") shell_wrap(pts, t, h=H)
    pattern_panel("through_cut", pattern_wrapped("hex_honeycomb", L), [L + 1, H], t=t, border=[0, 4, 4])
        polygon(shell_strip_pts(pts, hf=rim, h=H));
color("#d9b98a") linear_extrude(2) polygon(pts);
