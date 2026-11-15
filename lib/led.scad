// LED strip system: tracks (channels), snap-in diffusers, joiner keys, end caps, corners, host recesses.
// Use:  use <../../lib/led.scad>
use <core.scad>
//
// Everything is built from ONE cross-section, so tracks, corners, diffusers and keys always match.
//   spec = led_spec(strip, style)      strip = [width, thickness] (led_strip_dims("10mm") etc.)
// Conventions: a straight track runs along +X from x=0, centred on y=0, its back (mounting face) on z=0,
// open to +z. The strip lies on the floor; a diffuser snaps into grooves at the top of the walls.
// Underneath runs a T-slot: a joiner key pushed half into each piece lines two pieces up.
// Corners start at x=0 heading +X like a track, so a corner placed at a track's end continues it.

LED_STRIPS  = ["5mm", "8mm", "10mm", "12mm", "8mm IP65", "10mm IP65", "custom"];
LED_STYLES  = ["shallow", "deep"];                 // light distance to the diffuser: compact or smoother light
LED_DIFFUSERS = ["flat", "dome", "none"];
LED_CORNERS = ["inward", "outward", "flat"];       // inside edge, outside edge, turn in the mounting plane
LED_MOUNTS  = ["glue", "screw"];

LED_FLOOR = 3.0;    // floor thickness (holds the key slot)
LED_WALL  = 1.6;    // side walls
LED_CLR   = 0.3;    // strip width play per side
G_TOP = 0.8; G_H = 1.2; G_D = 0.7;                 // diffuser groove: below the wall top, height, depth
KEY_W1 = 3.2; KEY_W2 = 5.4; KEY_V1 = 0.8; KEY_V2 = 1.8;   // T-slot: mouth width, head width, mouth top, head top
LED_KEY_L = 20;     // joiner key length
D_CLR = 0.15;       // diffuser / key / cap clearance

// typical sizes; check your strip's datasheet (IP65 = silicone coated: wider and thicker)
function led_strip_dims(name, custom=[10, 2.5]) =
    name == "5mm" ? [5, 2] : name == "8mm" ? [8, 2] : name == "10mm" ? [10, 2.5] : name == "12mm" ? [12, 2.5] :
    name == "8mm IP65" ? [10, 4.5] : name == "10mm IP65" ? [12, 4.8] : custom;
// spec = [seat width, cavity depth above the floor, strip thickness]
function led_spec(strip, style="shallow") = [strip[0] + 2*LED_CLR, strip[1] + (style == "deep" ? 8 : 3.5), strip[1]];
function led_W(spec) = spec[0] + 2*LED_WALL;           // track width
function led_H(spec) = LED_FLOOR + spec[1];            // track height (without diffuser)

// ---------- 2D cross-sections (u = across, v = up) ----------
module led_track_2d(spec) {
    sw = spec[0]; W = led_W(spec); H = led_H(spec);
    difference() {
        translate([-W/2, 0]) square([W, H]);
        translate([-sw/2, LED_FLOOR]) square([sw, H]);
        for (s=[-1,1]) translate([s > 0 ? sw/2 - 0.01 : -sw/2 - G_D, H - G_TOP - G_H]) square([G_D + 0.01, G_H]);
        translate([-KEY_W1/2, -1]) square([KEY_W1, KEY_V1 + 1.01]);
        translate([-KEY_W2/2, KEY_V1]) square([KEY_W2, KEY_V2 - KEY_V1]);
    }
}
module led_diffuser_2d(spec, style="flat", t=1.0) {
    sw = spec[0]; W = led_W(spec); H = led_H(spec); c = D_CLR;
    gb = H - G_TOP - G_H; gt = H - G_TOP;              // groove bottom / top
    leg_bot = max(LED_FLOOR + spec[2] + 0.3, gb - 1.2); // legs stop above the strip
    b = 0.4; lt = 0.8;                                 // bump height, leg thickness
    if (style == "dome") {
        translate([0, H]) intersection() {
            difference() { scale([W/2, W*0.35]) circle(r=1, $fn=72); scale([W/2 - t, W*0.35 - t]) circle(r=1, $fn=72); }
            translate([-W, 0]) square([2*W, W]);
        }
        for (s=[-1,1]) mirror([s > 0 ? 0 : 1, 0]) translate([sw/2 - c - lt, H]) square([W/2 - (sw/2 - c - lt), t*0.8]);  // ledges: legs to dome, rest on the walls
    }
    else translate([-W/2, H]) square([W, t]);
    for (s=[-1,1]) mirror([s > 0 ? 0 : 1, 0]) {
        translate([sw/2 - c - lt, leg_bot]) square([lt, H - leg_bot + 0.01]);
        polygon([[sw/2 - c - 0.01, gb + c], [sw/2 - c + b, gb + c + b], [sw/2 - c + b, gt - c], [sw/2 - c - 0.01, gt - c]]);
    }
}
module led_key_2d() {
    c = D_CLR;
    translate([-KEY_W1/2 + c, 0]) square([KEY_W1 - 2*c, KEY_V1 + 0.01]);
    translate([-KEY_W2/2 + c, KEY_V1]) square([KEY_W2 - 2*c, KEY_V2 - KEY_V1 - c]);
}

// ---------- sweeps ----------
module led_straight(len) { rotate([90,0,90]) linear_extrude(len) children(); }   // 2D (u,v) -> along +X
// sweep a cross-section through a 90° corner with straight ends of length ext.
//   flat:    turns left (+Y) in the mounting plane, inner radius r
//   outward: wraps over an outside edge, then runs down (-Z), opening facing +X; r = radius of the back
//   inward:  turns up (+Z) into an inside corner, opening facing -X; r = radius of the open face.
//            fill=true fills behind the bend so the piece sits flush in a sharp corner.
module led_corner_sweep(kind, spec, r=6, ext=12, fill=false) {
    H = led_H(spec); W = led_W(spec);
    led_straight(ext) children();
    if (kind == "flat") {
        Rc = r + W/2;
        translate([ext, Rc, 0]) rotate([0,0,-90]) rotate_extrude(angle=90, $fn=96) translate([Rc, 0]) children();
        translate([ext + Rc, Rc - 0.01, 0]) rotate([0,0,90]) led_straight(ext) children();
    } else if (kind == "outward") {
        translate([ext, 0, -r]) multmatrix([[0,1,0,0],[0,0,1,0],[1,0,0,0],[0,0,0,1]])
            rotate_extrude(angle=90, $fn=96) translate([r, 0]) rotate(-90) children();
        translate([ext + r, 0, -r + 0.01]) rotate([0,90,0]) led_straight(ext) children();
    } else {
        Rb = r + H;
        translate([ext, 0, Rb]) multmatrix([[0,1,0,0],[0,0,-1,0],[-1,0,0,0],[0,0,0,1]])
            rotate_extrude(angle=90, $fn=96) translate([Rb, 0]) mirror([1,0]) rotate(-90) children();
        translate([ext + Rb, 0, Rb - 0.01]) rotate([0,-90,0]) led_straight(ext) children();
        if (fill) difference() {
            translate([ext, -W/2, 0]) cube([Rb, W, Rb]);
            translate([ext, 0, Rb]) rotate([90,0,0]) cylinder(r=Rb - 0.01, h=W + 2, center=true, $fn=96);
        }
    }
}

// ---------- parts ----------
// straight track; mount "screw" adds countersunk M3 holes every `pitch`; wire_exit cuts a side exit near x=0
module led_track(len, spec, mount="glue", pitch=100, wire_exit=false) {
    difference() {
        led_straight(len) led_track_2d(spec);
        if (mount == "screw") for (x=[LED_KEY_L/2 + 6 : pitch : len - LED_KEY_L/2 - 6]) translate([x, 0, 0]) {
            csk_hole(LED_FLOOR);
        }
        if (wire_exit) translate([6, -led_W(spec)/2 - 1, LED_FLOOR]) cube([4, led_W(spec)/2 + 1, 3]);
    }
}
module led_diffuser(len, spec, style="flat", t=1.0) { if (style != "none") led_straight(len) led_diffuser_2d(spec, style, t); }
// joiner key, centred on x=0: push half into each track's T-slot
module led_key(l=LED_KEY_L) {
    translate([-l/2, 0, 0]) difference() {
        led_straight(l) led_key_2d();
        for (x=[0, l]) translate([x, 0, KEY_V2]) rotate([0,45,0]) cube([1, 10, 1], center=true);   // end chamfers
    }
}
// end cap for x=0 (plate at x<0) with a short key into the slot; cable_d > 0 adds a hole for the wires
module led_end_cap(spec, cable_d=4, t=1.6) {
    H = led_H(spec);
    difference() {
        translate([-t, 0, 0]) led_straight(t) hull() led_track_2d(spec);
        if (cable_d > 0) translate([-t - 1, 0, LED_FLOOR + cable_d/2 + 0.2]) rotate([0,90,0]) cylinder(d=cable_d, h=t + 2, $fn=32);
    }
    translate([-0.01, 0, 0]) led_straight(6) led_key_2d();
}
module led_corner(kind, spec, r=6, ext=12) { led_corner_sweep(kind, spec, r, ext, fill=true) led_track_2d(spec); }
module led_corner_diffuser(kind, spec, r=6, ext=12, style="flat") {
    if (style != "none") led_corner_sweep(kind, spec, r, ext) led_diffuser_2d(spec, style);
}
// cutter: sink a track flush into a host surface (host face at z = led_H(spec), track back at z=0)
module led_recess(len, spec, clr=0.2) {
    translate([-clr, 0, 0]) led_straight(len + 2*clr) offset(delta=clr) hull() led_track_2d(spec);
}
