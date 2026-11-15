// Sliding markers on a T-rail, and stopper pegs: scoreboards, counters, abacus-like trackers, gauges.
// Use:  use <../../lib/rail.scad>
// Conventions: the rail runs along +X, centred on y=0, its foot on z=0 (the mounting surface).
// A slider is centred on x=0 and its pointer faces -Y. Peg heads sit on z=0 (the rail top) with
// the shaft going down -Z.
//
// One rail spec, passed to every module so rail, slider and pegs always agree:
//   rail = [flange_w, flange_t, web_w, web_h]
//   rail_h(rail) = total height, slider_w(rail, clr, wall) = slider width

RAIL_STYLES    = ["flat", "rounded", "beveled"];
MARKER_STYLES  = ["block", "rounded", "arrow", "knob"];
POINTER_STYLES = ["triangle", "needle", "none"];
HEAD_STYLES    = ["screw", "dome", "flat", "hex", "ball"];

function rail_h(rail) = rail[3] + rail[1];
function slider_w(rail, clr=0.25, wall=1.6) = rail[0] + 2*clr + 2*wall;
function slider_top(rail, clr=0.25, top=2) = rail_h(rail) + clr + top;

// ---------- rail ----------
module t_rail_profile(rail, style="flat") {
    fw = rail[0]; ft = rail[1]; ww = rail[2]; wh = rail[3];
    translate([-ww/2, 0]) square([ww, wh + 0.01]);
    translate([0, wh]) {
        if (style == "rounded") hull() {
            translate([-fw/2, 0]) square([fw, 0.01]);
            for (s=[-1,1]) translate([s*(fw/2 - ft/2), ft/2]) circle(r=ft/2, $fn=24);   // stays inside the flange box
        }
        else if (style == "beveled") polygon([[-fw/2,0],[fw/2,0],[fw/2,ft*0.45],[fw/2-ft*0.55,ft],[-fw/2+ft*0.55,ft],[-fw/2,ft*0.45]]);
        else translate([-fw/2, 0]) square([fw, ft]);
    }
}
// rail from x0 to x1 with vertical clearance holes at the x positions in `holes`
module t_rail(x0, x1, rail, style="flat", holes=[], hole_d=3.4) {
    difference() {
        translate([x0,0,0]) rotate([90,0,90]) linear_extrude(x1 - x0) t_rail_profile(rail, style);
        for (x=holes) translate([x,0,-1]) cylinder(d=hole_d, h=rail_h(rail) + 2, $fn=32);
    }
}

// ---------- slider ----------
// l = length along the rail. The pointer reaches ptr_len beyond the slider's -Y side, at its top.
module rail_slider(rail, l=10, clr=0.25, wall=1.6, top=2, lip_t=1.8, style="block",
                   pointer="triangle", ptr_len=3.5, ptr_w=6, ptr_t=1.4, dimple=true) {
    fw = rail[0]; ft = rail[1]; ww = rail[2]; wh = rail[3];
    sw = slider_w(rail, clr, wall);
    st = slider_top(rail, clr, top);
    zl = wh - clr - lip_t;
    kh = 4.5;                                  // knob height (knob style)
    module body() {
        if (style == "rounded") hull() {
            translate([-l/2, -sw/2, zl]) cube([l, sw, st - zl - 2]);
            for (s=[-1,1]) translate([-l/2, s*(sw/2 - 2), st - 2]) rotate([0,90,0]) cylinder(r=2, h=l, $fn=32);
        }
        else if (style == "arrow")
            translate([0,0,zl]) linear_extrude(st - zl)
                polygon([[-l/2, sw/2], [l/2, sw/2], [l/2, -sw/2], [0.6, -sw/2 - ptr_len], [-0.6, -sw/2 - ptr_len], [-l/2, -sw/2]]);
        else {
            translate([-l/2, -sw/2, zl]) cube([l, sw, st - zl]);
            if (style == "knob") translate([0, 0, st - 0.01]) {
                cylinder(d1=min(l, sw) - 1, d2=min(l, sw) - 3, h=kh - 1.5, $fn=48);
                translate([0,0,kh - 1.5]) scale([1,1,0.55]) sphere(d=min(l, sw) - 3, $fn=48);
            }
        }
        pz = style == "rounded" ? st - 1.2 : st;           // pointer top (rounded tops fall away at the edge)
        if (style != "arrow" && pointer != "none")
            translate([0, -sw/2, pz - ptr_t]) linear_extrude(ptr_t) {
                if (pointer == "needle") polygon([[-1.2,0],[1.2,0],[0.5,-ptr_len - 1],[0,-ptr_len - 1.6],[-0.5,-ptr_len - 1]]);
                else polygon([[-ptr_w/2,0],[ptr_w/2,0],[0.4,-ptr_len],[-0.4,-ptr_len]]);
                translate([-(pointer == "needle" ? 1.2 : ptr_w/2), 0]) square([pointer == "needle" ? 2.4 : ptr_w, 3]);  // root, anchored inside the body
            }
    }
    difference() {
        body();
        translate([-l, -(fw/2 + clr), wh - clr]) cube([2*l, fw + 2*clr, ft + 2*clr]);
        translate([-l, -(ww/2 + clr), -1]) cube([2*l, ww + 2*clr, wh + 1]);
        if (dimple && (style == "block" || style == "arrow")) translate([0, 0, st + 2.4]) sphere(r=3, $fn=48);
    }
}

// ---------- stopper pegs ----------
// head only, base on z=0. For every style the full diameter d reaches from z=0 to at least z=1.2, so
// a slider (ceiling a few tenths above the rail) stops at the same place whatever the style.
module peg_head(d=6.5, h=2.5, style="screw") {
    if (style == "dome") { cylinder(d=d, h=1.2); translate([0,0,1.19]) scale([1,1,(h - 1.2)/(d/2)]) intersection() { sphere(d=d, $fn=48); translate([-d,-d,0]) cube(2*d); } }
    else if (style == "flat") { cylinder(d=d, h=h - 0.5); translate([0,0,h - 0.5]) cylinder(d1=d, d2=d - 1, h=0.5); }
    else if (style == "hex") { cylinder(d=d*1.1, h=h - 0.4, $fn=6); translate([0,0,h - 0.4]) cylinder(d1=d*1.1, d2=d*1.1 - 0.8, h=0.4, $fn=6); }
    else if (style == "ball") { cylinder(d=d, h=1.2); translate([0,0,1.2]) cylinder(d1=d, d2=d*0.55, h=0.8); translate([0,0,h + d*0.1]) sphere(d=d*0.9, $fn=48); }
    else difference() {
        union() { cylinder(d=d, h=h - 0.8); translate([0,0,h - 0.8]) cylinder(d1=d, d2=d - 1.6, h=0.8); }
        translate([0,0,h - 0.6]) cube([d, 0.7, 1.4], center=true);
    }
}

// single stopper: head on z=0, shaft down to z=-shaft_l
module stop_peg(d=6.5, h=2.5, style="screw", shaft_d=3, shaft_l=10) {
    peg_head(d, h, style);
    translate([0,0,-shaft_l]) cylinder(d=shaft_d, h=shaft_l + 0.01, $fn=32);
}
// bar stopper over a joint: two shafts at ±pitch/2, one head bridging them
module twin_peg(pitch=8, d=6.5, h=2.5, style="screw", shaft_d=3, shaft_l=10) {
    difference() {
        hull() for (s=[-1,1]) translate([s*pitch/2, 0, 0]) peg_head(d, h, style == "screw" ? "flat" : style);
        if (style == "screw") for (s=[-1,1]) translate([s*pitch/2, 0, h - 0.6]) cube([d*0.8, 0.7, 1.4], center=true);
    }
    for (s=[-1,1]) translate([s*pitch/2, 0, -shaft_l]) cylinder(d=shaft_d, h=shaft_l + 0.01, $fn=32);
}
