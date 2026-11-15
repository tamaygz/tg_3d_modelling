# 3DModelling – working notes for Claude

Home for all 3D-modelling tasks (repo `tamaygz/tg_3d_modelling`, cloud environment "3DModelling"). Each model lives in `projects/<name>/` with its `.scad`, a README,
a `<name>_log.md` design log, its print outputs (`<name>_print/`), the per-part STLs as modelled
(`<name>_parts/`), the latest `--bundle` zip and `<name>_configurator.html`. Commit all of these; the user wants them in the repo.
When a new bundle is made, delete the old zip. Shared helpers are in `lib/`.

## Toolchain
- **OpenSCAD**, driven by the `openscad` skill (render.sh / asm.py). Run its `setup.sh` once per fresh container,
  or let the environment setup script install `openscad`, `xvfb` and `fonts-liberation`.
- **Text in models:** the WebAssembly OpenSCAD engine finds no system fonts, so any text renders empty.
  Fix: copy the `.ttf` from `lib/` beside the model, add `use <Font.ttf>`, and build with
  `OSCAD_ENGINE=native` (OpenSCAD 2021 is slower, but fine for models this size).
- `fits.scad` (ISO 286 fits): `fit_mid("H7", d)` for holes and `fit_mid("p6"|"k6"|"g6", d)` for shafts.
  Not every class exists at every size (no `m6`; use `k6`).
- In the parts table, `pieces=` must count every separate solid. Text inlays have one piece per glyph,
  plus dots and borders, so compute that count in the .scad.

## Browser configurator
- `python3 tools/make_configurator.py projects/<name>/<name>.scad` writes `<name>_configurator.html`:
  a standalone page that runs the real .scad with OpenSCAD WebAssembly (from the jsDelivr CDN), with a
  form for every parameter, a coloured 3D view per part, STL downloads and a customised .scad download.
- It reads the parameters from the top of the file down to `// derived` (`name = value; // comment`, with
  `// ---- Section ----` headings) and the parts from the `parts` table. Keep new models in that layout.
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
| `projects/scoreboard` | v1 modelled, not printed yet | sliding-pin scoreboard (0–19 + 20…100 steps), see its log |
