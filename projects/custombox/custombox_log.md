# Custom box – design log

## v1 (2026-11-16)
- One model for boxes, baskets, bins and bowls, following the MakerWorld Paramacraft examples the user sent
  (rounded boxes with lattice and woven walls, sloped and wavy rims, plain rim and base bands, inset lid).
- New library `lib/shell.scad`: outlines (box runs with round / chamfer / square corners, ellipse, squircle, wavy),
  a rim height field, the unrolled wall strip, and `shell_wrap()` which bends a flat panel round the outline.
- `lib/patterns.scad` extended generically: `$pat_window` builds any pattern / panel / lining piece by piece
  (checked: two halves add up to the whole for all modes), every generator takes a `center`, and `border` may be
  [sides, bottom, top] so a wavy top edge keeps a band of constant height.
- Decisions:
  - Walls are flat facets, one per outline edge, each a windowed `pattern_panel()`; a straight side is a single
    facet, so a rounded box is about 30 solids and builds in seconds. No 3D booleans except for weaves.
  - The rim is a height field over the plan (not a function of the distance round the box), so it is continuous
    on any outline and front / back / sides stay consistent.
  - Corners: "pattern" wraps one pattern round (cells fitted to the perimeter), "solid" gives each wall its own
    panel and allows different front / back patterns.
  - Inset lid on a 45° ledge instead of a lip: both lid faces stay flat, any pattern mode prints face up.
  - Mounting through a boss on the back wall, because walls are thinner than the 4.5 mm attachment socket.
- Fixes during design (found by the watertight / one-piece checks):
  - the two ends of a wrapped wall met face to face at the seam: strips now reach 0.3 mm past their ends;
  - identical cut-outs of neighbouring facets nearly coincided at the joints (non-manifold slivers): every other
    facet is pulled in and set back by 0.04 mm (`SHELL_SHRINK`); first attempt cancelled itself for cut-outs
    (hole and material both moved), fixed with a clip-only helper for negative shapes;
  - the floor edge lay exactly in the wall's outer faces: floor outline 0.05 mm inside;
  - the lid ledge poked 0.01 mm into the lid.
- Checks: every variant in tests.txt gives one watertight box (and lid); lid and plates clear the box.

## v1.1 (2026-11-16) – mounting built into the wall, ties
- User feedback: the boss behind the patterned back wall printed twice (wall, then plate). Now the back wall has
  a solid zone with the sockets (`container_mount()`): pattern joins its sides, thickened to 6 mm only there, 45°
  underside when it floats, merges with rim / base band within 10 mm. Seam moves to the back left corner when mounted.
- Flowing waves and ripples get ties automatically when cut through (lib/patterns.scad `pattern_tied()`).

## v1.2 (2026-11-16) – fin, slide track, ball joint
- `attach_type = "fin"`: socket under the floor in a solid floor zone (thickened upwards), slide plate + fin with a
  blade for anchoring between sofa cushions (user's snack and drinks box). `slide` track and `attach_joint = "ball"` too.

## v1.3 (2026-11-16) – no seam where the wall closes
- User report: with Voronoi the pattern did not match where the wall's two ends meet. Cause: random patterns do
  not repeat (and earbuds / sunglasses never fitted any pattern to the perimeter). Now every wall that runs all
  round uses `pattern_wrapped()`: cells scaled to fit, wavelength fitted, Voronoi / Truchet repeat after one round.
  Measured: mismatch at the seam 140-340 mm2 before, none after, for all patterns.

## Prints and feedback
- (none yet)

## Open questions
- Lid clearance 0.3 mm and ledge width 1.6 mm: confirm on a print.
- Thin lattice walls printed upright: check stringing and the bridges of wide cells.
- Wanted next? Two-colour export (frame and pattern as separate parts), tapered (leaning) walls, dividers, handles.
