// A container with a grip cut-out, a cable hole and a mounting zone built into its back wall (lib/README.md)
use <../shell.scad>
use <../patterns.scad>
use <../attach.scad>
use <../container.scad>
size = [84, 46]; t = 2.2; H = 52;
runs = shell_rect_runs(size, "round", 9, 4);
pts  = container_box_pts(runs);
rim  = function(p) H - shell_rim_dip(p, size, depth=16, width=30);
p    = pattern_sized("triangular_lattice", 0.6, strut_min=1);
m    = container_mount(pts, "skadis", "S", 1, rim, t, [5, 3]);
color("#3d4a54") {
    container_floor(pts, 3, p, "solid") translate([0, 2]) circle(d=14);
    container_walls(pts, t, H, rim, p, "through_cut", bands=[5, 3], mount=m, anchor=[0, -size[1]/2]);
}
container_attach("all", m, attach_opts(), 0, H);
