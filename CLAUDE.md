# 3DModelling – working notes for Claude

Home for all 3D-modelling tasks (repo `tamaygz/tg_3d_modelling`, cloud environment "3DModelling").
Read `README.md` (structure, tools, adding a project) and `lib/README.md` (library reference and conventions) first.

## Rules
- **One command:** after any change to a model or the library run `python3 tools/build.py <project> --test`
  (`all` after a lib change). It rebuilds parts, print files, bundle (with lib files) and configurator, removes
  old bundles, and checks every variant in `tests.txt`. Don't run those steps by hand.
- **Commit what build.py writes** (print files, viewer, configurator) except what `.gitignore` excludes
  (`*_parts/`, bundle zips: the user stopped tracking those). **Commit and push after each finished step**, not only at the end.
- **Library first.** Projects lay out library parts; they don't copy code. New reusable things go into `lib/`
  with a header (use line, frame convention), an option list for styles, and an entry in `lib/README.md`.
  Layers: `core.scad` → element files → data (`emblems/`, `fonts/`) → projects.
- **Project pattern** (see `projects/_template/`): `include <../../lib/core.scad>`, `part`, Customizer sections
  (`/* [Section] */`, `// description` above EACH `name = value;` (never one line for a pair: the configurator then
  shows nothing for the second, and the user could not tell a wave's amplitude from its count), trailing `// [a, b, c]` or `// [min:step:max]`),
  `/* [Hidden] */`, derived values, `parts` / `checks` / `report` tables, then 2D shapes, solids, assembly through
  `pick()`. Colours from the `COL_*` palette. Offer style choices as string options, plus a `style_preset`
  where there are many (scoreboard's PRESETS). Automatic sizes (a setting of 0) come from `pattern_sized()`.
- **Mounting:** hanging or standing projects use the attachment host helpers (`attach_fit` + `attach_note`:
  smaller plate or none with a WARNING, never an error; `attach_xs`, `attach_y`, `attach_sockets`, `each attach_rows(...)` in the parts table, one `attach_all(part, ...)`
  line to draw plates / track / ball joint) and expose `attach_type`, `attach_size`, `attach_count`,
  `attach_joint`, `slide_axis`. Plates snap into the host; types include `slide` (track on the wall), `fin`
  (blade under the host: `attach_face(type) == "bottom"`, containers only), `clamp` (C-clamp + printed screw,
  threads from `lib/thread.scad`) and `pipe` (snap-on claw, strain ≤ 2%). New plate types or joints go into
  `lib/attach.scad` so every project gets them; add them to each project's option list and tests.
- **Fit, do not fail** (user request): a setting that does not fit is reduced or left out and reported
  (WARNING echo + a `report` line). `assert` only when no printable part can result. Compare lengths with a
  0.01 tolerance (a mount needing exactly the available 122.8 mm was once rejected).
- **READMEs have pictures:** each project lists them in `shots.txt` (image | parameters | camera), rendered by
  `python3 tools/make_screenshots.py <project>|lib|all` into `images/`; library pictures come from
  `lib/examples/*.scad`. Re-render after a visible change. Each project README starts with its pictures and the
  link to its online configurator (`https://tamaygz.github.io/tg_3d_modelling/<project>`). Marketing pictures (4:3, for
  MakerWorld and the main README) come from `python3 tools/make_marketing.py`; the listing plan is `marketing/makerworld.md`;
  the MakerWorld print-profile 3MF from `tools/make_showcase_3mf.py` (Bambu plates format, read from BambuStudio's
  bbs_3mf.cpp / PartPlate.cpp). build.py writes `<name>_makerworld.scad` (one file, `tools/flatten_scad.py`) for the
  projects in its MAKERWORLD set; flattening refuses name clashes that `use` would have hidden.
- **Lighting and wiring:** `lib/led.scad` and `lib/cable.scad`, not one-off parts.
- **Patterns** (lattices, cube rosette, weaves, Voronoi, scales, Truchet, Girih, asanoha, waves, ripples, fluted): `lib/patterns.scad`, never
  project code. Pick by name via `pattern_spec()`, apply with `pattern_panel(mode, ...)` or the single helpers
  (`pattern_cutout_2d`, `pattern_relief`, `pattern_cutter`, `pattern_lining`). Frame: XY plane, surface z = 0,
  outside +Z; build flat, then rotate onto walls. New patterns: a generator in `lib/patterns/`, a branch in
  `_pat_gen_2d`, defaults + `pattern_features`, a gallery tile and tests. Do clipping and cuts in 2D and extrude:
  3D booleans are slow in OpenSCAD 2021 (only the weaves need one).
- **Containers and curved walls:** `lib/shell.scad` (outline as points or named runs, rim height function, tapered walls
  `shell_wrap_taper` in an unrolled fan frame,
  `shell_strip_pts`, `shell_wrap`) and `lib/container.scad` (walls with framed openings and plain areas, floor, lid ledge,
  mounting zone for the attachment plates via `container_mount()` + `mount=`, rim dip for grips, compartments:
  `container_layout()` + `container_grid()` + `container_dividers()`, joints via `container_grid_plain()`). Rim heights per
  wall: `shell_rim()` (raise / waves / notches per side). Layouts typed as text are read with `lib/strings.scad`. `projects/custombox` is the reference (`projects/planter` for tapered walls: `container_wall_taper()`, build them cut-from-solid, never as facets that each carry their own holes); `earbuds` and
  `sunglasses` show a holder for a given item (presets + clearance, cable opening, grip, nose support).
  One facet per outline edge: keep straight sides as a single edge. Frame widths as `[sides, bottom, top]`.
  A wall that closes on itself must use a pattern that repeats after the perimeter: `pattern_wrapped()` (the
  container walls do it); check a seam by subtracting the pattern moved by one perimeter from itself.
- **Snap fits** must bend the flexing part by 2% or less; prove it with a probe (see `projects/led_kit`, `probe`).
- **Logos / artwork:** exact reproduction = `tools/svg_to_scad.py` into `lib/emblems/` (never `import()` an SVG:
  the browser engine scales it differently). Verify with `tools/artfit.py overlay`. The user wants a 100% match
  when recreating a given logo. To make generic elements match artwork, fit their parameters against the exact
  polygons (template: `projects/bolavuit_logo/fitting/`).
- **Fonts:** only redistributable fonts in `lib/fonts/` (see its README); register them in `lib/fonts.scad` and
  re-run `tools/font_metrics.py`. Prepare new fonts with `tools/prepare_font.py` (subset + ttfautohint): unhinted
  TrueType fonts crash the browser OpenSCAD on any text ("RuntimeError: null function"). A modified OFL font with a
  Reserved Font Name gets a new family name (Source Serif 4 Bold → "Book Serif"). Text that must fit a space uses `text_len()` / `arc_text_2d(max_len=...)`, never
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
- Variables of a `use`d file are not visible to the file that uses it (`GIRIH_RATIO` was undefined in
  patterns.scad), and passing `undef` to a parameter does NOT fall back to its default: resolve defaults inside.
- `if ($children > 0)` must be decided in the public module: a nested `children()` call counts as one child even
  when it is empty, and `intersection()` with an empty child gives nothing.
- Special variables (`$pat_window`) pass context down to children without threading parameters; test with
  `is_undef($x)` (no warning). Function literals (`f = function(p) ...`) work in 2021.01.
- CGAL unions of pieces that overlap with nearly identical surfaces (same cut-outs rotated a few degrees, faces
  exactly in line, solids ending face to face) export as non-manifold slivers. Make them differ by a real hair
  (0.03–0.05 mm) or overlap by a real volume; `tools`-side check: every edge must have exactly 2 faces.
- A pattern window must be tight: generators cover the whole window, and weave strands are as long as its diagonal.
- No `rands()` for patterns: `pat_hash()` gives the same numbers in every OpenSCAD version and in the browser.
- `hull()` with a sphere or cylinder whose radius exceeds its height above the floor pokes through the floor:
  limit the radius to the height and clip with a half-space (see `container_ridge()`); test wide-and-low extremes.
- To copy a pattern from a picture, measure its repeat (autocorrelation of the hole mask) and the hole sizes
  before guessing a construction: the cube rosette looked like a two-size pattern but is one triangular grid.
- Appending in Python: NEVER `open(f, "w").write(open(f).read() + x)`: the "w" open truncates the file before the
  read (it emptied tests.txt twice). Read first, then write. After editing tests.txt, compare the variant count.
- Guard long-running Python scripts with `__main__` (an import once re-ran a 30-minute fit).

## Browser configurator
- Built by build.py (or `tools/make_configurator.py`): the page embeds the model and its lib files and runs the
  real OpenSCAD in the browser, so it must be rebuilt after every change. Page template:
  `tools/configurator_template.html`.
- It reads parameters from the Customizer block and the evaluated `parts` table (generated tables work).
  The tools evaluate the table with `$all_parts = true`, so optional parts (track, fin, ball joint) are always
  offered and drawn; a library function that adds part rows only for some settings must honour that flag.
- Web site + release: the manual workflow `.github/workflows/configurators.yml` stages projects with
  `tools/make_pages.py`, builds pages with yawkat/web-openscad-editor (pinned commit, OpenSCAD snapshot 2026.01.19),
  deploys to GitHub Pages and creates a release (`tools/release_notes.py`). That generator only bundles files from
  bare `include <...>` / `use <...>` lines: no trailing comment on those lines (make_pages.py refuses them).
  pick() colours parts from the `parts` table, which gives the web preview its colours.

## User preferences
- Licence: CC BY-NC-SA 4.0 (`LICENSE`): no commercial use. Call the project "free" / "source on GitHub", not "open source".
- Parametric models, every user-facing setting at the top; separate printable parts instead of one fused model.
- Gives reference images and expects the model to follow them closely.
- ~250 mm printer bed: split long parts at a natural joint and join with dowels.
- Default colours: wood-brown board, gold rails and sliders, silver stoppers, black inlays.
- Wants generalised, reusable library parts and consistent patterns across projects.
- Printing time matters: no solid plate behind a patterned wall (he rejected the mounting boss). Build solid
  zones INTO the wall, let the pattern join them, and blend them into rim / base bands.
  Mounting zones are flush with the wall's INSIDE face (nothing into the enclosure) and use the wall's own
  thickness; only what the socket still needs (`attach_host_t()` = 5.2 mm total) grows OUTWARD as a pad with 45°
  edges; sockets cut in from its outer face, never cut through. Chamfer every part that stands out (no 90° outer edges).
- The plate system must stay generic and interchangeable: one socket for every type, plates swappable any time
  (no type-specific plate-less mounts). Keep the depth minimal within that (socket 4.0 + 1.2 back, magnet 8 × 2).
- Cut-through patterns must be printable and stiff: lines need regular cross ties in the pattern's style.
- Holders for things: wants presets for popular products (researched sizes, his own device first: Soundcore P31i
  earbuds), a custom size, and a grip cut-out at the front.

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
| `projects/attachments` | v5.1, not printed yet | test coupon + every attachment plate, slide track, fin, clamp, pipe claw, ball joint; print first to check the fits |
| `projects/pattern_gallery` | v1.3, not printed yet | catalogue + test bench of the 15 `lib/patterns.scad` patterns; views: gallery, sample, modes, box |
| `projects/custombox` | v1.6, not printed yet | configurable box / basket / bin: outline, corners, rim raise / waves / notches per wall, patterned walls, compartments (grid or % layout), floor, inset lid, mounting zone in the back wall |
| `projects/earbuds` | v1.4, not printed yet | charging-case holder: presets (P31i …), poses, cable hole / dock / slot, grip cut-out, mounting zone |
| `projects/sunglasses` | v1.5, not printed yet | folded-glasses tray: size presets, nose support, grip cut-out, mounting zone |
| `projects/planter` | v1, not printed yet | self-watering pot: tapered outline, reservoir below / side tower / sealed side tank, soil insert + wick basket, float with toppers, styled band and rim, sensor / drip / hanger / saucer |
| `projects/_template` | – | starting point for new projects |
