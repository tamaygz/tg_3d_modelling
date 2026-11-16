// Parametric patterns for any flat surface: walls, floors, roofs, lids, panels, inserts.
// Use:  use <../../lib/patterns.scad>
//
// Three layers, so a project only picks a pattern by name and says how to apply it:
//   1. pattern engine      pattern_2d() / pattern_3d(): the bare pattern (generators in lib/patterns/*.scad)
//   2. surface application pattern_cutout_2d(), pattern_panel_2d(), pattern_relief(), pattern_cutter(),
//                          pattern_lining(), and pattern_panel(mode, ...) which builds a whole decorated panel
//   3. project geometry    the project places the result with ordinary translate() / rotate()
//
// Frame (every module here): the pattern lies in the XY plane, centred on the origin, inside the rectangle
// `size` = [x, y]. The decorated surface is the plane z = 0 with its outside towards +Z:
//   pattern_3d / pattern_relief   stand on z = 0 and rise to z = h
//   pattern_cutter                reaches from z = 0 down to z = -depth (subtract it from the host)
//   pattern_lining                lies on z = 0, t thick
//   pattern_panel                 is a slab from z = 0 to z = t with the decorated face on top (relief above t)
// To decorate a vertical wall, a sloped roof or any other flat face, build in this frame and then move it:
// e.g. rotate([90, 0, 0]) for a wall facing -Y. Nothing in here assumes a horizontal surface.
//
// Children: the modules take the surface outline as a 2D child (any shape inside `size`); without a child
// the outline is the rectangle `size`. pattern_2d / pattern_3d use the child only to clip the pattern.
//
// A pattern is described by a name or by a spec (one spec, many uses):
//   p = pattern_spec("hex_honeycomb", cell=12, strut=1.5, angle=15);
//   pattern_2d(p, [100, 80]);            pattern_2d("voronoi", [100, 80], cell=10, seed=7);
use <patterns/tiling.scad>
use <patterns/geometric.scad>
use <patterns/woven.scad>
use <patterns/organic.scad>
use <patterns/decorative.scad>
use <patterns/relief.scad>

// ---------- option lists ----------
PATTERNS = ["hex_honeycomb", "square_grid", "diamond_lattice", "triangular_lattice",     // geometric lattices
            "basket_weave", "tri_weave",                                                  // woven (3D)
            "voronoi",                                                                    // organic
            "fish_scales", "truchet_arcs", "girih_star_cross",                            // decorative
            "flowing_waves", "concentric_ripples"];                                       // surface relief
PATTERN_MODES   = ["solid", "through_cut", "open_lattice", "raised", "recessed", "overlay"];   // pattern_panel(mode)
PATTERN_CUTS    = ["cells", "lines"];              // what a cut removes: the openings between the pattern, or the pattern itself
RELIEF_PROFILES = ["flat", "round"];               // top of raised elements
LINING_MODES    = ["through_cut", "raised", "recessed"];
LINING_EDGES    = ["square", "chamfer"];

// smallest printable rib and opening (mm); change them per spec with pattern_spec(min_strut=, min_opening=)
PAT_MIN_STRUT   = 0.8;
PAT_MIN_OPENING = 1.0;
PAT_EPS = 0.01;                                    // overlap between stacked layers, so they fuse

// ---------- pattern spec ----------
// [cell, strut] defaults: cell = repeat pitch, strut = rib / strip / line width (see lib/README.md for each pattern)
function pattern_default(name) =
    name == "hex_honeycomb" ? [12, 1.5] : name == "square_grid" ? [10, 1.5] :
    name == "diamond_lattice" ? [[12, 18], 1.5] : name == "triangular_lattice" ? [14, 1.5] :
    name == "basket_weave" ? [10, 7] : name == "tri_weave" ? [24, 3] :
    name == "voronoi" ? [14, 1.5] : name == "fish_scales" ? [[12, 12], 0.8] :
    name == "truchet_arcs" ? [12, 1.6] : name == "girih_star_cross" ? [24, 1.6] :
    name == "flowing_waves" ? [8, 2.4] : name == "concentric_ripples" ? [6, 2] : undef;
function pattern_known(name) = !is_undef(pattern_default(name));

// name      one of PATTERNS
// cell      repeat pitch, number or [x, y]          strut    rib / strip / line width, number or [a, b]
// angle     rotation of the pattern (degrees)       offset   [x, y] shift of the pattern (phase), in its own axes
// density   >1 = more, smaller cells (pitch = cell/density; strut unchanged)
// seed      for the patterns with random variation  scale    [x, y] stretch of the finished pattern (also stretches ribs)
// opts      pattern-specific settings as [["key", value], ...] (see pattern_opt_keys())
// min_strut, min_opening   printability limits checked by every module (0 = no check)
function pattern_spec(name, cell, strut, angle=0, offset=[0, 0], density=1, seed=1, scale=[1, 1], opts=[],
                      min_strut=PAT_MIN_STRUT, min_opening=PAT_MIN_OPENING) =
    assert(pattern_known(name), str("unknown pattern \"", name, "\"; choose one of ", PATTERNS))
    assert(density > 0, "pattern density must be above 0")
    [name, is_undef(cell) ? pattern_default(name)[0] : cell, is_undef(strut) ? pattern_default(name)[1] : strut,
     angle, offset, density, seed, pat_xy(scale), opts, min_strut, min_opening];
// settings each pattern reads from opts (anything else is ignored)
function pattern_opt_keys(name) =
    name == "hex_honeycomb" ? ["orient"] : name == "square_grid" ? ["stagger"] :
    name == "triangular_lattice" ? ["alternate", "orient"] :
    name == "basket_weave" || name == "tri_weave" ? ["lift", "style"] :
    name == "voronoi" ? ["irregularity", "min_cell", "round"] :
    name == "fish_scales" ? ["overlap", "curvature", "stagger", "shingle", "steps"] :
    name == "truchet_arcs" ? ["variation", "bias"] : name == "girih_star_cross" ? ["star", "star_ratio"] :
    name == "flowing_waves" ? ["amplitude", "wavelength", "phase", "shift", "ties"] :
    name == "concentric_ripples" ? ["rings", "first", "centers", "spokes", "falloff", "steps"] : [];
function pat_opt(opts, key, default) = let(r = [for (e=opts) if (e[0] == key) e[1]]) len(r) > 0 ? r[0] : default;

// a name (plus the common settings given as arguments) or a ready spec -> spec
function _ps(p, cell, strut, angle, seed, opts) = is_string(p)
    ? pattern_spec(p, cell, strut, is_undef(angle) ? 0 : angle, seed=is_undef(seed) ? 1 : seed, opts=is_undef(opts) ? [] : opts) : p;
function _pc(s) = s[1]/s[5];                                   // effective cell
function _po(s, key, default) = pat_opt(s[8], key, default);

function pattern_is_3d(p) = let(n = is_string(p) ? p : p[0]) n == "basket_weave" || n == "tri_weave";
// true if the pattern's material forms one network that reaches the edge of any outline (so it can stand
// alone as an open lattice or stay in one piece when its cells are cut through)
function pattern_is_connected(p) = let(s = _ps(p), n = s[0])
    n == "truchet_arcs" ? false : n == "concentric_ripples" ? let(sp = _po(s, "spokes", undef)) is_undef(sp) || sp > 0 : true;
// Line patterns need ties when they are cut through: without them the lines only hang on the frame (they
// would print as long bridges and flex). Wherever the cells are cut out, a spec that does not say otherwise gets
// them: flowing_waves ties = 1 (a bar between neighbouring ribs every wavelength), concentric_ripples spokes = 6.
// Set opts ["ties", 0] / ["spokes", 0] to switch them off, or a number to choose. Reliefs are left as they are.
function pattern_tied(p) = let(s = _ps(p), add =
    s[0] == "flowing_waves" && is_undef(_po(s, "ties", undef)) ? [["ties", 1]] :
    s[0] == "concentric_ripples" && is_undef(_po(s, "spokes", undef)) ? [["spokes", 6]] : [])
    len(add) == 0 ? s : [for (i=[0:len(s)-1]) i == 8 ? concat(s[8], add) : s[i]];
// Wrapping a pattern round a closed wall: it only closes without a seam if it repeats after exactly the length
// of the wall. pattern_period(p) = the length along X after which a pattern repeats (0 = it does not).
// pattern_wrapped(p, L) = the same pattern, adjusted as little as possible so that L is a whole number of
// repeats: the cell size is scaled by a few percent (rib widths stay), flowing waves get a fitting wavelength,
// and the random patterns (voronoi, truchet_arcs) are made to repeat after L. Rotated or stretched patterns and
// concentric ripples are returned unchanged (they cannot be made to repeat this way).
function pattern_period(p) = let(s = _ps(p), n = s[0], c = pat_xy(_pc(s))[0])
    n == "hex_honeycomb" ? (_po(s, "orient", "pointy") == "flat" ? c*sqrt(3) : c) :
    n == "triangular_lattice" ? (_po(s, "orient", "up") == "side" ? c*sqrt(3) : c) :
    n == "basket_weave" ? 2*c : n == "tri_weave" ? c/sin(60) :
    n == "truchet_arcs" ? 2*c :
    n == "flowing_waves" ? _po(s, "wavelength", 30) : n == "concentric_ripples" ? 0 : c;
function pattern_wrapped(p, L) = let(s = _ps(p), per = pattern_period(s))
    s[3] != 0 || s[7] != [1, 1] || per <= 0 ? s : let(
        n = max(1, round(L/per)), k = L/(n*per),
        add = s[0] == "flowing_waves" ? [["wavelength", L/n]] :
              s[0] == "voronoi" ? [["wrap", n]] : s[0] == "truchet_arcs" ? [["wrap", 2*n]] : [],
        cell = s[0] == "flowing_waves" ? s[1] : is_list(s[1]) ? [for (x=s[1]) x*k] : s[1]*k)
        [for (i=[0:len(s)-1]) i == 1 ? cell : i == 8 ? concat(add, s[8]) : s[i]];
// the same pattern moved by d = [x, y] on the surface (the anchor of the pattern goes to d)
function pattern_shift(p, d) = let(s = _ps(p), q = pat_rot(d, -s[3])) [for (i=[0:len(s)-1]) i == 4 ? s[4] + q : s[i]];

// ---------- printability ----------
// [smallest rib width, smallest opening] of a spec
function pattern_features(p) = let(s = _ps(p), n = s[0], c = pat_xy(_pc(s)), st = pat_xy(s[2]))
    n == "hex_honeycomb" ? [st[0], c[0] - st[0]] :
    n == "square_grid" ? [min(st), min(c[0] - st[0], c[1] - st[1])] :
    n == "diamond_lattice" ? [st[0], 2*(c[0]*c[1]/4/norm(c/2) - st[0]/2)] :
    n == "triangular_lattice" ? [st[0], 2*(c[0]/(2*sqrt(3)) - st[0]/2)] :
    n == "basket_weave" ? [st[0], c[0] - st[0]] :
    n == "tri_weave" ? [st[0], tri_weave_opening(c[0], st[0])] :
    n == "voronoi" ? [st[0], c[0]/2 - st[0]] :
    n == "fish_scales" ? [st[0], min(c[0], fish_row_pitch(c, _po(s, "overlap", 0.4))) - st[0]] :
    n == "truchet_arcs" ? [st[0], c[0]/2 - st[0]] :
    n == "girih_star_cross" ? [st[0], 0.29*_po(s, "star", c[0]) - st[0]] :
    n == "flowing_waves" ? [st[0], wave_gap(c[0], st[0], _po(s, "amplitude", 3), _po(s, "wavelength", 30), _po(s, "shift", 0))] :
    [st[0], c[0] - st[0]];
// "" if the spec is printable, otherwise what is wrong (use in an assert, or show it to the user)
function pattern_problem(p) = let(s = _ps(p), f = pattern_features(s), closed = s[0] == "basket_weave" && abs(f[1]) < 0.001)
    s[9] > 0 && f[0] < s[9] - 0.001 ? str(s[0], ": rib/strip width ", f[0], " is below min_strut ", s[9]) :
    f[1] < -0.001 ? str(s[0], ": strut ", s[2], " does not fit into cell ", _pc(s), " (elements overlap)") :
    s[10] > 0 && !closed && f[1] < s[10] - 0.001 ? str(s[0], ": openings are about ", f[1], " wide, below min_opening ", s[10],
        " (larger cell, thinner strut, or lower density)") : "";

// ---------- layer 1: pattern engine ----------
// the bare 2D pattern (material), generated to cover `cover` around the origin, in the pattern's own axes
module _pat_gen_2d(s, cover, g=[0, 0]) {
    n = s[0]; c = _pc(s); st = s[2];
    if (n == "hex_honeycomb") hex_honeycomb_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "orient", "pointy"), center=g);
    else if (n == "square_grid") square_grid_2d(cover, c, st, _po(s, "stagger", 0), center=g);
    else if (n == "diamond_lattice") diamond_lattice_2d(cover, c, pat_xy(st)[0], center=g);
    else if (n == "triangular_lattice") triangular_lattice_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "alternate", true), _po(s, "orient", "up"), center=g);
    else if (n == "basket_weave") basket_weave_2d(cover, pat_xy(c)[0], pat_xy(st)[0], center=g);
    else if (n == "tri_weave") tri_weave_2d(cover, pat_xy(c)[0], pat_xy(st)[0], center=g);
    else if (n == "voronoi") voronoi_2d(cover, pat_xy(c)[0], pat_xy(st)[0], s[6], _po(s, "irregularity", 1), _po(s, "min_cell", 0), _po(s, "round", 0), center=g, wrap=_po(s, "wrap", 0));
    else if (n == "fish_scales") fish_scales_2d(cover, pat_xy(c), pat_xy(st)[0], _po(s, "overlap", 0.4), _po(s, "curvature", 0.7), _po(s, "stagger", 0.5), center=g);
    else if (n == "truchet_arcs") truchet_arcs_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "variation", "random"), s[6], _po(s, "bias", 0.5), center=g, wrap=_po(s, "wrap", 0));
    else if (n == "girih_star_cross") girih_star_cross_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "star", undef), _po(s, "star_ratio", undef), center=g);
    else if (n == "flowing_waves") flowing_waves_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "amplitude", 3), _po(s, "wavelength", 30), _po(s, "phase", 0), _po(s, "shift", 0), center=g, ties=_po(s, "ties", 0));
    else if (n == "concentric_ripples") concentric_ripples_2d(cover, pat_xy(c)[0], pat_xy(st)[0], _po(s, "rings", 0), _po(s, "first", undef), _po(s, "centers", [[0, 0]]), _po(s, "spokes", 0), center=g);
}
// relief levels: most patterns are one flat level; fish scales rise towards their tips, ripples fall off outwards
function pattern_levels(p) = let(s = _ps(p), n = s[0])
    n == "fish_scales" && _po(s, "shingle", true) ? _po(s, "steps", 3) :
    n == "concentric_ripples" && _po(s, "falloff", 0) > 0 ? _po(s, "steps", 4) : 1;
function _pat_level_top(s, k, K) = s[0] == "concentric_ripples" ? 1 - _po(s, "falloff", 0)*(K - k)/K : k/K;   // share of h
module _pat_level_2d(s, cover, k, K, g=[0, 0]) {
    n = s[0]; c = _pc(s); st = s[2];
    if (K == 1) _pat_gen_2d(s, cover, g);
    else if (n == "fish_scales") fish_scales_level_2d(cover, k, K, pat_xy(c), _po(s, "overlap", 0.4), _po(s, "curvature", 0.7), _po(s, "stagger", 0.5), center=g);
    else concentric_ripples_level_2d(cover, k, K, pat_xy(c)[0], pat_xy(st)[0], _po(s, "rings", 0), _po(s, "first", undef), _po(s, "centers", [[0, 0]]), _po(s, "spokes", 0), center=g);
}
module _pat_weave_3d(s, cover, h, g=[0, 0]) {
    c = pat_xy(_pc(s))[0]; w = pat_xy(s[2])[0];
    if (s[0] == "basket_weave") basket_weave_3d(cover, h, c, w, _po(s, "lift", undef), _po(s, "style", "flat"), g);
    else tri_weave_3d(cover, h, c, w, _po(s, "lift", undef), _po(s, "style", "flat"), g);
}
// Window: set the special variable $pat_window = [[cx, cy], [w, h]] around any module of this file to build only
// that part of the surface. The result is exactly the piece of the full pattern, panel or lining inside the
// window (frames and outlines are still worked out on the whole surface). lib/shell.scad uses this to bend a
// panel round corners piece by piece; use it yourself to split a large panel into printable tiles.
function _pat_win(size) = is_undef($pat_window) ? [[0, 0], size] : $pat_window;
// area the generator must cover (in its own axes) to fill a window of `wsize`, and the point it must cover it around
function _pat_cover(s, wsize) = let(a = s[3]) [(abs(wsize[0]*cos(a)) + abs(wsize[1]*sin(a)))/s[7][0], (abs(wsize[0]*sin(a)) + abs(wsize[1]*cos(a)))/s[7][1]];
function _pat_gcenter(s, wc) = let(q = pat_rot(wc, -s[3]) - s[4]) [q[0]/s[7][0], q[1]/s[7][1]];
module _pat_place(s) { rotate(s[3]) translate(s[4]) scale(s[7]) children(); }
// the surface rectangle, cut down to the window
module _pat_rect(size) {
    if (is_undef($pat_window)) square(size, center=true);
    else intersection() { square(size, center=true); translate($pat_window[0]) square($pat_window[1], center=true); }
}
// clip finished 2D geometry to the window (nothing to do without one)
// $pat_shrink (optional, with a window) pulls the piece's material in by that much. Pieces that overlap at an
// angle (facets of a bent wall) get different values, so their surfaces cross cleanly instead of almost coinciding.
module _pat_w() {
    if (is_undef($pat_window)) children();
    else if (is_undef($pat_shrink) || $pat_shrink == 0) intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
    else offset(delta=-$pat_shrink) intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
}
// shrink only (for 2D that is already cut to the window)
module _pat_s() { if (is_undef($pat_window) || is_undef($pat_shrink) || $pat_shrink == 0) children(); else offset(delta=-$pat_shrink) children(); }
// clip only, no shrink: for shapes that are cut OUT of the material (their edges move with the material's)
module _pat_wc() {
    if (is_undef($pat_window)) children();
    else intersection() { translate($pat_window[0]) square($pat_window[1], center=true); children(); }
}
// the placed pattern, generated for the window only
module _pat_field(s, size) { w = _pat_win(size); _pat_place(s) _pat_gen_2d(s, _pat_cover(s, w[1]), _pat_gcenter(s, w[0])); }
// inset of an outline: b = one distance all round, or [sides, bottom, top] / [x, y] for different frame widths
// (the list form moves the outline instead of offsetting it, so a wavy top edge keeps a band of constant height)
function _pat_b3(b) = is_list(b) ? (len(b) > 2 ? b : [b[0], b[1], b[1]]) : [b, b, b];
function _pat_badd(b, d) = is_list(b) ? [for (x=b) max(0, x + d)] : max(0, b + d);
module _pat_inset(b) {
    if (is_list(b)) { q = _pat_b3(b); intersection() { translate([q[0], 0]) children(); translate([-q[0], 0]) children(); translate([0, q[1]]) children(); translate([0, -q[2]]) children(); } }
    else if (b == 0) children();
    else offset(delta=-b) children();
}
module _pat_check(s, size) {
    assert(is_list(size) && len(size) == 2 && size[0] > 0 && size[1] > 0, "pattern: size must be [x, y]");
    assert(pattern_problem(s) == "", pattern_problem(s));
}

// 2D pattern (the material: ribs, lines, strands seen from above), clipped to `size` and to the child outline.
// Use it with linear_extrude(), difference(), intersection(), union() like any other 2D shape.
module pattern_2d(p, size, cell, strut, angle, seed, opts) {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_2d(s, size) children(); else _pattern_2d(s, size) square(size, center=true);
}
module _pattern_2d(s, size) {
    intersection() { _pat_rect(size); children(); _pat_field(s, size); }
}
module _pattern_level(s, size, k, K) {
    w = _pat_win(size);
    intersection() { _pat_rect(size); children(); _pat_place(s) _pat_level_2d(s, _pat_cover(s, w[1]), k, K, _pat_gcenter(s, w[0])); }
}

// 3D pattern in its natural form, standing on z = 0, h high in total, clipped like pattern_2d:
// woven patterns as real over-under strands, fish scales as stepped shingles, ripples with falloff, all others
// as a plain extrusion. profile "round" rounds the top of flat ribs in `steps` layers.
module pattern_3d(p, size, h=2, cell, strut, angle, seed, opts, profile="flat", steps=3) {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_3d(s, size, h, profile, steps) children();
    else _pattern_3d(s, size, h, profile, steps) square(size, center=true);
}
module _pattern_3d(s, size, h, profile="flat", steps=3) {
    K = pattern_levels(s);
    if (pattern_is_3d(s)) intersection() {
        w = _pat_win(size);
        _pat_place(s) _pat_weave_3d(s, _pat_cover(s, w[1]), h, _pat_gcenter(s, w[0]));
        translate([0, 0, -1]) linear_extrude(h + 2) intersection() { _pat_rect(size); children(); }
    }
    else if (K == 1 && profile == "round") {
        r = min(h, pat_xy(s[2])[0]/2);                                // rounding radius of the rib tops
        linear_extrude(h - r + PAT_EPS) _pat_s() _pattern_2d(s, size) children();
        for (i=[1:steps]) let(a = 90*i/steps, a0 = 90*(i - 1)/steps)
            linear_extrude(h - r + r*sin(a)) offset(delta=-r*(1 - cos(a0)) - (i == 1 ? 0 : PAT_EPS)) _pat_s() _pattern_2d(s, size) children();
    }
    else for (k=[1:K]) linear_extrude(h*_pat_level_top(s, k, K)) _pat_s() _pattern_level(s, size, k, K) children();
}

// ---------- layer 2: surface application ----------
module _pat_outline(size) { intersection() { square(size, center=true); children(); } }
// remove slivers narrower than e from a 2D shape (openings cut off by the edge of the surface)
module _pat_open(e) { if (e > 0) offset(delta=e/2) offset(delta=-e/2) children(); else children(); }

// 2D shape to cut out of a surface so the pattern stays: the openings between the pattern ("cells") or the
// pattern itself ("lines"), kept `inset` away from the edge of the outline. Openings narrower than the spec's
// min_opening (slivers at the edge) are left closed.
module pattern_cutout_2d(p, size, cell, strut, angle, seed, opts, inset=0, cut="cells") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_cutout_2d(s, size, inset, cut) children();
    else _pattern_cutout_2d(s, size, inset, cut) square(size, center=true);
}
module _pattern_cutout_2d(s, size, inset=0, cut="cells") {
    if (cut == "lines") _pat_wc() intersection() { _pat_inset(inset) _pat_outline(size) children(); _pat_field(s, size); }
    else _pat_wc() _pat_open(s[10]) difference() { _pat_inset(inset) _pat_outline(size) children(); _pat_field(pattern_tied(s), size); }
}
// 2D open lattice: the outline with the cells cut out, leaving the pattern and a closed frame `border` wide
module pattern_panel_2d(p, size, cell, strut, angle, seed, opts, border=2, cut="cells") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_panel_2d(s, size, border, cut) children();
    else _pattern_panel_2d(s, size, border, cut) square(size, center=true);
}
module _pattern_panel_2d(s, size, border=2, cut="cells") {
    _pat_w() difference() { _pat_outline(size) children(); _pattern_cutout_2d(s, size, border, cut) children(); }
}

// raised pattern to add on a surface at z = 0: h high, kept `pad` away from the edge of the outline.
// It starts a hair below z = 0 so it fuses with the host.
module pattern_relief(p, size, h=0.8, cell, strut, angle, seed, opts, pad=0, profile="flat", steps=3) {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_relief(s, size, h, pad, profile, steps) children();
    else _pattern_relief(s, size, h, pad, profile, steps) square(size, center=true);
}
module _pattern_relief(s, size, h, pad=0, profile="flat", steps=3) {
    translate([0, 0, -PAT_EPS]) _pattern_3d(s, size, h + PAT_EPS, profile, steps) _pat_inset(pad) children();
}

// cutter to subtract from a host whose surface is z = 0 (body below): engraves the pattern ("lines") or cuts
// its openings ("cells") `depth` deep; for a through-cut give the wall thickness or more.
module pattern_cutter(p, size, depth=0.6, cell, strut, angle, seed, opts, pad=0, cut="lines") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    translate([0, 0, -depth]) linear_extrude(depth + PAT_EPS)
        if ($children > 0) _pattern_cutout_2d(s, size, pad, cut) children();
        else _pattern_cutout_2d(s, size, pad, cut) square(size, center=true);
}

// lining / overlay: a separate decorative skin lying on a surface at z = 0.
// t = skin thickness, inset = distance from the edge of the surface to the edge of the skin, border = plain
// frame around the pattern, mode: "through_cut" = perforated skin (the cells are open, the host shows through),
// "raised" = closed skin with the pattern raised by `depth` on it, "recessed" = pattern engraved `depth` deep
// into the skin. edge "chamfer" steps the top edge in by t/2.
module pattern_lining(p, size, t=0.6, cell, strut, angle, seed, opts, mode="through_cut", depth=0.4, inset=1.5, border=1.5,
                      edge="square", profile="flat") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_lining(s, size, t, mode, depth, inset, border, edge, profile) children();
    else _pattern_lining(s, size, t, mode, depth, inset, border, edge, profile) square(size, center=true);
}
module _pattern_lining(s, size, t, mode, depth, inset, border, edge, profile) {
    assert(mode != "through_cut" || pattern_is_connected(s), str(s[0], " leaves loose pieces when cut through: use raised or recessed", s[0] == "concentric_ripples" ? ", or add spokes" : ""));
    assert(mode != "recessed" || depth < t, str("lining: recess depth ", depth, " must be less than the lining thickness ", t));
    ch = edge == "chamfer" ? t/2 : 0;                    // chamfer height = how far the top steps in
    cut_d = mode == "through_cut" ? t : mode == "recessed" ? depth : 0;
    zc = t - cut_d; zh = t - ch;                         // where the cut and the chamfer start
    zs = [0, min(zc, zh), max(zc, zh), t];               // layers: plain / cut and / or stepped in
    translate([0, 0, -PAT_EPS]) for (i=[0:2]) if (zs[i+1] - zs[i] > 0.001)
        translate([0, 0, zs[i]]) linear_extrude(zs[i+1] - zs[i] + PAT_EPS) _pat_w() difference() {
            offset(delta=-inset - (ch > 0 && zs[i] >= zh - 0.001 ? ch : 0)) _pat_outline(size) children();
            if (cut_d > 0 && zs[i] >= zc - 0.001) _pattern_cutout_2d(s, size, _pat_badd(border, inset), mode == "through_cut" ? "cells" : "lines") children();
        }
    if (mode == "raised") translate([0, 0, t]) _pattern_relief(s, size, depth, _pat_badd(border, inset), profile) children();
}

// a complete flat panel from an outline: slab z = 0..t, decorated face on top.
//   "solid"         plain slab
//   "through_cut"   the pattern's cells cut through the slab, `border` + `pad` of solid edge left
//   "open_lattice"  only the pattern and a frame `border` wide, no backing (woven patterns: real strands, t high)
//   "raised"        slab plus the pattern raised by `depth`, kept `border` + `pad` from the edge
//   "recessed"      the pattern engraved `depth` deep into the slab
//   "overlay"       slab plus a lining (lining_t thick; lining_mode, depth, inset = pad, border)
module pattern_panel(mode, p, size, t=2, cell, strut, angle, seed, opts, depth=0.8, border=2, pad=0, profile="flat",
                     lining_t=0.6, lining_mode="through_cut", lining_edge="square") {
    s = _ps(p, cell, strut, angle, seed, opts);
    _pat_check(s, size);
    if ($children > 0) _pattern_panel(mode, s, size, t, depth, border, pad, profile, lining_t, lining_mode, lining_edge) children();
    else _pattern_panel(mode, s, size, t, depth, border, pad, profile, lining_t, lining_mode, lining_edge) square(size, center=true);
}
module _pattern_panel(mode, s, size, t, depth, border, pad, profile, lining_t, lining_mode, lining_edge) {
    assert(len([for (m=PATTERN_MODES) if (m == mode) m]) == 1, str("unknown pattern mode \"", mode, "\"; choose one of ", PATTERN_MODES));
    open = mode == "through_cut" || mode == "open_lattice";
    assert(!open || pattern_is_connected(s), str(s[0], " leaves loose pieces as ", mode, ": use raised, recessed or overlay", s[0] == "concentric_ripples" ? ", or add spokes" : ""));
    assert(mode != "recessed" || depth < t, str("panel: recess depth ", depth, " must be less than the thickness ", t));
    if (mode == "solid") linear_extrude(t) _pat_w() _pat_outline(size) children();
    else if (mode == "open_lattice" && pattern_is_3d(s)) {
        linear_extrude(t) _pat_w() difference() { _pat_outline(size) children(); _pat_inset(border) _pat_outline(size) children(); }
        _pattern_3d(s, size, t) _pat_inset(_pat_badd(_pat_badd(border, pad), -0.3)) children();     // strands reach 0.3 into the frame
    }
    else if (open) linear_extrude(t) _pattern_panel_2d(s, size, _pat_badd(border, pad)) children();
    else if (mode == "raised") {
        linear_extrude(t) _pat_w() _pat_outline(size) children();
        translate([0, 0, t]) _pattern_relief(s, size, depth, _pat_badd(border, pad), profile) children();
    }
    else if (mode == "recessed") {
        linear_extrude(t - depth) _pat_w() _pat_outline(size) children();
        translate([0, 0, t - depth - PAT_EPS]) linear_extrude(depth + PAT_EPS) _pat_w()
            difference() { _pat_outline(size) children(); _pattern_cutout_2d(s, size, _pat_badd(border, pad), "lines") children(); }
    }
    else {
        linear_extrude(t) _pat_w() _pat_outline(size) children();
        translate([0, 0, t]) _pattern_lining(s, size, lining_t, lining_mode, depth, pad, border, lining_edge, profile) children();
    }
}
