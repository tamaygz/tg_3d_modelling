# Bola Vuit logo – design log

## v1 (2026-11-15)
- lib/emblem.scad: generic leaf, laurel branch/wreath, Bezier ribbon, banner (band, tails, bow, outline/filled),
  arc text (condensable), pool ball (ring, disc, crescent), stroke helper.
- First rebuild from generic elements tuned against the original by overlay: close, but not identical.
- User asked for a 100% match: tools/svg_to_scad.py converts the original's white artwork path into polygon
  regions (29), named as elements in lib/emblems/bolavuit.scad. Default source = exact.
- Verified: rasterised export vs reference PNG: 0 px differ beyond 2 px of an edge (only anti-aliasing).
- Found: `import()` of the SVG scales differently in the browser engine (154 mm instead of 120): don't use it.
- logo_width now means the artwork width (it was the artboard width).

## v2 (2026-11-15) – rebuilt elements fitted to the original
- User feedback: the rebuilt leaves/laurel, banner and bow were far off; wanted a very close fit and the font.
- Measured and fitted every generic element against the exact polygons (fitting/): leaves (slender almond,
  sin^0.62, 27% of length, straight), wreath layout (groups of 1 inner + 2 outer leaves; explicit 11-leaf list
  per side incl. 2 bottom leaves hidden in the banner outline), banner (band, swallowtail tails, folds, strip,
  lens loops, crossing tapered legs, ears, 13.6 px outline), ball (ring r 459 not 447, crescent, disc),
  numeral (Lato Bold), lettering (Source Serif 4 Bold, per-letter warp matrices).
- Whole rebuilt logo vs original: overlap 0.728 → 0.899.
- Font search: ~120 open fonts; best Source Serif 4 0.861, Eczar 0.858; Rockwell Extra Bold 0.72 (not it).
- Lessons: Pillow's text bbox is not the ink box; give Nelder-Mead real step sizes for parameters starting at 0;
  guard scripts with __main__ (an import re-ran a 30 min fit twice).

## v2.1 (2026-11-15) – housekeeping
- Rebuilt output byte-identical after the library cleanup (banner now `banner_spec()`-capable, shared leaf code).
- fitting/: superseded scripts and results removed, paths made portable, helpers moved to tools/artfit.py.

## Prints and feedback
- (none yet)

## Open questions
- Smallest size the user wants: below about 102 mm the banner outlines get thinner than 0.8 mm.
