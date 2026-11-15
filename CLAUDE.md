# 3DModelling – working notes for Claude

Home for all 3D-modelling tasks (repo `tamaygz/tg_3d_modelling`, cloud environment "3DModelling"). Each model lives in `projects/<name>/` with its `.scad`, a README,
a `<name>_log.md` design log, its print outputs (`<name>_print/`), the per-part STLs as modelled
(`<name>_parts/`), the latest `--bundle` zip and `<name>_configurator.html`. Commit all of these; the user wants them in the repo.
When a new bundle is made, delete the old zip. Shared building blocks are in `lib/` (see `lib/README.md`): plaque outlines, routed edges, rails/sliders/pegs, number scales, fits, fonts.

## Toolchain
- **OpenSCAD**, driven by the `openscad` skill (render.sh / asm.py). Run its `setup.sh` once per fresh container,
  or let the environment setup script install `openscad`, `xvfb` and `fonts-liberation`.
- **Text in models:** `use <../../lib/fonts.scad>` and `font_for("serif")` etc. The skill's WebAssembly engine
  finds no fonts, so build text models with `OSCAD_ENGINE=native` (slower, fine for these sizes).
- **Reuse the lib first.** Before modelling a board, plaque, rail, slider, peg or number scale, use `lib/`.
  When a project grows something generic, move it into `lib/` with its style option list and keep
  `lib/README.md` current. Check every style option of a lib module (fit + clash) after changing it.
- **Mounting:** give hanging or standing projects `attach_socket()`s in their back (from `lib/attach.scad`)
  instead of their own hangers, with Attachment parameters (type, size, count) like the scoreboard. Plates snap in (user wants snap fits, not slides or keys).
  Keep sockets clear of anything else in the back (dowels, screw holes) and assert they fit the host's height.
- **Lighting and wiring:** use `lib/led.scad` (tracks, diffusers, corners, recess cutter) and `lib/cable.scad`
  (clips, ties, ducts, grommets, route grooves) rather than one-off parts. Snap fits must bend the flexing
  part by 2% or less: check this with a probe (see projects/led_kit `probe`).
- **Logos / artwork:** exact reproduction = `tools/svg_to_scad.py` into `lib/emblems/` (never `import()` an SVG:
  the browser engine scales it differently). Verify by rasterising the export and diffing against the original
  (bolavuit: 0 px differ beyond 2 px of an edge). Generic look-alike elements live in `lib/emblem.scad`.
  The user wants a 100% match when recreating a given logo.
- **Fitting generic elements to artwork:** model the element in Python with the same formulas as the .scad module,
  maximise IoU against the exact polygons (scipy Nelder-Mead with explicit initial steps), export the parameters to
  `lib/emblems/<name>_rebuilt.scad`, then re-measure the OpenSCAD output. Template: projects/bolavuit_logo/fitting/.
- **Commit and push after each finished step**, not only at the end (the user lost track of uncommitted work once).
- **Bundles:** after `asm.py --bundle`, run `python3 tools/bundle_with_lib.py projects/<name>/<name>_<rev>.zip`
  so the zip carries the lib files it needs.
- `fits.scad` (ISO 286 fits): `fit_mid("H7", d)` for holes and `fit_mid("p6"|"k6"|"g6", d)` for shafts.
  Not every class exists at every size (no `m6`; use `k6`).
- OpenSCAD ranges `[a:b]` with a > b run BACKWARDS instead of being empty. Always write `[a:1:b]` in loops
  over counts that can reach 0 or 1. Test optional features with empty lists (`steps = []`).
- Text width: a digit is about 0.78 × text size wide in the widest bundled font (sans bold). Size plates
  and borders for the widest label, not the pitch.
- In the parts table, `pieces=` must count every separate solid. Text inlays have one piece per glyph,
  plus dots and borders, so compute that count in the .scad.

## Browser configurator
- `python3 tools/make_configurator.py projects/<name>/<name>.scad` writes `<name>_configurator.html`:
  a standalone page that runs the real .scad with OpenSCAD WebAssembly (from the jsDelivr CDN), with a
  form for every parameter, a coloured 3D view per part, STL downloads and a customised .scad download.
- Write parameters in **OpenSCAD Customizer format** (also works in OpenSCAD's own Customizer panel):
  `/* [Section] */` headings, a `// description` line above each `name = value;`, optional trailing
  `// [a, b, c]` (dropdown) or `// [min:step:max]`, and `/* [Hidden] */` before derived values.
- Offer style choices as string parameters with option lists, plus a `style_preset` that overrides
  them (see the scoreboard's PRESETS table).
- **Re-run it after every .scad change**, because the page embeds a copy of the model. Commit the HTML too.
- Fonts work in the browser engine once the .ttf is in `/fonts` with a `fonts.conf`; the page does this.

## User preferences / how the user works
- Wants parametric models with every user-facing setting at the top of the file.
- Wants separate printable parts (tracks, sliders, stoppers…) instead of one fused model.
- Gives a reference photo for style and expects the model to follow it.
- Design for a ~250 mm printer bed: split long parts at a natural joint and join them with dowels.
- Default print colours: wood-brown board, gold rails and sliders, silver stoppers, black text inlay
  (2-colour 3MF).

## Design conventions that worked
- Sliders on rails: a T-rail (flange on a web) with a C-slider whose lips grip under the flange.
  0.25 mm clearance per side, slider printed top-down (`print=x180`).
- Stopper pegs go through a clearance hole in the rail and press into the board (H7/p6). The head blocks
  the slider and the peg holds the rail down.
- Verify with numbers first: `asm.py --clash --check`, then `--section` through the fit.
  Use `--bundle` for the final deliverable.

## Projects
| Project | Status | Notes |
|---|---|---|
| `projects/scoreboard` | v3: styles, presets and attachment plates, not printed yet | sliding-pin scoreboard (0–19 + 20…100 steps), see its log |
| `projects/led_kit` | v1, not printed yet | LED tracks, diffusers, corners, cable parts; test and showcase for lib/led + lib/cable |
| `projects/bolavuit_logo` | v1, not printed yet | Bola Vuit logo plaque: exact (from the SVG) or rebuilt from lib/emblem; 2-colour |
| `projects/attachments` | v2 snap fit, not printed yet | test coupon + every attachment plate type; print this first to check the snap fit |
