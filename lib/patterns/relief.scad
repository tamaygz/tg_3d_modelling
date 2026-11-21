// Surface relief patterns: flowing waves, concentric ripples, fluted / reeded ribs.
// Use:  use <../../lib/patterns.scad> and pattern_2d("flowing_waves", ...), or use this file for the single generators.
// Frame: XY plane, anchored on the origin, covers `size` (centred) and a little more; not clipped.
// The *_2d modules return the MATERIAL (ribs, rings).
use <tiling.scad>

// ---------- flowing waves ----------
// Parallel ribs along X that follow a sine wave. cell = rib pitch (centre to centre), strut = rib width
// (measured across the rib, the same everywhere), amplitude and wavelength of the wave, phase (degrees) of the
// first rib, shift (degrees) added from rib to rib (0 = ribs run parallel, 180 = neighbours mirror each other).
// The wave repeats every `wavelength`, so panels cut at multiples of it join without a visible seam.
function wave_max_slope(amplitude, wavelength) = amplitude*2*PI/wavelength;
function wave_min_radius(amplitude, wavelength) = amplitude == 0 ? 1e9 : pow(wavelength/(2*PI), 2)/amplitude;    // tightest bend of the centre line
// smallest gap between two neighbouring ribs (they come closest where the wave is steepest; exact for shift = 0)
function wave_gap(cell, strut, amplitude, wavelength, shift=0) = let(v = cell - 2*amplitude*abs(sin(shift/2)))
    v/sqrt(1 + pow(wave_max_slope(amplitude, wavelength), 2)) - strut;
function wave_rib_pts(L, y0, strut, amplitude, wavelength, phase, n, xc=0) = let(
    k = 360/wavelength,
    c = [for (i=[0:n]) let(x = xc - L/2 + i*L/n, s = amplitude*k*PI/180*cos(k*x + phase), u = [-s, 1]/norm([s, 1]))
        [[x, y0 + amplitude*sin(k*x + phase)], u*strut/2]])
    concat([for (p=c) p[0] + p[1]], [for (i=[n:-1:0]) c[i][0] - c[i][1]]);
// ties > 0 joins every rib to the next with a short bar, `ties` wavelengths apart, so the ribs form one network
// that prints and stays stiff when the pattern is cut through. The bars sit where two ribs come closest
// (shift != 0), or alternately on the crests and in the troughs (parallel ribs), like the bonds of brickwork.
function wave_tie_x(j, wavelength, phase=0, shift=0) = let(
    target = shift == 0 ? (abs(j)%2 == 0 ? 90 : 270) : (sin(shift/2) > 0 ? 180 : 0))
    (target - phase - j*shift - shift/2)*wavelength/360;
module flowing_waves_2d(size, cell=8, strut=2.4, amplitude=3, wavelength=30, phase=0, shift=0, center=[0, 0], ties=0) {
    assert(wave_min_radius(amplitude, wavelength) > strut/2, str("flowing_waves: the wave bends tighter (radius ",
        wave_min_radius(amplitude, wavelength), ") than half the rib width ", strut/2, ": lower the amplitude or raise the wavelength"));
    L = size[0] + 2*cell; n = max(8, ceil(L/wavelength*32));
    for (j=[pat_i0(size[1] + 2*amplitude, cell, center[1]):pat_i1(size[1] + 2*amplitude, cell, center[1])])
        polygon(wave_rib_pts(L, j*cell, strut, amplitude, wavelength, phase + j*shift, n, center[0]));
    if (ties > 0) for (j=[pat_i0(size[1] + 2*amplitude, cell, center[1]):pat_i1(size[1] + 2*amplitude, cell, center[1])]) {
        P = wavelength*ties; x0 = wave_tie_x(j, wavelength, phase, shift);
        for (m=[floor((center[0] - L/2 - x0)/P):ceil((center[0] + L/2 - x0)/P)]) let(x = x0 + m*P,
            ya = j*cell + amplitude*sin(360*x/wavelength + phase + j*shift),
            yb = (j + 1)*cell + amplitude*sin(360*x/wavelength + phase + (j + 1)*shift))
            translate([x - strut/2, ya]) square([strut, yb - ya]);
    }
}

// ---------- concentric ripples ----------
// Rings around one or more centres. cell = ring spacing, strut = ring width, rings = number of rings per centre
// (0 = as many as needed to fill `size`), first = radius of the first ring (default = cell), centers = list of
// [x, y]. spokes > 0 adds that many radial bars per centre, which ties the rings into one connected web (needed
// for cut-through and open-lattice use; plain rings are loose).
function ripple_count(size, cell, rings=0, first, centers=[[0, 0]]) = rings > 0 ? rings :
    ceil((norm(size)/2 + max([for (c=centers) norm(c)]) - (is_undef(first) ? cell : first))/cell) + 1;
function ripple_radius(i, cell, first) = (is_undef(first) ? cell : first) + (i - 1)*cell;      // ring i = 1..n
module ripple_rings_2d(i0, i1, cell=6, strut=2, first, centers=[[0, 0]], spokes=0) {
    for (c=centers) translate(c) {
        for (i=[i0:1:i1]) let(r = ripple_radius(i, cell, first), fn = max(32, min(180, ceil(r*2.5))))
            difference() { circle(r=r + strut/2, $fn=fn); if (r > strut/2) circle(r=r - strut/2, $fn=fn); }
        if (spokes > 0 && i1 > i0) for (a=[0:spokes-1]) rotate(a*360/spokes)
            translate([ripple_radius(i0, cell, first), -strut/2]) square([ripple_radius(i1, cell, first) - ripple_radius(i0, cell, first), strut]);
    }
}
// (rings always start at their centre, so a window far from it still needs every ring up to there)
module concentric_ripples_2d(size, cell=6, strut=2, rings=0, first, centers=[[0, 0]], spokes=0, center=[0, 0]) {
    ripple_rings_2d(1, ripple_count(size + 2*[abs(center[0]), abs(center[1])], cell, rings, first, centers), cell, strut, first, centers, spokes);
}
// relief with falloff, level k of `steps` (1 = lowest, all rings): the inner rings rise higher than the outer ones
module concentric_ripples_level_2d(size, k, steps=4, cell=6, strut=2, rings=0, first, centers=[[0, 0]], spokes=0, center=[0, 0]) {
    n = ripple_count(size + 2*[abs(center[0]), abs(center[1])], cell, rings, first, centers);
    ripple_rings_2d(1, ceil(n*(steps - k + 1)/steps), cell, strut, first, centers, spokes);
}

// ---------- fluted / reeded ribs ----------
// Parallel straight ribs, like a fluted column or a reeded vase. cell = rib pitch, strut = rib width (reeded) or
// groove width (fluted); strut = cell makes them touch, as on most reeded vases. orient: "vertical" = ribs along
// Y (upright on a wall built with lib/shell.scad), "horizontal" = along X.
// Its natural 3D form (see fluted_level_2d) has a rounded profile:
//   style "reeded"  convex half-round ribs standing on the surface
//   style "fluted"  concave half-round grooves sunk into a band of the relief height
//   style "ribbed"  flat-topped ribs (a plain extrusion)
// Cut through, the ribs are tied like flowing waves (ties every tie_pitch, staggered like brick bonds).
FLUTE_STYLES = ["reeded", "fluted", "ribbed"];
FLUTE_ORIENTS = ["vertical", "horizontal"];
FLUTE_FLOOR = 0.25;      // fluted style: groove bottoms stay this share of the relief height above the surface
module _flute_turn(orient, size, center) {
    if (orient == "vertical") rotate(90) children(); else children();
}
module fluted_2d(size, cell=6, strut=6, orient="vertical", tie_pitch=0, ties=0, center=[0, 0]) {
    v = orient == "vertical";
    s = v ? [size[1], size[0]] : size; c = v ? pat_rot(center, -90) : center;
    rotate(v ? 90 : 0) flowing_waves_2d(s, cell, min(strut, cell), 0, tie_pitch > 0 ? tie_pitch : 4*cell, 0, 0, c, ties);
}
// level k of `steps` of the rounded relief (extrude level k from 0 to k/steps of the relief height)
module fluted_level_2d(size, k, steps=6, cell=6, strut=6, style="reeded", orient="vertical", center=[0, 0]) {
    v = orient == "vertical";
    s = v ? [size[1], size[0]] : size; c = v ? pat_rot(center, -90) : center;
    t = (k - 0.5)/steps;                                          // height share this level stands for
    w = min(strut, cell);
    L = s[0] + 2*cell;
    rows = [pat_i0(s[1], cell, c[1], 2):pat_i1(s[1], cell, c[1], 2)];
    rotate(v ? 90 : 0) {
        if (style == "fluted") difference() {                     // concave grooves: the band minus each groove's
            translate(c) square([L, s[1] + 4*cell], center=true);   // width at this height; the grooves keep a floor of
            if (t > FLUTE_FLOOR) for (j=rows)                       // FLUTE_FLOOR x the relief height, so the band is one piece
                translate([c[0], j*cell]) square([L + 1, w*sqrt(1 - pow(1 - (t - FLUTE_FLOOR)/(1 - FLUTE_FLOOR), 2))], center=true);
        }
        else for (j=rows) translate([c[0], j*cell])                // convex ribs: narrower towards the top
            square([L, style == "ribbed" ? w : w*sqrt(1 - t*t)], center=true);
    }
}
