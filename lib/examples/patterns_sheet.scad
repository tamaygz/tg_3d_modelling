// All 12 patterns of lib/patterns.scad as flat samples (picture for lib/README.md)
use <../patterns.scad>
N = ["hex_honeycomb", "square_grid", "diamond_lattice", "triangular_lattice", "basket_weave", "tri_weave",
     "voronoi", "fish_scales", "truchet_arcs", "girih_star_cross", "flowing_waves", "concentric_ripples"];
for (i=[0:11]) translate([(i%4)*70, -floor(i/4)*70, 0]) {
    color("#3d4a54") linear_extrude(1.2) difference() { square(64, center=true); square(60, center=true); }
    color(i < 4 ? "#9aa4ad" : i < 6 ? "#d9b98a" : i == 6 ? "#4d6170" : i < 10 ? "#c9a13b" : "#7b8794")
        pattern_3d(N[i], [60, 60], h=N[i] == "basket_weave" || N[i] == "tri_weave" ? 2.4 : 1.2);
}
