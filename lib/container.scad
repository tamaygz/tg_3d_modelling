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
// The optional child cuts openings (loop frame, see the top of this file).
module container_wall(pts, e0, e1, t, h, hf, p, mode="solid", border=[0, 4, 4], depth=0.8, lining_t=0.6, frame=2) {
    if ($children > 0) _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, true) children();
    else _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, false) square(1);
}
module _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, holes) {
    u = shell_dists(pts); L = u[e1 + 1] - u[e0];
    dx = u[len(pts)]/2 - (u[e0] + u[e1 + 1])/2;                 // loop frame -> this strip's frame
    strip = shell_strip_pts(pts, e0, e1, hf, h);
    shell_wrap(pts, t, e0, e1, h=h, above=depth) {
        pattern_panel(mode, p, [L + 1, h], t=t, depth=depth, border=border, lining_t=lining_t)
            difference() { polygon(strip); if (holes) translate([dx, 0]) children(); }
        if (holes && frame > 0) linear_extrude(t) shell_window_2d() intersection() {
            polygon(strip);
            difference() { offset(delta=frame) translate([dx, 0]) children(); translate([dx, 0]) children(); }
        }
    }
}
// All walls of a container. runs = undef: one panel all the way round (the pattern runs through the corners).
// runs = shell_runs_edges(...) of a box outline: every side is its own panel with `post_w` of plain wall at both
// ends, and the corner runs are plain.
module container_walls(pts, t, h, hf, p, mode="solid", bands=[4, 4], depth=0.8, lining_t=0.6, runs, post_w=3, frame=2) {
    if ($children > 0) _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, true) children();
    else _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, false) square(1);
}
module _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, holes) {
    if (is_undef(runs)) {
        if (holes) container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame) children();
        else container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame);
    }
    else for (r=runs) {
        corner = container_is_corner(r[0]);
        if (holes) container_wall(pts, r[1], r[2], t, h, hf, p, corner ? "solid" : mode, [corner ? 0 : post_w, bands[0], bands[1]], depth, lining_t, frame) children();
        else container_wall(pts, r[1], r[2], t, h, hf, p, corner ? "solid" : mode, [corner ? 0 : post_w, bands[0], bands[1]], depth, lining_t, frame);
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
// A solid boss on the outside of the back wall (the straight wall at y = y_back) takes the sockets of the
// snap-in attachment plates (attach.scad); its back face is the mounting plane. Walls are thinner than a socket.
function container_boss_t() = attach_depth() + 1.5;
// socket x positions on a back wall with `len` of straight length (fewer than `count` if they do not fit)
function container_mount_xs(count, len, type, size) =
    type == "none" ? [] : attach_xs(count, max(1, len - attach_socket_w(size) - 8)/0.6, type, size=size);   // attach_xs spreads over 60% of its span
function container_boss_size(xs, size) = [len(xs) == 0 ? 0 : max(xs) - min(xs) + attach_socket_w(size) + 8, attach_socket_len(size) + 8];
// boss centre height for a back wall whose lowest point is h_back
function container_boss_z(h_back, size) = let(bh = container_boss_size([0], size)[1]) max(bh/2, min(h_back - bh/2, h_back/2));
// "" if the plates fit, otherwise what is wrong
function container_mount_problem(xs, size, len, h_back) = let(b = container_boss_size(xs, size))
    h_back < b[1] ? str("mounting: the back wall is ", h_back, " mm high at its lowest point, the ", size, " plate needs ", b[1], " mm. Use a smaller plate or a higher back.") :
    b[0] > len ? str("mounting: ", len(xs), " plate(s) of size ", size, " need ", b[0], " mm of straight back wall, there is ", len, " mm.") : "";
// places children drawn in the attachment frame (back face z = 0, +Y up) onto the back wall
module container_to_back(y_back, z) { translate([0, y_back + container_boss_t() - 0.2, z]) rotate([90, 0, 0]) children(); }
module container_boss(type, size, xs, y_back, z) {
    b = container_boss_size(xs, size);
    container_to_back(y_back, z) difference() {
        translate([(min(xs) + max(xs))/2 - b[0]/2, -b[1]/2, 0]) cube([b[0], b[1], container_boss_t()]);
        attach_sockets(type, size, xs, attach_y(0));
    }
}
// the plates, seated (z_bottom / z_top = lowest and highest point of the container, for stand and roof plates)
module container_plates(type, size, xs, y_back, z, opts, z_bottom=0, z_top=100) {
    container_to_back(y_back, z) attach_plates(type, size, xs, attach_y(0), opts, z_bottom - z, z_top - z);
}
