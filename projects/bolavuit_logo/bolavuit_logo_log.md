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

## Prints and feedback
- (none yet)

## Open questions
- Smallest size the user wants: below about 102 mm the banner outlines get thinner than 0.8 mm.
