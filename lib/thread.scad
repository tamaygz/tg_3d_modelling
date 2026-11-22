// Printable screw threads, nuts and knobs: clamp screws, lids, adjusters, levelling feet.
// Use:  use <../../lib/thread.scad>
// Frame: the thread's axis is +Z, it starts at z = 0 and runs up to z = len.
//
// Metric threads with the ISO coarse pitch (THREAD_ISO), a 60 degree profile with flat crests and roots. Printed
// threads need play: the rod is made `clr` smaller and the hole (thread_cutter) `clr` larger on the radius.
// Print rods standing (axis vertical); a threaded hole prints best with its axis vertical too. Below about M8,
// printed threads are weak: use a real bolt and a captive nut (thread_nut_trap) instead.
//
// The thread is built as one surface whose radius follows the helical profile, so it is always a single closed,
// manifold solid and renders fast in OpenSCAD 2021.

// [name, diameter, pitch] (ISO 261 coarse series)
THREAD_ISO = [["M6", 6, 1], ["M8", 8, 1.25], ["M10", 10, 1.5], ["M12", 12, 1.75], ["M16", 16, 2],
              ["M20", 20, 2.5], ["M24", 24, 3], ["M30", 30, 3.5]];
THREAD_SIZES = ["M6", "M8", "M10", "M12", "M16", "M20", "M24", "M30"];
THREAD_CLR = 0.25;          // play per side between a printed rod and a printed hole
function thread_clr() = THREAD_CLR;      // (for files that `use` this one: they cannot see its variables)
KNOB_STYLES = ["wave", "knurl", "round"];

function thread_spec(name) = let(r = [for (t=THREAD_ISO) if (t[0] == name) t]) len(r) > 0 ? r[0] : THREAD_ISO[4];
function thread_d(name) = thread_spec(name)[1];
function thread_pitch(name) = thread_spec(name)[2];
function thread_depth(pitch) = 0.5413*pitch;          // ISO basic profile: 5/8 of the fundamental triangle height

// radius of the threaded surface at angle a (degrees) and height z: crest share 1/8, root share 1/4 of the pitch
function _thr_r(d, p, a, z) = let(f = ((z/p - a/360)%1 + 1)%1, h = thread_depth(p),
    t = f < 0.125 ? 1 : f < 0.5 ? 1 - (f - 0.125)/0.375 : f < 0.75 ? 0 : (f - 0.75)/0.25)
    d/2 - h + h*t;
// the threaded solid: rod of nominal diameter d (minus 2*clr), pitch p, length len; chamfer = 45 degree lead-in at
// both ends (0 = none). grow > 0 makes a cutter for a threaded hole (the same surface, larger).
module thread_solid(d, p, len, grow=0, chamfer=true, fn=48) {
    n = fn; k = max(2, ceil(len/(p/8)));
    ch = chamfer ? thread_depth(p) : 0;
    pts = concat(
        [for (j=[0:k]) let(z = len*j/k) for (i=[0:n-1]) let(a = 360*i/n,
            r = _thr_r(d, p, a, z) + grow,
            cut = d/2 + grow - (ch > 0 ? max(0, ch - min(z, len - z)) : 0))   // chamfered ends: the crest is cut down
            [min(r, cut)*cos(a), min(r, cut)*sin(a), z]],
        [[0, 0, 0], [0, 0, len]]);
    c0 = (k + 1)*n; c1 = c0 + 1;
    faces = concat(
        [for (j=[0:k-1]) for (i=[0:n-1]) each [[j*n + i, (j+1)*n + (i+1)%n, j*n + (i+1)%n], [j*n + i, (j+1)*n + i, (j+1)*n + (i+1)%n]]],
        [for (i=[0:n-1]) [c0, i, (i+1)%n]],
        [for (i=[0:n-1]) [c1, k*n + (i+1)%n, k*n + i]]);
    polyhedron(pts, faces, convexity=4);
}
// a printed threaded rod of size `name` (THREAD_SIZES), `len` long
module thread_rod(name="M16", len=30, clr=THREAD_CLR) {
    thread_solid(thread_d(name) - 2*clr, thread_pitch(name), len);
}
// cutter for a threaded hole of size `name`, `len` deep (reaches 0.01 past both ends); countersink = lead-in cone
module thread_cutter(name="M16", len=20, clr=THREAD_CLR, countersink=true) {
    d = thread_d(name); p = thread_pitch(name);
    translate([0, 0, -0.01]) thread_solid(d, p, len + 0.02, grow=clr, chamfer=false);
    if (countersink) for (z=[0, len]) translate([0, 0, z]) cylinder(d1=z == 0 ? d + 2*clr + 1 : d - 2*thread_depth(p), d2=z == 0 ? d - 2*thread_depth(p) : d + 2*clr + 1,
        h=(1 + 2*clr + 2*thread_depth(p))/2, center=true, $fn=61);   // 61: no vertex in line with the thread's 48
}
// pocket for a real hex nut (across flats s, height h), axis +Z from z = 0 (cutter)
module thread_nut_trap(s=13, h=6.5, clr=0.2) { cylinder(d=(s + 2*clr)/cos(30), h=h + clr, $fn=6); }

// grip knob, axis +Z from z = 0: "wave" = wavy rim (as on many printed clamps), "knurl" = straight ridges,
// "round" = plain with a rounded top edge
module thread_knob(d=30, h=12, style="wave", waves=8) {
    if (style == "round") hull() { cylinder(d=d, h=h - 1.5, $fn=72); cylinder(d=d - 3, h=h, $fn=72); }
    else if (style == "knurl") linear_extrude(h) polygon([for (i=[0:71]) let(a = i*5, r = d/2 - (i%3 == 0 ? 1.2 : 0)) r*[cos(a), sin(a)]]);
    else for (s=[0, 1]) translate([0, 0, s*h/2]) linear_extrude(h/2 + (s == 0 ? 0.01 : 0), twist=(s == 0 ? 1 : -1)*180/waves, slices=8)
        rotate(s == 0 ? 0 : -180/waves) polygon([for (i=[0:143]) let(a = i*2.5) (d/2 - 1.2 + 1.2*cos(a*waves))*[cos(a), sin(a)]]);
}
