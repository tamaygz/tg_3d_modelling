// Emblem / badge elements as 2D generators: leaves, laurel branches and wreaths, ribbon banners,
// text on an arc, pool balls, and an outline (stroke) helper. Extrude or inlay them in any project.
// Use:  use <../../lib/emblem.scad>   (fonts: also `use <../../lib/fonts.scad>`)
// Conventions: 2D, y up, units are whatever the caller works in (mm, or the source drawing's px).

LEAF_STYLES   = ["almond", "pointed", "round"];
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
// leaf from its base (origin) to its tip (0, len). belly = where it is widest (0..1), bend curves the
// tip sideways (+ = to +x), vein > 0 cuts a centre vein of that width.
module leaf_2d(len=30, w=10, style="almond", belly=0.45, bend=0.12, vein=0, n=36) {
    p = style == "pointed" ? 1.35 : style == "round" ? 0.65 : 1.0;
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
// branch along an arc of radius r around the origin, from angle a0 (base) to a1 (tip); leaves alternate
// outside / inside the arc and lean towards the tip by out_angle / in_angle. grow scales the leaves from
// the base (1) to the tip (grow). stem > 0 draws the stem.
module laurel_branch_2d(r=100, a0=228, a1=140, pairs=6, leaf_len=40, leaf_w=13, out_angle=32, in_angle=38,
                        tip_leaf=true, grow=0.9, style="almond", bend=0.1, vein=0, stem=0) {
    dir = a1 < a0 ? -1 : 1;                                    // walking direction along the arc
    n = 2*pairs;
    for (i=[0:n-1]) let(t = (i + 0.5)/n, a = a0 + (a1 - a0)*t, k = 1 + (grow - 1)*t, out = i % 2 == 0,
                        tang = a + dir*90, lean = out ? -dir*out_angle : dir*in_angle)
        translate(polar(r, a)) rotate(tang + lean - 90)
            leaf_2d(leaf_len*k, leaf_w*k, style, bend=(out ? -1 : 1)*dir*bend, vein=vein*k);
    if (tip_leaf) translate(polar(r, a1)) rotate(a1 + dir*90 - 90) leaf_2d(leaf_len*grow*1.05, leaf_w*grow, style, bend=0, vein=vein*grow);
    if (stem > 0) for (i=[0:23]) hull() for (j=[i, i+1]) translate(polar(r, a0 + (a1 - a0)*j/24)) circle(d=stem, $fn=12);
}
// wreath: a branch on the left (around the origin) and its mirror image on the right
module laurel_wreath_2d(r=100, a0=228, a1=140, pairs=6, leaf_len=40, leaf_w=13, out_angle=32, in_angle=38,
                        tip_leaf=true, grow=0.9, style="almond", bend=0.1, vein=0, stem=0) {
    for (m=[0, 1]) mirror([m, 0])
        laurel_branch_2d(r, a0, a1, pairs, leaf_len, leaf_w, out_angle, in_angle, tip_leaf, grow, style, bend, vein, stem);
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
// complete banner. bow adds a knot with two loops and hanging ends under the middle. style "outline" draws
// every piece as a stroke-wide outline, hidden behind the pieces in front of it (band, knot, loops, ends, tails).
module banner_2d(w=100, h=18, sag=4, tail_len=12, tail_drop=12, tail_w=9, notch=5, bow=true, style="filled", stroke=1) {
    d = 0.12*w;                                                   // bow size
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
                    stripe=false) {
    R = d/2;
    stroke_2d(ring_w, inside=true) circle(r=R, $fn=144);
    translate(disc_offset*d) difference() {
        circle(r=disc*R, $fn=96);
        text(str(number), size=numeral*d, font=font, halign="center", valign="center");
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
