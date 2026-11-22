// A tray with compartments: rows of 3, 2 and 1 from a layout text, dividers that follow a sloped, notched rim
// and carry finger notches (lib/README.md, "Compartments")
use <../shell.scad>
use <../patterns.scad>
use <../container.scad>
size = [120, 90]; t = 2.2; H = 40;
runs = shell_rect_runs(size, "round", 12, 4);
pts  = container_box_pts(runs);
rim  = function(p) shell_rim(p, size, H, raise=[0, 12, 0, 0], notches=[["front", 12, 40]]);
p    = pattern_sized("hex_honeycomb", 0.6, strut_min=1);
g    = container_layout("33,33,33 / 50,50 / 100");
grid = container_grid(pts, t, g[0], g[1], "rows", 2);
color("#b98a52") {
    container_floor(pts, 2, p, "solid");
    container_walls(pts, t, H + 12, rim, p, "through_cut", bands=[4, 3], plain=container_grid_plain(pts, grid, 2, 3), anchor=[0, -size[1]/2]);
    container_dividers(pts, grid, 2, H + 12, function(q) rim(q) - 4, [[p, "through_cut"], [p, "through_cut"]], [4, 3], 3, notch=[10, 24]);
}
