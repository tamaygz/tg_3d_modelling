// Attachment plates: test coupon + one plate + lock key
// Print the coupon and a plate first to check the slide fit, then use the same plate on any project.
use <../../lib/attach.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Plate] */
// what the plate mounts to
attach_type = "wall"; // [wall, keyhole, skadis, hook, magnet, stand, flat]
// plate size: S 30x30, M 45x40, L 60x50 mm
attach_size = "M"; // [S, M, L]
// print the key that locks the plate in place
lock_key = true;

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

/* [Hidden] */
// probe for checks: 0 = off, 1 = plate at the entry position, lifted out (must be free), 2 = locked, lifted (must hit)
probe = 0;
D  = attach_dims(attach_size);
a  = attach_slide(attach_size);
cw = attach_socket_w(attach_size) + 12;          // coupon width
cl = attach_socket_len(attach_size) + 12;        // coupon length
ct = attach_depth() + 3;                         // coupon thickness
cy = -a/2;                                       // coupon centre y (socket is offset down by the slide)

parts = [
  ["coupon", "Test coupon",  "PLA", [0,0,25],  "#7a2e1c", "print=x180"],
  ["plate",  "Attachment plate", "PLA", [0,0,-25], "#4d6170", (attach_type == "skadis" || attach_type == "hook") ? "print=auto" : "print=x180"],
  ["key",    "Lock key",     "PLA", [0,-30,-12], "#b8b8b8"]
];
checks = [ ["plate","coupon","clear"], ["key","coupon","clear"], ["key","plate","clear"] ];
report = [ ["plate w", D[0]], ["plate l", D[1]], ["slide to lock", a], ["socket length", attach_socket_len(attach_size)] ];

module pick(n){ if (part=="all" || part==n) children(); }
module plate() { attach_plate(attach_type, attach_size, screw_d, head_d, magnet, 0.15, hook_gap, stand_reach, stand_angle, stand_depth); }
module coupon() { difference() { translate([-cw/2, cy - cl/2, 0]) cube([cw, cl, ct]); attach_socket(attach_size); } }

if (probe == 0) {
  pick("coupon") coupon();
  pick("plate") plate();
  if (lock_key) pick("key") attach_key(attach_size);
} else {
  // the plate's path out of the coupon: lifted 0..6 mm (in -z) from the entry (1) or locked (2) position
  intersection() {
    coupon();
    for (dz=[0:0.5:6]) translate([0, probe == 1 ? -a : 0, -dz]) attach_core(attach_size);
  }
}
