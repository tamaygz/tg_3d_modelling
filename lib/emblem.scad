// Emblem / badge elements as 2D generators: leaves, laurel branches and wreaths, ribbon banners,
// text on an arc, pool balls, and an outline (stroke) helper. Extrude or inlay them in any project.
// Use:  use <../../lib/emblem.scad>   (fonts: also `use <../../lib/fonts.scad>`)
// Conventions: 2D, y up, units are whatever the caller works in (mm, or the source drawing's px).

LEAF_STYLES   = ["almond", "pointed", "round"];   // almond = measured classic laurel leaf
BANNER_STYLES = ["filled", "outline"];

// ---------- helpers ----------
// outline of children() as a band of width w (centred on the edge, or inside it with inside=true)
module stroke_2d(w=1, inside=false) {
    difference() {
        offset(delta=inside ? 0 : w/2) children();
        offset(delta=inside ? -w : -w/2) children();
    }
}
// circle through three points -> [centre, radius]
function circle3(a, b, c) = let(
    d = 2*(a[0]*(b[1]-c[1]) + b[0]*(c[1]-a[1]) + c[0]*(a[1]-b[1])),
    ux = ((a*a)*(b[1]-c[1]) + (b*b)*(c[1]-a[1]) + (c*c)*(a[1]-b[1]))/d,
    uy = ((a*a)*(c[0]-b[0]) + (b*b)*(a[0]-c[0]) + (c*c)*(b[0]-a[0]))/d)
    [[ux, uy], norm(a - [ux, uy])];
function polar(r, a) = [r*cos(a), r*sin(a)];

// ---------- leaves and laurel ----------
// leaf from its base (origin) to its tip (0, len). Width profile w/2 * sin(pi t^q)^p, with q set so the leaf is
// widest at `belly`. style sets p: almond 0.62 (measured from classic laurel artwork: slender, slightly blunt ends),
// pointed 1.0, round 0.45. bend curves the tip sideways (+ = to +x); vein > 0 cuts a centre vein.
module leaf_2d(len=30, w=8, style="almond", belly=0.5, bend=0, vein=0, n=40) {
    p = style == "pointed" ? 1.0 : style == "round" ? 0.45 : 0.62;
    q = ln(0.5)/ln(belly);
    function hw(t) = w/2 * pow(sin(180*pow(t, q)), p);
    function bx(t) = bend*len*t*t;
    pts = concat([for (i=[0:n]) let(t=i/n) [bx(t) + hw(t), t*len]],
                 [for (i=[n-1:-1:1]) let(t=i/n) [bx(t) - hw(t), t*len]]);
    difference() {
        polygon(pts);
        if (vein > 0) polygon(concat([for (i=[1:n-2]) let(t=i/n) [bx(t) + vein/2*(1-t), t*len]],
                                     [for (i=[n-2:-1:1]) let(t=i/n) [bx(t) - vein/2*(1-t), t*len]]));
    }
}
// leaves listed explicitly, for a left branch around the origin: [angle of the base (deg), radius of the base,
// lean from the branch direction (+ = outwards), length, width]. The branch runs up with decreasing angle.
module laurel_leaves_2d(leaves, style="almond", vein=0) {
    for (l=leaves) translate(polar(l[1], l[0])) rotate(l[0] - 90 + l[2] - 90) leaf_2d(l[3], l[4], style, vein=vein*l[4]);
}
// leaves generated in repeating groups along an arc (left branch, base at angle a0, walking up by step per group).
// roles = per leaf in a group: [angle offset (deg), radius offset, lean (+ = out), size]. Defaults: one inner and
// two outer leaves per group, fitted to classic laurel artwork. Leaves taper from size 1 to `grow` at the tip.
LAUREL_ROLES = [[0, -30.9, -21.8, 0.942], [6.7, -10.0, 28.2, 1.033], [20.3, 19.2, 12.9, 0.878]];
function laurel_group_leaves(r=600, a0=209, step=28.3, groups=3, leaf_len=324, ratio=0.287, grow=0.935, roles=LAUREL_ROLES) =
    [for (g=[0:groups-1], k=[0:len(roles)-1]) let(ro = roles[k], d = g*step + ro[0], t = d/(groups*step),
                                                  L = leaf_len*ro[3]*(1 + (grow - 1)*t))
        [a0 - d, r + ro[1], ro[2], L, ratio*L]];
module laurel_branch_2d(r=600, a0=209, step=28.3, groups=3, leaf_len=324, ratio=0.287, grow=0.935, roles=LAUREL_ROLES,
                        leaves=undef, style="almond", vein=0, stem=0) {
    L = is_undef(leaves) ? laurel_group_leaves(r, a0, step, groups, leaf_len, ratio, grow, roles) : leaves;
    laurel_leaves_2d(L, style, vein);
    if (stem > 0) let(a1 = min([for (l=L) l[0]]), a2 = max([for (l=L) l[0]]))
        for (i=[0:23]) hull() for (j=[i, i+1]) translate(polar(r, a2 + (a1 - a2)*j/24)) circle(d=stem, $fn=12);
}
// wreath: a branch on the left (around the origin) and its mirror image on the right
module laurel_wreath_2d(r=600, a0=209, step=28.3, groups=3, leaf_len=324, ratio=0.287, grow=0.935, roles=LAUREL_ROLES,
                        leaves=undef, style="almond", vein=0, stem=0) {
    for (m=[0, 1]) mirror([m, 0]) laurel_branch_2d(r, a0, step, groups, leaf_len, ratio, grow, roles, leaves, style, vein, stem);
}

// ---------- ribbons and banners ----------
function bez(p, t) = pow(1-t,3)*p[0] + 3*pow(1-t,2)*t*p[1] + 3*(1-t)*t*t*p[2] + pow(t,3)*p[3];
function _nrm(p, t) = let(d = bez(p, min(1, t + 0.01)) - bez(p, max(0, t - 0.01))) [-d[1], d[0]]/norm(d);
// ribbon of width w along a cubic Bezier p = [p0, c1, c2, p3]; V notches (depth) cut into either end
module ribbon_2d(p, w=10, notch_start=0, notch_end=0, n=32) {
    L = [for (i=[0:n]) bez(p, i/n) + w/2*_nrm(p, i/n)];
    Rt = [for (i=[n:-1:0]) bez(p, i/n) - w/2*_nrm(p, i/n)];
    t0 = bez(p, 0.02) - bez(p, 0); t1 = bez(p, 1) - bez(p, 0.98);
    polygon(concat(L, notch_end > 0 ? [bez(p, 1) - notch_end*t1/norm(t1)] : [], Rt,
                   notch_start > 0 ? [bez(p, 0) + notch_start*t0/norm(t0)] : []));
}
// front band: chord w, height h, arched up by sag in the middle. Origin = middle of the line through the
// band's lower corners.
function _arch(x, w, sag) = sag*(1 - pow(2*x/w, 2));
module banner_band_2d(w=100, h=18, sag=4, slant=4, n=40) {
    polygon(concat([for (i=[0:n]) let(x = -w/2 + w*i/n) [x + (i == 0 ? -slant : i == n ? slant : 0), h + _arch(x, w, sag)]],
                   [for (i=[n:-1:0]) let(x = -w/2 + w*i/n) [x, _arch(x, w, sag)]]));
}
// tails: from a notched tip out beside the band end, down and back in under the band towards the middle
module banner_tails_2d(w=100, h=18, tail_len=12, tail_drop=12, tail_w=9, notch=5) {
    for (m=[0,1]) mirror([m,0]) ribbon_2d([[-(w/2 + tail_len), -0.7*tail_drop], [-(w/2 + 0.85*tail_len), -1.55*tail_drop],
                                           [-0.35*w, -1.5*tail_drop], [-0.12*w, -0.8*tail_drop]], tail_w, notch_start=notch);
}
module banner_knot_2d(w=100, d=6)  { translate([0, -0.45*d]) scale([1, 0.8]) circle(d=d, $fn=48); }
module banner_loops_2d(w=100, d=6) { for (s=[-1,1]) hull() { translate([0, -0.45*d]) circle(d=d*0.5, $fn=24); translate([s*0.18*w, -0.15*d]) scale([0.09*w, 0.45*d]) circle(r=1, $fn=48); } }
module banner_ends_2d(w=100, d=6, tail_w=9, notch=5) {
    for (s=[-1,1]) ribbon_2d([[0, -0.55*d], [s*0.3*d, -0.7*d], [s*0.55*d, -0.82*d], [s*0.8*d, -0.92*d]], tail_w*0.45, notch_end=notch*0.4);
}
// complete banner (simple version): band, tails, optional bow. See ribbon_banner_2d() for the detailed one.
module banner_2d(w=100, h=18, sag=4, tail_len=12, tail_drop=12, tail_w=9, notch=5, bow=true, style="filled", stroke=1) {
    d = 0.12*w;
    module band()  banner_band_2d(w, h, sag);
    module knot()  if (bow) banner_knot_2d(w, d);
    module loops() if (bow) banner_loops_2d(w, d);
    module ends()  if (bow) banner_ends_2d(w, d, tail_w, notch);
    module tails() banner_tails_2d(w, h, tail_len, tail_drop, tail_w, notch);
    if (style == "outline") {
        stroke_2d(stroke, inside=true) band();
        difference() { stroke_2d(stroke, inside=true) knot();  band(); }
        difference() { stroke_2d(stroke, inside=true) loops(); band(); knot(); }
        difference() { stroke_2d(stroke, inside=true) ends();  band(); knot(); loops(); }
        difference() { stroke_2d(stroke, inside=true) tails(); band(); knot(); loops(); ends(); }
    } else { band(); knot(); loops(); ends(); tails(); }
}

// ---------- detailed ribbon banner ----------
// Built like a drawn ribbon: the INTERIORS of the pieces (front band, two swallowtail tails, two folds, the strip
// under the band) are trimmed by the pieces in front of them, then an outline `stroke` wide is drawn around all of
// them; the bow (two lens loops and two crossing tapered legs) and the two corner ears are solid.
// spec = [band, tail, fold, strip, loops, legs, ear, stroke] (see BANNER_SPEC_* for the layout of each entry);
// coordinates are relative to the banner's centre line x = 0, mirrored for the right side.
// style "outline" (like engraved/printed badges) or "filled" (solid ribbon).
function _qb(p0, c, p1, n=24) = [for (i=[0:n]) let(t=i/n) (1-t)*(1-t)*p0 + 2*(1-t)*t*c + t*t*p1];
function _inner(l) = [for (i=[1:len(l)-2]) l[i]];
function _tail1(l) = [for (i=[1:len(l)-1]) l[i]];
function banner_band_pts(v, n=40) = let(hwt=v[0], hwb=v[1], yt=v[2], st=v[3], yb=v[4], sb=v[5], bulge=v[6], ym=(yt - st + yb - sb)/2)
    concat([for (i=[0:n-1]) let(x = -hwt + 2*hwt*i/(n-1)) [x, yt - st*pow(x/hwt, 2)]],
           _inner(_qb([hwt, yt - st], [(hwt + hwb)/2 + bulge, ym], [hwb, yb - sb])),
           [for (i=[0:n-1]) let(x = hwb - 2*hwb*i/(n-1)) [x, yb - sb*pow(x/hwb, 2)]],
           _inner(_qb([-hwb, yb - sb], [-(hwt + hwb)/2 - bulge, ym], [-hwt, yt - st])));
// tail: A -c1- T1 -c3- N -c4- T2 -c2- B -c5- A  (v = [A, c1, T1, N, T2, c2, B, c3, c4, c5] as 20 numbers)
function banner_tail_pts(v) = let(P = [for (i=[0:9]) [v[2*i], v[2*i+1]]])
    concat(_qb(P[0], P[1], P[2]), _tail1(_qb(P[2], P[7], P[3])), _tail1(_qb(P[3], P[8], P[4])),
           _tail1(_qb(P[4], P[5], P[6])), _inner(_qb(P[6], P[9], P[0])));
// closed shape: 4 corners + 4 edge controls (16 numbers + 16 numbers as [x,y] pairs: corners first)
function banner_qpoly_pts(v) = let(P = [for (i=[0:7]) [v[2*i], v[2*i+1]]])
    [for (i=[0:3]) let(e = _qb(P[i], P[4+i], P[(i+1)%4], 16)) each [for (j=[0:15]) e[j]]];
function _leaf_pts(L, W, p=0.62, bend=0, n=40) =
    concat([for (i=[0:n]) let(t=i/n) [bend*L*t*t + W/2*pow(sin(180*t), p), t*L]],
           [for (i=[n-1:-1:1]) let(t=i/n) [bend*L*t*t - W/2*pow(sin(180*t), p), t*L]]);
// tapered ribbon along a quadratic Bezier p0-c-p1, width w0 -> w1
function taper_ribbon_pts(p0, c, p1, w0, w1, n=24) = let(
    P = [for (i=[0:n]) let(t=i/n) (1-t)*(1-t)*p0 + 2*(1-t)*t*c + t*t*p1],
    N = [for (i=[0:n]) let(t=i/n, d = 2*(1-t)*(c - p0) + 2*t*(p1 - c)) [-d[1], d[0]]/norm(d)],
    w = [for (i=[0:n]) (w0 + (w1 - w0)*i/n)/2])
    concat([for (i=[0:n]) P[i] + w[i]*N[i]], [for (i=[n:-1:0]) P[i] - w[i]*N[i]]);
module _both() { children(); mirror([1, 0]) children(); }
module ribbon_banner_2d(spec, style="outline", show_bow=true, show_ears=true) {
    bandv = spec[0]; tailv = spec[1]; foldv = spec[2]; stripv = spec[3]; lv = spec[4]; gv = spec[5]; earv = spec[6]; st = spec[7];
    module band()  polygon(banner_band_pts(bandv));
    module bandO() offset(r=st, $fn=24) band();
    module loops() if (show_bow) _both() translate([-lv[0], lv[1]]) rotate(90 - lv[2]) polygon(_leaf_pts(lv[3], lv[4], lv[5], lv[6]));
    module legs()  if (show_bow) _both() polygon(taper_ribbon_pts([-gv[0], gv[1]], [gv[2], gv[3]], [gv[4], gv[5]], gv[6], gv[7]));
    module ears()  if (show_ears) _both() polygon(concat(_qb([earv[0], earv[1]], [earv[6], earv[7]], [earv[2], earv[3]]), [[earv[4], earv[5]]],
                                                       _inner(_qb([earv[4], earv[5]], [earv[8], earv[9]], [earv[0], earv[1]]))));
    module tails() difference() { _both() polygon(banner_tail_pts(tailv)); bandO(); }
    module folds() difference() { _both() polygon(banner_qpoly_pts(foldv)); bandO(); offset(r=st, $fn=24) tails(); loops(); }
    module strip() difference() { polygon([for (i=[0:3]) [stripv[2*i], stripv[2*i+1]]]); bandO(); loops(); offset(r=st, $fn=24) folds(); }
    module inside() { band(); tails(); folds(); strip(); }
    if (style == "filled") { inside(); loops(); legs(); ears(); }
    else { difference() { offset(r=st, $fn=24) inside(); inside(); } loops(); legs(); ears(); }
}
// interiors only (the dark parts of an outlined banner), e.g. for a plaque's background
module ribbon_banner_inside_2d(spec) { ribbon_banner_2d(spec, "filled", show_bow=false, show_ears=false); }

// ---------- text on an arc ----------
// approximate advance widths (em) of capitals in the bundled serif bold; others fall back to 0.70
function _adv(ch) = let(t = [["I",0.39],["J",0.50],["M",0.94],["W",1.0],[" ",0.25],["L",0.67],["T",0.67],["E",0.67],
                             ["F",0.61],["P",0.61],["S",0.56],["1",0.50],["O",0.78],["Q",0.78],["N",0.72],["H",0.78]])
    let(f = [for (p=t) if (p[0] == ch) p[1]]) len(f) ? f[0] : 0.70;
function _cum(s, i) = i <= 0 ? 0 : _cum(s, i-1) + _adv(s[i-1]);
// text centred on angle `at` along a circle of radius r (baseline), reading left to right over the top.
// size: capitals are about 0.91 x size tall (bundled fonts). width < 1 condenses the letters (0.7 = 30% narrower).
// tracking adds space between letters (em). inward=true reads along the bottom of the circle instead.
module arc_text_2d(txt, r=100, size=10, font="Liberation Serif:style=Bold", at=90, tracking=0.04, width=1, inward=false) {
    em = 1.34*size*width;
    tot = _cum(txt, len(txt)) + tracking*(len(txt) - 1);
    for (i=[0:len(txt)-1]) if (txt[i] != " ") let(s = (_cum(txt, i) + i*tracking + _adv(txt[i])/2 - tot/2)*em,
                                                  a = inward ? at + s/r*180/PI : at - s/r*180/PI)
        translate(polar(r, a)) rotate(inward ? a + 90 : a - 90)
            scale([width, 1]) text(txt[i], size=size, font=font, halign="center", valign="baseline");
}

// ---------- pool ball ----------
// the light parts of a ball of diameter d: outer ring, number disc with the numeral cut out, and a crescent
// highlight from angle hl_from to hl_to, thickest (hl_w x radius) at hl_mid. pool_ball_body_2d() is the full disc (for the dark layer). stripe=true adds a stripe band.
module pool_ball_2d(d=50, number=8, ring_w=2, disc=0.5, disc_offset=[-0.005, 0.11], numeral=0.29,
                    font="Liberation Sans:style=Bold", highlight=true, hl_center=[0, 0], hl_from=20, hl_to=-98, hl_mid=-70, hl_r=0.846, hl_w=0.166,
                    stripe=false, numeral_matrix=undef) {
    R = d/2;
    stroke_2d(ring_w, inside=true) circle(r=R, $fn=144);
    difference() {
        translate(disc_offset*d) circle(r=disc*R, $fn=96);
        if (is_undef(numeral_matrix)) translate(disc_offset*d) text(str(number), size=numeral*d, font=font, halign="center", valign="center");
        else multmatrix([[numeral_matrix[0][0], numeral_matrix[0][1], 0, numeral_matrix[0][2]], [numeral_matrix[1][0], numeral_matrix[1][1], 0, numeral_matrix[1][2]], [0,0,1,0], [0,0,0,1]])
            text(str(number), size=100, font=font, halign="left", valign="baseline");   // fitted placement (relative to the ball centre)
    }
    if (highlight) let(ro = hl_r*R, mid = hl_mid, c0 = hl_center*d,
                       p1 = c0 + polar(ro, hl_from), p2 = c0 + polar(ro, hl_to), pm = c0 + polar(ro - hl_w*R, mid),
                       ci = circle3(p1, p2, pm))
        intersection() {
            difference() { translate(c0) circle(r=ro, $fn=144); translate(ci[0]) circle(r=ci[1], $fn=144); }
            polygon([c0, c0 + polar(2*R, hl_from), c0 + polar(2*R, mid), c0 + polar(2*R, hl_to)]);
        }
    if (stripe) intersection() { circle(r=R - ring_w, $fn=144); difference() { square([d, d*0.5], center=true); circle(r=disc*R*1.05, $fn=96); } }
}
module pool_ball_body_2d(d=50) { circle(d=d, $fn=144); }
