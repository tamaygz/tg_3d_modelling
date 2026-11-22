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
function shell_bounds(pts) = [[min([for (p=pts) p[0]]), min([for (p=pts) p[1]])], [max([for (p=pts) p[0]]), max([for (p=pts) p[1]])]];
// outward unit normal of edge i, and of point i (mean of its two edges)
function shell_edge_normal(pts, i) = let(d = pts[(i+1)%len(pts)] - pts[i]) [d[1], -d[0]]/norm(d);
function shell_point_normal(pts, i) = let(n = len(pts), v = shell_edge_normal(pts, i) + shell_edge_normal(pts, (i + n - 1)%n)) v/norm(v);

// wave the outline in plan: every point moves in or out by amp*sin(count waves round the outline).
// Needs short edges (side_n in shell_rect_runs, n in the ellipse functions).
function shell_wavy_pts(pts, amp=2, count=8, phase=0) = amp == 0 ? pts : let(u = shell_dists(pts), L = u[len(pts)])
    [for (i=[0:len(pts)-1]) pts[i] + shell_point_normal(pts, i)*amp*sin(360*count*u[i]/L + phase)];

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
    else offset(delta=is_undef($pat_shrink) ? 0 : -$pat_shrink) intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
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
