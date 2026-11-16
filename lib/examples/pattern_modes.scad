// One pattern in every application mode (picture for lib/README.md)
use <../patterns.scad>
MODES = ["through_cut", "open_lattice", "raised", "recessed", "overlay"];
p = pattern_spec("girih_star_cross", cell=22, strut=1.6);
for (i=[0:4]) translate([i*70, 0, 0]) color(["#9aa4ad", "#d9b98a", "#c9a13b", "#4d6170", "#3d4a54"][i])
    pattern_panel(MODES[i], p, [60, 60], t=2.4, depth=1, border=3, lining_t=0.8) offset(r=6) square(48, center=true);
