// Shells: thin walls that follow a closed outline. Boxes, baskets, bins, trays, lamp shades.
// Use:  use <../../lib/shell.scad>
//
// An outline is a closed list of [x, y] points, counter-clockwise, in the XY plane (the floor plane, z = 0).
// It is the OUTER face of the wall; the wall body lies inside it and rises along +Z.
//
// shell_wrap() bends a flat panel round the outline. Its child builds the panel in the "strip frame":
//     x = distance along the outline, 0 at the middle of the strip
//     y = height, 0 at mid-height (y = -h/2 is the floor plane z = 0, y = +h/2 is z = h)
//     z = thickness: z = 0 is the inner face, z = t the outer face (on the outline); relief goes beyond t
// which is exactly the frame of lib/patterns.scad with size = [strip length, h], so
//     shell_wrap(pts, t, h=60) pattern_panel("through_cut", "hex_honeycomb", [shell_len(pts), 60], t=t) polygon(shell_strip_pts(pts, hf=..., h=60));
// makes a patterned wall all round. The wall is built one flat facet per outline edge: shell_wrap sets
// $pat_window for each facet, the pattern modules build just that piece, and the facets overlap where they
// meet. Straight runs of the outline should therefore be ONE long edge (fast); curves need short edges.
// Other 2D content in the child must be clipped with shell_window_2d().
//
// The top edge can follow any height function hf(p) of the position p = [x, y] (slopes, waves):
// shell_strip_pts() turns it into the outline of the unrolled strip.
//
// Tapered walls (pots, vases, lamp shades, cups): shell_wrap_taper() leans the wall in or out. The outline is
// scaled by s about the z axis between z = 0 and z = ht (s = top size / bottom size). Such a wall is a pyramid
// frustum: every facet is a flat trapezoid, and the whole wall unrolls exactly into a flat fan (it is developable),
// so patterns keep their true size on the wall. Its child is built in the "fan frame", which is the strip frame
// bent round the fan's apex: see the section "tapered walls" below.
use <patterns.scad>

SHELL_CORNERS = ["round", "chamfer", "square"];
SHELL_LAP    = 0.1;     // mm a facet reaches past its joint, so neighbours overlap
SHELL_SHRINK = 0.04;    // mm every other facet is pulled in: identical cut-outs of two facets then cross cleanly
                        // at the joint instead of almost coinciding (which leaves slivers in the exported mesh)

// ---------- outlines ----------
// Box outline as named runs [[name, points], ...], counter-clockwise starting with the front side (y = -depth/2):
// "front", "corner_fr", "right", "corner_br", "back", "corner_bl", "left", "corner_fl" (no corner runs when
// square). corner: see SHELL_CORNERS, r = corner radius / chamfer size, fn = edges per round corner, side_n =
// edges per straight side (1 unless the outline is going to be waved or needs a vertex in the middle).
function shell_rect_runs(size, corner="round", r=10, fn=6, side_n=1) = let(
    W = size[0], D = size[1], rr = corner == "square" ? 0 : min(r, W/2 - 0.5, D/2 - 0.5),
    c = [[W/2 - rr, -D/2 + rr], [W/2 - rr, D/2 - rr], [-W/2 + rr, D/2 - rr], [-W/2 + rr, -D/2 + rr]],   // corner centres fr, br, bl, fl
    a0 = [-90, 0, 90, 180],
    ends = [for (k=[0:3]) [c[(k+3)%4] + rr*[cos(a0[k]), sin(a0[k])], c[k] + rr*[cos(a0[k]), sin(a0[k])]]],   // side k: start, end
    names = ["front", "right", "back", "left"], cn = ["corner_fr", "corner_br", "corner_bl", "corner_fl"],
    m = corner == "chamfer" ? 1 : fn)
    [for (k=[0:3]) each concat(
        [[names[k], [for (i=[0:side_n]) ends[k][0] + (ends[k][1] - ends[k][0])*i/side_n]]],
        rr > 0 ? [[cn[k], [for (i=[0:m]) c[k] + rr*[cos(a0[k] + 90*i/m), sin(a0[k] + 90*i/m)]]]] : [])];
// all points of a list of runs as one closed outline (shared end points once)
function shell_runs_pts(runs) = [for (r=runs) for (i=[0:len(r[1])-2]) r[1][i]];
// [[name, first edge, last edge], ...] of the runs within shell_runs_pts()
function shell_runs_edges(runs, k=0, e=0) = k >= len(runs) ? [] :
    concat([[runs[k][0], e, e + len(runs[k][1]) - 2]], shell_runs_edges(runs, k + 1, e + len(runs[k][1]) - 1));
function shell_run(edges, name) = [for (r=edges) if (r[0] == name) r][0];

// ellipse and superellipse ("squircle": e = 2 ellipse .. 4 soft box .. 8 nearly square) with n edges, starting at the back
function shell_ellipse_pts(size, n=48) = [for (i=[0:n-1]) let(a = 90 + i*360/n) [size[0]/2*cos(a), size[1]/2*sin(a)]];
function shell_squircle_pts(size, e=4, n=48) = [for (i=[0:n-1]) let(a = 90 + i*360/n, c = cos(a), s = sin(a))
    [size[0]/2*sign(c)*pow(abs(c), 2/e), size[1]/2*sign(s)*pow(abs(s), 2/e)]];

// the same outline starting at point k
function shell_start_at(pts, k) = let(n = len(pts)) [for (i=[0:n-1]) pts[(i + k)%n]];

// ---------- measuring ----------
function _sh_sum(v, n) = n <= 0 ? 0 : v[n-1] + _sh_sum(v, n - 1);
function shell_edge_lens(pts) = let(n = len(pts)) [for (i=[0:n-1]) norm(pts[(i+1)%n] - pts[i])];
// distance along the outline of every point; n + 1 values, the last is the perimeter
function shell_dists(pts) = let(l = shell_edge_lens(pts)) [for (i=[0:len(pts)]) _sh_sum(l, i)];
function shell_len(pts, e0=0, e1) = let(u = shell_dists(pts), b = is_undef(e1) ? len(pts) - 1 : e1) u[b + 1] - u[e0];
// area of the outline (shoelace), mm2
function shell_area(pts) = let(n = len(pts)) abs([for (i=[0:n-1]) pts[i][0]*pts[(i+1)%n][1] - pts[(i+1)%n][0]*pts[i][1]]*[for (i=[0:n-1]) 1])/2;
function shell_bounds(pts) = [[min([for (p=pts) p[0]]), min([for (p=pts) p[1]])], [max([for (p=pts) p[0]]), max([for (p=pts) p[1]])]];
// outward unit normal of edge i, and of point i (mean of its two edges)
function shell_edge_normal(pts, i) = let(d = pts[(i+1)%len(pts)] - pts[i]) [d[1], -d[0]]/norm(d);
function shell_point_normal(pts, i) = let(n = len(pts), v = shell_edge_normal(pts, i) + shell_edge_normal(pts, (i + n - 1)%n)) v/norm(v);

// wave the outline in plan: every point moves in or out by amp*sin(count waves round the outline).
// Needs short edges (side_n in shell_rect_runs, n in the ellipse functions).
function shell_wavy_pts(pts, amp=2, count=8, phase=0) = amp == 0 ? pts : let(u = shell_dists(pts), L = u[len(pts)])
    [for (i=[0:len(pts)-1]) pts[i] + shell_point_normal(pts, i)*amp*sin(360*count*u[i]/L + phase)];

// the outline moved in (d > 0) or out (d < 0) by d along its point normals: an approximate offset for smooth
// outlines and convex polygons (corners keep their angle: the move is d / cos(half the turn) there)
function shell_inset_pts(pts, d) = let(n = len(pts))
    [for (i=[0:n-1]) let(a = shell_edge_normal(pts, (i + n - 1)%n), b = shell_edge_normal(pts, i), m = (a + b)/norm(a + b))
        pts[i] - m*d/max(0.2, m*a)];
// regular polygon with k sides and circumradius r (k >= 24 reads as a circle), one corner pointing to `angle`
function shell_ngon_pts(r, k, angle=90) = [for (i=[0:k-1]) let(a = angle + 360*i/k) [r*cos(a), r*sin(a)]];

// ---------- height field ----------
// A ready-made rim height for a box of `size`: base height at the front left, rising by rise = [to the right,
// to the back] across the box, plus cosine waves across the width and the depth:
// waves = [[amplitude, count], [amplitude, count]] (x, y), phase in degrees. (Older form of shell_rim() below.)
function shell_rim_height(p, size, base, rise=[0, 0], waves=[[0, 1], [0, 1]], phase=0) =
    shell_rim(p, size, base, [0, rise[1], 0, rise[0]], waves, phase);
// The same per side, for a box of plan `size` centred on the origin (front = -y, back = +y, left = -x, right = +x):
//   raise   = [front, back, left, right]: how much higher that wall's rim is (negative = lower). Each one slopes
//             to 0 at the opposite wall, and they add up (back 20 + right 10: the back right corner is 30 higher).
//   waves   = [[amplitude, count] along x (front and back), [amplitude, count] along y (left and right)]:
//             the rim rises and falls by `amplitude` mm, `count` waves over the width / depth
//   notches = [[side, depth, width, center], ...]: a dip in the rim of that wall (see shell_rim_dip: grip cut-outs,
//             pouring lips); `width` at half depth, `center` shifts it along the wall
function shell_rim(p, size, base, raise=[0, 0, 0, 0], waves=[[0, 1], [0, 1]], phase=0, notches=[]) =
    base + raise[0]*(0.5 - p[1]/size[1]) + raise[1]*(0.5 + p[1]/size[1])
         + raise[2]*(0.5 - p[0]/size[0]) + raise[3]*(0.5 + p[0]/size[0])
         + waves[0][0]*cos(360*waves[0][1]*p[0]/size[0] + phase) + waves[1][0]*cos(360*waves[1][1]*p[1]/size[1] + phase)
         - (len(notches) == 0 ? 0 : [for (n=notches) shell_rim_dip(p, size, n[1], n[2], is_undef(n[3]) ? 0 : n[3], n[0])]*[for (n=notches) 1]);
// [lowest, highest] the rim of shell_rim() can reach (corners of the slopes, wave amplitudes, deepest notch)
function shell_rim_range(size, base, raise=[0, 0, 0, 0], waves=[[0, 1], [0, 1]], notches=[]) = let(
    c = [for (sx=[-1, 1], sy=[-1, 1]) raise[0]*(0.5 - sy/2) + raise[1]*(0.5 + sy/2) + raise[2]*(0.5 - sx/2) + raise[3]*(0.5 + sx/2)],
    w = abs(waves[0][0]) + abs(waves[1][0]),
    d = len(notches) == 0 ? 0 : max([for (n=notches) shell_rim_dip_depth(n[1], n[2])]))
    [base + min(c) - w - d, base + max(c) + w];

// A dip in the rim (a grip cut-out, a pouring lip): subtract it from a rim height. The rim drops by `depth` in
// the middle of one side (side = "front" / "back" / "left" / "right", center = shift along that side) and fades
// out over `fade` mm away from that wall, so the other walls are not affected. `width` is the width of the dip at
// half its depth. The shoulders are never steeper than about 50 degrees (SHELL_DIP_RUN mm of run per mm of drop),
// so a rim band keeps its strength along them: a dip too narrow for its depth comes out shallower, and
// shell_rim_dip_depth() tells you how deep it really is.
SHELL_DIP_RUN = 1.2;
function _sh_ramp(x) = x <= 0 ? 1 : x >= 1 ? 0 : (1 + cos(180*x))/2;
function shell_rim_dip_depth(depth, width) = min(depth, width/SHELL_DIP_RUN);
function shell_rim_dip(p, size, depth=10, width=30, center=0, side="front", fade=8) = let(
    d = shell_rim_dip_depth(depth, width),
    along = side == "front" || side == "back" ? p[0] : p[1],
    away = side == "front" ? p[1] + size[1]/2 : side == "back" ? size[1]/2 - p[1] : side == "left" ? p[0] + size[0]/2 : size[0]/2 - p[0],
    shoulder = min(width, max(SHELL_DIP_RUN*d, 4)))
    d <= 0 ? 0 : d*_sh_ramp((abs(along - center) - (width - shoulder)/2)/shoulder)*_sh_ramp(away/fade - 0.5);

// Periodic line shapes for rims and decorative lines: value -1 .. 1, one period per unit of x, crest (+1) at x = 0.
//   wave = cosine, zigzag = straight flanks, scallop = round bumps meeting in sharp dips (a scalloped rim),
//   petal = the reverse: round dips and pointed tips (a crown or tulip rim)
SHELL_WAVES = ["wave", "zigzag", "scallop", "petal"];
function shell_wave(style, x) = let(f = x - floor(x), g = f > 0.5 ? f - 1 : f)       // g = -0.5 .. 0.5 round the crest
    style == "zigzag" ? 1 - 4*abs(g) :
    style == "scallop" ? 2*sqrt(max(0, 1 - 4*g*g)) - 1 :
    style == "petal" ? 1 - 2*sqrt(max(0, 1 - 4*(0.5 - abs(g))*(0.5 - abs(g)))) :
    cos(360*f);
// A rim (or any line round the wall) for round and polygonal containers, by the direction from the centre
// (angle 0 = +x, 90 = back +y, -90 = front):
//   raise = [mm, direction]: the line is `mm` higher on that side and as much lower opposite (a slanted cut)
//   waves = [amplitude, count, style, phase]: `count` waves of SHELL_WAVES `style` round the container
//   dips  = [[direction, depth, width], ...]: dips like shell_rim_dip (width at half depth, mm along the wall
//           at the point's radius): grips, cable notches, a pouring lip
function shell_rim_round(p, base, raise=[0, 90], waves=[0, 6, "wave", 0], dips=[]) = let(
    a = atan2(p[1], p[0]), r = max(1, norm(p)),
    w = waves[0] == 0 ? 0 : waves[0]*shell_wave(waves[2], waves[1]*(a - waves[3])/360))
    base + raise[0]*cos(a - raise[1]) + w
    - (len(dips) == 0 ? 0 : [for (d=dips) shell_round_dip(a, r, d[0], d[1], d[2])]*[for (d=dips) 1]);
function _sh_adiff(a, b) = let(d = (a - b)%360) d > 180 ? d - 360 : d < -180 ? d + 360 : d;
function shell_round_dip(a, r, dir, depth, width) = let(
    d = shell_rim_dip_depth(depth, width), along = abs(_sh_adiff(a, dir))*PI*r/180, shoulder = min(width, max(SHELL_DIP_RUN*d, 4)))
    d <= 0 ? 0 : d*_sh_ramp((along - (width - shoulder)/2)/shoulder);
// [lowest, highest] of shell_rim_round()
function shell_rim_round_range(base, raise=[0, 90], waves=[0, 6, "wave", 0], dips=[]) = let(
    d = len(dips) == 0 ? 0 : max([for (x=dips) shell_rim_dip_depth(x[1], x[2])]))
    [base - abs(raise[0]) - abs(waves[0]) - d, base + abs(raise[0]) + abs(waves[0])];

// distance along the outline of the point on it that is nearest to q (to place things on a wall from plan coordinates)
function shell_dist_at(pts, q) = let(u = shell_dists(pts), n = len(pts),
    c = [for (i=[0:n-1]) let(A = pts[i], d = pts[(i+1)%n] - A, t = max(0, min(1, (q - A)*d/(d*d)))) [norm(q - A - t*d), u[i] + t*norm(d)]],
    m = min([for (x=c) x[0]]))
    [for (x=c) if (x[0] == m) x[1]][0];

// ---------- unrolled strip ----------
// 2D outline of the wall strip over edges e0..e1 in the strip frame: bottom at y = -h/2, top edge at
// hf(p) - h/2, sampled every `step` mm. hf = function (p) -> height above the floor (default: h everywhere).
// h = the reference height (use the largest height of the wall); it only fixes where y = 0 is.
// The strip reaches `ext` beyond both ends, so neighbouring strips (and the two ends of a full loop) overlap
// instead of meeting face to face.
function shell_strip_pts(pts, e0=0, e1, hf, h, step=2, ext=0.3) = let(
    n = len(pts), b = is_undef(e1) ? n - 1 : e1, u = shell_dists(pts), uc = (u[e0] + u[b + 1])/2,
    top = [for (i=[e0:b]) let(A = pts[i], B = pts[(i+1)%n], m = max(1, ceil((u[i+1] - u[i])/step)))
        for (k=[0:(i == b ? m : m - 1)]) let(q = A + (B - A)*k/m) [u[i] + (u[i+1] - u[i])*k/m - uc, (is_undef(hf) ? h : hf(q)) - h/2]],
    m = len(top) - 1)
    concat([[u[e0] - uc - ext, -h/2], [u[b + 1] - uc + ext, -h/2], [top[m][0] + ext, top[m][1]]],
           [for (i=[m:-1:0]) top[i]], [[top[0][0] - ext, top[0][1]]]);

// ---------- wrapping ----------
// clip 2D content of a shell_wrap child to the facet being built (pattern modules do this themselves)
module shell_window_2d() {
    if (is_undef($pat_window)) children();
    else offset(delta=is_undef($pat_shrink) ? 0 : -$pat_shrink) intersection() { pat_window_2d(); children(); }
}
// Bend the child (a panel in the strip frame, see the top of this file) round the outline, over edges e0..e1
// (default: all the way round). t = wall thickness, h = reference height used for the strip frame.
// above = how far relief may stand out beyond t (only used to close the gaps at inward bends).
module shell_wrap(pts, t, e0=0, e1, h=50, above=0) {
    n = len(pts); b = is_undef(e1) ? n - 1 : e1;
    u = shell_dists(pts); uc = (u[e0] + u[b + 1])/2;
    for (i=[e0:b]) {
        A = pts[i]; B = pts[(i+1)%n]; d = (B - A)/norm(B - A); nr = [d[1], -d[0]];
        dp = pts[i] - pts[(i + n - 1)%n]; dn = pts[(i+2)%n] - B;
        // at an inward bend the facets part on the inside: lengthen them so they overlap; elsewhere SHELL_LAP is enough
        ta = dp[0]*d[1] - dp[1]*d[0]; tb = d[0]*dn[1] - d[1]*dn[0];                 // > 0: outward (convex) corner
        sh = SHELL_SHRINK*((i == n - 1 && n%2 == 1) ? 2 : i%2);                    // neighbouring facets differ
        ea = SHELL_LAP + sh + (ta < 0 ? (t + above)*tan(acos(max(-1, min(1, dp*d/norm(dp))))/2) : 0);
        eb = SHELL_LAP + sh + (tb < 0 ? (t + above)*tan(acos(max(-1, min(1, dn*d/norm(dn))))/2) : 0);
        xm = (u[i] + u[i+1])/2 - uc; M = (A + B)/2;
        $pat_shrink = sh;
        $pat_window = [[xm + (eb - ea)/2, 0], [u[i+1] - u[i] + ea + eb, h + 2]];
        // the pulled-in facets also sit that much further in, so faces of nearly straight neighbours do not coincide
        multmatrix([[d[0], 0, nr[0], M[0] - d[0]*xm - nr[0]*(t + sh)],
                    [d[1], 0, nr[1], M[1] - d[1]*xm - nr[1]*(t + sh)],
                    [0, 1, 0, h/2], [0, 0, 0, 1]]) children();
    }
}

// ---------- tapered walls ----------
// The outline pts (outer face at z = 0) is scaled by k(z) = 1 + (s - 1) z / ht about the z axis, so the outer
// face at height z is shell_taper_pts(pts, s, ht, z). s > 1 flares out (a flower pot), s < 1 narrows (an urn);
// s = 1 is a straight wall and everything below falls back to the strip frame of shell_wrap. Height functions
// hf(p) take the point p of the outline at z = 0 (the foot of the wall), as for straight walls.
//
// Fan frame (the child of shell_wrap_taper): the wall unrolled flat, true to size. It is the strip frame bent
// round the fan's apex: at the middle of the strip x = 0 and y = -h/2 at the floor, y grows up the wall (measured
// along the slant, so y = -h/2 + z / cos(lean) there), x runs along the wall to the right (seen from outside),
// z = 0 inner face .. t outer face. Away from the middle the floor line and the rim are arcs round the apex.
// Use shell_taper_strip_pts() for outlines in it and shell_taper_at() for single points; patterns drawn in it
// keep their size and shape on the wall.
function shell_taper_k(s, ht, z) = 1 + (s - 1)*z/ht;
function shell_taper_pts(pts, s, ht, z) = let(k = shell_taper_k(s, ht, z)) [for (p=pts) p*k];
function shell_is_tapered(s) = abs(s - 1) > 1e-6;
// largest lean of the wall from vertical (degrees; + = outwards)
function shell_taper_lean(pts, s, ht) = let(r = max([for (p=pts) norm(p)])) atan(r*(s - 1)/ht);
// raw fan: [sigma (1 = apex below, -1 = above), apex angle of every point (n + 1, the first again at the end),
// distance of every point from the apex]
function _sht_cum(b, i) = i <= 0 ? 0 : _sht_cum(b, i - 1) + b[i - 1];
function _sht_fan(pts, s, ht) = let(n = len(pts), za = -ht/(s - 1),
    v = [for (i=[0:n]) let(p = pts[i%n]) [p[0], p[1], -za]],
    b = [for (i=[0:n-1]) atan2(norm(cross(v[i], v[i+1])), v[i]*v[i+1])],
    c = [for (i=[0:n]) _sht_cum(b, i)])
    [s > 1 ? 1 : -1, c, [for (x=v) norm(x)]];
function _sht_raw(fan, i) = fan[2][i]*[sin(fan[1][i]), fan[0]*cos(fan[1][i])];
function _sht_rot(a, v) = [v[0]*cos(a) - v[1]*sin(a), v[0]*sin(a) + v[1]*cos(a)];
// frame for the strip over edges e0..e1, reference height h:
// [sigma (0 = straight wall), fan, rotation, shift, distances u, uc, s, ht, h, pts]
function shell_taper_frame(pts, s, ht, e0=0, e1, h=50) = let(n = len(pts), b = is_undef(e1) ? n - 1 : e1,
    u = shell_dists(pts), uc = (u[e0] + u[b + 1])/2)
    !shell_is_tapered(s) ? [0, undef, 0, [0, 0], u, uc, s, ht, h, pts] : let(
    fan = _sht_fan(pts, s, ht),
    k = [for (i=[e0:b]) if (u[i] <= uc + 1e-9 && uc <= u[i+1] + 1e-9) i][0],
    f = (uc - u[k])/(u[k+1] - u[k]),
    M = _sht_raw(fan, k) + (_sht_raw(fan, k + 1) - _sht_raw(fan, k))*f,
    th = fan[0]*atan2(M[0], fan[0]*M[1]))
    [fan[0], fan, th, [0, -h/2] - _sht_rot(th, M), u, uc, s, ht, h, pts];
// fan-frame point of the wall above edge i, fraction f along it, height z
function shell_taper_edge_at(F, i, f, z) = F[0] == 0 ? [F[4][i] + (F[4][i+1] - F[4][i])*f - F[5], z - F[8]/2] : let(
    A = _sht_raw(F[1], i), B = _sht_raw(F[1], i + 1))
    _sht_rot(F[2], (A + (B - A)*f)*shell_taper_k(F[6], F[7], z)) + F[3];
// fan-frame point at distance uu along the foot of the wall (from point 0, as shell_dists) and height z
function shell_taper_at(F, uu, z) = let(u = F[4], n = len(u) - 1,
    w = uu - floor(uu/u[n])*u[n],                                  // round the loop
    i = [for (j=[0:n-1]) if (u[j] <= w + 1e-9 && w <= u[j+1] + 1e-9) j][0])
    shell_taper_edge_at(F, i, (w - u[i])/(u[i+1] - u[i]), z);
// the point of the outline at distance u along it (from point 0)
function shell_pt_at(pts, u) = let(d = shell_dists(pts), n = len(pts), L = d[n], w = u - floor(u/L)*L,
    i = [for (j=[0:n-1]) if (d[j] <= w + 1e-9 && w <= d[j+1] + 1e-9) j][0])
    pts[i] + (pts[(i+1)%n] - pts[i])*(w - d[i])/(d[i+1] - d[i]);
// distance along the outline (as shell_dists) where the direction `a` from the origin (degrees) meets it
function shell_dist_at_dir(pts, a) = let(n = len(pts), u = shell_dists(pts), d = [cos(a), sin(a)],
    hit = [for (i=[0:n-1]) let(A = pts[i], B = pts[(i+1)%n], e = B - A, den = d[0]*e[1] - d[1]*e[0])
        if (abs(den) > 1e-12) let(t = (d[0]*A[1] - d[1]*A[0])/den, r = (A[0]*e[1] - A[1]*e[0])/den)
            if (t >= -1e-9 && t <= 1 + 1e-9 && r > 0) u[i] + t*norm(e)])
    hit[0];
// [[distance along the outline, turn in degrees], ...] of every point of the outline (how sharply the wall bends there)
function shell_joints(pts) = let(n = len(pts), u = shell_dists(pts))
    [for (i=[0:n-1]) let(a = pts[i] - pts[(i + n - 1)%n], b = pts[(i+1)%n] - pts[i]) [u[i], acos(max(-1, min(1, a*b/norm(a)/norm(b))))]];
// fan-frame point at the foot of the wall nearest to plan point q, at height z
function shell_taper_at_plan(F, q, z) = shell_taper_at(F, shell_dist_at(F[9], q), z);
// Outline of the wall over edges e0..e1 in the fan frame, between the height functions lf (bottom, default
// z = z0) and hf (top, default h), sampled every `step` mm; reaches `ext` beyond both ends (as shell_strip_pts).
function shell_taper_strip_pts(pts, s, ht, e0=0, e1, hf, h=50, lf, z0=0, step=2, ext=0.3) = let(
    n = len(pts), b = is_undef(e1) ? n - 1 : e1, F = shell_taper_frame(pts, s, ht, e0, b, h), u = F[4],
    smp = [for (i=[e0:b]) let(A = pts[i], B = pts[(i+1)%n], m = max(1, ceil((u[i+1] - u[i])/step)))
        for (k=[0:(i == b ? m : m - 1)]) [i, k/m, A + (B - A)*k/m]],
    lo = [for (x=smp) shell_taper_edge_at(F, x[0], x[1], is_undef(lf) ? z0 : lf(x[2]))],
    hi = [for (x=smp) shell_taper_edge_at(F, x[0], x[1], is_undef(hf) ? h : hf(x[2]))],
    m = len(smp) - 1,
    d0 = let(v = shell_taper_edge_at(F, e0, 1, 0) - shell_taper_edge_at(F, e0, 0, 0)) v/norm(v),
    d1 = let(v = shell_taper_edge_at(F, b, 1, 0) - shell_taper_edge_at(F, b, 0, 0)) v/norm(v))
    concat([lo[0] - d0*ext], [for (i=[0:m]) lo[i]], [lo[m] + d1*ext, hi[m] + d1*ext], [for (i=[m:-1:0]) hi[i]], [hi[0] - d0*ext]);
// [w, h] of a rectangle centred on the fan frame's origin that holds the whole strip (the `size` for patterns)
function shell_taper_size(strip) = let(b = shell_bounds(strip))
    [2*max(abs(b[0][0]), abs(b[1][0])) + 2, 2*max(abs(b[0][1]), abs(b[1][1])) + 2];
// Bend the child (built in the fan frame) onto the tapered wall over edges e0..e1. t = wall thickness (measured
// square to the wall), h = reference height (the highest point of the rim, as in shell_wrap), above = relief
// beyond t. Each facet gets $pat_window (turned to the facet) and $pat_clip = its exact trapezoid in the fan
// (plus the laps at the joints), so the facets meet in the plane that halves their angle.
// z0 = where the strip's foot is: the inner face of a wall that leans in reaches below its outer foot, so start
// such walls a little higher (shell_taper_foot()) and let the floor fill in.
// s = 1 builds a straight wall the same way (shell_wrap is the faster choice there for panels without cuts).
// shrink = false: no facet is pulled in; lap = extra reach past each joint. Cutters read $shell_alt, $shell_turn,
// $shell_ends (see container_wall_taper).
function shell_taper_foot(pts, s, ht, t) = s < 1 ? t*sin(abs(shell_taper_lean(pts, s, ht))) + 0.02 : 0;
module shell_wrap_taper(pts, s, ht, t, e0=0, e1, h=50, above=0, shrink=true, lap=0) {
    n = len(pts); b = is_undef(e1) ? n - 1 : e1;
    F = shell_taper_frame(pts, s, ht, e0, b, h);
    for (i=[e0:b]) {
        A = pts[i]; B = pts[(i+1)%n]; d = (B - A)/norm(B - A);
        dp = pts[i] - pts[(i + n - 1)%n]; dn = pts[(i+2)%n] - B;
        ta = dp[0]*d[1] - dp[1]*d[0]; tb = d[0]*dn[1] - d[1]*dn[0];               // > 0: outward (convex) corner
        turn_a = acos(max(-1, min(1, dp*d/norm(dp)))); turn_b = acos(max(-1, min(1, dn*d/norm(dn))));
        alt = (i == n - 1 && n%2 == 1) ? 2 : i%2;                                // neighbouring facets differ
        sh = shrink ? SHELL_SHRINK*alt : 0;
        ea = SHELL_LAP + lap + sh + (ta < 0 ? (t + above)*tan(turn_a/2) : 0);
        eb = SHELL_LAP + lap + sh + (tb < 0 ? (t + above)*tan(turn_b/2) : 0);
        // the facet in the fan frame
        Da = shell_taper_edge_at(F, i, 0, 0); Db = shell_taper_edge_at(F, i, 1, 0);
        e = (Db - Da)/norm(Db - Da); e2 = [-e[1], e[0]];
        zl = -1 - t; zh = h + 2;
        q = [shell_taper_edge_at(F, i, 0, zl) - e*ea, shell_taper_edge_at(F, i, 1, zl) + e*eb,
             shell_taper_edge_at(F, i, 1, zh) + e*eb, shell_taper_edge_at(F, i, 0, zh) - e*ea];
        c = (q[0] + q[1] + q[2] + q[3])/4;
        wx = [for (p=q) (p - c)*e]; wy = [for (p=q) (p - c)*e2];
        // the facet in the world: bottom edge A..B, up the slant, outer face on the outline
        P = [A[0], A[1], 0]; E1 = [d[0], d[1], 0];
        W = [A[0]*(s - 1), A[1]*(s - 1), ht]; W2 = W - (W*E1)*E1; E2 = W2/norm(W2); E3 = cross(E1, E2);
        o = P - E1*(e*Da) - E2*(e2*Da) - E3*(t + sh);
        $pat_shrink = sh;
        $pat_window = [c, [max(wx) - min(wx) + 0.2, max(wy) - min(wy) + 0.2], atan2(e[1], e[0])];
        $pat_clip = q;
        // for cutters (container_wall_taper): near each joint, every other facet's cut must contain its
        // neighbour's, whose faces stand square to a facet turned by up to $shell_turn degrees: $shell_alt
        // (0, 1, 2) says which facets grow, $shell_ends are the strips 1.5 mm from each end of the facet
        $shell_alt = alt;
        $shell_turn = max(turn_a, turn_b);
        $shell_ends = [[q[0], q[0] + e*1.5, q[3] + e*1.5, q[3]], [q[1] - e*1.5, q[1], q[2], q[2] - e*1.5]];
        multmatrix([[E1[0]*e[0] + E2[0]*e2[0], E1[0]*e[1] + E2[0]*e2[1], E3[0], o[0]],
                    [E1[1]*e[0] + E2[1]*e2[0], E1[1]*e[1] + E2[1]*e2[1], E3[1], o[1]],
                    [E1[2]*e[0] + E2[2]*e2[0], E1[2]*e[1] + E2[2]*e2[1], E3[2], o[2]],
                    [0, 0, 0, 1]]) children();
    }
}
