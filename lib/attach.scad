// Universal attachment plates: one socket in a host's back, many interchangeable plates.
// Use:  use <../../lib/attach.scad>
//
// How it works: push the plate straight into the socket and it snaps in. Each end of the plate (top and
// bottom) has two flexible arms with a bump on a 45° lead-in. The bumps bend the arms inward through the
// socket mouth and click into grooves in the socket's end walls. The plate's solid corners carry the load,
// not the arms, so hanging or standing cannot unsnap it. To remove it, lever it out with a flat
// screwdriver in the notch below the plate.
//
// Conventions (host frame): the host's back face is z=0 and its body is z>0. The plate is drawn seated,
// centred on the origin; it fills z=0..ATTACH_T and its features point to -z (the wall). +Y is up when the
// host hangs. The socket reaches from y=-l/2-ATTACH_NOTCH (pry notch) to y=+l/2.

ATTACH_TYPES = ["none", "wall", "keyhole", "skadis", "hook", "magnet", "stand", "flat", "roof"];
ATTACH_SIZES = ["S", "M", "L"];
ATTACH_T     = 4.5;   // socket depth = plate core thickness
ATTACH_CLR   = 0.2;   // plate-to-socket clearance per face
ATTACH_NOTCH = 3;     // pry notch below the plate
SNAP_LIP     = 1.5;   // socket mouth wall above the groove
SNAP_B       = 0.8;   // bump height (arm deflection on the way in = SNAP_B - ATTACH_CLR)
SNAP_ARM     = 1.2;   // arm thickness
SNAP_GAP     = 1.0;   // slot behind each arm
SNAP_CORNER  = 4;     // solid corners at each end of the arms (they carry the load)
SNAP_BUMP    = 6;     // bump length along each arm, at its free tip

function attach_dims(size) = size == "S" ? [30, 30] : size == "L" ? [60, 50] : [45, 40];   // [w (x), l (y)]
function attach_socket_len(size) = attach_dims(size)[1] + ATTACH_NOTCH;                   // socket length (y)
function attach_socket_w(size) = attach_dims(size)[0];                                     // socket width (x)
function attach_depth() = ATTACH_T;
function attach_strip() = ATTACH_CLR + SNAP_ARM + SNAP_GAP;    // end strips taken by the snap arms (keep features out)
// bump profile, (y outward, z): retention ramp, flat top, 45° lead-in towards +z (the way in)
function snap_z0() = SNAP_LIP + 0.05 + 0.35*SNAP_B;   // ramp foot just inside the groove: no preload when seated
function snap_z1() = snap_z0() + 0.35*SNAP_B + 0.4 + SNAP_B;
function snap_groove() = [SNAP_LIP, snap_z1() + ATTACH_CLR];   // groove z range in the socket

// ---------- host side ----------
// cutter for the host: subtract it from the host body (back face z=0)
module attach_socket(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; g = snap_groove();
    translate([-w/2, -l/2, -1]) cube([w, l, ATTACH_T + 1]);                                   // pocket
    for (s=[-1,1]) translate([-w/2 + SNAP_CORNER - 0.5, s > 0 ? l/2 - 0.01 : -l/2 - SNAP_B - 0.01, g[0]])
        cube([w - 2*SNAP_CORNER + 1, SNAP_B + 0.02, g[1] - g[0]]);                            // snap grooves
    translate([-4, -l/2 - ATTACH_NOTCH, -1]) cube([8, ATTACH_NOTCH + 0.01, 2 + 1]);         // pry notch
}

// ---------- plates ----------
// the interface every plate shares: core with snap arms, seated position
module attach_core(size="M") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    ya = l/2 - c;                                    // arm outer face
    xa = w/2 - SNAP_CORNER;                          // arms reach from the corners (x=±xa) to the centre
    difference() {
        translate([-w/2 + c, -l/2 + c, 0]) cube([w - 2*c, l - 2*c, ATTACH_T - c]);
        for (s=[-1,1]) mirror([0, s > 0 ? 0 : 1, 0]) {
            translate([-xa, ya - SNAP_ARM - SNAP_GAP, -1]) cube([2*xa, SNAP_GAP, ATTACH_T + 2]);   // slot behind the arms
            translate([-SNAP_GAP/2, ya - SNAP_ARM - SNAP_GAP, -1]) cube([SNAP_GAP, SNAP_ARM + SNAP_GAP + 1, ATTACH_T + 2]);  // split at the tips
        }
    }
    for (s=[-1,1], sx=[-1,1]) mirror([0, s > 0 ? 0 : 1, 0]) mirror([sx > 0 ? 0 : 1, 0, 0])
        translate([SNAP_GAP/2 + 0.3, ya - 0.01, 0]) rotate([90,0,90]) linear_extrude(min(SNAP_BUMP, xa - SNAP_GAP/2 - 2))
            polygon([[0, snap_z0() - 0.35*SNAP_B], [SNAP_B, snap_z0()], [SNAP_B, snap_z1() - SNAP_B], [0, snap_z1()]]);
}

// type: see ATTACH_TYPES.  Options:
//   screw_d / head_d   wall: wood-screw clearance hole and countersunk head (90°)
//   magnet = [d, h]     magnet: round magnets glued into pockets from the wall side
//   hook_gap           hook: thickness of the rod, rail, wire or door the hook goes over
//   stand_reach        stand: distance from the plate centre down to the host's bottom edge (+ = below)
//   stand_angle        stand: how far the host leans back from vertical
//   stand_depth        stand: how far behind the host the foot rests
//   roof_reach         roof: plate centre up to the ceiling (must clear the host's top edge)
//   roof_angle         roof: angle between the host and the ceiling (90 = hangs straight down)
//   roof_depth         roof: ceiling flange depth (front to back)
module attach_plate(type="wall", size="M", screw_d=4.5, head_d=8.5, magnet=[10, 3], magnet_clr=0.15,
                    hook_gap=6, stand_reach=40, stand_angle=15, stand_depth=40, skadis_t=5,
                    roof_reach=60, roof_angle=90, roof_depth=40) {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    difference() {
        union() {
            attach_core(size);
            if (type == "skadis") for (x=skadis_x(w)) translate([x, 0, 0]) skadis_hook(skadis_t);
            if (type == "hook") translate([0, l/2 - attach_strip(), 0]) rail_hook(w - 2*c, hook_gap);
            if (type == "stand") for (s=[-1,1]) translate([s*(w/2 - c - 1.6), 0, 0])        // in the solid corners
                stand_fin(l - 2*c, stand_reach, stand_angle, stand_depth);
            if (type == "roof") roof_bracket(w - 2*c, l, roof_reach, roof_angle, roof_depth, screw_d, head_d);
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

// ---------- host helpers (use these in a project instead of placing sockets by hand) ----------
// per-type options as one list, so hosts can pass them on: build it with attach_opts(...)
function attach_opts(screw_d=4.5, head_d=8.5, magnet=[10, 3], hook_gap=6, stand_angle=15, stand_depth=40,
                     roof_gap=10, roof_angle=90, roof_depth=40) =
    [screw_d, head_d, magnet, hook_gap, stand_angle, stand_depth, roof_gap, roof_angle, roof_depth];
// x positions for `count` sockets spread over 60% of `span` around `centre`. Skådis plates stay on the 40 mm grid.
// avoid = [x, half width]: shift the whole row so no socket centre lies within that zone (dowels, screws ...).
function attach_xs(count, span, type="wall", centre=0, avoid=undef) = let(
    sp0 = count > 1 ? 0.6*span/(count - 1) : 0,
    sp  = type == "skadis" ? max(40, round(sp0/40)*40) : sp0,
    x0  = [for (i=[0:1:count-1]) centre + (i - (count - 1)/2)*sp],
    sh  = is_undef(avoid) ? [] : [for (x=x0) if (abs(x - avoid[0]) < avoid[1]) (x >= avoid[0] ? 1 : -1)*(avoid[1] - abs(x - avoid[0]))])
    [for (x=x0) x + (len(sh) > 0 ? sh[0] : 0)];
// plate centre y that centres socket + pry notch on a host whose middle is y_mid
function attach_y(y_mid) = y_mid + ATTACH_NOTCH/2;
// does a socket of this size fit a host `height` tall?  (use in an assert with attach_fit_msg)
function attach_fits(size, height, margin=3) = attach_socket_len(size) <= height - margin;
function attach_fit_msg(size, height) = str("attach_size ", size, " needs ", attach_socket_len(size), " mm of height; this host has ", height, " mm. Choose a smaller size.");
// row for the project's `parts` table
function attach_print_tag(type) = (type == "skadis" || type == "hook" || type == "roof") ? "print=auto" : "print=x180";
function attach_parts_row(type, count, pull=[0, 0, -50], colour="#4d6170") =
    ["attach", "Attachment plate", "PLA", pull, colour, str("pieces=", count), attach_print_tag(type)];
// cutter: all sockets of a host (subtract from the host; back face z=0)
module attach_sockets(type, size, xs, y) { if (type != "none") for (x=xs) translate([x, y, 0]) attach_socket(size); }
// all plates of a host, seated. y_bottom / y_top = the host's lowest / highest edge (for stand and roof plates)
module attach_plates(type, size, xs, y, opts=undef, y_bottom=undef, y_top=undef) {
    o = is_undef(opts) ? attach_opts() : opts;
    if (type != "none") for (x=xs) translate([x, y, 0])
        attach_plate(type, size, screw_d=o[0], head_d=o[1], magnet=o[2], hook_gap=o[3],
                     stand_reach=is_undef(y_bottom) ? 40 : y - y_bottom, stand_angle=o[4], stand_depth=o[5],
                     roof_reach=is_undef(y_top) ? 60 : y_top - y + o[6], roof_angle=o[7], roof_depth=o[8]);
}

// ---------- plate features ----------
// ceiling bracket: a stem rises behind the host from the plate to a ceiling flange (4 countersunk screws, room
// side). The stem joins only the plate's middle, with 0.6 mm clearance over the snap arms so they can flex.
// The flange top (ceiling contact) is at y = reach; `angle` is between the host and the ceiling.
module roof_bracket(w, l, reach=60, angle=90, depth=40, screw_d=4.5, head_d=8.5, st=5, ft=5, tab=10) {
    sp = attach_strip();
    jz = -0.6 - st/2;                                            // stem centre line (z)
    module at_joint() { translate([0, reach, jz]) rotate([90 - angle, 0, 0]) children(); }   // flange frame
    FW = w + 2*tab;
    translate([-w/2, -l/2 + sp + 0.5, -0.61]) cube([w, l - 2*sp - 1, 0.62]);                // pad onto the core
    translate([-w/2, -l/2 + sp + 0.5, -0.6 - st]) cube([w, reach - ft + l/2 - sp - 0.5 + 0.01, st]);  // stem
    difference() {
        at_joint() translate([-FW/2, -ft, -depth/2]) cube([FW, ft, depth]);                  // flange
        for (x=[-1,1], z=[-1,1]) at_joint() translate([x*(w/2 + tab/2), 0, z*(depth/2 - 6)]) rotate([90,0,0]) {
            translate([0,0,-1]) cylinder(d=screw_d, h=ft + 2, $fn=32);
            translate([0,0,ft - (head_d - screw_d)/2 - 0.01]) cylinder(d1=screw_d, d2=head_d + 0.4, h=(head_d - screw_d)/2 + 0.02, $fn=48);
        }
    }
    for (x=[-w/2, w/2 - 3]) hull() {                             // gussets, behind the stem only
        translate([x, reach - ft - 18, -0.6 - st]) cube([3, 18, st]);
        at_joint() translate([x, -ft, -depth/2 + 1]) cube([3, 0.01, depth/2 - 1 - st/2]);
    }
}

function skadis_x(w) = w >= 44 ? [-20, 20] : [0];          // hook columns 40 mm apart (same row)
function magnet_xy(w, l, d) = let(dx = w/2 - d/2 - 3, dy = l/2 - attach_strip() - d/2 - 1.5)
    (w >= 2*d + 10 && dy >= d/2 + 1) ? [[-dx,-dy],[dx,-dy],[-dx,dy],[dx,dy]] : [[-dx,0],[dx,0]];

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
