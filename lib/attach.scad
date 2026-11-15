// Universal attachment plates: one socket in a host's back, many interchangeable plates.
// Use:  use <../../lib/attach.scad>
//
// How it works: the host has a shallow socket with undercut sides in its back face. A plate drops in
// with its side tabs through the socket's windows, then slides +Y by attach_slide() so the tabs lock
// under the lip (a bayonet slide). Hanging or standing loads push the plate further into the lock;
// the optional key fills the gap left behind so it cannot slide back out.
//
// Conventions (host frame): the host's back face is z=0 and its body is z>0. The plate is drawn in its
// LOCKED position, centred on the origin; it fills z=0..ATTACH_T and its features point to -z (the wall).
// +Y is up when the host hangs. The socket reaches from y=-l/2-slide to y=+l/2.

ATTACH_TYPES = ["none", "wall", "keyhole", "skadis", "hook", "magnet", "stand", "flat"];
ATTACH_SIZES = ["S", "M", "L"];
ATTACH_T   = 4.5;   // socket depth = plate core thickness
ATTACH_LIP = 2;     // lip thickness at the socket mouth
ATTACH_TAB = 2.5;   // tab reach under the lip, per side
ATTACH_N   = 2;     // tabs per side
ATTACH_CLR = 0.2;   // plate-to-socket clearance per face

function attach_dims(size) = size == "S" ? [30, 30] : size == "L" ? [60, 50] : [45, 40];   // [w (x), l (y)]
function attach_slide(size) = attach_dims(size)[1] / (2*ATTACH_N);                       // slide to lock
function attach_socket_len(size) = attach_dims(size)[1] + attach_slide(size);             // socket length (y)
function attach_socket_w(size) = attach_dims(size)[0] + 2*ATTACH_TAB;                      // socket width (x)
function attach_depth() = ATTACH_T;
// tab spans along y (locked position), as [y0, y1]
function attach_tabs(size) = let(l = attach_dims(size)[1], a = attach_slide(size))
    [for (k=[0:ATTACH_N-1]) [-l/2 + a + 2*a*k, -l/2 + 2*a + 2*a*k]];

// ---------- host side ----------
// cutter for the host: subtract it from the host body (back face z=0)
module attach_socket(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; a = attach_slide(size);
    translate([-w/2, -l/2 - a, -1]) cube([w, l + a, ATTACH_T + 1]);                               // mouth
    translate([-w/2 - ATTACH_TAB, -l/2 - a, ATTACH_LIP]) cube([w + 2*ATTACH_TAB, l + a, ATTACH_T - ATTACH_LIP]);  // undercut
    for (t=attach_tabs(size)) translate([-w/2 - ATTACH_TAB, t[0] - a, -1])                      // tab windows
        cube([w + 2*ATTACH_TAB, t[1] - t[0], ATTACH_LIP + 1.01]);
}

// ---------- plates ----------
// the interface every plate shares (core + tabs), locked position
module attach_core(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    translate([-w/2 + c, -l/2 + c, 0]) cube([w - 2*c, l - 2*c, ATTACH_T - c]);
    for (t=attach_tabs(size), s=[-1,1])
        translate([s > 0 ? w/2 - c - 0.01 : -w/2 - ATTACH_TAB + c, t[0] + c, ATTACH_LIP + c])   // joins the core
            cube([ATTACH_TAB + 0.01, t[1] - t[0] - 2*c, ATTACH_T - ATTACH_LIP - 2*c]);
}

// type: see ATTACH_TYPES.  Options:
//   screw_d / head_d   wall: wood-screw clearance hole and countersunk head (90°)
//   magnet = [d, h]     magnet: round magnets glued into pockets from the wall side
//   hook_gap           hook: thickness of the rod, rail, wire or door the hook goes over
//   stand_reach        stand: distance from the plate centre down to the host's bottom edge (+ = below)
//   stand_angle        stand: how far the host leans back from vertical
//   stand_depth        stand: how far behind the host the foot rests
module attach_plate(type="wall", size="M", screw_d=4.5, head_d=8.5, magnet=[10, 3], magnet_clr=0.15,
                    hook_gap=6, stand_reach=40, stand_angle=15, stand_depth=40, skadis_t=5) {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    difference() {
        union() {
            attach_core(size);
            if (type == "skadis") for (x=skadis_x(w)) translate([x, 0, 0]) skadis_hook(skadis_t);
            if (type == "hook") translate([0, l/2 - c, 0]) rail_hook(w - 2*c, hook_gap);
            if (type == "stand") for (s=[-1,1]) translate([s*(w/2 - c - 1.6), 0, 0])
                stand_fin(l - 2*c, stand_reach, stand_angle, stand_depth);
        }
        if (type == "wall") for (y=[-l/4, l/4]) translate([0, y, 0]) {
            translate([0,0,-1]) cylinder(d=screw_d, h=ATTACH_T + 2, $fn=32);
            translate([0,0,ATTACH_T - c - (head_d - screw_d)/2]) cylinder(d1=screw_d, d2=head_d + 0.4, h=(head_d - screw_d)/2 + 0.2 + 0.01, $fn=48);
            translate([0,0,ATTACH_T - c - 0.01]) cylinder(d=head_d + 0.4, h=1, $fn=48);
        }
        if (type == "keyhole") translate([0, -min(8, l/4), 0])
            keyhole_cut(head_d=9, neck_d=4.5, travel=min(10, l/2 - 4), neck_t=2, depth=ATTACH_T - c - 0.6);
        if (type == "magnet") for (p=magnet_xy(w, l, magnet[0])) translate([p[0], p[1], -1])
            cylinder(d=magnet[0] + 2*magnet_clr, h=magnet[1] + 1, $fn=48);
        if (type == "flat") for (i=[-3:3]) {
            translate([i*w/7 - 0.4, -l/2, -1]) cube([0.8, l, 1.5]);
            translate([-w/2, i*l/7 - 0.4, -1]) cube([w, 0.8, 1.5]);
        }
    }
}

// key that fills the slide gap after the plate is locked (push it into the socket mouth)
module attach_key(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; a = attach_slide(size); c = ATTACH_CLR;
    difference() {
        translate([-w/2 + c, -l/2 - a + c, 0]) cube([w - 2*c, a - 2*c, ATTACH_T - c]);
        translate([0, -l/2 - a/2, -1]) cylinder(d=min(6, a - 3), h=1.6, $fn=32);   // pry dimple
    }
}

// ---------- plate features ----------
function skadis_x(w) = w >= 44 ? [-20, 20] : [0];          // hook columns 40 mm apart (same row)
function magnet_xy(w, l, d) = let(dx = w/2 - d/2 - 3, dy = l/2 - d/2 - 3)
    (w >= 2*d + 10 && l >= 2*d + 10) ? [[-dx,-dy],[dx,-dy],[-dx,dy],[dx,dy]] : [[-dx,0],[dx,0]];

// IKEA Skådis hook: 4.6 wide tab through a 5 x 15 slot, latch drops behind the 5 mm board
module skadis_hook(board_t=5) {
    g = board_t + 0.3;                                       // board + play
    translate([-2.3, 0, 0]) rotate([90,0,90]) linear_extrude(4.6)
        polygon([[-2, 0.01], [5, 0.01], [5, -g], [5 - 1.5, -g - 3], [-8, -g - 3], [-8, -g], [-2, -g]]);
}
// hook over a rod / rail / door of thickness `gap`: an arm runs out from the plate's top strip, and a lip
// drops down behind the rod. Profile in (y, z); y=0 is the plate's top edge.
module rail_hook(w, gap=6, t=4, lip=10) {
    translate([-w/2, 0, 0]) rotate([90,0,90]) linear_extrude(w)
        polygon([[0, 0.01], [0, -gap - t], [-lip, -gap - t], [-lip, -gap], [-t, -gap], [-t, 0.01]]);
}
// kickstand fin: from the plate down to a foot resting on the floor behind the host
module stand_fin(l, reach, angle, depth, t=3.2) {
    fy = -reach + depth*tan(angle);                          // foot height (y) in the host frame
    translate([-t/2, 0, 0]) rotate([90,0,90]) linear_extrude(t)
        hull() { translate([-l/2, -0.01]) square([l, 0.02]); translate([fy, -depth]) circle(r=2.5, $fn=24); }
}
// keyhole cut from the wall side (z=0) into a plate
module keyhole_cut(head_d=9, neck_d=4.5, travel=10, neck_t=2, depth=4) {
    translate([0,0,-1]) cylinder(d=head_d, h=depth + 1, $fn=48);
    translate([0,0,-1]) hull() { cylinder(d=neck_d, h=neck_t + 1, $fn=32); translate([0,travel,0]) cylinder(d=neck_d, h=neck_t + 1, $fn=32); }
    translate([0,0,neck_t]) hull() { cylinder(d=head_d, h=depth - neck_t, $fn=48); translate([0,travel,0]) cylinder(d=head_d, h=depth - neck_t, $fn=48); }
}
