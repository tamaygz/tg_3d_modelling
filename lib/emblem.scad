// Emblem / badge elements as 2D generators: leaves, laurel branches and wreaths, ribbon banners,
// text on an arc, pool balls. Extrude or inlay them in any project.
// Use:  use <../../lib/emblem.scad>   (fonts: also `use <../../lib/fonts.scad>`)
use <core.scad>
// Conventions: 2D, y up, units are whatever the caller works in (mm, or the source drawing's px).

LEAF_STYLES   = ["almond", "pointed", "round"];   // almond = measured classic laurel leaf
BANNER_STYLES = ["filled", "outline"];

// ---------- leaves and laurel ----------
// leaf from its base (origin) to its tip (0, len). Width profile w/2 * sin(pi t^q)^p, with q set so the leaf is
// widest at `belly`. style sets p: almond 0.62 (measured from classic laurel artwork: slender, slightly blunt ends),
// pointed 1.0, round 0.45. bend curves the tip sideways (+ = to +x); vein > 0 cuts a centre vein.
function leaf_p(style) = style == "pointed" ? 1.0 : style == "round" ? 0.45 : 0.62;
function leaf_pts(len=30, w=8, p=0.62, belly=0.5, bend=0, n=40) = let(q = ln(0.5)/ln(belly))
    concat([for (i=[0:n]) let(t=i/n) [bend*len*t*t + w/2*pow(sin(180*pow(t, q)), p), t*len]],
           [for (i=[n-1:-1:1]) let(t=i/n) [bend*len*t*t - w/2*pow(sin(180*pow(t, q)), p), t*len]]);
module leaf_2d(len=30, w=8, style="almond", belly=0.5, bend=0, vein=0, n=40) {
    difference() {
        polygon(leaf_pts(len, w, leaf_p(style), belly, bend, n));
        if (vein > 0) polygon(concat([for (i=[1:n-2]) let(t=i/n) [bend*len*t*t + vein/2*(1-t), t*len]],
                                     [for (i=[n-2:-1:1]) let(t=i/n) [bend*len*t*t - vein/2*(1-t), t*len]]));
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

// ---------- ribbon banner ----------
// Built like a drawn ribbon: the INTERIORS of the pieces (front band, two swallowtail tails, two folds, the strip
// under the band) are trimmed by the pieces in front of them, then an outline `stroke` wide is drawn around all of
// them; the bow (two lens loops and two crossing tapered legs) and the two corner ears are solid.
//   ribbon_banner_2d(banner_spec(w=120))            classic banner, 120 wide, centred on the origin
//   ribbon_banner_2d(spec, "filled")                solid ribbon instead of outlines
// spec = [band, tail, fold, strip, loops, legs, ear, stroke], coordinates relative to the centre line x = 0:
//   band  [half width top, half width bottom, y top, arch drop top, y bottom, arch drop bottom, end bulge]
//   tail  10 points A c1 T1 N T2 c2 B c3 c4 c5 (edges A-T1, T1-N, N-T2, T2-B, B-A with their controls), left side
//   fold  4 corners + 4 edge controls, left side          strip  4 corners (rough area, trimmed by the rest)
//   loops [x, y, angle, length, width, shape p, bend]     legs   [top x, top y, ctrl x, ctrl y, foot x, foot y, w0, w1]
//   ear   tip, upper base, lower base, 2 controls, left   stroke outline width
// BANNER_CLASSIC is fitted to classic badge artwork (1280 units wide, origin at the middle of the band).
BANNER_CLASSIC = [[639.57, 560.11, 101.4, 103.15, -101.41, 91.16, 16.91], [-605.8, -120.85, -704.26, -136.24, -784.33, -202.25, -597.4, -228.36, -759.67, -369.82, -651.05, -283.79, -421.66, -245.3, -663.82, -172.88, -699.93, -268.29, -522.32, -176.52], [-484.13, -186.19, -334.23, -141.71, -222.29, -231.82, -373.03, -254.7, -400.07, -152.27, -329.23, -194.4, -263.46, -272.45, -439.44, -222.06], [-342.91, -109.96, 281.3, -108.55, 319.23, -141.99, -336.69, -155.36], [12.851, -144.682, -11.621, 317.681, 72.867, 0.815, -0.001], [14.64, -152.77, 30.07, -200.86, 119.26, -278.08, 24.94, 15.18], [-647.47, 54.72, -467.82, 52.93, -496.37, 53.62, -581.3, 78.74, -594.58, -22.91], 17.06];
// classic banner scaled to band width w; stroke overrides the outline width
function banner_scale(spec, k) = [
    [for (v=spec[0]) v*k], [for (v=spec[1]) v*k], [for (v=spec[2]) v*k], [for (v=spec[3]) v*k],
    [spec[4][0]*k, spec[4][1]*k, spec[4][2], spec[4][3]*k, spec[4][4]*k, spec[4][5], spec[4][6]],
    [for (v=spec[5]) v*k], [for (v=spec[6]) v*k], spec[7]*k];
function banner_spec(w=100, stroke=undef) = let(s = banner_scale(BANNER_CLASSIC, w/(2*BANNER_CLASSIC[0][0])))
    [s[0], s[1], s[2], s[3], s[4], s[5], s[6], is_undef(stroke) ? s[7] : stroke];
function banner_band_pts(v, n=40) = let(hwt=v[0], hwb=v[1], yt=v[2], st=v[3], yb=v[4], sb=v[5], bulge=v[6], ym=(yt - st + yb - sb)/2)
    concat([for (i=[0:n-1]) let(x = -hwt + 2*hwt*i/(n-1)) [x, yt - st*pow(x/hwt, 2)]],
           inner(qbez([hwt, yt - st], [(hwt + hwb)/2 + bulge, ym], [hwb, yb - sb])),
           [for (i=[0:n-1]) let(x = hwb - 2*hwb*i/(n-1)) [x, yb - sb*pow(x/hwb, 2)]],
           inner(qbez([-hwb, yb - sb], [-(hwt + hwb)/2 - bulge, ym], [-hwt, yt - st])));
function banner_tail_pts(v) = let(P = [for (i=[0:9]) [v[2*i], v[2*i+1]]])
    concat(qbez(P[0], P[1], P[2]), rest(qbez(P[2], P[7], P[3])), rest(qbez(P[3], P[8], P[4])),
           rest(qbez(P[4], P[5], P[6])), inner(qbez(P[6], P[9], P[0])));
function banner_qpoly_pts(v) = let(P = [for (i=[0:7]) [v[2*i], v[2*i+1]]])
    [for (i=[0:3]) let(e = qbez(P[i], P[4+i], P[(i+1)%4], 16)) each [for (j=[0:15]) e[j]]];
// tapered ribbon along a quadratic Bezier p0-c-p1, width w0 -> w1
function taper_ribbon_pts(p0, c, p1, w0, w1, n=24) = let(
    P = qbez(p0, c, p1, n),
    N = [for (i=[0:n]) let(t=i/n, d = 2*(1-t)*(c - p0) + 2*t*(p1 - c)) [-d[1], d[0]]/norm(d)],
    w = [for (i=[0:n]) (w0 + (w1 - w0)*i/n)/2])
    concat([for (i=[0:n]) P[i] + w[i]*N[i]], [for (i=[n:-1:0]) P[i] - w[i]*N[i]]);
module ribbon_banner_2d(spec, style="outline", show_bow=true, show_ears=true) {
    bandv = spec[0]; tailv = spec[1]; foldv = spec[2]; stripv = spec[3]; lv = spec[4]; gv = spec[5]; earv = spec[6]; st = spec[7];
    module band()  polygon(banner_band_pts(bandv));
    module bandO() offset(r=st, $fn=24) band();
    module loops() if (show_bow) mirror_pair() translate([-lv[0], lv[1]]) rotate(90 - lv[2]) polygon(leaf_pts(lv[3], lv[4], lv[5], 0.5, lv[6]));
    module legs()  if (show_bow) mirror_pair() polygon(taper_ribbon_pts([-gv[0], gv[1]], [gv[2], gv[3]], [gv[4], gv[5]], gv[6], gv[7]));
    module ears()  if (show_ears) mirror_pair() polygon(concat(qbez([earv[0], earv[1]], [earv[6], earv[7]], [earv[2], earv[3]]), [[earv[4], earv[5]]],
                                                              inner(qbez([earv[4], earv[5]], [earv[8], earv[9]], [earv[0], earv[1]]))));
    module tails() difference() { mirror_pair() polygon(banner_tail_pts(tailv)); bandO(); }
    module folds() difference() { mirror_pair() polygon(banner_qpoly_pts(foldv)); bandO(); offset(r=st, $fn=24) tails(); loops(); }
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
        else affine2d(numeral_matrix)
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
