// Cable mounting and routing: clips, flat-cable hooks, zip-tie mounts, duct with snap lid, grommets,
// and cutters that route cables through a host.
// Use:  use <../../lib/cable.scad>
// Conventions: mounting parts sit on z=0 (glue face or screw face) with the cable running along +X.
// Cutters are subtracted from a host whose face is z=0 and whose body is z>0 (like attach_socket()).

CABLE_MOUNTS = ["adhesive", "screw"];   // adhesive pad (glue / tape) or a countersunk M3 screw tab

module _screw_tab(y, base_t) {          // countersunk M3 hole at (0, y)
    translate([0, y, -1]) cylinder(d=3.4, h=base_t + 2, $fn=24);
    translate([0, y, base_t - 1.55]) cylinder(d1=3.4, d2=6.6, h=1.56, $fn=32);
}

// round cable (diameter d) snapped into a C-clamp
module cable_clip(d=5, mount="adhesive", len=10, wall=1.6, base_t=2) {
    R = d/2 + wall; zc = base_t + d/2 + 0.15;
    difference() {
        union() {
            translate([-len/2, -R, 0]) cube([len, 2*R + (mount == "screw" ? 9 : 0), base_t]);
            translate([-len/2, 0, zc]) rotate([0,90,0]) cylinder(r=R, h=len, $fn=48);
            translate([-len/2, -R, 0]) cube([len, 2*R, zc]);
        }
        translate([-len, 0, zc]) rotate([0,90,0]) cylinder(d=d + 0.3, h=2*len, $fn=48);
        translate([-len, -0.375*d, zc + d*0.3]) cube([2*len, 0.75*d, d]);          // snap-in mouth (75% of d)
        if (mount == "screw") _screw_tab(R + 4.5, base_t);
    }
}
// flat cable or LED-strip lead (width w, thickness t): slide it in under the lip from the open side
module flat_cable_clip(w=8, t=2.5, mount="adhesive", len=10, base_t=2) {
    lip_z = base_t + t + 0.3;
    difference() {
        union() {
            translate([-len/2, -2, 0]) cube([len, w + 4.4 + (mount == "screw" ? 9 : 0), base_t]);
            translate([-len/2, w + 0.4, 0]) cube([len, 2, lip_z + 1.4]);                // post
            translate([-len/2, w*0.35, lip_z]) cube([len, w*0.65 + 2.4, 1.4]);          // lip
            translate([-len/2, w*0.35, lip_z - 0.5]) cube([len, 0.8, 0.51]);           // catch at the lip tip
        }
        if (mount == "screw") _screw_tab(w + 2.4 + 4.5, base_t);
    }
}
// zip-tie anchor: the tie (width tie_w) threads through the tunnel along Y
module tie_mount(tie_w=4.8, mount="adhesive", base_t=2) {
    L = mount == "screw" ? 28 : 16; tw = tie_w + 0.6; th = 1.8;
    difference() {
        union() {
            translate([-L/2, -8, 0]) cube([L, 16, base_t]);
            translate([-(tw/2 + 2.5), -8, 0]) cube([tw + 5, 16, base_t + th + 1.6]);
        }
        translate([-tw/2, -9, base_t]) cube([tw, 18, th]);
        if (mount == "screw") for (x=[-10, 10]) translate([x, 0, 0]) rotate([0,0,90]) _screw_tab(0, base_t);
    }
}
// cable duct (raceway): inner w x h (h >= 6), snap lid; screw holes every `pitch` when mount == "screw".
// Profile (y, z) extruded along +X. Ramped beads on the outside of the walls catch the lid's hooks.
module cable_duct(len=100, w=12, h=8, wall=1.4, base_t=1.6, mount="adhesive", pitch=60) {
    assert(h >= 6, "cable_duct: h must be at least 6 mm for the lid snap");
    W = w + 2*wall; z0 = base_t + h;
    difference() {
        rotate([90,0,90]) linear_extrude(len) {
            translate([-W/2, 0]) square([W, z0]);
            for (s=[-1,1]) mirror([s > 0 ? 0 : 1, 0])
                polygon([[W/2 - 0.01, z0 - 4.0], [W/2 + 0.45, z0 - 4.0], [W/2 + 0.45, z0 - 3.7], [W/2 - 0.01, z0 - 2.8]]);   // bead with lead-in
        }
        translate([-1, -w/2, base_t]) cube([len + 2, w, h + 1]);
        if (mount == "screw") for (x=[pitch/2 : pitch : len]) translate([x, 0, 0]) _screw_tab(0, base_t);
    }
}
module cable_duct_lid(len=100, w=12, h=8, wall=1.4, base_t=1.6, t=1.2, c=0.2) {
    W = w + 2*wall; z0 = base_t + h; lt = 0.9; li = W/2 + 0.45 + c;     // leg inner face clears the bead
    rotate([90,0,90]) linear_extrude(len) {
        translate([-li - lt, z0 + c]) square([2*(li + lt), t]);
        for (s=[-1,1]) mirror([s > 0 ? 0 : 1, 0]) {
            translate([li, z0 - 5]) square([lt, 5 + c + 0.01]);                                       // flexing leg
            polygon([[li + 0.01, z0 - 4.2], [W/2 + c, z0 - 4.2], [W/2 + c, z0 - 4.5], [li + 0.01, z0 - 5]]);   // hook under the bead, chamfered
        }
    }
}

// split grommet for a hole of hole_d through a panel of panel_t: push it in, lay the cable in through the slit
module cable_grommet(hole_d=10, cable_d=5, panel_t=12, flange=3, flange_t=1.2) {
    difference() {
        union() { cylinder(d=hole_d + 2*flange, h=flange_t, $fn=64); cylinder(d=hole_d - 0.2, h=flange_t + panel_t, $fn=64); }
        translate([0,0,-1]) cylinder(d=cable_d + 0.5, h=panel_t + flange_t + 2, $fn=48);
        translate([0, -0.6, -1]) cube([hole_d + 2*flange, 1.2, panel_t + flange_t + 2]);           // slit
    }
}

// ---------- cutters for hosts ----------
// groove along a 2D polyline `pts` ([[x,y],...]), width w, depth d into the host face (z=0)
module cable_route(pts, w=6, d=4) {
    for (i=[0:1:len(pts)-2]) hull() for (p=[pts[i], pts[i+1]]) translate([p[0], p[1], -1]) cylinder(d=w, h=d + 1, $fn=32);
}
// notch through a host edge so a cable can leave the back; centred on x=0 at the edge y=0, opening to -Y
module cable_notch(w=6, d=4, reach=8) {
    translate([-w/2, -1, -1]) cube([w, reach + 1, d + 1]);
}
// round hole for a grommet or a cable straight through the host
module cable_hole(d=10, depth=50) { translate([0,0,-1]) cylinder(d=d, h=depth + 2, $fn=48); }
