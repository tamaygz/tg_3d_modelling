// Self-watering planter: a tapered pot with a water reservoir, a soil insert that wicks from it, a float that
// shows the water level (with a cute topper), and a decorated band in the visible upper part of the wall.
// Reservoir below the insert (stacked), below with a fill tower on the side, or a sealed side tank that keeps the
// reservoir topped up. Built with lib/shell.scad (tapered walls), lib/container.scad, lib/patterns.scad and
// lib/thread.scad (tank cap).
include <../../lib/core.scad>
use <../../lib/shell.scad>
use <../../lib/patterns.scad>
use <../../lib/container.scad>
use <../../lib/thread.scad>

part = "all";                    // which part to export ("all" = assembly); set by the build tools

/* [Size] */
// outer radius at the foot of the pot (mm; half the width for square and polygon shapes)
r_bottom = 45; // [20:1:120]
// outer radius at the rim (mm): larger than r_bottom = the pot flares out, smaller = it narrows (an urn)
r_top = 58; // [20:1:125]
// height of the pot to the rim (mm), before rim waves and slants
pot_height = 110; // [50:1:250]
// outline of the pot
shape = "round"; // [round, polygon, rounded_square, squircle]
// polygon: number of sides
sides = 6; // [3:1:12]
// rounded square: corner radius (mm)
corner_r = 14; // [2:1:60]
// squircle: 2 = ellipse, 4 = soft square, 8 = nearly square
squareness = 4; // [2:0.5:10]
// depth / width (1 = round or square; less = oval or oblong)
aspect = 1; // [0.5:0.05:1.5]
// waves in the outline itself (a fluted, flower-like pot): how far the wall swings in and out (mm; 0 = none)
side_wave = 0; // [0:0.25:8]
// number of those waves round the pot
side_wave_count = 12; // [3:1:40]

/* [Style] */
// a preset sets the outline, band pattern, lines and lip below; custom = use the settings as they are
style_preset = "custom"; // [custom, terracotta, honeycomb, scallop, fluted, crown, blossom]
// where the decorated band starts, in % of the pot height (the visible upper part; 66 = the upper third)
band_from = 66; // [0:1:95]
// pattern in the band
band_pattern = "hex_honeycomb"; // [hex_honeycomb, square_grid, diamond_lattice, triangular_lattice, cube_rosette, basket_weave, tri_weave, voronoi, fish_scales, truchet_arcs, girih_star_cross, asanoha, flowing_waves, concentric_ripples, fluted]
// how the band pattern is applied (through_cut only above the reservoir: the insert holds the soil)
band_mode = "raised"; // [solid, through_cut, raised, recessed, overlay]
// band pattern repeat size (mm; 0 = the pattern's default)
band_cell = 0; // [0:0.5:60]
// band rib / line width (mm; 0 = the pattern's default)
band_strut = 0; // [0:0.1:12]
// rotation of the band pattern (degrees)
band_angle = 0; // [-90:5:90]
// relief height (raised), engraving depth (recessed), lining thickness (overlay) (mm)
band_relief = 1; // [0.2:0.1:3]
// seed for Voronoi and Truchet
seed = 1; // [1:1:999]
// shape of the line where the band starts
band_line = "wave"; // [straight, wave, zigzag, scallop, petal]
// band line: how far it rises and falls (mm)
band_line_amp = 4; // [0:0.5:30]
// band line: number of waves round the pot
band_line_count = 6; // [1:1:24]
// band line: slant (mm higher at the back, lower at the front; 0 = level)
band_line_tilt = 0; // [-40:1:40]
// decoration along the band line
band_edge = "bead"; // [none, bead, groove]
// band edge: width of the bead or groove (mm)
band_edge_w = 2.4; // [1:0.2:6]
// band edge: how far the bead stands out / the groove goes in (mm)
band_edge_h = 1; // [0.4:0.1:2.5]
// plain gap between the band line and the pattern (mm)
band_gap = 3; // [0:0.5:20]
// shape of the rim
rim_line = "straight"; // [straight, wave, zigzag, scallop, petal]
// rim: how far it rises and falls (mm)
rim_amp = 4; // [0:0.5:30]
// rim: number of waves round the pot
rim_count = 6; // [1:1:24]
// rim: slant (mm higher on the side given by rim_tilt_dir, as much lower opposite; 0 = level)
rim_tilt = 0; // [-50:1:50]
// rim slant: direction of the high side (degrees; 90 = back, -90 = front, 0 = right)
rim_tilt_dir = 90; // [-180:15:180]
// dip in the front of the rim, e.g. a lip or a cut-out for leaves (depth, mm; 0 = none)
rim_dip = 0; // [0:1:60]
// front dip: width at half its depth (mm)
rim_dip_w = 50; // [10:1:200]
// plain band under the rim (mm)
rim_band = 5; // [0:0.5:30]
// rolled lip on the rim, like a terracotta pot: height (mm; 0 = none)
lip_h = 0; // [0:1:40]
// rolled lip: how far it stands out (mm)
lip_out = 2.5; // [0.5:0.5:6]

/* [Water] */
// below = the reservoir is under the insert (stacked pots), filled through a shaft in the soil;
// below_side = the same reservoir, filled through a tower on the outside; side = a sealed tank on the side
// keeps the reservoir topped up to the top of its feed opening (bird-bath principle) and holds much more
reservoir = "below"; // [below, below_side, side]
// highest water level above the floor (mm): the overflow hole (below, below_side) or the tank's feed opening (side)
water_height = 30; // [10:1:120]
// air gap between the highest water level and the soil (mm): keeps the roots out of standing water
air_gap = 10; // [0:1:40]
// overflow hole at the highest water level, so rain or too much water runs out instead of reaching the soil
overflow = true;
// direction of the overflow hole (degrees; 90 = back, -90 = front)
overflow_dir = 180; // [-180:15:180]
// fill shaft and float guide: inner diameter (mm)
fill_d = 30; // [16:1:50]
// direction of the fill shaft in the soil (below, side) (degrees)
fill_dir = 90; // [-180:15:180]
// tower (below_side) or tank (side): inner diameter (mm)
tank_d = 44; // [20:1:100]
// direction of the tower or tank (degrees; 0 = right)
tank_dir = 0; // [-180:15:180]

/* [Insert] */
// gap between the insert and the pot wall (mm)
insert_gap = 1; // [0.4:0.1:4]
// insert wall thickness (mm)
insert_t = 1.6; // [1.2:0.2:4]
// how far the insert's top sits below the pot's lowest rim point (mm)
insert_drop = 4; // [0:1:30]
// how the soil drinks: cup = a perforated wick basket that the soil fills and stands in the water;
// rope = holes for cotton / nylon cords; both
wick = "cup"; // [cup, rope, both]
// wick basket: diameter (mm)
wick_d = 40; // [20:1:100]
// rope wicks: number of holes
rope_count = 2; // [1:1:6]
// rope wicks: rope diameter (mm)
rope_d = 5; // [2:0.5:12]
// small holes in the insert floor that let surplus water drip into the reservoir
drain_holes = 8; // [0:1:24]

/* [Level indicator] */
// float in the fill shaft or tower: a rod with a topper that rises when there is water
indicator = "float"; // [none, float]
// what sits on top of the rod
topper = "flower"; // [none, flower, sun, star, heart, drop, leaf, mushroom, cloud]
// topper size (mm)
topper_size = 24; // [12:1:50]
// a cute face on the topper (a separate part in a second colour)
topper_face = true;
// rod: printed, or a bamboo skewer cut to the length given in the report
rod = "printed"; // [printed, skewer]
// rod or skewer diameter (mm)
rod_d = 4; // [2.5:0.5:8]

/* [Extras] */
// holder for a capacitive soil moisture sensor (v1.2 board about 98 x 23 mm; measure yours), with a cable notch in the rim
sensor = "none"; // [none, capacitive]
// sensor board width (mm)
sensor_w = 23; // [10:0.5:40]
// sensor board thickness (mm)
sensor_t = 1.6; // [0.8:0.1:4]
// direction of the sensor holder (degrees)
sensor_dir = -45; // [-180:15:180]
// clip for a drip irrigation line: tube outer diameter (mm; 0 = none; 4/7 mm drip line = 7)
drip_d = 0; // [0:0.5:16]
// direction of the drip line clip (degrees)
drip_dir = 45; // [-180:15:180]
// lugs at the rim for hanging cords
hanger = "none"; // [none, cords]
// number of lugs
hanger_count = 3; // [2:1:6]
// saucer under the pot (catches the overflow)
saucer = false;
// saucer: margin round the pot's foot (mm)
saucer_margin = 8; // [3:1:30]
// saucer: rim height (mm)
saucer_h = 14; // [6:1:40]

/* [Print] */
// wall thickness of the pot (mm). Water-tight: 4 or more perimeters, PETG, no vase mode (see README)
wall_t = 2.4; // [1.6:0.2:5]
// floor thickness of the pot (mm)
floor_t = 2.4; // [1.2:0.2:6]
// curved walls are built from flat facets this long (mm; smaller = smoother and slower)
facet = 6; // [2:0.5:20]

/* [Hidden] */
$fn = 48;
// style presets: [shape, band pattern, band mode, band line, band edge, rim line, lip height, side wave]
PRESETS = [
  ["terracotta", ["round", "fluted", "solid", "straight", "bead", "straight", 14, 0]],
  ["honeycomb",  ["round", "hex_honeycomb", "through_cut", "wave", "bead", "straight", 0, 0]],
  ["scallop",    ["round", "fish_scales", "raised", "scallop", "none", "scallop", 0, 0]],
  ["fluted",     ["round", "fluted", "raised", "straight", "groove", "straight", 0, 0]],
  ["crown",      ["polygon", "asanoha", "recessed", "petal", "groove", "petal", 0, 0]],
  ["blossom",    ["round", "voronoi", "through_cut", "wave", "bead", "wave", 0, 1.5]]
];
custom_style = [shape, band_pattern, band_mode, band_line, band_edge, rim_line, lip_h, side_wave];
pi_ = search([style_preset], PRESETS)[0];
ST = is_num(pi_) ? PRESETS[pi_][1] : custom_style;              // active style
s_shape = ST[0]; s_pat = ST[1]; s_mode = ST[2]; s_line = ST[3]; s_edge = ST[4]; s_rim = ST[5]; s_lip = ST[6]; s_wave = ST[7];

// ---------- outline ----------
R0 = r_bottom;                                                   // foot radius
sc = r_top/r_bottom;                                             // taper: top / foot size
ht = pot_height;                                                 // height at which the outline is sc times larger
t = wall_t; ft = floor_t;
size0 = [2*R0, 2*R0*aspect];
n_round = max(24, ceil(2*PI*max(R0, r_top)/facet/4)*4);          // facets round a curved pot
poly_c = [for (j=[0:sides-1]) let(a = -90 + 180/sides + 360*j/sides) [R0*cos(a), R0*aspect*sin(a)]];   // a flat side at the front
poly_m = s_wave > 0 ? max(2, ceil(2*PI*R0/sides/facet)) : 2;    // edges per polygon side (a vertex in each side's middle)
poly_pts = [for (j=[0:sides-1]) for (k=[0:poly_m-1]) poly_c[j] + (poly_c[(j+1)%sides] - poly_c[j])*k/poly_m];
sq_fn = max(2, ceil(min(corner_r, R0*min(1, aspect) - 0.5)*PI/2/(facet/2)));   // corners get short facets: patterns run round them
sq_pts = shell_runs_pts(shell_rect_runs(size0, "round", corner_r, sq_fn, s_wave > 0 ? max(2, ceil(2*R0/facet)) : 2));
base0 = s_shape == "polygon" ? poly_pts : s_shape == "rounded_square" ? sq_pts
      : s_shape == "squircle" ? shell_squircle_pts(size0, squareness, n_round) : shell_ellipse_pts(size0, n_round);
wavy = shell_wavy_pts(base0, s_wave, side_wave_count);
has_tower = reservoir != "below";
seam_dir = has_tower ? tank_dir : fill_dir;                      // the unrolled wall's ends meet here, behind a plain stripe
function _adiff(a, b) = let(d = ((a - b)%360 + 540)%360 - 180) abs(d);
seam_k = let(d = [for (p=wavy) _adiff(atan2(p[1], p[0]), seam_dir)], m = min(d)) [for (i=[0:len(d)-1]) if (d[i] == m) i][0];
pts = shell_start_at(wavy, seam_k);
L = shell_len(pts);
lean = shell_taper_lean(pts, sc, ht);                            // largest lean of the wall from vertical (degrees)
tin = t/cos(lean);                                               // wall thickness measured level
function k_at(z) = shell_taper_k(sc, ht, z);
function u_dir(a) = shell_dist_at_dir(pts, a);                  // distance along the foot to direction a
function r_dir(a, z=0) = norm(shell_pt_at(pts, u_dir(a)))*k_at(z);   // outer radius in direction a at height z
function dir_v(a) = [cos(a), sin(a)];
Rm = sum([for (p=pts) norm(p)])/len(pts);                         // mean foot radius

// ---------- heights ----------
z_w = ft + water_height;                                         // highest water level
z_f = z_w + air_gap;                                             // underside of the insert floor
fi = 3;                                                          // insert floor thickness
cb_coll = fi - 0.6;                                              // wick basket: 45 degree collar in the insert floor
ledge_w = insert_gap + 3;                                        // ledge the insert stands on
// rim
want_sensor = sensor != "none";
cable_dip = want_sensor ? [[sensor_dir, 6, 10]] : [];
dips = concat(rim_dip > 0 ? [[-90, rim_dip, rim_dip_w]] : [], cable_dip);
r_amp = s_rim == "straight" ? 0 : rim_amp;
rim_waves = [r_amp, rim_count, s_rim, 0];
rng0 = shell_rim_round_range(ht, [rim_tilt, rim_tilt_dir], rim_waves, concat(rim_dip > 0 ? [[-90, rim_dip, rim_dip_w]] : []));
z_ti_ask = rng0[0] - insert_drop;                                // insert top: below the lowest rim point
min_soil = 30;                                                   // insert at least this deep
dip_max = max(0, rng0[0] + (rim_dip > 0 ? shell_rim_dip_depth(rim_dip, rim_dip_w) : 0) - insert_drop - z_f - fi - min_soil);
dips_ok = concat(rim_dip > 0 ? [[-90, min(rim_dip, dip_max), rim_dip_w]] : [], cable_dip);
dip_note = rim_dip > 0 && rim_dip > dip_max + 0.01 ? str("front rim dip limited to ", dip_max, " mm: deeper would leave less than ", min_soil, " mm of soil above the reservoir") : "";
rim = function(p) shell_rim_round(p, ht, [rim_tilt, rim_tilt_dir], rim_waves, dips_ok);
rng = shell_rim_round_range(ht, [rim_tilt, rim_tilt_dir], rim_waves, dips_ok);
h_ref = rng[1] + 1;                                              // nothing is higher than this
rng_dec = shell_rim_round_range(ht, [rim_tilt, rim_tilt_dir], rim_waves, concat(rim_dip > 0 ? [[-90, min(rim_dip, dip_max), rim_dip_w]] : []));
z_ti = rng_dec[0] - insert_drop;                                 // insert top (the cable notch is not counted)
assert(z_ti - z_f - fi >= 15, str("the soil insert would be only ", z_ti - z_f - fi, " mm deep: make the pot taller (pot_height) or the reservoir lower (water_height, air_gap)"));
// band: the decorated upper part
b_amp = s_line == "straight" ? 0 : band_line_amp;
band_lo_min = s_mode == "through_cut" ? z_f + fi + 3 : ft + 2;   // through-cut only where the insert holds the soil
band_z_ask = ht*band_from/100;
band_z_max = rng[0] - rim_band - 8 - b_amp - abs(band_line_tilt);   // keep room for at least a little pattern
band_z = max(band_lo_min + b_amp + abs(band_line_tilt), min(band_z_ask, band_z_max));
band_note = abs(band_z - band_z_ask) > 0.01 ? str("band starts at ", band_z, " mm instead of ", band_z_ask,
    s_mode == "through_cut" && band_z_ask < band_lo_min + b_amp + abs(band_line_tilt) ? ": a through-cut band must stay above the reservoir" : ": it needs room under the rim") : "";
band_lf = function(p) shell_rim_round(p, band_z, [band_line_tilt, 90], [b_amp, band_line_count, s_line, 180/band_line_count], []);
has_band = s_mode != "solid" || s_edge != "none";

// ---------- pattern ----------
function opts_for(name) = name == "flowing_waves" ? [["amplitude", 3], ["wavelength", 30]] : name == "concentric_ripples" ? [["spokes", 6]] : [];
band_spec = pattern_sized(s_pat, 1, band_cell, band_strut, band_angle, seed, opts_for(s_pat), min_strut=0.8, min_opening=1);
band_mode_used = container_safe_mode(s_mode, band_spec);
F = shell_taper_frame(pts, sc, ht, 0, len(pts) - 1, h_ref);      // the unrolled wall (fan frame), as the wall uses it
function fan(a, z) = shell_taper_at(F, u_dir(a), z);
function fan_u(u, z) = shell_taper_at(F, u, z);

// ---------- fill shaft and float guide (below, side) ----------
has_shaft = reservoir != "below_side";
g_id = fill_d;                                                   // float guide: inner diameter
g_ro = g_id/2 + 1.6;                                             // guide tube: outer radius
sh_ri = g_ro + 0.3; sh_ro = sh_ri + 1.6;                         // the insert's shaft round it
r_in_dir = function(a, z) r_dir(a, z) - tin;                     // pot inner face
r_ins_in = function(a, z) r_in_dir(a, z) - insert_gap - insert_t/cos(lean);   // insert inner face
g_r = min(r_in_dir(fill_dir, ft) - g_ro - 1, r_in_dir(fill_dir, z_f + fi + 3) - g_ro - 1, r_ins_in(fill_dir, z_f + fi) - sh_ro - 0.6,
          r_ins_in(fill_dir, z_ti) - sh_ro - 0.6);          // the shaft is upright: it must fit at the insert's floor and top
g_xy = g_r*dir_v(fill_dir);                                      // guide axis
g_top = z_f + fi + 4;                                            // the guide reaches into the insert's shaft

// ---------- tower / tank (below_side, side) ----------
up_out = max(band_mode_used == "raised" || band_mode_used == "overlay" ? band_relief : 0, s_edge == "bead" ? band_edge_h : 0, s_lip > 0 ? lip_out : 0);   // what stands out of the pot wall
tk_ri = tank_d/2; tk_ro = tk_ri + max(t, up_out + 1.4);         // the tank's wall is thick enough to bridge reliefs on the pot
tk_d0 = r_dir(tank_dir, 0) + tk_ri + up_out + 0.6;               // tank axis from the pot axis, at the floor
tk_sl = r_dir(tank_dir, ht)/ht - r_dir(tank_dir, 0)/ht;          // it leans with the wall
tk_top = reservoir == "side" ? h_ref : rim(r_dir(tank_dir)*dir_v(tank_dir)) - 0.5;   // open tower: flush with the rim
tk_roof_k = 1/(1 - abs(tk_sl)) + 0.1;                            // roof cone steepness (45 degrees after the lean)
tk_neck = "M30";
tk_neck_ro = thread_d(tk_neck)/2;
tk_body_top = reservoir == "side" ? max(z_w + 20, rng[0] - (tk_ro - tk_neck_ro)*tk_roof_k - 2) : tk_top;
tk_neck_z = tk_body_top + (tk_ro - tk_neck_ro + 1)*tk_roof_k;    // foot of the threaded neck
tk_neck_l = 12;
win_w = min(tank_d*0.6, 30);                                     // feed opening between tank and reservoir
win_lo = ft + 0.6;
win_hi = reservoir == "side" ? z_w : z_w + 5;
tk_vol = reservoir == "side" ? PI*tk_ri*tk_ri*(tk_body_top - ft) : 0;
function tk_c(z) = (tk_d0 + tk_sl*z)*dir_v(tank_dir);

// ---------- float ----------
want_float = indicator == "float";
fl_ro = (has_shaft ? g_id : tank_d)/2 - 1;                       // float: outer radius
fl_w = 1.2;                                                      // float wall
fl_h = min(max(14, water_height*0.8), 40);                       // float: cylinder height
fl_cone = fl_ro - (rod_d/2 + 1.6);                               // 45 degree roof
fl_boss = 9;                                                     // socket for the rod on top
z_exit = has_shaft ? z_ti : tk_top;                              // the rod comes out here
rod_in = 8;                                                      // rod inserted into the float and the topper
show_min = 4;                                                    // topper above the guide when the reservoir is empty
fl_top0 = ft + fl_h + fl_cone + fl_boss;                         // float top when resting on the floor
rod_len = z_exit + show_min - fl_top0 + 2*rod_in + (topper == "none" ? 6 : 0);
rho = 1.27;                                                      // PETG, g/cm3
v_air = PI*pow(fl_ro - fl_w, 2)*fl_h + PI/3*fl_cone*(pow(fl_ro - fl_w, 2) + (fl_ro - fl_w)*(rod_d/2) + pow(rod_d/2, 2));
v_shell = PI*(pow(fl_ro, 2) - pow(fl_ro - fl_w, 2))*fl_h + PI*fl_ro*fl_ro*fl_w*1.4 + PI*pow(rod_d/2 + 1.6, 2)*fl_boss;
v_rod = rod == "printed" ? PI*pow(rod_d/2, 2)*rod_len : 0.6*PI*pow(rod_d/2, 2)*rod_len;   // bamboo ~0.75 g/cm3
tp_th = rod_d + 3.2;                                             // topper thickness (holds the rod's socket)
v_top = topper == "none" ? 0 : 0.45*(0.5*topper_size*topper_size*tp_th + 10*(rod_d + 4)*tp_th);   // printed with 15 % infill
mass = rho*(v_shell + v_top)/1000 + (rod == "printed" ? rho : 0.75)*v_rod/1000;   // g
lift = v_air/1000 - mass;                                        // g of spare lift with the bell full of air
draft = min(fl_h, mass*1000/(PI*fl_ro*fl_ro));                   // how deep it floats (mm, about)
float_z = want_float ? max(ft, z_w - draft) : ft;                // shown floating at the highest level
float_note = want_float && lift < 2 ? str("the float may not lift its rod and topper (", round(lift*10)/10, " g spare): use a smaller topper, a skewer, or a wider fill_d") : "";

// ---------- wick basket ----------
ask_cup = wick == "cup" || wick == "both";
// the basket sits in the middle, or moves away from the float guide, or gets smaller (WARNING) where both do not fit
cb_room = min(r_in_dir(fill_dir + 180, ft) - 1.5, r_ins_in(fill_dir + 180, z_f) - 1);   // from the axis to the wall opposite the guide
cb_side = min(r_in_dir(fill_dir + 90, ft), r_in_dir(fill_dir - 90, ft), r_ins_in(fill_dir + 90, z_f) + 0.5, r_ins_in(fill_dir - 90, z_f) + 0.5) - 1.5;   // sideways
cb_gap = has_shaft ? g_r - g_ro - 1.5 : 1e4;                     // from the axis to the guide
cb_r0 = min(wick_d/2, (min(cb_gap, cb_room) + cb_room)/2 - cb_coll - 0.5, cb_side - cb_coll - 0.5);
want_cup = ask_cup && cb_r0 >= 8;                                // a basket narrower than 16 mm is left out: rope wicks instead
want_rope = wick == "rope" || wick == "both" || (ask_cup && !want_cup);
cb_r = max(8, cb_r0);                                            // basket outer radius at the top (+ collar)
cb_off = has_shaft ? max(0, cb_r + cb_coll + 0.5 - cb_gap) : 0;  // shift away from the guide
cb_c = -cb_off*dir_v(fill_dir);                                  // basket axis
cb_note = ask_cup && !want_cup ? "wick basket left out: the fill shaft leaves no room for it; holes for rope wicks instead"
        : want_cup && cb_r < wick_d/2 - 0.01 ? str("wick basket made ", 2*cb_r, " mm wide instead of ", wick_d, ": the fill shaft leaves no more room") : "";
cb_h = z_f + fi - ft - 0.02;                                     // from the pot floor to just under the top of the insert floor

// ---------- insert ----------
ins_pts0 = shell_inset_pts(shell_taper_pts(pts, sc, ht, z_f), tin + insert_gap);   // insert outline at its floor
ins_h = z_ti - z_f;
ins_r = [for (p=pts) norm(p)];
ins_sc = min([for (r=[min(ins_r), max(ins_r)]) (r*k_at(z_ti) - tin - insert_gap)/(r*k_at(z_f) - tin - insert_gap)]);   // one scale for the insert: the tightest (it stays clear everywhere)
ins_rim = function(p) ins_h;
ins_in_area = function(z) shell_area(shell_inset_pts(shell_taper_pts(pts, sc, ht, z), tin + insert_gap + insert_t/cos(lean)));
dr_r = (cb_r + cb_off + 4 + min([for (p=ins_pts0) norm(p)]) - insert_t - 3)/2;   // drain holes: on this ring
drains = [for (j=[0:1:drain_holes-1]) let(a = fill_dir + 180/max(1, drain_holes) + 360*j/max(1, drain_holes), q = dr_r*dir_v(a))
    if ((!has_shaft || norm(q - g_xy) > sh_ro + 4) && (!want_cup || norm(q - cb_c) > cb_r + cb_coll + 4)) q];
ropes = want_rope ? [for (j=[0:1:rope_count-1]) cb_c + ((want_cup ? cb_r + cb_coll : 0) + rope_d + 4)*dir_v(fill_dir + 90 + 360*j/rope_count)] : [];

// ---------- extras ----------
want_drip = drip_d > 0;
hang = hanger == "cords";
hang_dirs = [for (j=[0:hanger_count-1]) 90 + 360*j/hanger_count + 180/hanger_count];
saucer_m = saucer_margin;
sc_floor = 2; sc_rib = 2;

// ---------- volumes (ml) ----------
pot_in_area = function(z) shell_area(shell_inset_pts(shell_taper_pts(pts, sc, ht, z), tin));
water_ml = ((pot_in_area(ft) + 4*pot_in_area((ft + z_w)/2) + pot_in_area(z_w))/6*water_height
          - (want_cup ? PI*cb_r*cb_r*water_height : 0) - (has_shaft ? PI*g_ro*g_ro*water_height : 0))/1000;
soil_ml = ((ins_in_area(z_f + fi) + 4*ins_in_area((z_f + fi + z_ti)/2) + ins_in_area(z_ti))/6*(z_ti - z_f - fi))/1000;

// ---------- plain zones of the decorated wall ----------
seam_w = has_tower ? 2*tk_ro + 6 : 6;
zones = concat([[seam_w/4, seam_w/2], [L - seam_w/4, seam_w/2]],
               hang ? [for (a=hang_dirs) [u_dir(a), 14]] : []);

// tables read by the tools
parts = [
  ["pot", "Pot", "PETG, 4+ perimeters", [0, 0, 0], COL_TERRACOTTA],
  ["insert", "Soil insert", "PETG / PLA", [0, 0, 120], COL_SAGE],
  ["wick", "Wick basket", "PETG / PLA", [0, 0, 60], COL_SAGE],
  ["float", "Float", "PETG, 0% infill", [0, 0, 170], COL_WATER, "group=buoy"],
  ["rod", "Rod", rod == "skewer" ? "bamboo skewer (reference)" : "PETG / PLA", [0, 0, 170], COL_WHITE, "group=buoy", "print=x90"],
  ["topper", "Topper", "PLA", [0, 0, 175], COL_PETAL, "group=buoy", "print=x270", "plate=topper"],
  ["face", "Topper face", "PLA black", [0, -6, 175], COL_INK, "group=buoy", "print=x270", "plate=topper", str("pieces=", face_pieces())],
  ["cap", "Tank cap", "PETG", [0, 0, 40], COL_WATER, "print=x180"],
  ["saucer", "Saucer", "PETG", [0, 0, -40], COL_TERRACOTTA]
];
checks = concat(
  [["insert", "pot", ">=", 0], ["insert", "pot", "<=", 0.05]],                       // the insert stands on the ledge
  want_cup ? [["wick", "pot", ">=", 0], ["wick", "insert", ">=", 0]] : [],
  want_float ? [["float", "pot", "clear"], ["rod", "insert", "clear"]] : [],
  want_float && topper != "none" ? [["topper", "insert", "clear"], ["topper", "pot", "clear"]] : [],
  reservoir == "side" ? [["cap", "pot", ">=", 0]] : [],
  saucer ? [["saucer", "pot", ">=", 0]] : []);
report = [["lean of the wall (deg)", lean], ["water (ml)", water_ml], ["tank (ml)", tk_vol/1000], ["soil (ml)", soil_ml],
          ["highest water level", z_w], ["insert floor", z_f], ["insert top", z_ti], ["band starts at", band_z],
          ["band as asked", band_note == "" ? 1 : 0], ["band pattern cut as asked", band_mode_used == s_mode || s_mode == "solid" ? 1 : 0],
          ["float lift (g)", want_float ? lift : 0], ["rod / skewer length", want_float ? rod_len : 0],
          ["topper rises (mm)", want_float ? water_height - draft : 0], ["rim dip as asked", dip_note == "" ? 1 : 0],
          ["wick basket width", want_cup ? 2*cb_r : 0], ["wick basket as asked", cb_note == "" ? 1 : 0]];

// ---------- 2D shapes ----------
module topper_2d(st, S) {
    r = S/2;
    if (st == "flower") { for (j=[0:5]) rotate(90 + 60*j) translate([r*0.55, 0]) circle(r*0.42); circle(r*0.5); }
    else if (st == "sun") { circle(r*0.62); for (j=[0:9]) rotate(90 + 36*j) polygon([[r*0.5, -r*0.16], [r, 0], [r*0.5, r*0.16]]); }
    else if (st == "star") offset(r=r*0.08) offset(delta=-r*0.08) polygon([for (j=[0:9]) let(a = 90 + 36*j, q = j%2 == 0 ? r : r*0.45) [q*cos(a), q*sin(a)]]);
    else if (st == "heart") translate([0, -r*0.15]) { for (x=[-1, 1]) translate([x*r*0.38, r*0.3]) circle(r*0.5); rotate(45) square(r*0.95, center=true); }
    else if (st == "drop") translate([0, -r*0.25]) hull() { circle(r*0.7); translate([0, r*1.05]) circle(r*0.06); }
    else if (st == "leaf") for (x=[-1, 1]) translate([x*r*0.45, 0]) rotate(-x*35) intersection() { translate([r*0.45, 0]) circle(r*0.62); translate([-r*0.45, 0]) circle(r*0.62); }
    else if (st == "mushroom") { translate([0, r*0.05]) intersection() { scale([1, 0.75]) circle(r); translate([-r, 0]) square([2*r, r]); }
                                 translate([0, -r*0.4]) square([r*0.7, r*0.95], center=true); }
    else if (st == "cloud") { translate([-r*0.45, -r*0.1]) circle(r*0.45); translate([r*0.4, -r*0.05]) circle(r*0.5); translate([0, r*0.25]) circle(r*0.55);
                              translate([-r*0.45, -r*0.55]) square([r*0.9, r*0.5]); }
}
// face position and size per topper: [centre, scale]
function face_at(st, S) = st == "drop" ? [[0, -S*0.18], S*0.75] : st == "mushroom" ? [[0, -S*0.25], S*0.5] : st == "heart" ? [[0, S*0.02], S*0.85]
    : st == "leaf" ? [[0, -S*0.2], S*0.5] : [[0, 0], S*(st == "cloud" ? 0.8 : 0.6)];
function face_pieces() = 3;                                      // two eyes and a smile
module face_2d(S) {
    for (x=[-1, 1]) translate([x*S*0.17, S*0.08]) circle(S*0.065);
    translate([0, -S*0.02]) intersection() { difference() { circle(S*0.22); circle(S*0.15); } translate([-S*0.25, -S*0.3]) square([S*0.5, S*0.3]); }
}

// ---------- solids: pot ----------
module pot_openings_2d() {
    if (overflow) let(zc = (reservoir == "side" ? z_w + 3 : z_w) + 3) translate(fan(overflow_dir, zc)) circle(d=6, $fn=24);
    if (has_tower) let(u = u_dir(tank_dir)) polygon([fan_u(u - win_w/2, win_lo), fan_u(u + win_w/2, win_lo),
        fan_u(u + win_w/2, win_hi - win_w/2), fan_u(u, win_hi), fan_u(u - win_w/2, win_hi - win_w/2)]);   // pointed arch: prints without support
}
module pot_wall() {
    container_wall_taper(pts, sc, ht, t, h_ref, rim, band_spec, band_mode_used, [0, band_gap, rim_band], band_relief, band_relief,
        lf=has_band ? band_lf : undef, zones=zones, line=[s_edge, band_edge_w, band_edge_h], lip=[s_lip, lip_out]) pot_openings_2d();
}
// a vertical cylinder sheared to lean with the pot wall (horizontal sections stay circles)
module tank_shear() { c0 = tk_c(0); d = tk_c(1) - c0; multmatrix([[1, 0, d[0], c0[0]], [0, 1, d[1], c0[1]], [0, 0, 1, 0], [0, 0, 0, 1]]) children(); }
module tank_body() {
    difference() {
        union() {
            tank_shear() cylinder(r=tk_ro, h=tk_body_top, $fn=64);
            linear_extrude(ft) hull() { translate(tk_c(0)) circle(r=tk_ro, $fn=64); translate(0.8*r_dir(tank_dir)*dir_v(tank_dir)) circle(r=tk_ro*0.7); }   // one floor with the pot
            // web filling the narrow crotch between tank and pot wall (it would trap slivers): from the tank's axis to an
            // arc of the wall, 0.6 t deep in it; it scales with the pot, the bore cuts what reaches into the tank
            let(r0 = r_dir(tank_dir), ph = asin(min(0.95, 0.8*tk_ro/r0)), m = 8)
                linear_extrude(tk_body_top, scale=k_at(tk_body_top)) polygon(concat([tk_d0*dir_v(tank_dir)],
                    [for (j=[0:m]) let(a = tank_dir - ph + 2*ph*j/m, q = shell_pt_at(pts, u_dir(a))) q*(1 - 0.6*t/norm(q))]));
            if (reservoir == "side") {
                tank_shear() translate([0, 0, tk_body_top - 0.01]) cylinder(r1=tk_ro, r2=tk_neck_ro - 1, h=(tk_ro - tk_neck_ro + 1)*tk_roof_k, $fn=64);
                translate(concat(tk_c(tk_neck_z), [tk_neck_z - 0.5])) thread_rod(tk_neck, tk_neck_l + 0.5);
            }
        }
        // bore (open tower: up through the top), feed opening into the pot
        tank_shear() translate([0, 0, ft]) cylinder(r=tk_ri, h=(reservoir == "side" ? tk_body_top - ft : tk_top + 2), $fn=64);
        if (reservoir == "side") {
            tank_shear() translate([0, 0, tk_body_top - 0.02]) cylinder(r1=tk_ri, r2=tk_neck_ro - 1 - t, h=(tk_ri - tk_neck_ro + 1 + t)*tk_roof_k, $fn=64);
            translate(concat(tk_c(tk_neck_z), [tk_neck_z - 6])) cylinder(r=tk_neck_ro - 1 - 1.6 - thread_depth(thread_pitch(tk_neck)), h=tk_neck_l + 10, $fn=48);
        }
        // feed opening through the tank's wall (the pot's wall gets its own, a little smaller, in pot_openings_2d)
        let(a = tank_dir, r0 = r_dir(a, win_lo) - 3*t, w = win_w/2 + 0.5) rotate(a) translate([r0, 0, 0]) rotate([90, 0, 90])
            linear_extrude(tk_d0 - r0) polygon([[-w, win_lo - 0.01], [w, win_lo - 0.01], [w, win_hi - w], [0, win_hi + 0.5], [-w, win_hi - w]]);
        if (reservoir == "below_side") translate([0, 0, tk_top]) cylinder(r=tk_d0 + tk_ro + abs(tk_sl)*h_ref + 20, h=h_ref + 50);   // flush with the rim
    }
    if (want_float && reservoir == "below_side") guide_ring(tk_c(tk_top - 2), tk_ri, tk_top - 2);
}
// spokes at the top of a guide: the rod runs in the centre, water is poured between them
module guide_ring(c, ri, z) {
    translate(concat(c, [z])) difference() {
        union() { for (j=[0:2]) rotate(90 + 120*j) translate([0, -1]) cube([ri + 0.5, 2, 2]); cylinder(r=rod_d/2 + 0.6 + 1.6, h=2); }
        translate([0, 0, -1]) cylinder(r=rod_d/2 + 0.6, h=4, $fn=24);
    }
}
module float_guide() {
    translate(concat(g_xy, [ft - 0.5])) difference() {
        cylinder(r=g_ro, h=g_top - ft + 0.5, $fn=48);
        translate([0, 0, -1]) cylinder(r=g_id/2, h=g_top - ft + 3, $fn=48);
        for (j=[0:2]) rotate(fill_dir + 60 + 120*j) translate([0, -2.5, 0.4]) cube([g_ro + 1, 5, 7]);   // water in and out
    }
}
module hanger_lug(a) {
    zt = rim(r_dir(a)*dir_v(a)) - 1.5; ro = 7; w = 12; h = 5;
    r_t = r_dir(a, zt); r_b = r_dir(a, zt - h - ro);
    rotate(a) difference() {
        hull() {
            translate([r_t - 0.8*t, -w/2, zt - h]) cube([ro + 0.8*t, w, h]);
            translate([r_b - 0.8*t, -w/2, zt - h - ro]) cube([0.8*t + 0.01, w, 0.01]);
        }
        translate([r_t + ro/2 + 0.3, 0, zt - h - ro - 1]) cylinder(d=4, h=h + ro + 2, $fn=24);
    }
}
module pot() {
    linear_extrude(ft) offset(delta=-0.05) polygon(pts);
    pot_wall();
    container_ledge(shell_taper_pts(pts, sc, ht, z_f), tin, z_f - 0.01, ledge_w, 6);
    if (has_shaft) float_guide();
    if (has_tower) tank_body();
    if (hang) for (a=hang_dirs) hanger_lug(a);
}

// ---------- solids: insert ----------
module tab(a, w, tab_l) {                                 // a holder reaching tab_l in from the insert's rim
    r_t = r_ins_in(a, z_ti); r_b = r_ins_in(a, z_ti - 4 - tab_l);
    z0 = z_ti - 4 - tab_l - 1;
    in_pts = function(z) shell_inset_pts(shell_taper_pts(pts, sc, ht, z), tin + insert_gap + insert_t/cos(lean)*0.4);   // to the middle of the insert wall
    intersection() {
        translate([0, 0, z0]) linear_extrude(z_ti - z0) intersection() { polygon(in_pts(z0)); polygon(in_pts(z_ti)); }
        rotate(a) difference() {
        hull() {
            translate([r_t - tab_l, -w/2, z_ti - 4]) cube([tab_l + 0.6, w, 4]);
            translate([r_b - 0.01, -w/2, z_ti - 4 - tab_l]) cube([0.61, w, 0.01]);
        }
        translate([r_t - tab_l/2 - 0.3, 0, z_ti - 30]) children();
        }
    }
}
module insert() {
    translate([0, 0, z_f]) {
        container_wall_taper(ins_pts0, ins_sc, ins_h, insert_t, ins_h + 1, ins_rim, "square_grid", "solid");
        difference() {
            linear_extrude(fi) offset(delta=-0.05) polygon(ins_pts0);
            if (want_cup) translate(concat(cb_c, [-0.01])) { cylinder(r=cb_r + 0.3, h=fi + 0.02, $fn=64); translate([0, 0, 0.6]) cylinder(r1=cb_r + 0.3, r2=cb_r + 0.3 + cb_coll + 0.02, h=cb_coll + 0.03, $fn=64); }
            if (has_shaft) translate(concat(g_xy, [-1])) cylinder(r=sh_ri, h=fi + 2, $fn=48);
            for (q=drains) translate(concat(q, [-1])) cylinder(d=4, h=fi + 2, $fn=16);
            for (q=ropes) translate(concat(q, [-1])) cylinder(d=rope_d + 1, h=fi + 2, $fn=24);
        }
    }
    if (has_shaft) {
        translate(concat(g_xy, [z_f + fi - 0.01])) difference() {
            cylinder(r=sh_ro, h=z_ti - z_f - fi + 0.01, $fn=48);
            translate([0, 0, -1]) cylinder(r=sh_ri, h=z_ti - z_f + 2, $fn=48);
        }
        // fin from the shaft to the wall
        rotate(fill_dir) let(r0 = g_r + sh_ro - 0.5, h0 = z_f + fi - 0.01) rotate([90, 0, 0]) translate([0, 0, -0.8])
            linear_extrude(1.6) polygon([[r0, h0], [r_ins_in(fill_dir, h0) + 0.5, h0], [r_ins_in(fill_dir, z_ti) + 0.5, z_ti], [r0, z_ti]]);
        if (want_float) guide_ring(g_xy, sh_ri, z_ti - 2);
    }
    if (want_sensor) tab(sensor_dir, sensor_w + 7, sensor_t + 7) translate([-sensor_t/2 - 0.25, -sensor_w/2 - 0.3, 0]) cube([sensor_t + 0.5, sensor_w + 0.6, 40]);
    if (want_drip) tab(drip_dir, drip_d + 7, drip_d + 6) cylinder(d=drip_d + 0.4, h=40, $fn=32);
}

// ---------- solids: wick basket, float, rod, topper, cap, saucer ----------
module wick_basket() {
    translate(concat(cb_c, [ft])) difference() {
        union() {
            cylinder(r1=cb_r - 1, r2=cb_r, h=cb_h - cb_coll, $fn=64);
            translate([0, 0, cb_h - cb_coll - 0.01]) cylinder(r1=cb_r, r2=cb_r + cb_coll, h=cb_coll + 0.01, $fn=64);
        }
        translate([0, 0, 1.6]) cylinder(r1=cb_r - 2.6, r2=cb_r - 1.6, h=cb_h, $fn=64);
        n = max(6, floor(2*PI*cb_r/9));
        for (j=[0:n-1]) rotate(360*j/n) translate([0, -0.8, 3]) cube([cb_r + 2, 1.6, cb_h - cb_coll - 7]);
        for (j=[-2:2]) translate([j*6 - 0.8, -cb_r*0.5, -1]) cube([1.6, cb_r, 3]);
    }
}
module float_body() {
    buoy_frame(float_z) difference() {
        union() {
            cylinder(r=fl_ro, h=fl_h, $fn=48);
            translate([0, 0, fl_h - 0.01]) cylinder(r1=fl_ro, r2=rod_d/2 + 1.6, h=fl_cone, $fn=48);
            translate([0, 0, fl_h + fl_cone - 0.02]) cylinder(r=rod_d/2 + 1.6, h=fl_boss, $fn=32);
        }
        translate([0, 0, -0.01]) cylinder(r=fl_ro - fl_w, h=fl_h, $fn=48);
        translate([0, 0, fl_h - 0.02]) cylinder(r1=fl_ro - fl_w, r2=0.01, h=fl_ro - fl_w, $fn=48);
        translate([0, 0, fl_h + fl_cone + fl_boss - rod_in]) cylinder(d=rod_d + 0.25, h=rod_in + 1, $fn=24);
    }
}
fl_lean = has_shaft ? [0, 0] : tk_c(1) - tk_c(0);              // in the leaning tower the float, rod and topper lean with it
function buoy_at(z) = concat(has_shaft ? g_xy : tk_c(z), [z]);  // the point of the float's axis at height z
// place children (built round a vertical axis from z = 0) on the float's axis from height z, leaning with it
module buoy_frame(z) { translate(buoy_at(z)) multmatrix([[1, 0, fl_lean[0], 0], [0, 1, fl_lean[1], 0], [0, 0, 1, 0], [0, 0, 0, 1]]) children(); }
rod_z0 = float_z + fl_h + fl_cone + fl_boss - rod_in;           // rod foot
module rod_part() { buoy_frame(rod_z0) cylinder(d=rod_d, h=rod_len, $fn=24); }
tp_z = rod_z0 + rod_len - rod_in;                               // topper foot
module topper_solid() {
    S = topper_size; stem = 10;
    buoy_frame(tp_z) difference() {
        rotate([90, 0, 0]) linear_extrude(tp_th, center=true) offset(r=0.6) offset(delta=-0.6) {
            translate([0, stem + S/2]) topper_2d(topper, S);
            translate([-(rod_d + 4)/2, 0]) square([rod_d + 4, stem + S*0.3]);
        }
        translate([0, 0, -1]) cylinder(d=rod_d + 0.25, h=rod_in + 1, $fn=24);
    }
}
module face_part() {
    S = topper_size; stem = 10; f = face_at(topper, S);
    buoy_frame(tp_z) rotate([90, 0, 0]) translate([0, 0, tp_th/2]) linear_extrude(0.6) translate(f[0] + [0, stem + S/2]) face_2d(f[1]);
}
cap_z = tk_neck_z - 0.5 + thread_pitch(tk_neck)*ceil(1.5/thread_pitch(tk_neck));   // the cap's thread in phase with the neck's
module tank_cap() {
    ch = tk_neck_l + 3; cr = tk_neck_ro + 3;
    translate(concat(tk_c(tk_neck_z), [cap_z])) difference() {
        thread_knob(2*cr, ch, "wave");
        translate([0, 0, -0.01]) thread_cutter(tk_neck, tk_neck_l);
    }
}
module saucer_2d() { offset(r=saucer_m) hull() { polygon(pts); if (has_tower) translate(tk_c(0)) circle(r=tk_ro, $fn=64); } }
module saucer_part() {
    translate([0, 0, -sc_floor - sc_rib]) {
        difference() {
            union() {
                linear_extrude(saucer_h - 1) offset(r=2) saucer_2d();
                translate([0, 0, saucer_h - 1.01]) linear_extrude(1.01, scale=1) offset(r=1) saucer_2d();   // chamfered top edge
            }
            translate([0, 0, sc_floor]) linear_extrude(saucer_h) saucer_2d();
        }
        for (j=[0:2]) rotate(90 + 120*j) translate([max(4, Rm*0.25), -1, sc_floor - 0.01]) cube([Rm*0.55, 2, sc_rib + 0.01]);
    }
}

// ---------- assembly ----------
module warn(note) { if (note != "") echo(str("WARNING: ", note)); }
warn(band_note);
warn(dip_note);
warn(float_note);
warn(cb_note);
if (band_mode_used != s_mode && s_mode != "solid") echo(str("WARNING: ", s_pat, " falls apart when cut through: raised instead"));
pick("pot") pot();
pick("insert") insert();
if (want_cup) pick("wick") wick_basket();
if (want_float) {
    pick("float") float_body();
    pick("rod") rod_part();
    if (topper != "none") pick("topper") topper_solid();
    if (topper != "none" && topper_face) pick("face") face_part();
}
if (reservoir == "side") pick("cap") tank_cap();
if (saucer) pick("saucer") saucer_part();
