# Self-watering planter

<table><tr><td align="center"><img src="images/planter.png" width="250" alt="default: raised honeycomb band above a wavy bead line, flower float"><br><sub>default: raised honeycomb band above a wavy bead, flower float</sub></td><td align="center"><img src="images/planter_terracotta.png" width="250" alt="terracotta preset: rolled lip, fluted band"><br><sub>terracotta: rolled lip</sub></td><td align="center"><img src="images/planter_honeycomb.png" width="250" alt="honeycomb preset: cut-through band"><br><sub>honeycomb: band cut through</sub></td><td align="center"><img src="images/planter_crown.png" width="250" alt="crown preset: hexagonal pot, petal rim"><br><sub>crown: hexagon, petal rim and line</sub></td></tr><tr><td align="center"><img src="images/planter_blossom.png" width="250" alt="blossom preset: wavy outline, Voronoi"><br><sub>blossom: wavy outline, Voronoi</sub></td><td align="center"><img src="images/planter_side_tank.png" width="250" alt="sealed side tank with screw cap, saucer"><br><sub>sealed side tank, saucer</sub></td><td align="center"><img src="images/planter_tower.png" width="250" alt="fill tower on the side, scallop preset, mushroom float"><br><sub>fill tower, scallops, mushroom float</sub></td><td align="center"><img src="images/planter_inside.png" width="250" alt="the soil insert with fill shaft, sensor holder and drip line clip"><br><sub>insert: fill shaft, sensor holder, drip clip</sub></td></tr></table>

**[Open the online configurator](https://tamaygz.github.io/tg_3d_modelling/planter)** · or open `planter_configurator.html` from this folder · [model](planter.scad) · [print files](planter_print) · [design log](planter_log.md)

A self-watering pot in the usual two-part form: a water-tight outer pot with a reservoir in its lower part, and a
soil insert standing on a ledge above it. A perforated wick basket, filled with soil, reaches down into the water
and keeps the soil moist; an air gap between the water and the soil keeps the roots out of standing water, and an
overflow hole stops the water rising above it. A float in the fill shaft lifts a rod with a cute topper: when the
topper sits low, it is time to water. The visible upper part of the wall carries a decorated band (any of the 15
library patterns) above a styled line, and the rim can be wavy, scalloped, slanted or rolled.

## How it works

| Reservoir | What it is |
|---|---|
| `below` (default) | stacked pots: the reservoir is under the insert; pour into the fill shaft (it is also the float's guide) |
| `below_side` | the same reservoir, filled through an open tower on the outside of the pot, which also holds the float |
| `side` | a sealed tank on the side, closed with a screw cap: it lets water out at the bottom until the reservoir covers its feed opening, then holds the rest (bird-bath principle). Much more water; the float in the insert's shaft shows when the tank has run dry |

Heights from the floor up: the reservoir to `water_height` (overflow hole / feed opening), then `air_gap`, then the
insert's floor; the wick basket (or rope wicks) bridges the gap. The report shows the water and soil volume in ml,
how far the topper rises and how much spare lift the float has.

## Settings

| Group | Settings | What you get |
|---|---|---|
| Size | `r_bottom`, `r_top`, `pot_height`, `shape` (round / polygon / rounded_square / squircle), `sides`, `corner_r`, `squareness`, `aspect`, `side_wave`, `side_wave_count` | a cone (or pyramid) from the foot radius to the rim radius; `r_top` smaller than `r_bottom` gives an urn; `aspect` makes it oval; `side_wave` flutes the outline |
| Style | `style_preset` (terracotta, honeycomb, scallop, fluted, crown, blossom), `band_from` (% of the height, 66 = upper third), `band_pattern`, `band_mode`, `band_cell`, `band_strut`, `band_angle`, `band_relief`, `seed` | the decorated band: raised, recessed, overlay, or cut through (only above the reservoir) |
| Band line | `band_line` (straight / wave / zigzag / scallop / petal), `band_line_amp`, `band_line_count`, `band_line_tilt`, `band_edge` (none / bead / groove), `band_edge_w`, `band_edge_h`, `band_gap` | where the band starts and how that line looks |
| Rim | `rim_line`, `rim_amp`, `rim_count`, `rim_tilt`, `rim_tilt_dir`, `rim_dip`, `rim_dip_w`, `rim_band`, `lip_h`, `lip_out` | wavy, scalloped, crowned, slanted or dipped rim; a rolled lip like a terracotta pot |
| Water | `reservoir`, `water_height`, `air_gap`, `overflow`, `overflow_dir`, `fill_d`, `fill_dir`, `tank_d`, `tank_dir` | reservoir type and size, overflow, the fill shaft / tower / tank |
| Insert | `insert_gap`, `insert_t`, `insert_drop`, `wick` (cup / rope / both), `wick_d`, `rope_count`, `rope_d`, `drain_holes` | the soil insert and how the soil drinks |
| Level indicator | `indicator`, `topper` (flower, sun, star, heart, drop, leaf, mushroom, cloud, none), `topper_size`, `topper_face`, `rod` (printed / skewer), `rod_d` | the float, its rod and the topper with an optional face in a second colour |
| Extras | `sensor` (capacitive), `sensor_w`, `sensor_t`, `sensor_dir`, `drip_d`, `drip_dir`, `hanger`, `hanger_count`, `saucer`, `saucer_margin`, `saucer_h` | soil moisture sensor holder with a cable notch in the rim, drip irrigation line clip, lugs for hanging cords, a saucer |
| Print | `wall_t`, `floor_t`, `facet` | wall and floor thickness, smoothness |

Settings that do not fit are reduced or left out with a `WARNING` (a band that would cut into the reservoir, a
rim dip that would leave too little soil, a wick basket with no room next to the fill shaft, a float that cannot
lift its topper).

## Printing

- **Pot (water-tight):** PETG, at least 4 perimeters (`wall_t` 2.4 mm = 5 to 6 lines of 0.45 mm), 5 or more
  bottom layers, normal mode, not vase mode (the layer seam leaks), PETG at the upper end of its temperature
  range. Fill it with water once before use; if it weeps, a coat of clear sealant inside fixes it. Overhangs stay
  under 45 degrees: the ledge for the insert is stepped, the tower window is a pointed arch.
- **Insert, wick basket, saucer:** PETG or PLA, as they come in `planter_print/`.
- **Float:** opening down on the bed, 1 to 2 perimeters, 0 % infill: it floats on the air it traps. Rod lying flat
  (or a bamboo skewer cut to the length in the report). **Topper** lying flat with 15 % infill, its face in a
  second colour on the same plate (`plate=topper`); push the rod into the float and the topper (glue if loose).
- **Tank cap (side tank):** the tank must be air-tight for the bird-bath principle: put a silicone washer or
  PTFE tape on the neck.
- Assembly: put the float into its guide (shaft in the pot, or the tower), lower the insert onto its ledge so the
  rod comes up through the guide ring, push on the topper; drop the wick basket into the insert's floor, fill it
  and the insert with soil.

Soil moisture sensor: the holder takes a capacitive v1.2 board (about 98 x 23 mm, 1.6 mm PCB; measure yours,
the boards vary) by its top edge, with the electronics above the soil; the cable leaves through the notch in the rim.

Files: `planter.scad` (model), `planter_print/` (print files), `planter_configurator.html`, `tests.txt` (checked
variants), `shots.txt` + `images/` (README pictures: `python3 tools/make_screenshots.py planter`), `planter_log.md`.
