// Containers: the parts of an open box built on a shell outline. Patterned walls with openings, floor, lid
// ledge, mounting boss. Used by projects/custombox, projects/earbuds, projects/sunglasses.
// Use:  use <../../lib/container.scad>   (builds on shell.scad, patterns.scad, attach.scad)
//
// Frame: the outline `pts` (see shell.scad) is the outer face of the walls in the floor plane; the floor's
// underside is z = 0 and everything rises along +Z. "Front" is -Y, "back" is +Y.
// Openings (cable holes, slots) are 2D children:
//   container_walls / container_wall  in the wall's unrolled frame: x = distance along the outline measured from
//                                     the middle of the whole loop (use container_u() to get it from a plan
//                                     point), y = height above the floor plane minus h/2
//   container_floor                   in plan (x, y)
// Each opening gets a plain collar `frame` wide, so it never ends in the middle of a lattice.
use <shell.scad>
use <patterns.scad>
use <attach.scad>

// x in the loop's unrolled frame of the outline point nearest to plan point q; y of a height z
function container_u(pts, q) = shell_dist_at(pts, q) - shell_len(pts)/2;
function container_v(z, h) = z - h/2;

// ---------- walls ----------
// One stretch of wall over outline edges e0..e1 as a patterned panel bent round the outline.
// t = wall thickness, h = reference height (the highest point of the rim), hf = function (p) -> rim height,
// p / mode = pattern spec and how it is applied (PATTERN_MODES), border = [sides, bottom, top] plain bands,
// depth = relief height / engraving depth, lining_t = lining thickness in overlay mode.
// plain  = areas without pattern (solid wall): [[x, z, w, h], ...] centre x in the loop frame, bottom z, size
// mount  = a container_mount() spec: its solid zone and sockets are built into the wall where they belong
// anchor = plan point the pattern is centred on (default: the middle of the strip)
// The optional child cuts openings (loop frame, see the top of this file).
module container_wall(pts, e0, e1, t, h, hf, p, mode="solid", border=[0, 4, 4], depth=0.8, lining_t=0.6, frame=2, plain=[], mount, anchor) {
    if ($children > 0) _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, true, plain, mount, anchor) children();
    else _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, false, plain, mount, anchor) square(1);
}
module _container_plain_2d(zones, h) { for (z=zones) translate([z[0] - z[2]/2, z[1] - h/2]) square([z[2], z[3]]); }
module _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, holes, plain, mount, anchor) {
    u = shell_dists(pts); L = u[e1 + 1] - u[e0];
    dx = u[len(pts)]/2 - (u[e0] + u[e1 + 1])/2;                 // loop frame -> this strip's frame
    strip = shell_strip_pts(pts, e0, e1, hf, h);
    // the mount belongs to the strip that holds the middle of its zone
    mx = is_undef(mount) ? undef : container_u(pts, mount[3] + [mount[11], 0]) + dx;
    has_m = !is_undef(mx) && abs(mx) < L/2;
    zones = concat([for (z=plain) [z[0] + dx, z[1], z[2], z[3]]], has_m ? _container_mount_plain(mount, mx, h) : []);
    pp = is_undef(anchor) ? p : pattern_shift(p, [container_u(pts, anchor) + dx, 0]);
    shell_wrap(pts, t, e0, e1, h=h, above=depth) {
        pattern_panel(mode, pp, [L + 1, h], t=t, depth=depth, border=border, lining_t=lining_t)
            difference() {
                polygon(strip);
                if (holes) translate([dx, 0]) children();
                offset(delta=-0.3) _container_plain_2d(zones, h);        // the pattern stops at the plain areas ...
            }
        // ... which are filled with solid wall (minus the mount's own block, which is thicker)
        if (len(zones) > 0) linear_extrude(t) shell_window_2d() difference() {
            intersection() { polygon(strip); _container_plain_2d(zones, h); }
            if (holes) translate([dx, 0]) children();
            if (has_m) offset(delta=-0.3) _container_plain_2d([_container_mount_zone(mount, mx)], h);
        }
        if (holes && frame > 0) linear_extrude(t) shell_window_2d() intersection() {
            polygon(strip);
            difference() { offset(delta=frame) translate([dx, 0]) children(); translate([dx, 0]) children(); }
        }
        if (has_m) _container_mount_block(mount, mx, t, h);
    }
}
// All walls of a container. runs = undef: one panel all the way round (the pattern runs through the corners).
// runs = shell_runs_edges(...) of a box outline: every side is its own panel with `post_w` of plain wall at both
// ends, and the corner runs are plain. bands = [bottom, top] plain bands; plain, mount, anchor: see container_wall
// (anchor only matters for the single panel; separate sides are centred on themselves).
module container_walls(pts, t, h, hf, p, mode="solid", bands=[4, 4], depth=0.8, lining_t=0.6, runs, post_w=3, frame=2, plain=[], mount, anchor) {
    if ($children > 0) _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, true, plain, mount, anchor) children();
    else _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, false, plain, mount, anchor) square(1);
}
module _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, holes, plain, mount, anchor) {
    if (is_undef(runs)) {
        if (holes) container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame, plain, mount, anchor) children();
        else container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame, plain, mount, anchor);
    }
    else for (r=runs) {
        corner = container_is_corner(r[0]);
        if (holes) container_wall(pts, r[1], r[2], t, h, hf, p, corner ? "solid" : mode, [corner ? 0 : post_w, bands[0], bands[1]], depth, lining_t, frame, plain, mount) children();
        else container_wall(pts, r[1], r[2], t, h, hf, p, corner ? "solid" : mode, [corner ? 0 : post_w, bands[0], bands[1]], depth, lining_t, frame, plain, mount);
    }
}
function container_is_corner(name) = len(name) > 6 && name[0] == "c" && name[6] == "_";
// a pattern that would fall apart when cut through is raised instead
function container_safe_mode(mode, p) = (mode == "through_cut" || mode == "open_lattice") && !pattern_is_connected(p) ? "raised" : mode;

// ---------- floor ----------
// Floor plate z = 0..t on the outline (a hair inside it, so its edge does not lie in the walls' outer faces).
// border = plain margin from the outline to the pattern (wall thickness + what you want to see). Child: holes in plan.
module container_floor(pts, t, p, mode="solid", border=5, depth=0.6, lining_t=0.6, frame=2) {
    if ($children > 0) _container_floor(pts, t, p, mode, border, depth, lining_t, frame, true) children();
    else _container_floor(pts, t, p, mode, border, depth, lining_t, frame, false) square(1);
}
module _container_floor(pts, t, p, mode, border, depth, lining_t, frame, holes) {
    bb = shell_bounds(pts);
    plan = [2*max(abs(bb[0][0]), abs(bb[1][0])) + 2, 2*max(abs(bb[0][1]), abs(bb[1][1])) + 2];
    pattern_panel(mode, p, plan, t=t, depth=depth, border=border, lining_t=lining_t)
        difference() { offset(delta=-0.05) polygon(pts); if (holes) children(); }
    if (holes && frame > 0) linear_extrude(t) intersection() {
        offset(delta=-0.05) polygon(pts);
        difference() { offset(delta=frame) children(); children(); }
    }
}
function container_plan(pts) = let(bb = shell_bounds(pts)) [2*max(abs(bb[0][0]), abs(bb[1][0])) + 2, 2*max(abs(bb[0][1]), abs(bb[1][1])) + 2];

// ---------- lid ledge ----------
// ring inside the walls with its top at z, `w` wide, growing out of the wall at 45 degrees (prints without support)
module container_ledge(pts, wall_t, z, w=1.6, steps=4) {
    for (k=[0:steps-1]) translate([0, 0, z - w*(k + 1)/steps]) linear_extrude(w/steps + 0.01) difference() {
        offset(delta=-wall_t + 0.1) polygon(pts);
        offset(delta=-wall_t - w*(steps - k)/steps) polygon(pts);
    }
}

// ---------- mounting ----------
// The snap-in attachment plates (attach.scad) need a socket 4.5 mm deep, more than a wall is thick. So the back
// wall (the straight wall at the largest y) gets a solid zone that is part of the wall itself: the pattern stops
// at it and joins it, the wall is thickened outwards just there to CONTAINER_BOSS_T, and the sockets are cut into
// it. Its back face is the mounting plane. Where the zone starts above the floor its underside rises at 45 degrees,
// so the wall still prints upright without support; its other edges are chamfered. If the rim band or the base
// band is close, the solid area runs on into it (following a sloped or wavy rim) instead of leaving a strip of pattern.
//
//   m = container_mount(pts, attach_type, attach_size, attach_count, rim, wall_t, [bottom band, rim band]);
//   assert(container_mount_problem(m) == "", container_mount_problem(m));
//   container_walls(..., mount=m);                       // or container_wall(..., mount=m) for every run
//   pick("attach") container_plates(m, attach_opts(), 0, h_top);
//   parts row: attach_parts_row(attach_type, container_mount_count(m))
CONTAINER_BOSS_T = 6;        // wall thickness in the mounting zone: socket depth 4.5 + 1.5 behind it
CONTAINER_ZONE_M = 4;        // solid wall around the sockets
CONTAINER_MERGE  = 10;       // a strip of pattern narrower than this between the zone and a band is made solid too

// mount spec: [type, size, xs, back centre [x, y], z0, zone width, zone height, floating, protrusion, t,
//              straight back length, zone centre x offset, lowest rim over the zone, merge up, merge down]
// (undef for type "none"). hf = rim height function, t = wall thickness, bands = [bottom, top] plain bands.
function container_mount(pts, type, size, count, hf, t, bands=[4, 4]) = type == "none" ? undef : let(
    bb = shell_bounds(pts), yb = bb[1][1],
    bx = [for (q=pts) if (q[1] > yb - 0.01) q[0]],                      // the points of the straight back wall
    len = max(bx) - min(bx), cx = (max(bx) + min(bx))/2,
    prot = max(0, CONTAINER_BOSS_T - t),
    sw = attach_socket_w(size), sl = attach_socket_len(size),
    xs = attach_xs(count, max(1, len - sw - 2*CONTAINER_ZONE_M)/0.6, type, size=size),   // attach_xs spreads over 60% of its span
    xm = (max(xs) + min(xs))/2, zw = max(xs) - min(xs) + sw + 2*CONTAINER_ZONE_M,
    hmin = min([for (i=[0:8]) hf([cx + xm + (i/8 - 0.5)*zw, yb - 0.01])]),
    zh0 = sl + 2*CONTAINER_ZONE_M,
    z_mid = max(0, min(hmin - zh0, (hmin - zh0)/2)),                   // centred on the wall ...
    floating = z_mid - prot > bands[0] + 1,                            // ... unless that leaves it close to the floor
    zh = zh0 + (floating ? prot : 0),                                  // room for the 45 degree underside
    z0 = floating ? max(0, min(hmin - zh, (hmin - zh)/2)) : 0)
    [type, size, xs, [cx, yb], z0, zw, zh, floating, prot, t, len, xm, hmin,
     hmin - bands[1] - (z0 + zh) < CONTAINER_MERGE, floating && z0 - bands[0] < CONTAINER_MERGE];
function container_mount_count(m) = is_undef(m) ? 0 : len(m[2]);
// "" if the mount fits, otherwise what is wrong
function container_mount_problem(m) = is_undef(m) ? "" :
    m[12] < m[6] ? str("mounting: the back wall is ", m[12], " mm high at its lowest point, the ", m[1], " plate needs ", m[6], " mm. Use a smaller plate or a higher back.") :
    m[5] > m[10] ? str("mounting: ", len(m[2]), " plate(s) of size ", m[1], " need ", m[5], " mm of straight back wall, there is ", m[10], " mm.") : "";
// height of the plate centres above the floor plane
function container_mount_z(m) = m[4] + (m[7] ? m[8] : 0) + CONTAINER_ZONE_M + ATTACH_NOTCH_ + attach_dims(m[1])[1]/2;
ATTACH_NOTCH_ = attach_socket_len("S") - attach_dims("S")[1];          // pry notch below a plate
// the zone and the plain (pattern-free) areas of the wall, in the strip frame (mx = strip x of the zone's middle)
function _container_mount_zone(m, mx) = [mx, m[4], m[5], m[6]];
function _container_mount_plain(m, mx, h) = concat(
    [[mx, m[4] - 2, m[5] + 4, m[6] + 4]],
    m[13] ? [[mx, m[4], m[5] + 4, 2*h]] : [],                          // on up to the rim
    m[14] ? [[mx, -h, m[5] + 4, m[4] + h + 1]] : []);                  // on down to the floor
// the thick part: wall layer + chamfered boss, with the sockets; built in the strip frame of its facet
module _container_mount_block(m, mx, t, h) {
    inside = is_undef($pat_window) || abs($pat_window[0][0] - mx) < $pat_window[1][0]/2;     // only on the facet that holds it
    if (inside) translate([mx, 0, t + m[8]]) rotate([0, 180, 0]) difference() {           // now z = 0 is the back face, +z into the wall
        c = min(1, m[8]);                                                                  // small chamfer at the sides and the top
        union() {
            if (m[8] > 0) hull() {
                translate([-m[5]/2 + c, m[4] - h/2 + (m[7] ? m[8] : 0), 0]) cube([m[5] - 2*c, m[6] - (m[7] ? m[8] : 0) - c, 0.01]);
                translate([-m[5]/2, m[4] - h/2, m[8] - 0.01]) cube([m[5], m[6], 0.01]);
            }
            translate([-m[5]/2, m[4] - h/2, m[8] - 0.01]) cube([m[5], m[6], t + 0.01]);
        }
        attach_sockets(m[0], m[1], [for (x=m[2]) x - m[11]], container_mount_z(m) - h/2);
    }
}
// the plates, seated (z_bottom / z_top = lowest and highest point of the container, for stand and roof plates)
module container_plates(m, opts, z_bottom=0, z_top=100) {
    if (!is_undef(m)) translate([m[3][0], m[3][1] + m[8], container_mount_z(m)]) rotate([90, 0, 0])
        attach_plates(m[0], m[1], m[2], 0, opts, z_bottom - container_mount_z(m), z_top - container_mount_z(m));
}
