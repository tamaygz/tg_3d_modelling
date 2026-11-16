// Every attachment plate type, the slide track, the fin and the ball joint (picture for lib/README.md)
use <../attach.scad>
T = ["wall", "keyhole", "skadis", "hook", "magnet", "stand", "flat", "roof", "slide"];
for (i=[0:8]) translate([(i%5)*62, -floor(i/5)*95, 0]) rotate([180, 0, 0]) {
    color("#4d6170") attach_plate(T[i], "S");
    if (T[i] == "slide") color("#6f8494") slide_tracks("S", [0], 0);
}
translate([4*62, -95, 0]) rotate([180, 0, 0]) attach_all("all", "wall", "S", [0], 0, joint="ball");
