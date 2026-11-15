# 3DModelling – working notes for Claude

Home for all 3D-modelling tasks (repo `tamaygz/tg_3d_modelling`, cloud environment "3DModelling").
Read `README.md` (structure, tools, adding a project) and `lib/README.md` (library reference and conventions) first.

## Rules
- **One command:** after any change to a model or the library run `python3 tools/build.py <project> --test`
  (`all` after a lib change). It rebuilds parts, print files, bundle (with lib files) and configurator, removes
  old bundles, and checks every variant in `tests.txt`. Don't run those steps by hand.
- **Commit everything build.py writes** (parts, print files, zip, viewer, configurator): the user wants them in
  the repo. **Commit and push after each finished step**, not only at the end.
- **Library first.** Projects lay out library parts; they don't copy code. New reusable things go into `lib/`
  with a header (use line, frame convention), an option list for styles, and an entry in `lib/README.md`.
  Layers: `core.scad` → element files → data (`emblems/`, `fonts/`) → projects.
- **Project pattern** (see `projects/_template/`): `include <../../lib/core.scad>`, `part`, Customizer sections
  (`/* [Section] */`, `// description` above each `name = value;`, trailing `// [a, b, c]` or `// [min:step:max]`),
  `/* [Hidden] */`, derived values, `parts` / `checks` / `report` tables, then 2D shapes, solids, assembly through
  `pick()`. Colours from the `COL_*` palette. Offer style choices as string options, plus a `style_preset`
  where there are many (scoreboard's PRESETS).
- **Mounting:** hanging or standing projects use the attachment host helpers (`attach_xs`, `attach_y`,
  `attach_fits` assert, `attach_sockets`, `attach_plates`, `attach_parts_row`) and expose `attach_type`,
  `attach_size`, `attach_count`. Plates snap in (the user wants snap fits, not slides or keys).
- **Lighting and wiring:** `lib/led.scad` and `lib/cable.scad`, not one-off parts.
- **Snap fits** must bend the flexing part by 2% or less; prove it with a probe (see `projects/led_kit`, `probe`).
- **Logos / artwork:** exact reproduction = `tools/svg_to_scad.py` into `lib/emblems/` (never `import()` an SVG:
  the browser engine scales it differently). Verify with `tools/artfit.py overlay`. The user wants a 100% match
  when recreating a given logo. To make generic elements match artwork, fit their parameters against the exact
  polygons (template: `projects/bolavuit_logo/fitting/`).
- **Fonts:** only redistributable fonts in `lib/fonts/` (see its README); register them in `lib/fonts.scad` and
  re-run `tools/font_metrics.py`. Text that must fit a space uses `text_len()` / `arc_text_2d(max_len=...)`, never
  guessed letter widths.
- **Layout tests:** when something must stay on a plate or inside a frame, add `| inside CONTAINER: parts` lines
  to `tests.txt`, including the variants with each optional band switched off.
- **Verify before claiming:** numbers first (checks, clash, sections), one look at a render only when needed.
  After a refactor, compare part volumes and triangle counts with the committed STLs: asm.py's "shape changed"
  also fires on mere triangle reordering.

## OpenSCAD gotchas learned here
- The skill's WebAssembly engine finds no fonts: text models build with `OSCAD_ENGINE=native` (build.py does this).
  Native OpenSCAD here is 2021.01: no list slicing, no string `+` (use `str()`), no `roof()`.
- Ranges `[a:b]` with a > b run BACKWARDS: write `[a:1:b]` for counts that can reach 0 or 1. Test empty lists.
- A second assignment to a variable wins over the first, whatever the order: to try a parameter, rewrite its line
  (build.py's tests do) or pass `-D`.
- Modules in a `use`d file cannot see the project's variables: that is why `core.scad` is `include`d.
- Text: OpenSCAD's em is 1.3563 × `size` for every font; use the metrics functions. Pillow's text bbox is not the ink box.
- `pieces=` in the parts table must count every separate solid (text = one per glyph); compute it in the .scad.
  Free artwork whose count varies: add `| ignore PIECES` to that line in `tests.txt`.
- `fits.scad`: `fit_mid("H7", d)` holes, `fit_mid("p6"|"k6"|"g6", d)` shafts; no `m6`.
- Guard long-running Python scripts with `__main__` (an import once re-ran a 30-minute fit).

## Browser configurator
- Built by build.py (or `tools/make_configurator.py`): the page embeds the model and its lib files and runs the
  real OpenSCAD in the browser, so it must be rebuilt after every change. Page template:
  `tools/configurator_template.html`.
- It reads parameters from the Customizer block and the evaluated `parts` table (generated tables work).

## User preferences
- Parametric models, every user-facing setting at the top; separate printable parts instead of one fused model.
- Gives reference images and expects the model to follow them closely.
- ~250 mm printer bed: split long parts at a natural joint and join with dowels.
- Default colours: wood-brown board, gold rails and sliders, silver stoppers, black inlays.
- Wants generalised, reusable library parts and consistent patterns across projects.

## Design conventions that worked
- Sliders on rails: T-rail + C-slider gripping under the flange, 0.25 mm clearance per side, printed top-down.
- Stopper pegs through a clearance hole in the rail, pressed into the board (H7/p6).
- Attachment plates: push-in snap arms at both ends, solid corners carry the load, pry notch below.
- Multi-colour reliefs: one part per colour, all tagged with the same `plate=` so they export as one 3MF.

## Projects
| Project | Status | Notes |
|---|---|---|
| `projects/scoreboard` | v3.2, not printed yet | sliding-pin scoreboard; styles, presets, attachment plates |
| `projects/snooker_guide` | v1, not printed yet | multi-colour relief plaque of the snooker setup with points |
| `projects/bolavuit_logo` | v2, not printed yet | logo plaque: exact (from SVG) or rebuilt from lib/emblem (0.90 overlap) |
| `projects/led_kit` | v1, not printed yet | LED tracks, diffusers, corners, cable parts |
| `projects/attachments` | v3, not printed yet | test coupon + every attachment plate; print first to check the snap fit |
| `projects/_template` | – | starting point for new projects |
