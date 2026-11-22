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

use <thread.scad>

ATTACH_TYPES = ["none", "wall", "keyhole", "skadis", "hook", "magnet", "stand", "flat", "roof", "slide", "fin", "clamp", "pipe"];
PIPE_AXES = ["horizontal", "vertical"];
ATTACH_JOINTS = ["none", "ball"];        // optional ball joint between the host and the plate (any type)
SLIDE_AXES    = ["horizontal", "vertical"];
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
//   clamp_gap          clamp: opening between the jaws = thickest desk top, shelf or bar it grips
//   clamp_reach        clamp: from the clamp's back (spine) to the edge of the screw hole = how far it grips in
//   clamp_screw        clamp: printed screw size (THREAD_SIZES in thread.scad; M10..M20 are sensible)
//   pipe_d             pipe: outer diameter of the pipe, tube, rail or conduit the claw snaps onto
//   pipe_axis          pipe: the pipe runs "horizontal" (along the plate's width) or "vertical"
module attach_plate(type="wall", size="M", screw_d=4.5, head_d=8.5, magnet=[10, 3], magnet_clr=0.15,
                    hook_gap=6, stand_reach=40, stand_angle=15, stand_depth=40, skadis_t=5,
                    roof_reach=60, roof_angle=90, roof_depth=40, slide_axis="horizontal",
                    clamp_gap=40, clamp_reach=25, clamp_screw="M16", pipe_d=20, pipe_axis="horizontal") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR;
    if (type == "slide" || type == "fin") slide_plate(size, type == "fin" ? "horizontal" : slide_axis);
    else if (type == "clamp") { attach_core(size); clamp_frame(size, clamp_gap, clamp_reach, clamp_screw); }
    else if (type == "pipe") { attach_core(size); pipe_claw(size, pipe_d, pipe_axis); }
    else difference() {
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
                     roof_gap=10, roof_angle=90, roof_depth=40,
                     slide_axis="horizontal", track_len=0, fin_len=120, fin_w=80, fin_t=4, ball_d=16,
                     clamp_gap=40, clamp_reach=25, clamp_screw="M16", pipe_d=20, pipe_axis="horizontal") =
    [screw_d, head_d, magnet, hook_gap, stand_angle, stand_depth, roof_gap, roof_angle, roof_depth,
     slide_axis, track_len, fin_len, fin_w, fin_t, ball_d, clamp_gap, clamp_reach, clamp_screw, pipe_d, pipe_axis];
// which face of the host a type mounts on: the fin hangs under the host, everything else is on its back
function attach_face(type) = type == "fin" ? "bottom" : "back";
// x positions for up to `count` sockets spread over 60% of `span` around `centre`. Skådis plates stay on the 40 mm
// grid. With `size` given, sockets keep 6 mm between them and the count drops to what fits the span, so use
// len(attach_xs(...)) as the real count. avoid = [x, half width]: shift the row so no socket centre lies in that zone.
function attach_xs(count, span, type="wall", centre=0, avoid=undef, size=undef) = let(
    pitch = is_undef(size) ? 0 : attach_socket_w(size) + 6,
    n   = is_undef(size) ? count : max(1, min(count, floor((span - 6)/pitch))),
    sp0 = n > 1 ? max(pitch, 0.6*span/(n - 1)) : 0,
    sp1 = type == "skadis" ? max(40, round(sp0/40)*40) : sp0,
    sp  = n > 1 && !is_undef(size) ? min(sp1, (span - pitch)/(n - 1)) : sp1,
    x0  = [for (i=[0:1:n-1]) centre + (i - (n - 1)/2)*sp],
    sh  = is_undef(avoid) ? [] : [for (x=x0) if (abs(x - avoid[0]) < avoid[1]) (x >= avoid[0] ? 1 : -1)*(avoid[1] - abs(x - avoid[0]))])
    [for (x=x0) x + (len(sh) > 0 ? sh[0] : 0)];
// plate centre y that centres socket + pry notch on a host whose middle is y_mid
function attach_y(y_mid) = y_mid + ATTACH_NOTCH/2;
// does a socket of this size fit a host `height` tall?
// thickness (optional) = host thickness behind the socket: needs the socket depth plus a 1 mm floor
function attach_fits(size, height, margin=3, thickness=undef) =
    attach_socket_len(size) <= height - margin + 0.001 && (is_undef(thickness) || thickness >= ATTACH_T + 1 - 0.001);
// What actually fits: the type and size asked for if the host is large enough, otherwise the next smaller plate
// size, otherwise no attachment at all. Returns [type, size, note]; note is "" or a sentence saying what was
// changed. Use the returned type and size everywhere, and show the note with attach_note(). A host should never
// stop with an error because an attachment does not fit.
function attach_smaller(size) = size == "L" ? "M" : size == "M" ? "S" : "";
function attach_fit(type, size, height, margin=3, thickness=undef) =
    type == "none" ? ["none", size, ""] :
    !is_undef(thickness) && thickness < ATTACH_T + 1 - 0.001 ?
        ["none", size, str("attachment left out: sockets need a host at least ", ATTACH_T + 1, " mm thick, this one is ", thickness, " mm")] :
    attach_fits(size, height, margin) ? [type, size, ""] :
    attach_smaller(size) == "" ?
        ["none", size, str("attachment left out: even the smallest plate (S) needs ", attach_socket_len("S") + margin, " mm of height, this host has ", height, " mm")] :
    let(r = attach_fit(type, attach_smaller(size), height, margin, thickness))
        [r[0], r[1], r[0] == "none" ? r[2] : str("attachment plate size reduced from ", size, " to ", r[1], " to fit a height of ", height, " mm")];
// prints a note as a warning in the render log (nothing if the note is empty)
module attach_note(note) { if (note != "") echo(str("WARNING: ", note)); }
// What actually fits: the type and size asked for if the host is large enough, otherwise the next smaller plate
// size, otherwise no attachment at all. Returns [type, size, note]; note is "" or a sentence saying what was
// changed. Use the returned type and size everywhere, and show the note with attach_note(). A host should never
// stop with an error because an attachment does not fit.
function attach_smaller(size) = size == "L" ? "M" : size == "M" ? "S" : "";
function attach_fit(type, size, height, margin=3, thickness=undef) =
    type == "none" ? ["none", size, ""] :
    !is_undef(thickness) && thickness < ATTACH_T + 1 - 0.001 ?
        ["none", size, str("attachment left out: sockets need a host at least ", ATTACH_T + 1, " mm thick, this one is ", thickness, " mm")] :
    attach_fits(size, height, margin) ? [type, size, ""] :
    attach_smaller(size) == "" ?
        ["none", size, str("attachment left out: even the smallest plate (S) needs ", attach_socket_len("S") + margin, " mm of height, this host has ", height, " mm")] :
    let(r = attach_fit(type, attach_smaller(size), height, margin, thickness))
        [r[0], r[1], r[0] == "none" ? r[2] : str("attachment plate size reduced from ", size, " to ", r[1], " to fit a height of ", height, " mm")];
// prints a note as a warning in the render log (nothing if the note is empty)
module attach_note(note) { if (note != "") echo(str("WARNING: ", note)); }
function attach_fit_msg(size, height, thickness=undef) =
    !is_undef(thickness) && thickness < ATTACH_T + 1
        ? str("attachment sockets need a host at least ", ATTACH_T + 1, " mm thick; this one is ", thickness, " mm. Make it thicker or set attach_type to none.")
        : str("attach_size ", size, " needs ", attach_socket_len(size), " mm of height; this host has ", height, " mm. Choose a smaller size.");
// row for the project's `parts` table
function attach_print_tag(type) = (type == "skadis" || type == "hook" || type == "roof") ? "print=auto" : "print=x180";
// cutter: all sockets of a host (subtract from the host; back face z=0)
module attach_sockets(type, size, xs, y) { if (type != "none") for (x=xs) translate([x, y, 0]) attach_socket(size); }
// all plates of a host, seated. y_bottom / y_top = the host's lowest / highest edge (for stand and roof plates)
module attach_plates(type, size, xs, y, opts=undef, y_bottom=undef, y_top=undef) {
    o = is_undef(opts) ? attach_opts() : opts;
    if (type != "none") for (x=xs) translate([x, y, 0])
        attach_plate(type, size, screw_d=o[0], head_d=o[1], magnet=o[2], hook_gap=o[3],
                     stand_reach=is_undef(y_bottom) ? 40 : y - y_bottom, stand_angle=o[4], stand_depth=o[5],
                     roof_reach=is_undef(y_top) ? 60 : y_top - y + o[6], roof_angle=o[7], roof_depth=o[8], slide_axis=o[9],
                     clamp_gap=o[15], clamp_reach=o[16], clamp_screw=o[17], pipe_d=o[18], pipe_axis=o[19]);
}

// ---------- everything that hangs on the sockets, in one call ----------
// Part ids (all optional except "attach"): "attach" plates, "attach_track" slide track or fin, and with a ball
// joint "attach_ball" ball plates, "attach_joint" cup adapters, "attach_ring" lock rings.
// attach_rows() gives their rows for the `parts` table: use  parts = concat([... your rows ...], attach_rows(...));
// Rows of parts that only exist with some settings (track, fin, ball joint) are left out when they are not used;
// the build tools set $all_parts = true to get every row, so the configurators can offer and draw them.
// frame = "flat" for a host modelled lying on its back (plaques; also a socket under a floor), "back" for a host
// modelled upright with the sockets in a vertical back wall (containers): it only sets the print orientation.
function attach_rows(type, count, joint="none", pull=[0, 0, -50], colour="#4d6170", frame="flat", opts=undef) = let(
    o = is_undef(opts) ? attach_opts() : opts,
    up = frame == "back" ? "print=x90" : "print=x180",                  // wall side up
    down = frame == "back" ? "print=x270" : "print=x0",                 // wall side on the bed
    plate_tag = (type == "skadis" || type == "hook" || type == "roof" || type == "clamp" || type == "pipe") ? "print=auto" : up,
    n_track = type == "fin" || (type == "slide" && o[9] == "horizontal") ? 1 : count,
    all = !is_undef($all_parts) && $all_parts)          // the tools ask for every part a model can have
    concat(
        [["attach", "Attachment plate", "PLA", pull, colour, str("pieces=", count), plate_tag]],
        type == "slide" || (all && type != "fin") ? [["attach_track", type == "slide" ? "Slide track" : "Slide track / fin", "PLA / PETG", pull*1.5, "#6f8494", str("pieces=", n_track), down]] : [],
        type == "fin" ? [["attach_track", "Fin with slide track", "PETG", pull*1.5, "#6f8494", "pieces=1", "print=auto"]] : [],
        type == "clamp" || all ? [["attach_screw", "Clamp screw", "PETG", pull*1.2, "#2f3a44", str("pieces=", count), "print=auto"]] : [],
        (type != "none" && joint == "ball") || all ? [
            ["attach_ball", "Ball plate", "PETG", pull*0.3, "#8fa3b0", str("pieces=", count), up],
            ["attach_joint", "Ball joint adapter", "PETG", pull*0.6, "#5b7282", str("pieces=", count), down],
            ["attach_ring", "Ball joint lock ring", "PETG", pull*0.45, "#c9a13b", str("pieces=", count), "print=auto"]] : []);
// Draws all of it, seated on a host whose back face is z = 0 (sockets at xs, y). `part` = the project's part
// variable ("all" or one id): only that part is drawn, so a project needs just this one line.
module attach_all(part, type, size, xs, y, opts=undef, y_bottom=undef, y_top=undef, joint="none", skip_plates=false) {
    o = is_undef(opts) ? attach_opts() : opts;
    ball = joint == "ball" && type != "none";
    zj = ball ? ball_joint_back(size, o[14]) : 0;                       // the plates sit on the adapters instead of the host
    module sel(id, col) { if (part == "all" || part == id) color(col) children(); }
    if (type != "none") {
        if (!skip_plates) sel("attach", "#4d6170") translate([0, 0, zj]) attach_plates(type, size, xs, y, o, y_bottom, y_top);
        if (type == "clamp") sel("attach_screw", "#2f3a44") translate([0, 0, zj]) for (x=xs) translate([x, y, 0]) clamp_screw_seated(size, o[15], o[16], o[17]);
        if (type == "slide") sel("attach_track", "#6f8494") translate([0, 0, zj]) slide_tracks(size, xs, y, o[9], o[10], o[0], o[1]);
        if (type == "fin") sel("attach_track", "#6f8494") translate([(min(xs) + max(xs))/2, y, zj]) slide_fin(o[12], o[11], o[13]);
        if (ball) for (x=xs) translate([x, y, 0]) {
            sel("attach_ball", "#8fa3b0") ball_plate(size, o[14]);
            sel("attach_joint", "#5b7282") ball_adapter(size, o[14]);
            sel("attach_ring", "#c9a13b") ball_ring(size, o[14]);
        }
    }
}

// a box with all its edges chamfered by c (parts that stand out from a host: no sharp corners, easier to print)
module attach_chamfer_box(size, c=1) {
    hull() {
        translate([c, c, 0]) cube(size - [2*c, 2*c, 0]);
        translate([c, 0, c]) cube(size - [2*c, 0, 2*c]);
        translate([0, c, c]) cube(size - [0, 2*c, 2*c]);
    }
}

// ---------- slide track ----------
// A dovetail track with rounded edges is screwed to the wall; the plate has the matching channel and the host
// slides onto the track. horizontal: the channel runs through the plate from side to side, one long track carries
// all plates and the host can be slid along it. vertical: the channel is open at the bottom and closed at the top,
// the host is dropped onto a short track per plate and hangs on its upper end.
// The same plate rides on the fin (type "fin"): a track with a long blade, for a host that is anchored from below
// (the blade goes between two sofa cushions, into a slot, into the ground).
SLIDE_W   = 16;      // track width on the host side (the wide side of the dovetail)
SLIDE_N   = 10;      // track width on the wall
SLIDE_H   = 4.5;     // track height
SLIDE_R   = 0.8;     // rounding of the track's edges
SLIDE_CLR = 0.25;    // play between track and channel, per side
SLIDE_GAP = 0.5;     // air between the plate and the wall
function slide_standoff() = SLIDE_H + SLIDE_GAP;                         // wall plane below the host's back face
// cross-section, wall on y = 0, track up to y = SLIDE_H; grow = play (for the channel)
module slide_profile_2d(grow=0) {
    offset(r=SLIDE_R, $fn=24) offset(delta=-SLIDE_R + grow)
        polygon([[-SLIDE_N/2, 0], [SLIDE_N/2, 0], [SLIDE_W/2, SLIDE_H], [-SLIDE_W/2, SLIDE_H]]);
}
module slide_plate(size="M", axis="horizontal") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR; sp = attach_strip();
    zw = -slide_standoff();                                              // wall plane
    bw = w - 2*c; bl = l - 2*sp - 1;                                     // carriage block, clear of the snap arms
    assert(axis == "horizontal" ? bl >= SLIDE_W + 2*SLIDE_CLR + 5 : bw >= SLIDE_W + 2*SLIDE_CLR + 5, "slide plate: this plate size is too small for the track");
    attach_core(size);
    difference() {
        translate([-bw/2, -bl/2, zw + 0.2]) attach_chamfer_box([bw, bl, -zw - 0.2 + 1.2], 1);        // chamfered; its top is inside the core
        if (axis == "horizontal") translate([0, 0, zw]) rotate([90, 0, 90]) linear_extrude(w + 2, center=true) union() {
            slide_profile_2d(SLIDE_CLR); translate([-SLIDE_N/2 - SLIDE_CLR, -1]) square([SLIDE_N + 2*SLIDE_CLR, 1 + SLIDE_R]);
        }
        else translate([0, slide_stop_y(size), zw]) rotate([90, 0, 0]) linear_extrude(l) union() {     // open at the bottom, closed at the top
            slide_profile_2d(SLIDE_CLR); translate([-SLIDE_N/2 - SLIDE_CLR, -1]) square([SLIDE_N + 2*SLIDE_CLR, 1 + SLIDE_R]);
        }
    }
}
function slide_stop_y(size) = attach_dims(size)[1]/2 - attach_strip() - 4;        // upper end of a vertical channel
// a track of length L along X, wall face on z = 0, with countersunk screw holes
module slide_track(L, screw_d=4.5, head_d=8.5) {
    n = max(2, floor(L/60) + 1); e = min(12, L/4);
    difference() {
        intersection() {
            rotate([90, 0, 90]) linear_extrude(L, center=true) slide_profile_2d();
            linear_extrude(SLIDE_H + 1) offset(r=2.5, $fn=24) square([L - 5, SLIDE_W - 5], center=true);     // rounded ends
        }
        for (i=[0:n-1]) translate([-L/2 + e + i*(L - 2*e)/(n - 1), 0, 0]) {
            translate([0, 0, -1]) cylinder(d=screw_d, h=SLIDE_H + 2, $fn=32);
            translate([0, 0, SLIDE_H - (head_d - screw_d)/2]) cylinder(d1=screw_d, d2=head_d + 0.4, h=(head_d - screw_d)/2 + 0.01, $fn=48);
        }
    }
}
function slide_track_len(size, xs, axis, track_len) = track_len > 0 ? track_len :
    axis == "horizontal" ? max(xs) - min(xs) + attach_dims(size)[0] + 60 : attach_dims(size)[1] + 20;
// the track(s) of a host, seated in its plates (host back face z = 0)
module slide_tracks(size, xs, y, axis="horizontal", track_len=0, screw_d=4.5, head_d=8.5) {
    L = slide_track_len(size, xs, axis, track_len);
    if (axis == "horizontal") translate([(min(xs) + max(xs))/2, y, -slide_standoff()]) slide_track(L, screw_d, head_d);
    else for (x=xs) translate([x, y + slide_stop_y(size) - SLIDE_CLR - L/2, -slide_standoff()]) rotate(90) slide_track(L, screw_d, head_d);
}
// fin: a track of length w with a blade `len` long and t thick standing on its wall side. Drawn seated: the
// track's wall plane at z = -slide_standoff(), the blade pointing to -z (away from the host).
module slide_fin(w=80, len=120, t=4, base=3) {
    z0 = -slide_standoff();
    translate([0, 0, z0]) slide_track_plain(w);
    translate([-w/2, -(SLIDE_N + 8)/2, z0 - base]) attach_chamfer_box([w, SLIDE_N + 8, base + 0.01], 0.8);   // the host rests on this
    hull() {                                                                                          // blade with rounded lower corners
        translate([-w/2, -t/2, z0 - base - 1]) cube([w, t, 1]);
        for (s=[-1, 1]) translate([s*(w/2 - 8), 0, z0 - base - len + 8]) rotate([90, 0, 0]) cylinder(r=8, h=t, center=true, $fn=32);
    }
    for (s=[-1, 1]) hull() {                                                                          // fillets blade / base
        translate([-w/2, s*(SLIDE_N + 8)/2 - (s > 0 ? 0.5 : 0), z0 - base]) cube([w, 0.5, 0.01]);
        translate([-w/2, -0.25, z0 - base - (SLIDE_N + 8)/2 + t/2]) cube([w, 0.5, 0.01]);
    }
}
module slide_track_plain(L) {
    intersection() {
        rotate([90, 0, 90]) linear_extrude(L, center=true) slide_profile_2d();
        linear_extrude(SLIDE_H + 1) offset(r=2.5, $fn=24) square([L - 5, SLIDE_W - 5], center=true);
    }
}

// ---------- ball joint ----------
// For any attachment type: the host carries a ball (a plate with a ball on a neck in its socket), the plate of
// the chosen type snaps into an adapter that grips the ball with a slotted cup. The host can be turned and tilted
// freely; pushing the lock ring down the tapered cup clamps it in place.
// Assembly: ring over the ball onto the neck, press the ball into the cup, push the ring towards the adapter.
BALL_LAT    = 20;      // the cup closes this many degrees past the ball's equator (what holds the ball)
BALL_WALL   = 1.5;     // cup wall at the equator
BALL_PETALS = 6;       // slots in the cup
BALL_SLOT   = 1.2;     // slot width
BALL_TAPER  = 0.6;     // the cup's outside grows by this much from its mouth to its foot (the ring wedges on it)
BALL_MAX_STRAIN = 0.02;
function ball_neck_d(d) = d*0.5;
function ball_centre_z(d) = -(d/2 + 6);                                   // ball centre below the host's back face
function ball_cup_foot_z(d) = ball_centre_z(d) - d/2 - 1.5;               // top of the adapter block (z)
function ball_joint_back(size, d) = ball_cup_foot_z(d) - (ATTACH_T + 1.5); // the adapter's back face = new mounting plane
// how far the petals bend when the ball is pressed in, their length and the strain that causes (must stay under 2%)
function ball_petal_bend(d) = d/2*(1 - cos(BALL_LAT));
function ball_petal_len(d) = d/2*(sin(BALL_LAT) + 0.85);                  // from the mouth down to the end of the slots
function ball_strain(d) = 1.5*(BALL_WALL + 0.25)*ball_petal_bend(d)/pow(ball_petal_len(d), 2);
// largest tilt from straight before the neck touches the cup's mouth
function ball_tilt(d) = 90 - BALL_LAT - asin(ball_neck_d(d)/d) - 3;
module ball_plate(size="M", d=16) {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; nd = ball_neck_d(d); zc = ball_centre_z(d);
    root = min(w, l) - 2*attach_strip() - 6;                              // foot of the neck, clear of the snap arms
    attach_core(size);
    hull() { translate([0, 0, -0.6]) cylinder(d=root, h=0.61, $fn=48); translate([0, 0, -3]) cylinder(d=nd, h=0.1, $fn=48); }
    translate([0, 0, zc]) cylinder(d=nd, h=-zc - 2.9, $fn=48);
    translate([0, 0, zc]) sphere(d=d, $fn=64);
    translate([0, 0, zc]) cylinder(d1=d*cos(45), d2=nd, h=d/2*sin(45) + (d*cos(45) - nd)/2, $fn=48);   // 45 degree shoulder: prints ball-up
}
function _ball_cup_r(d, z) = let(zm = ball_centre_z(d) + d/2*sin(BALL_LAT), zf = ball_cup_foot_z(d))          // outside radius of the cup at z
    d/2 + BALL_WALL + 0.4 + BALL_TAPER*(zm - z)/(zm - zf);
module ball_adapter(size="M", d=16) {
    assert(ball_strain(d) <= BALL_MAX_STRAIN, str("ball joint: a ", d, " mm ball would bend the cup by ", ball_strain(d)*100, "% (limit 2%)"));
    w = attach_dims(size)[0]; l = attach_dims(size)[1];
    zc = ball_centre_z(d); zf = ball_cup_foot_z(d); zm = zc + d/2*sin(BALL_LAT); zb = ball_joint_back(size, d);
    difference() {
        union() {
            translate([-w/2 - 4, -l/2 - ATTACH_NOTCH - 4, zb]) attach_chamfer_box([w + 8, l + ATTACH_NOTCH + 8, zf - zb], 1);    // block with the socket
            translate([0, 0, zf - 0.01]) cylinder(r1=_ball_cup_r(d, zf), r2=_ball_cup_r(d, zm), h=zm - zf + 0.01, $fn=72);
        }
        translate([0, 0, zc]) sphere(d=d + 0.1, $fn=64);
        for (i=[0:BALL_PETALS-1]) rotate(i*360/BALL_PETALS + 30) translate([0, -BALL_SLOT/2, zc - 0.85*d/2]) cube([d, BALL_SLOT, d]);
        translate([0, 0, zb]) attach_socket(size);
    }
}
// lock ring, drawn resting on the cup near its mouth, where it just touches: pushing it towards the adapter
// wedges it onto the taper and squeezes the cup (about 0.05 mm per mm of travel)
module ball_ring(size="M", d=16, h=5) {
    zc = ball_centre_z(d); zm = zc + d/2*sin(BALL_LAT); z1 = zm - 1; z0 = z1 - h;
    translate([0, 0, z0]) difference() {
        cylinder(r=_ball_cup_r(d, z0) + 2.4, h=h, $fn=72);
        translate([0, 0, -0.01]) cylinder(r1=_ball_cup_r(d, z0 - 0.01) + 0.02, r2=_ball_cup_r(d, z1 + 0.01) + 0.02, h=h + 0.02, $fn=72);
        for (i=[0:11]) rotate(i*30) translate([_ball_cup_r(d, z0) + 2.4, 0, -1]) cylinder(d=2, h=h + 2, $fn=16);   // grip
    }
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

// ---------- clamp ----------
// A C-clamp behind the plate for desk tops, shelves, table edges and flat bars. The spine runs down from the plate's
// top edge; the upper jaw rests on the desk, the lower jaw carries a threaded boss with a printed screw (part
// attach_screw: grip knob below, pressure pad with a 45 degree underside on top). The spine joins only the plate's
// middle, 0.6 mm clear of the snap arms, like the roof bracket. All outer edges are chamfered.
// gap = opening between the jaws, reach = from the spine's inner face to the edge of the screw hole.
function clamp_jaw_t(screw) = max(7, 0.55*thread_d(screw));          // jaw thickness
function clamp_boss_h(screw) = max(clamp_jaw_t(screw), 1.3*thread_d(screw));   // threaded length in the lower jaw
function clamp_spine_t(size) = size == "S" ? 6 : size == "M" ? 7 : 8;
function clamp_axis_z(size, reach, screw) = -0.6 - clamp_spine_t(size) - reach - thread_d(screw)/2 - thread_clr();
function clamp_top_y(size) = attach_dims(size)[1]/2 - ATTACH_CLR;
function clamp_low_y(size, gap, screw) = clamp_top_y(size) - 2*clamp_jaw_t(screw) - gap;     // underside of the lower jaw
function clamp_pad_h(screw) = 3 + (thread_d(screw)/2 + 5 - (thread_d(screw)/2 - thread_depth(thread_pitch(screw))));   // pad: 45 degree cone + 3 mm disc
module clamp_frame(size="M", gap=40, reach=25, screw="M16") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR; sp = attach_strip();
    d = thread_d(screw); jt = clamp_jaw_t(screw); bh = clamp_boss_h(screw); st = clamp_spine_t(size);
    W = max(w - 2*c, d + 10);                                   // jaw width (at least the boss)
    zt = -0.6 - st;                                             // the spine's inner face (the clamped object stops here)
    za = clamp_axis_z(size, reach, screw);
    J = -za + d/2 + 6;                                          // jaw length from z = 0
    yt = clamp_top_y(size); yl = clamp_low_y(size, gap, screw);
    g = min(8, gap/4);                                          // 45 degree gusset in the inner corners
    assert(gap >= clamp_pad_h(screw) + 4, str("clamp: the opening must be at least ", clamp_pad_h(screw) + 4, " mm for the screw's pad"));
    translate([-w/2 + c, -l/2 + sp + 0.5, -0.61]) cube([w - 2*c, l - 2*sp - 1, 0.62]);              // joins the core's middle
    difference() {
        union() {
            translate([-W/2, yl, -0.6 - st]) attach_chamfer_box([W, yt - yl, st], 1);                    // spine
            for (y0=[yt - jt, yl]) translate([-W/2, y0, -J]) attach_chamfer_box([W, jt, J - 0.6 + 0.01 - 0.01], 1);   // jaws
            for (s=[1, -1]) let(y = s > 0 ? yt - jt : yl + jt)                                         // gussets
                translate([-W/2 + 1, y, zt + 0.01]) rotate([0, 90, 0]) linear_extrude(W - 2)
                    polygon([[0, 0], [g, 0], [0, -s*g]]);
            translate([0, yl + jt + 0.01, za]) rotate([90, 0, 0]) cylinder(r=d/2 + 5, h=bh, $fn=64);  // threaded boss
            translate([0, yl + jt + 0.01 - bh, za]) rotate([90, 0, 0]) cylinder(r1=d/2 + 5, r2=d/2 + 4, h=1, $fn=64);
        }
        translate([0, yl + jt + 0.02, za]) rotate([90, 0, 0]) thread_cutter(screw, bh + 1.05);
    }
}
// the screw in its own frame: axis +Z, knob from z = 0, thread above it, pad on top
module clamp_screw(gap=40, screw="M16") {
    d = thread_d(screw); h = thread_depth(thread_pitch(screw)); bh = clamp_boss_h(screw);
    kh = 12; tl = gap + bh - clamp_pad_h(screw) + 2;            // the pad can close the full opening
    thread_knob(d + 16, kh, "wave");
    translate([0, 0, kh - 0.01]) thread_rod(screw, tl + 0.02);
    translate([0, 0, kh + tl]) {                                // pad: 45 degree cone (prints without support), then a disc
        cylinder(r1=d/2 - h, r2=d/2 + 5, h=d/2 + 5 - (d/2 - h), $fn=64);
        translate([0, 0, d/2 + 5 - (d/2 - h) - 0.01]) cylinder(r=d/2 + 5, h=3, $fn=64);
    }
}
// seated in the frame (host frame), half open
module clamp_screw_seated(size="M", gap=40, reach=25, screw="M16") {
    yl = clamp_low_y(size, gap, screw); bh = clamp_boss_h(screw);
    open = gap/2;                                               // pad half way up
    y0 = clamp_top_y(size) - clamp_jaw_t(screw) - open - clamp_pad_h(screw) - (gap + bh - clamp_pad_h(screw) + 2) - 12;
    translate([0, y0, clamp_axis_z(size, reach, screw)]) rotate([-90, 0, 0]) clamp_screw(gap, screw);
}

// ---------- pipe claw ----------
// A rounded claw that snaps onto a pipe, tube, round bar or conduit of diameter d (like electrical conduit clips).
// The claw wraps the pipe; its opening is chosen so the claw bends by about 1.5% when it is pushed on (asserted
// under 2%: split-ring bending, strain = opening change * wall / (3 pi R^2)). The tips flare out at 45 degrees as a
// lead-in. axis "horizontal": the pipe runs along the plate's width; "vertical": along its length.
function pipe_wall(d) = max(2.2, 0.12*d);
function pipe_open(d) = let(t = pipe_wall(d), R = (d + t)/2) min(0.88, max(0.72, 1 - 0.015*3*PI*R*R/(t*d)));   // opening / d
function pipe_strain(d) = let(t = pipe_wall(d), R = (d + t)/2) d*(1 - pipe_open(d))*t/(3*PI*R*R);
PIPE_CLR = 0.2;
module pipe_claw_2d(d=20, base=4, base_w=20) {
    t = pipe_wall(d); ri = d/2 + PIPE_CLR; ro = ri + t; vc = 0.6 + base + ro;      // v = distance behind the plate
    a = pipe_open(d)*d/2; yc = sqrt(max(0, ri*ri - a*a));                         // opening half width, chord position
    offset(r=0.6, $fn=16) offset(delta=-0.6) difference() {
        union() {
            translate([0, vc]) circle(r=ro, $fn=96);
            translate([-base_w/2, 0.6 - 0.01]) square([base_w, vc - 0.6]);
        }
        translate([0, vc]) circle(r=ri, $fn=96);
        translate([0, vc]) polygon([[-a, yc], [a, yc], [a + 3*ro, yc + 3*ro], [-a - 3*ro, yc + 3*ro]]);   // opening + 45 degree lead-in
    }
}
module pipe_claw(size="M", d=20, axis="horizontal") {
    w = attach_dims(size)[0]; l = attach_dims(size)[1]; c = ATTACH_CLR; sp = attach_strip();
    assert(pipe_strain(d) <= 0.02, str("pipe claw: ", d, " mm would bend the claw by ", pipe_strain(d)*100, "% (limit 2%)"));
    mid = l - 2*sp - 1;                                          // the plate's middle, clear of the snap arms
    translate([-w/2 + c, -mid/2, -0.61]) cube([w - 2*c, mid, 0.62]);                // joins the core's middle
    if (axis == "vertical") translate([0, mid/2, 0]) rotate([90, 0, 0]) linear_extrude(mid)
        mirror([0, 1]) pipe_claw_2d(d, 4, min(w - 2*c, 0.8*d));
    else translate([-(w - 2*c)/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(w - 2*c)
        mirror([0, 1]) pipe_claw_2d(d, 4, min(mid, 0.8*d));
}
