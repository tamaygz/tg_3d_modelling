// Board / plaque shapes: 2D outlines, routed-edge slabs, decorative grooves, keyhole hangers.
// Use:  use <../../lib/shapes.scad>
// Conventions: 2D outlines are centred on the origin; slabs sit on z=0 (back face) and rise to z=t.

PLAQUE_SHAPES  = ["rect", "rounded", "chamfered", "notched", "arched", "wave", "scalloped"];
EDGE_PROFILES  = ["flat", "roundover", "chamfer", "cove", "ogee"];
GROOVE_STYLES  = ["none", "single", "double"];

// ---------- outlines ----------
// size = [length, height] of the plain body; arched/wave/scalloped edges add up to `amp` above and below.
// r = corner radius (rounded), corner cut (chamfered) or notch radius (notched).
module plaque_2d(size, shape="rounded", r=8, amp=5, waves=2, n=160) {
    L = size[0]; H = size[1];
    function edge(t) =
        shape == "arched"    ? amp * sin(180*t) :
        shape == "wave"      ? amp * 0.5 * (1 + cos(360*waves*t)) :
        shape == "scalloped" ? amp * abs(sin(180*max(1, round(waves*4))*t)) : 0;
    if (shape == "rect") square([L, H], center=true);
    else if (shape == "rounded") offset(r=r) offset(delta=-r) square([L, H], center=true);
    else if (shape == "chamfered") offset(delta=r, chamfer=true) offset(delta=-r) square([L, H], center=true);
    else if (shape == "notched") difference() {
        square([L, H], center=true);
        for (sx=[-1,1], sy=[-1,1]) translate([sx*L/2, sy*H/2]) circle(r=r, $fn=48);
    }
    else {
        top = [for (i=[0:n]) let(t=i/n) [-L/2 + t*L,  H/2 + edge(t)]];
        bot = [for (i=[n:-1:0]) let(t=i/n) [-L/2 + t*L, -H/2 - edge(t)]];
        rr = min(r, H/4);
        offset(r=rr) offset(delta=-rr) polygon(concat(top, bot));
    }
}

// ---------- routed edge ----------
// inset of the edge at height z' (0 = bottom of the profile zone, r = top face)
function edge_inset(profile, r, zp) =
    profile == "roundover" ? r - sqrt(max(0, r*r - zp*zp)) :
    profile == "chamfer"   ? zp :
    profile == "cove"      ? sqrt(max(0, r*r - (r - zp)*(r - zp))) :
    profile == "ogee"      ? (zp < r/2 ? sqrt(max(0, pow(r/2,2) - pow(r/2 - zp, 2)))
                                       : r/2 + (r/2 - sqrt(max(0, pow(r/2,2) - pow(zp - r/2, 2))))) :
    0;

// extrude children() (a 2D outline) to thickness t with a routed top edge of size r
module profiled_slab(t, profile="roundover", r=3, steps=8) {
    if (profile == "flat" || r <= 0) linear_extrude(t) children();
    else {
        linear_extrude(t - r + 0.01) children();
        for (k=[1:steps]) translate([0, 0, t - r + (k-1)*r/steps])
            linear_extrude(r/steps + 0.01) offset(delta=-edge_inset(profile, r, k*r/steps)) children();
    }
}

// decorative groove following children() (2D outline), cut down from the top face z=t
module outline_groove(t, inset=5.5, w=0.8, depth=0.8, style="single", gap=1.6) {
    if (style != "none")
        for (i=[0:(style == "double" ? 1 : 0)]) let(d = inset + i*(w + gap))
            translate([0, 0, t - depth]) linear_extrude(depth + 1)
                difference() { offset(delta=-d) children(); offset(delta=-d-w) children(); }
}

// ---------- hanging ----------
// keyhole slot cut into the back face (z=0); the screw head drops in at the origin and slides +y by `travel`
module keyhole_slot(head_d=9, neck_d=4.5, travel=10, neck_t=2.5, depth=6) {
    translate([0,0,-0.1]) {
        cylinder(d=head_d, h=depth + 0.1);
        hull() { cylinder(d=neck_d, h=neck_t + 0.1); translate([0,travel,0]) cylinder(d=neck_d, h=neck_t + 0.1); }
    }
    translate([0,0,neck_t]) hull() { cylinder(d=head_d, h=depth - neck_t); translate([0,travel,0]) cylinder(d=head_d, h=depth - neck_t); }
}
