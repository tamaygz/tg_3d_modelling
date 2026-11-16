// Attachment plates: test coupon + one plate + lock key
// Print the coupon and a plate first to check the snap fit, then use the same plate on any project.
include <../../lib/core.scad>
use <../../lib/attach.scad>

part = "all";                    // which part to export ("all" = assembly)

/* [Plate] */
// what the plate mounts to
attach_type = "wall"; // [wall, keyhole, skadis, hook, magnet, stand, flat, roof, slide, fin]
// plate size: S 30x30, M 45x40, L 60x50 mm
attach_size = "M"; // [S, M, L]
// ball joint between the host and the plate: turn and tilt freely, the lock ring clamps it
attach_joint = "none"; // [none, ball]

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
// slide: the track runs horizontally (slide the host along) or vertically (drop the host onto it)
slide_axis = "horizontal"; // [horizontal, vertical]
// slide: track length (0 = a length that suits the plate)
track_len = 0; // [0:5:250]
// fin: how far the blade reaches, its width and thickness
fin_len = 120; // [30:5:250]
fin_w = 80; // [30:5:240]
fin_t = 4; // [2:0.5:10]
// ball joint: ball diameter
ball_d = 16; // [12:1:24]

/* [Hidden] */
// probe for checks: 0 = off; 1 = half way in (arms must bend ~0.6 mm); 2 = seated (must be clear); 3 = seated, pulled back 0.4 mm (bumps must catch); 4 = ball at the mouth of the cup
probe = 0;
D  = attach_dims(attach_size);
cw = attach_socket_w(attach_size) + 12;          // coupon width
cl = attach_socket_len(attach_size) + 12;        // coupon length
ct = attach_depth() + 3;                         // coupon thickness
cy = -3/2;                                       // coupon centre y (the socket has a pry notch below)

a_opts = attach_opts(screw_d, head_d, magnet, hook_gap, stand_angle, stand_depth, roof_reach - D[1]/2, roof_angle, roof_depth,
                     slide_axis, track_len, fin_len, fin_w, fin_t, ball_d);
rows = attach_rows(attach_type, 1, attach_joint, [0,0,-25], COL_FIXTURE, opts=a_opts);
parts = [
  ["coupon", "Test coupon",  "PLA", [0,0,25],  COL_WOOD, "print=x180"],
  ["plate",  "Attachment plate", "PLA", [0,0,-25], COL_FIXTURE, rows[0][6]],
  each [for (i=[1:1:len(rows)-1]) rows[i]]
];
checks = concat([["plate", "coupon", "clear"]],
  attach_type == "slide" || attach_type == "fin" ? [["attach_track", "plate", ">=", 0]] : [],
  attach_joint == "ball" ? [["attach_ball", "coupon", "clear"], ["attach_ball", "attach_joint", "clear"], ["plate", "attach_joint", "clear"], ["attach_ring", "attach_ball", ">=", 0]] : []);
report = [ ["plate w", D[0]], ["plate l", D[1]], ["socket length", attach_socket_len(attach_size)],
           ["ball joint: cup strain %", ball_strain(ball_d)*100], ["ball joint: tilt each way (deg)", ball_tilt(ball_d)],
           ["ball joint: stand-off", -ball_joint_back(attach_size, ball_d)], ["slide: stand-off", slide_standoff()] ];

zj = attach_joint == "ball" ? ball_joint_back(attach_size, ball_d) : 0;      // with a joint the plate sits on the adapter
module plate() {
  translate([0, 0, zj]) attach_plate(attach_type, attach_size, screw_d=screw_d, head_d=head_d, magnet=magnet, hook_gap=hook_gap,
               stand_reach=stand_reach, stand_angle=stand_angle, stand_depth=stand_depth,
               roof_reach=roof_reach, roof_angle=roof_angle, roof_depth=roof_depth, slide_axis=slide_axis);
}
module coupon() { difference() { translate([-cw/2, cy - cl/2, 0]) cube([cw, cl, ct]); attach_socket(attach_size); } }

if (probe == 0) {
  pick("coupon") coupon();
  pick("plate") plate();
  attach_all(part == "plate" ? "none" : part, attach_type, attach_size, [0], 0, a_opts, joint=attach_joint, skip_plates=true);   // track / fin / ball joint parts
} else if (probe == 4) {
  // ball joint: the ball at the mouth of the cup; the overlap is how far the petals must bend (ball_petal_bend)
  intersection() { ball_adapter(attach_size, ball_d); translate([0, 0, ball_centre_z(ball_d) + ball_d/2*sin(20)]) sphere(d=ball_d, $fn=64); }
} else {
  intersection() { coupon(); translate([0, 0, probe == 1 ? -2.3 : probe == 3 ? -0.4 : 0]) attach_core(attach_size); }
}
