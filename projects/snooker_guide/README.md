# Snooker Setup Guide

A wall plaque for next to the snooker table: the table in relief with every ball on its spot and its points,
so beginners can see the setup at a glance. Each colour is its own part, in one multi-colour 3MF.
Open `snooker_guide_configurator.html` to change the settings and download the parts.

The layout follows the official (WPBSA) table: playing area 3569 × 1778 mm, baulk line 737 mm from the baulk
cushion, D radius 292 mm, yellow / brown / green on the baulk line (yellow on the right seen from the baulk end),
blue on the centre spot, pink midway between centre spot and top cushion, black 324 mm from the top cushion,
15 reds packed behind the pink. Balls are drawn 1.6× true size by default so they read from a distance.

| Group | Settings |
|---|---|
| Size | `table_len` (playing-area length on the print, default 200 mm), `ball_scale`, `baulk_side` (left / right) |
| Points | `show_points`, `points_size`, `points_color` (white, black, gold, ball colour), `points_pos` (right, left, above, below), `points_style` (raised / inlay), `points_reds`, `points_cue`, `show_legend` (row of all balls with points), `title` |
| Balls | `show_cue`, `ball_style` (dome, hemisphere, flat), `ball_h` |
| Table depth | `table_base_t`, `rail_h`, `cushion_h`, `cloth_t`, rail and cushion widths, `table_edge` (top profile), `table_bottom` (underside finish: flat, roundover, chamfer, cove, ogee), pockets and rims, line width |
| Surround plate | `show_plate`, `plate_shape` (rect, rounded, chamfered, notched, arched, wave, scalloped), thickness, margin, edge profile, groove |
| Attachment | `attach_type` (none, wall, keyhole, skadis, hook, magnet, stand, flat, roof), size, count, roof gap and angle, stand angle |

Notes
- Default size is 242 × 174 × 11.4 mm, which fits a 250 mm bed. Without the plate the table alone is 222 × 123 mm;
  the legend and title need the plate.
- Colours: plate, rails, cloth, cushions, pockets, rims, markings, 8 ball colours, numbers, title (up to 17 bodies).
  Without a multi-colour printer, print the parts separately (each is in `snooker_guide_parts/`) and glue them in,
  or print in one colour and paint.
- The pink's number moves above the ball when it would otherwise land on the reds.

Files: `snooker_guide.scad`, `snooker_guide_print/` (guide.3mf + attachment plate), `snooker_guide_parts/`,
`snooker_guide_configurator.html`, `snooker_guide_<rev>.zip` (bundle with lib).

Rebuild and check with `python3 tools/build.py snooker_guide --test` (variants in `tests.txt`).
