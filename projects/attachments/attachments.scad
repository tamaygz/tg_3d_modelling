// Attachment plates: test coupon + one plate + lock key
// Print the coupon and a plate first to check the snap fit, then use the same plate on any project.
use <../../lib/attach.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Plate] */
// what the plate mounts to
attach_type = "wall"; // [wall, keyhole, skadis, hook, magnet, stand, flat, roof]
// plate size: S 30x30, M 45x40, L 60x50 mm
attach_size = "M"; // [S, M, L]

/* [Options] */
// wall: screw hole diameter
screw_d = 4.5;
// wall: countersunk head diameter
head_d = 8.5;
// magnet: [diameter, height] of the round magnets
magnet = [10, 3];
// hook: thickness of the rod, rail or door it hangs on
hook_gap = 6;
// stand: plate centre to the host's bottom edge
stand_reach = 40;
// stand: lean back from vertical (degrees)
stand_angle = 15; // [5:1:30]
// stand: foot distance behind the host
stand_depth = 40;
// roof: plate centre up to the ceiling
roof_reach = 60;
// roof: angle between the host and the ceiling (90 = hangs straight down)
roof_angle = 90; // [45:5:135]
// roof: ceiling flange depth
roof_depth = 40;

/* [Hidden] */
// probe for checks: 0 = off; 1 = half way in (arms must bend ~0.6 mm); 2 = seated (must be clear); 3 = seated, pulled back 0.4 mm (bumps must catch)
probe = 0;
D  = attach_dims(attach_size);
cw = attach_socket_w(attach_size) + 12;          // coupon width
cl = attach_socket_len(attach_size) + 12;        // coupon length
ct = attach_depth() + 3;                         // coupon thickness
cy = -3/2;                                       // coupon centre y (the socket has a pry notch below)

parts = [
  ["coupon", "Test coupon",  "PLA", [0,0,25],  "#7a2e1c", "print=x180"],
  ["plate",  "Attachment plate", "PLA", [0,0,-25], "#4d6170", (attach_type == "skadis" || attach_type == "hook" || attach_type == "roof") ? "print=auto" : "print=x180"],
];
checks = [ ["plate","coupon","clear"] ];
report = [ ["plate w", D[0]], ["plate l", D[1]], ["socket length", attach_socket_len(attach_size)] ];

module pick(n){ if (part=="all" || part==n) children(); }
module plate() { attach_plate(attach_type, attach_size, screw_d, head_d, magnet, 0.15, hook_gap, stand_reach, stand_angle, stand_depth,
                               roof_reach=roof_reach, roof_angle=roof_angle, roof_depth=roof_depth); }
module coupon() { difference() { translate([-cw/2, cy - cl/2, 0]) cube([cw, cl, ct]); attach_socket(attach_size); } }

if (probe == 0) {
  pick("coupon") coupon();
  pick("plate") plate();
} else {
  intersection() { coupon(); translate([0, 0, probe == 1 ? -2.3 : probe == 3 ? -0.4 : 0]) attach_core(attach_size); }
}
