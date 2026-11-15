# Sliding-pin scoreboard (parametric)

Open `scoreboard.scad` in OpenSCAD (keep `fits.scad` and `LiberationSerif-Regular.ttf` beside it).
Set `part = "board_l"` (or any id below) and press F6 → Export STL to export a single part.

## Files
- `scoreboard.scad`: the model (needs `fits.scad` and `LiberationSerif-Regular.ttf` beside it)
- `scoreboard_print/`: print-ready STL/3MF files, oriented for printing
- `scoreboard_parts/`: each part as an STL in its assembled position
- `scoreboard_7113f59.zip`: complete bundle (model, print files, viewer), revision 7113f59
- `scoreboard.html`: interactive 3D viewer

## Main parameters
| Parameter | Default | Meaning |
|---|---|---|
| `players` | 2 | number of tracks; two tracks share one number plate (odd count = last plate has one track) |
| `base_min`, `base_max` | 0, 19 | main score range |
| `steps` | [20,40,60,80,100] | second-dimension steps |
| `zero_step` | true | "0" home position before the steps |
| `pitch`, `step_pitch` | 11, 14 | spacing of the numbers (mm), which sets the board length |
| `split_board` | true | cut the board at the divider into two halves joined by dowels |
| `demo_scores` | [[7,2],[15,4]] | where the sliders sit in the preview only |

## Parts (ids)
`board_l`, `board_r`, `plate_u`/`text_u`, `plate_s`/`text_s` (number plate + black inlay, 2-colour 3MF),
`rail_u`, `rail_s` (one of each per player), `slider` (2 per player: one for points, one for steps),
`stop_end` (2 per player), `stop_div` (1 per player), `dowel`.

## Assembly
1. Glue the board halves together with the dowels. Press or glue the number plates into their pockets.
2. Lay a main rail and a step rail on each track. They meet at the divider.
3. Press one `stop_end` peg through each outer rail end into the board.
4. Slide one slider onto each rail from the joint end, with the pointer facing the number plate.
5. Press the `stop_div` divider in across the joint. It locks both rails and separates the two sliders.
The peg shafts are an H7/p6 press fit; add a drop of glue if your printer prints holes oversize.
Hang the board from the two keyhole slots on the back.
