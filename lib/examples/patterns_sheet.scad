// All 15 patterns of lib/patterns.scad as flat samples (picture for lib/README.md)
use <../patterns.scad>
N = ["hex_honeycomb", "square_grid", "diamond_lattice", "triangular_lattice", "cube_rosette",
     "basket_weave", "tri_weave", "voronoi", "fish_scales", "truchet_arcs",
     "girih_star_cross", "asanoha", "flowing_waves", "concentric_ripples", "fluted"];
for (i=[0:14]) translate([(i%5)*70, -floor(i/5)*70, 0]) {
    color("#3d4a54") linear_extrude(1.2) difference() { square(64, center=true); square(60, center=true); }
    color(i < 5 ? "#9aa4ad" : i < 7 ? "#d9b98a" : i == 7 ? "#4d6170" : i < 12 ? "#c9a13b" : "#7b8794")
        pattern_3d(N[i], [60, 60], h=N[i] == "basket_weave" || N[i] == "tri_weave" ? 2.4 : 1.2);
}
