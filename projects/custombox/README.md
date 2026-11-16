# Custom box

One model for any container: square and modern, round and flowing, or anything between. Outline, corners, rim,
walls, floor and lid are all settings, and every surface takes any of the 12 patterns from
[`lib/patterns.scad`](../../lib/README.md#patterns). Open `custombox_configurator.html` to design a box and download it.

| Group | Settings | What you get |
|---|---|---|
| Size | `width`, `depth`, `height` | outer size; `height` is the rim at the front left |
| Outline | `shape` (box / ellipse / squircle), `corners` (round / chamfer / square), `corner_r`, `squareness`, `side_wave`, `side_wave_count` | the footprint; `side_wave` swings the walls in and out for a flowing outline |
| Rim | `rise_back`, `rise_right`, `rim_wave_x/_count`, `rim_wave_y/_count`, `rim_wave_phase` | a sloped rim (different heights front / back / left / right) and waves along it |
| Walls | `wall_t`, `wall_pattern`, `wall_mode`, `wall_cell`, `wall_strut`, `wall_angle`, `wall_seed`, `wall_relief`, `rim_band`, `base_band`, `corner_fill`, `post_w`, `fit_cells`, `front_pattern/_mode`, `back_pattern/_mode` | pattern and how it is applied: solid, through-cut, open lattice, raised, recessed, overlay |
| Floor | `floor_t`, `floor_pattern`, `floor_mode`, `floor_cell`, `floor_strut`, `floor_angle`, `floor_relief`, `floor_margin` | thickness (strength) and its own pattern |
| Lid | `lid` (none / inset), `lid_t`, `lid_pattern`, `lid_mode`, `lid_grip` (hole / knob / none), `lid_drop`, `lid_clearance` | a lid that drops onto a ledge inside the box |
| Mounting | `attach_type`, `attach_size`, `attach_count` | snap-in plates (wall screws, keyhole, Skådis, hook, magnet, glue, ceiling) in a solid zone built into the back wall |
| Pattern details | strand style, Voronoi rounding, honeycomb orientation, wave size, ripple spokes, `min_strut`, `min_opening`, `facet` | fine tuning and printability limits |

## Recipes

| Look | Settings |
|---|---|
| Honeycomb basket (default) | – |
| Sloped bin | `rise_back = 35; wall_pattern = "triangular_lattice"` |
| Wavy rim | `rim_wave_x = 10; rim_wave_x_count = 1.5; height = 45` |
| Flowing organic bowl | `shape = "ellipse"; side_wave = 2.5; side_wave_count = 10; wall_pattern = "voronoi"; rim_wave_x = 6; rim_wave_y = 6; rim_wave_x_count = 2; rim_wave_y_count = 2` |
| Square modern box with lid | `corners = "square"; corner_fill = "solid"; wall_pattern = "square_grid"; front_pattern = "girih_star_cross"; lid = "inset"; lid_grip = "knob"` |
| Woven basket | `corner_fill = "solid"; wall_pattern = "basket_weave"; wall_mode = "open_lattice"; corner_r = 10` |
| Round can with a lining | `width = 80; depth = 80; corner_r = 40; wall_mode = "overlay"; wall_pattern = "girih_star_cross"` |
| Pegboard bin | `attach_type = "skadis"; corner_fill = "solid"; back_pattern = "hex_honeycomb"` |

## How it works

- **Corners.** With `corner_fill = "pattern"` one pattern runs all the way round, through the corners; `fit_cells`
  nudges the cell size so a whole number of cells fits and there is no seam (the report shows the cell used).
  With `"solid"` the corners are plain and every wall is its own panel with the pattern centred on it; the front
  and back can then have their own pattern and mode.
- **Rim.** The top edge follows a height field over the floor plan: `height` at the front left, plus `rise_right`
  and `rise_back` across the box, plus cosine waves across the width and the depth. The plain `rim_band` follows
  it with a constant height, and the pattern is clipped under it.
- **Patterns that would fall apart** when cut through (Truchet arcs, ripples without spokes) are raised instead;
  the report line "wall pattern cut as asked" shows 0 when that happened.
- **Lid.** Only for a flat rim (no slope, no waves). It rests on a ledge that grows out of the wall at 45°, so the
  box still prints without supports. The report says whether the lid was fitted.
- **Mounting.** The back wall itself gets a solid zone for the sockets: the pattern stops at it and joins its
  sides, and the wall is thickened to 6 mm only there (no separate plate behind the wall). It runs into the rim or
  base band when they are close and has a 45° underside when it starts above the floor. It needs the box shape, a
  straight back (`side_wave = 0`) and a back wall as high as the plate.
- **Line patterns** (flowing waves, ripples) get ties between their lines when they are cut through, so they
  print and stay stiff.

## Printing

- Print the box upright as modelled, the lid flat. No supports: lattice openings in the walls are bridged or
  self-supporting (honeycomb with corners up, diamonds and triangles are the easiest; wide square cells bridge).
- A wavy or sloped rim prints fine; the rim band keeps the top edge closed.
- Weaves on the walls are real over-under strands. Use `corner_fill = "solid"` with them: wrapped round the
  corners they work, but take several minutes to build in desktop OpenSCAD 2021.
- Curved outlines (ellipse, squircle, `side_wave`) are built from flat facets `facet` mm long.

Files: `custombox.scad` (model), `custombox_print/` (print files), `custombox_configurator.html`,
`tests.txt` (checked variants), `custombox_log.md`.
