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
- Checks: every variant in tests.txt gives one watertight box (and lid); lid and plates clear the box.

## Prints and feedback
- (none yet)

## Open questions
- Lid clearance 0.3 mm and ledge width 1.6 mm: confirm on a print.
- Thin lattice walls printed upright: check stringing and the bridges of wide cells.
- Wanted next? Two-colour export (frame and pattern as separate parts), tapered (leaning) walls, dividers, handles.
