// Containers: the parts of an open box built on a shell outline. Patterned walls with openings and plain areas,
// floor, lid ledge, ridge, compartments (divider walls), and a mounting zone for the attachment plates built into the back wall or the floor. Used by projects/custombox, projects/earbuds, projects/sunglasses.
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
use <strings.scad>

// x in the loop's unrolled frame of the outline point nearest to plan point q; y of a height z
function container_u(pts, q) = shell_dist_at(pts, q) - shell_len(pts)/2;
function container_v(z, h) = z - h/2;

// ---------- outline ----------
// The outline of a box from its runs (shell_rect_runs). split = true: every side is its own panel, the outline
// starts at the front. Otherwise the wall is one loop, and its seam is put in the back left corner, where no
// opening, mount or grip ever sits.
function container_box_pts(runs, split=false) = let(e = shell_runs_edges(runs), p = shell_runs_pts(runs),
    c = [for (r=e) if (r[0] == "corner_bl") r])
    split ? p : shell_start_at(p, len(c) > 0 ? c[0][1] + floor((c[0][2] - c[0][1] + 1)/2) : shell_run(e, "left")[1]);

// ---------- walls ----------
// One stretch of wall over outline edges e0..e1 as a patterned panel bent round the outline.
// t = wall thickness, h = reference height (the highest point of the rim), hf = function (p) -> rim height,
// p / mode = pattern spec and how it is applied (PATTERN_MODES), border = [sides, bottom, top] plain bands,
// depth = relief height / engraving depth, lining_t = lining thickness in overlay mode.
// plain  = areas without pattern (solid wall): [[x, z, w, h], ...] centre x in the loop frame, bottom z, size
// mount  = a container_mount() spec: its solid zone and sockets are built into the wall where they belong
// anchor = plan point the pattern is centred on (default: the middle of the strip)
// The optional child cuts openings (loop frame, see the top of this file).
// fit    = on a wall that runs all the way round, adjust the pattern so it closes without a seam (pattern_wrapped)
module container_wall(pts, e0, e1, t, h, hf, p, mode="solid", border=[0, 4, 4], depth=0.8, lining_t=0.6, frame=2, plain=[], mount, anchor, fit=true) {
    q = fit && e0 == 0 && e1 == len(pts) - 1 ? pattern_wrapped(p, shell_len(pts)) : p;
    if ($children > 0) _container_wall(pts, e0, e1, t, h, hf, q, mode, border, depth, lining_t, frame, true, plain, mount, anchor) children();
    else _container_wall(pts, e0, e1, t, h, hf, q, mode, border, depth, lining_t, frame, false, plain, mount, anchor) square(1);
}
module _container_plain_2d(zones, h) { for (z=zones) translate([z[0] - z[2]/2, z[1] - h/2]) square([z[2], z[3]]); }
module _container_wall(pts, e0, e1, t, h, hf, p, mode, border, depth, lining_t, frame, holes, plain, mount, anchor) {
    u = shell_dists(pts); L = u[e1 + 1] - u[e0];
    dx = u[len(pts)]/2 - (u[e0] + u[e1 + 1])/2;                 // loop frame -> this strip's frame
    strip = shell_strip_pts(pts, e0, e1, hf, h);
    // the mount belongs to the strip that holds the middle of its zone
    mx = is_undef(mount) || mount[16] != "back" ? undef : container_u(pts, mount[3] + [mount[11], 0]) + dx;
    has_m = !is_undef(mx) && mount[16] == "back" && abs(mx) < L/2;
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
            if (has_m) offset(delta=-0.3) _container_plain_2d(_container_mount_zones(mount, mx), h);
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
module container_walls(pts, t, h, hf, p, mode="solid", bands=[4, 4], depth=0.8, lining_t=0.6, runs, post_w=3, frame=2, plain=[], mount, anchor, fit=true) {
    if ($children > 0) _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, true, plain, mount, anchor, fit) children();
    else _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, false, plain, mount, anchor, fit) square(1);
}
module _container_walls(pts, t, h, hf, p, mode, bands, depth, lining_t, runs, post_w, frame, holes, plain, mount, anchor, fit) {
    if (is_undef(runs)) {
        if (holes) container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame, plain, mount, anchor, fit) children();
        else container_wall(pts, 0, len(pts) - 1, t, h, hf, p, mode, [0, bands[0], bands[1]], depth, lining_t, frame, plain, mount, anchor, fit);
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
// mount = a container_mount() spec: if it mounts under the floor, its solid zone and sockets are built in here.
module container_floor(pts, t, p, mode="solid", border=5, depth=0.6, lining_t=0.6, frame=2, mount) {
    if ($children > 0) _container_floor(pts, t, p, mode, border, depth, lining_t, frame, true, mount) children();
    else _container_floor(pts, t, p, mode, border, depth, lining_t, frame, false, mount) square(1);
}
module _container_floor_zones_2d(m, grow=0) { for (g=m[15]) translate(m[3] + [g[0], 0]) square([g[1] + 2*grow, m[6] + 2*grow], center=true); }
module _container_floor(pts, t, p, mode, border, depth, lining_t, frame, holes, mount) {
    has_m = !is_undef(mount) && mount[16] == "bottom";
    pattern_panel(mode, p, container_plan(pts), t=t, depth=depth, border=border, lining_t=lining_t)
        difference() {
            offset(delta=-0.05) polygon(pts);
            if (holes) children();
            if (has_m) _container_floor_zones_2d(mount, -0.3);          // the pattern stops at the mounting zone
        }
    if (holes && frame > 0) linear_extrude(t) intersection() {
        offset(delta=-0.05) polygon(pts);
        difference() { offset(delta=frame) children(); children(); }
    }
    // the zone itself: solid floor, thickened upwards (chamfered), sockets from below
    if (has_m) for (g=mount[15]) difference() {
        translate(concat(mount[3] + [g[0], 0], [0])) union() {
            translate([-g[1]/2, -mount[6]/2, 0]) cube([g[1], mount[6], t]);
            if (mount[8] > 0) hull() {
                translate([-g[1]/2, -mount[6]/2, t - 0.01]) cube([g[1], mount[6], 0.01]);
                translate([-g[1]/2 + mount[8], -mount[6]/2 + mount[8], t + mount[8] - 0.01]) cube([g[1] - 2*mount[8], mount[6] - 2*mount[8], 0.01]);
            }
        }
        translate([mount[3][0], 0, 0]) attach_sockets(mount[0], mount[1], g[2], attach_y(mount[3][1]));
    }
}
function container_plan(pts) = let(bb = shell_bounds(pts)) [2*max(abs(bb[0][0]), abs(bb[1][0])) + 2, 2*max(abs(bb[0][1]), abs(bb[1][1])) + 2];

// ---------- ridge ----------
// A rounded ridge standing on z = 0, centred on the origin, running along Y: a saddle that an item rests on or
// is centred by (the bridge of a pair of glasses, a bottle neck, a cable). It only ever rises from the floor:
// nothing reaches below z = 0, however wide and low it is.
//   w = width of the rounded top, foot = width on the floor, h = height, len = length on the floor (along Y)
//   run = [front, back]: how far the top is set in from the foot at the -Y and +Y end (0 = vertical face, more =
//         a gentler slope, so things slide over the ridge instead of catching behind it)
//   crown = 0..1: 0 = the top is a straight bar, 1 = fully domed along Y
module container_ridge(w=13, foot=24, h=26, len=12, run=[2, 6], crown=0.5) {
    r = min(w/2, h);                                       // top radius, never more than the height
    top = max(0.02, len - run[0] - run[1]);                // length of the top
    yc = (run[0] - run[1])/2;                              // the top sits towards the steeper end
    intersection() {
        hull() {
            translate([-max(foot, w)/2, -len/2, 0]) cube([max(foot, w), len, 0.01]);
            translate([0, yc, h - r]) rotate([90, 0, 0]) cylinder(r=r, h=max(0.02, top*(1 - crown)), center=true, $fn=48);
            if (crown > 0) translate([0, yc, h - r]) scale([1, max(0.02, top/2)/r, 1]) sphere(r=r, $fn=48);
        }
        translate([-max(foot, w), -len, 0]) cube([2*max(foot, w), 2*len, h + 1]);     // nothing below the floor
    }
}

// ---------- lid ledge ----------
// ring inside the walls with its top at z, `w` wide, growing out of the wall at 45 degrees (prints without support)
module container_ledge(pts, wall_t, z, w=1.6, steps=4) {
    for (k=[0:steps-1]) translate([0, 0, z - w*(k + 1)/steps]) linear_extrude(w/steps + 0.01) difference() {
        offset(delta=-wall_t + 0.1) polygon(pts);
        offset(delta=-wall_t - w*(steps - k)/steps) polygon(pts);
    }
}

// ---------- compartments ----------
// Divider walls that split the inside into compartments. The layout is a list of groups: rows (front to back)
// that are each split into compartments from left to right, or with order = "columns", columns (left to right)
// each split from front to back. Sizes are relative weights (percentages or any numbers): [[33, 33, 33], [50, 50],
// [100]] = a row of three, a row of two and one long compartment. The sizes are the compartments' own inside
// sizes: the divider thickness is taken off before sharing out the room.
//
//   g = container_layout(text, rows, cols, sizes_text);                 // from Customizer fields (see below)
//   grid = container_grid(pts, wall_t, g[0], g[1], order, divider_t);
//   container_walls(..., plain=container_grid_plain(pts, grid, post));  // solid joints in the outer walls
//   container_dividers(pts, grid, divider_t, h, hf, [px, mode_x], [py, mode_y], bands, ...);
//   grid[2] = notes ("" or what was changed), grid[3] = [smallest compartment x, y]
//
// Dividers along x (between rows) and along y (between columns) can carry different patterns (match them to the
// front / back and the side walls). They follow the rim height function hf (slopes, waves); lower them with an
// hf of their own. Their ends reach into the middle of the outer wall, where a plain joint keeps the pattern
// clear; a solid strip under each divider keeps a patterned floor closed under it.
CONTAINER_MIN_CELL = 8;      // narrowest compartment (mm); a layout that would go below it is thinned out
CONTAINER_DIV_FOOT = 2;      // solid floor strip on each side of a divider
// layout from text: "33,33,33 / 50,50 / 100" = one group per row (or column) with the compartments' sizes;
// empty = a plain grid of `rows` x `cols`. sizes_text = the rows' (columns') own sizes, empty = equal.
// Returns [groups, sizes, note]; weights of 0 or less are dropped.
function container_layout(text, rows=1, cols=1, sizes_text="") = let(
    g0 = [for (g=str_groups(text)) let(v = [for (x=g) if (x > 0) x]) if (len(v) > 0) v],
    groups = len(g0) > 0 ? g0 : [for (i=[1:1:max(1, rows)]) [for (j=[1:1:max(1, cols)]) 1]],
    s0 = [for (x=str_nums(sizes_text)) if (x > 0) x],
    sizes = len(s0) == len(groups) ? s0 : [for (g=groups) 1],
    off = [for (v=concat(len(g0) > 0 ? g0 : [], len(s0) == len(groups) ? [s0] : [])) let(t = v*[for (x=v) 1]) if (abs(t - 100) > 1.5 && len(v) > 1) 1])
    [groups, sizes, str(
        len(s0) > 0 && len(s0) != len(groups) ? str("compartments: ", len(s0), " row/column sizes given for ", len(groups), " rows/columns, using equal sizes") : "",
        len(s0) > 0 && len(s0) != len(groups) && len(off) > 0 ? "; " : "",
        len(off) > 0 ? "compartments: sizes that do not add up to 100 are scaled to fill the box" : "")];
// cells of span [a, b] for weights w with dividers t thick between them: [[start, end], ...]
function _ctr_cum(v, k) = k <= 0 ? 0 : _ctr_cum(v, k - 1) + v[k - 1];
function container_split(a, b, w, t) = let(n = len(w), s = w*[for (x=w) 1], avail = b - a - (n - 1)*t)
    [for (k=[0:1:n - 1]) let(c0 = a + avail*_ctr_cum(w, k)/s + k*t) [c0, c0 + avail*w[k]/s]];
// keep the groups and their compartments to what fits CONTAINER_MIN_CELL (the last ones are dropped)
function _ctr_fit(w, span, t) = len(w) <= 1 || (span - (len(w) - 1)*t)*min(w)/(w*[for (x=w) 1]) >= CONTAINER_MIN_CELL - 0.01 ? w
    : _ctr_fit([for (i=[0:1:len(w) - 2]) w[i]], span, t);
// where the line c + l*d leaves the outline: [l backwards (< 0), l forwards (> 0), cos of the angle at each wall]
function _ctr_hits(pts, c, d) = let(n = len(pts),
    h = [for (i=[0:n-1]) let(A = pts[i], B = pts[(i+1)%n], e = B - A, den = d[0]*e[1] - d[1]*e[0]) if (abs(den) > 1e-9)
        let(w = A - c, l = (w[0]*e[1] - w[1]*e[0])/den, m = (w[0]*d[1] - w[1]*d[0])/den) if (m >= -1e-6 && m <= 1 + 1e-6)
        [l, abs(d*[e[1], -e[0]])/norm(e)]],
    neg = [for (x=h) if (x[0] < 0) x], pos = [for (x=h) if (x[0] > 0) x],
    a = [for (x=neg) if (x[0] == max([for (y=neg) y[0]])) x][0], b = [for (x=pos) if (x[0] == min([for (y=pos) y[0]])) x][0])
    [a, b];
// how far in from the outer face (along the divider) its end must stop: the centre in the middle of the wall,
// both corners inside the outer face
function _ctr_inset(wall_t, t, cs) = let(c = max(0.5, cs), tn = sqrt(1 - c*c)/c) (wall_t/2 + t/2*tn)/c;
// The grid: [cells, dividers, notes, [smallest x, smallest y]]
//   cells    = [[x0, y0], [x1, y1]] inside each compartment
//   dividers = [A, B, axis ("x" = runs along x), junctions (distances from A where other dividers meet it), ends
//               in the outer wall [at A, at B]]
function container_grid(pts, wall_t, groups, sizes, order="rows", t=2) = let(
    bb = shell_bounds(pts), lo = bb[0] + [wall_t, wall_t], hi = bb[1] - [wall_t, wall_t],
    ax = order == "columns" ? 0 : 1, bx = 1 - ax,                       // groups are stacked along ax, split along bx
    P = function(a, b) ax == 1 ? [b, a] : [a, b],
    n0 = len(groups),
    sz = _ctr_fit(sizes, hi[ax] - lo[ax], t), n = len(sz),
    gr = [for (k=[0:1:n - 1]) _ctr_fit(groups[k], hi[bx] - lo[bx], t)],
    prim = container_split(lo[ax], hi[ax], sz, t),
    sec = [for (k=[0:1:n - 1]) container_split(lo[bx], hi[bx], gr[k], t)],
    cells = [for (k=[0:1:n - 1]) for (c=sec[k]) let(p0 = P(prim[k][0], c[0]), p1 = P(prim[k][1], c[1])) [p0, p1]],
    // dividers between groups: across the whole box, ends found on the outline
    mains = [for (k=[1:1:n - 1]) let(a = prim[k][0] - t/2, c = P(a, (lo[bx] + hi[bx])/2), d = P(0, 1), h = _ctr_hits(pts, c, d),
        A = c + d*(h[0][0] + _ctr_inset(wall_t, t, h[0][1])), B = c + d*(h[1][0] - _ctr_inset(wall_t, t, h[1][1])),
        js = [for (kk=[k - 1, k]) for (j=[1:1:len(sec[kk]) - 1]) (sec[kk][j][0] - t/2) - (c + d*(h[0][0] + _ctr_inset(wall_t, t, h[0][1])))[bx]])
        [A, B, ax == 1 ? "x" : "y", js, [true, true]]],
    // dividers inside a group: from divider to divider, or into the outer wall at the first and last group
    cross = [for (k=[0:1:n - 1]) for (j=[1:1:len(sec[k]) - 1]) let(b = sec[k][j][0] - t/2, c = P((prim[k][0] + prim[k][1])/2, b), d = P(1, 0),
        h = _ctr_hits(pts, c, d),
        a0 = k == 0 ? (c + d*(h[0][0] + _ctr_inset(wall_t, t, h[0][1])))[ax] : prim[k][0] - t/2,
        a1 = k == n - 1 ? (c + d*(h[1][0] - _ctr_inset(wall_t, t, h[1][1])))[ax] : prim[k][1] + t/2)
        [P(a0, b), P(a1, b), ax == 1 ? "y" : "x", [], [k == 0, k == n - 1]]],
    small = [min([for (c=cells) c[1][0] - c[0][0]]), min([for (c=cells) c[1][1] - c[0][1]])],
    cut = n < n0 || len([for (k=[0:1:n - 1]) if (len(gr[k]) < len(groups[k])) 1]) > 0)
    [cells, concat(mains, cross),
     cut ? str("compartments: fewer than asked, each needs at least ", CONTAINER_MIN_CELL, " mm inside") : "", small];
// plain (pattern-free) joints in the outer walls where the dividers meet them: pass as `plain` to container_walls
function container_grid_plain(pts, grid, t=2, post=3) = [for (dv=grid[1]) for (e=[0, 1]) if (dv[4][e])
    [container_u(pts, dv[e] + (dv[e] - dv[1 - e])/norm(dv[e] - dv[1 - e])*t), -1, t + 2*post, 1e4]];
// One divider wall from A to B (plan points), t thick, centred on the line. hf = top height function (plan point),
// h = reference height (the highest point), p / mode = pattern, border = [ends, bottom, top] plain bands,
// junctions = distances from A where other dividers meet it (kept plain), notch = [depth, width]: a finger notch
// in the middle of its top edge.
module container_divider(A, B, t, h, hf, p, mode="solid", border=[3, 4, 4], depth=0.8, lining_t=0.6, junctions=[], notch=[0, 30]) {
    L = norm(B - A); d = (B - A)/L; n = [d[1], -d[0]];
    q = [A + n*t/2, B + n*t/2];                                          // shell_wrap builds on the inner side of the line
    hn = function(x) is_undef(notch) || notch[0] <= 0 ? 0 : shell_rim_dip([(x - A)*d - L/2, -50], [L, 100], notch[0], notch[1], 0, "front");
    hfd = function(x) hf(x) - hn(x);
    jp = [for (s=junctions) [s - L, -1, t + 2*border[0], 1e4]];         // loop frame of a two-point outline
    container_wall(q, 0, 0, t, h, hfd, p, mode, border, depth, lining_t, 0, plain=jp, fit=false);
}
// all dividers of a grid. specs = [[pattern, mode] for dividers along x, [pattern, mode] along y]; bands = [bottom,
// top]; post = plain band at their ends and joints; floor_t = floor thickness (a solid strip under each divider)
module container_dividers(pts, grid, t, h, hf, specs, bands=[4, 4], post=3, depth=0.8, lining_t=0.6, notch=[0, 30], floor_t=2) {
    for (dv=grid[1]) {
        s = dv[2] == "x" ? specs[0] : specs[1];
        container_divider(dv[0], dv[1], t, h, hf, s[0], s[1], [post, bands[0], bands[1]], depth, lining_t, dv[3], notch);
        L = norm(dv[1] - dv[0]);
        if (floor_t > 0) translate(dv[0]) rotate(atan2(dv[1][1] - dv[0][1], dv[1][0] - dv[0][0]))
            translate([0, -t/2 - CONTAINER_DIV_FOOT, 0]) cube([L, t + 2*CONTAINER_DIV_FOOT, floor_t]);
    }
}

// ---------- mounting ----------
// The snap-in attachment plates (attach.scad) need a socket ATTACH_T deep plus ATTACH_BACK of closed wall behind
// it (attach_host_t() = 5.2 mm), usually more than a wall is thick. So the back wall (the straight wall at the
// largest y) gets a solid zone that is part of the wall itself: the pattern stops at it and joins it. The zone is
// flush with the wall's INSIDE face (nothing stands into the container, its content keeps all its room) and uses
// the wall's own thickness; only what is missing (CONTAINER_BOSS_T - t) grows OUTWARDS, with 45 degree edges all
// round (a flat bottom where it stands on the floor), so it prints upright without support. The sockets are cut
// into it from behind and the plates sit flush with its outer face. Every plate type uses the same socket, so the
// plates stay interchangeable. If the rim band or the base band is close, the solid area of the wall runs on into
// it (following a sloped or wavy rim) instead of leaving a strip of pattern.
// Plates that sit close together share one zone; further apart, each gets its own and the pattern continues between.
//
//   m = container_mount(pts, attach_type, attach_size, attach_count, rim, wall_t, [bottom band, rim band]);
//   attach_note(container_mount_note(m, attach_type, attach_size, attach_count));   // warns if it had to be reduced or left out
//   container_walls(..., mount=m);                       // or container_wall(..., mount=m) for every run
//   container_floor(..., mount=m);                       // builds it instead when the type mounts under the floor
//   container_attach(part, m, attach_opts(), 0, h_top, attach_joint);     // plates, track / fin, ball joint parts
//   parts rows: each container_attach_rows(attach_type, m, attach_joint)
CONTAINER_BOSS_T = attach_host_t();   // wall thickness in the mounting zone: socket + closed back (5.2 mm)
CONTAINER_ZONE_M = 4;        // solid wall around the sockets
CONTAINER_MERGE  = 10;       // a strip of pattern narrower than this between the zone and a band is made solid too

// mount spec: [type, size, xs, back centre [x, y] (outer face of the wall), z0, total width, zone height, floating,
//              protrusion (how far the zone stands out behind the wall), t,
//              straight back length, centre x offset, lowest rim over the zones, merge up, merge down,
//              zones [[centre x offset, width, its plates' x], ...]]
// (undef for type "none"). hf = rim height function, t = wall thickness, bands = [bottom, top] plain bands.
// The mount is fitted to the container: if the plates asked for do not fit, fewer plates and then the next
// smaller plate size are tried; if nothing fits there is no mount (undef). container_mount_note() says what was
// changed, so a project can warn instead of stopping:  attach_note(container_mount_note(m, type, size, count));
function container_mount(pts, type, size, count, hf, t, bands=[4, 4], floor_t=2) =
    type == "none" ? undef : _container_mount_fit(pts, type, size, count, count, hf, t, bands, floor_t);
function _container_mount_fit(pts, type, size, count, count0, hf, t, bands, floor_t) =
    let(m = _container_mount_try(pts, type, size, count, hf, t, bands, floor_t))
    container_mount_problem(m) == "" ? m :
    count > 1 ? _container_mount_fit(pts, type, size, count - 1, count0, hf, t, bands, floor_t) :
    attach_smaller(size) != "" ? _container_mount_fit(pts, type, attach_smaller(size), count0, count0, hf, t, bands, floor_t) : undef;
function container_mount_note(m, type, size, count) =
    type == "none" ? "" :
    is_undef(m) ? str("mounting left out: not even one S plate fits this ", attach_face(type) == "bottom" ? "floor" : "back wall",
                      attach_face(type) == "bottom" ? " (it needs 38 x 41 mm of floor inside the walls)"
                                                    : " (it needs 41 mm of height and 38 mm of straight width: raise the back or the height)") :
    m[1] != size ? str("mounting: plate size reduced from ", size, " to ", m[1], ", ", len(m[2]), " plate(s), to fit the ", m[16] == "bottom" ? "floor" : "back wall") :
    len(m[2]) < count ? str("mounting: ", len(m[2]), " plate(s) instead of ", count, " fit the ", m[16] == "bottom" ? "floor" : "back wall") : "";
function _container_mount_try(pts, type, size, count, hf, t, bands, floor_t) =
    attach_face(type) == "bottom" ? _container_mount_bottom(pts, type, size, count, t, floor_t) : let(
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
    zh = zh0 + (floating ? prot : 0),                                  // room for the pad's 45 degree underside
    z0 = floating ? max(0, min(hmin - zh, (hmin - zh)/2)) : 0,
    // plates close together share one zone; plates further apart get a zone each, with pattern between them
    gw = sw + 2*CONTAINER_ZONE_M,
    apart = len(xs) > 1 && xs[1] - xs[0] - gw >= CONTAINER_MERGE,
    groups = apart ? [for (x=xs) [x, gw, [x]]] : [[xm, zw, xs]])
    [type, size, xs, [cx, yb], z0, zw, zh, floating, prot, t, len, xm, hmin,
     hmin - bands[1] - (z0 + zh) < CONTAINER_MERGE, floating && z0 - bands[0] < CONTAINER_MERGE, groups, "back"];
// The same for a type that mounts under the host (attach_face(type) == "bottom", e.g. the fin): the zone is in
// the floor, in the middle of the plan, thickened upwards into the container; the sockets open downwards.
// Same layout; [3] = plan centre, [9] = floor thickness, [10] / [12] = room inside the walls in x / y.
function _container_mount_bottom(pts, type, size, count, t, floor_t) = let(
    bb = shell_bounds(pts), c = (bb[0] + bb[1])/2,
    room = bb[1] - bb[0] - 2*[t + 2, t + 2],
    sw = attach_socket_w(size), sl = attach_socket_len(size),
    xs = attach_xs(count, max(1, room[0] - sw - 2*CONTAINER_ZONE_M)/0.6, type, size=size),
    xm = (max(xs) + min(xs))/2, zw = max(xs) - min(xs) + sw + 2*CONTAINER_ZONE_M, gw = sw + 2*CONTAINER_ZONE_M,
    apart = len(xs) > 1 && xs[1] - xs[0] - gw >= CONTAINER_MERGE)
    [type, size, xs, c, 0, zw, sl + 2*CONTAINER_ZONE_M, false, max(0, CONTAINER_BOSS_T - floor_t), floor_t, room[0], xm, room[1],
     false, false, apart ? [for (x=xs) [x, gw, [x]]] : [[xm, zw, xs]], "bottom"];

function container_mount_count(m) = is_undef(m) ? 0 : len(m[2]);
// "" if the mount fits, otherwise what is wrong
function container_mount_problem(m) = is_undef(m) ? "" :
    m[16] == "bottom" ? (m[5] > m[10] + 0.01 || m[6] > m[12] + 0.01 ? str("mounting under the floor: ", len(m[2]), " plate(s) of size ", m[1], " need ", m[5], " x ", m[6],
        " mm of floor inside the walls, there is ", m[10], " x ", m[12], " mm.") : "") :
    m[12] < m[6] - 0.01 ? str("mounting: the back wall is ", m[12], " mm high at its lowest point, the ", m[1], " plate needs ", m[6], " mm. Use a smaller plate or a higher back.") :
    m[5] > m[10] + 0.01 ? str("mounting: ", len(m[2]), " plate(s) of size ", m[1], " need ", m[5], " mm of straight back wall, there is ", m[10], " mm.") : "";
// height of the plate centres above the floor plane
function container_mount_z(m) = m[4] + (m[7] ? m[8] : 0) + CONTAINER_ZONE_M + ATTACH_NOTCH_ + attach_dims(m[1])[1]/2;
ATTACH_NOTCH_ = attach_socket_len("S") - attach_dims("S")[1];          // pry notch below a plate
// the zones and the plain (pattern-free) areas of the wall, in the strip frame (mx = strip x of the mount's middle;
// along the back wall the strip's x runs against the plates' x)
function _container_mount_zones(m, mx) = [for (g=m[15]) [mx - (g[0] - m[11]), m[4], g[1], m[6]]];
function _container_mount_plain(m, mx, h) = [for (z=_container_mount_zones(m, mx)) each concat(
    [[z[0], z[1] - 2, z[2] + 4, z[3] + 4]],
    m[13] ? [[z[0], z[1], z[2] + 4, 2*h]] : [],                        // on up to the rim
    m[14] ? [[z[0], -h, z[2] + 4, z[1] + h + 1]] : [])];               // on down to the floor
// The thick parts, built in the strip frame of their facet (z = 0 inside face, z = t outside face). The zone is
// flush with the inside face; the thickness the sockets need beyond the wall (c = m[8]) stands out behind it as a
// pad with 45 degree edges (flat at the bottom when the zone stands on the floor). The sockets are cut in from
// the pad's outer face, leaving ATTACH_BACK of closed wall on the inside.
module _container_mount_block(m, mx, t, h) {
    for (g=m[15]) {
        gx = mx - (g[0] - m[11]); w = g[1];
        c = m[8] + (is_undef($pat_shrink) ? 0 : $pat_shrink);            // shell_wrap pulls some facets in a hair: the pad face stays on the plane
        inside = is_undef($pat_window) || abs($pat_window[0][0] - gx) < $pat_window[1][0]/2;    // only on the facet that holds it
        if (inside) translate([gx, 0, t + c]) rotate([0, 180, 0]) difference() {             // now z = 0 is the pad's outer face, +z into the container
            union() {
                translate([-w/2, m[4] - h/2, c - 0.01]) cube([w, m[6], t + 0.01]);                // the wall itself, solid
                if (c > 0) hull() {
                    translate([-w/2, m[4] - h/2, c - 0.01]) cube([w, m[6], 0.01]);
                    translate([-w/2 + c, m[4] - h/2 + (m[7] ? c : 0), 0]) cube([w - 2*c, m[6] - c - (m[7] ? c : 0), 0.01]);
                }
            }
            attach_sockets(m[0], m[1], [for (x=g[2]) x - g[0]], container_mount_z(m) - h/2);
        }
    }
}
// How thick a container's floor must be for a mount underneath (attach_face(type) == "bottom"): the whole floor
// gets that thickness, so it stays flat inside and the container still stands flat outside.
// How much deeper a container must be inside so that the pad of a back mount does not take room from its
// content, and how thick its floor must be for a mount underneath (the floor stays flat inside).
function container_mount_floor(type, floor_t) = type != "none" && attach_face(type) == "bottom" ? max(floor_t, CONTAINER_BOSS_T) : floor_t;
// Everything that hangs on the mount, seated: plates, slide track or fin, ball joint parts. `part` = the project's
// part variable: one line draws whichever of them is selected (see attach_all). z_bottom / z_top = lowest and
// highest point of the container (for roof plates).
module container_attach(part, m, opts, z_bottom=0, z_top=100, joint="none") {
    if (!is_undef(m)) {
        if (m[16] == "bottom") translate([m[3][0], 0, 0]) attach_all(part, m[0], m[1], m[2], attach_y(m[3][1]), opts, joint=joint);
        else translate([m[3][0], m[3][1] + m[8], container_mount_z(m)]) rotate([90, 0, 0])      // on the pad's outer face
            attach_all(part, m[0], m[1], m[2], 0, opts, z_bottom - container_mount_z(m), z_top - container_mount_z(m), joint);
    }
}
// rows for the project's `parts` table:  parts = [ ..., each container_attach_rows(attach_type, m, attach_joint) ];
function container_attach_rows(type, m, joint="none", pull=[0, 40, 0], opts=undef) =
    attach_rows(is_undef(m) ? "none" : type, container_mount_count(m), joint, is_undef(m) || m[16] == "back" ? pull : [0, 0, -40],
                frame=is_undef(m) || m[16] == "back" ? "back" : "flat", opts=opts);
