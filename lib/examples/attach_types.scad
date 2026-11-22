// Every attachment plate type, the slide track, the fin and the ball joint (picture for lib/README.md)
use <../attach.scad>
T = ["wall", "keyhole", "skadis", "hook", "magnet", "stand", "flat", "roof", "slide", "pipe", "clamp"];
P = [for (i=[0:9]) [(i%5)*70, -floor(i/5)*110]];   // two rows of five, then the clamp and the ball joint
for (i=[0:10]) translate(i < 10 ? P[i] : [90, -330]) rotate([180, 0, 0]) {
    color("#4d6170") attach_plate(T[i], "S");
    if (T[i] == "slide") color("#6f8494") slide_tracks("S", [0], 0);
    if (T[i] == "clamp") color("#2f3a44") clamp_screw_seated("S", 40, 25, "M16");
}
translate([230, -300, 0]) rotate([180, 0, 0]) attach_all("all", "wall", "S", [0], 0, joint="ball");
