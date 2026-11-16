# Pattern gallery – design log

## v1 (2026-11-15)
- New library `lib/patterns.scad` + `lib/patterns/` with 12 patterns in three layers: pattern engine
  (`pattern_2d`, `pattern_3d`), surface application (`pattern_cutout_2d`, `pattern_panel_2d`, `pattern_relief`,
  `pattern_cutter`, `pattern_lining`, `pattern_panel`), project geometry (this gallery).
- Decisions:
  - Lattices are a plate with the cells cut out, never separate outlines: one connected network, equal rib width.
  - Voronoi: one site per grid square, cell = intersection of the bisector half-planes of the 24 sites around
    it, each moved in by strut/2. Exact for this site set, deterministic, no dependence on the panel size.
  - Random numbers come from a small integer generator, not `rands()`, so desktop and browser builds agree.
  - Weaves: every strand is one swept solid; the height wave has its period along the strand. Tri-weave is the
    kagome weave (third family shifted half a cell; 0° over 60° over 120° over 0°). Checked: on every strand the
    over and under crossings are exactly half a period apart.
  - Clipping, thick-to-thin steps and through-cuts are done in 2D and then extruded; only the weaves need a 3D
    intersection. This keeps desktop OpenSCAD 2021 (CGAL) fast enough.
  - Fish-scale shingles and ripple falloff are stacked 2D levels (steps), which is also how they print.
- Checks: every part of every variant in tests.txt is one watertight piece (lattices connected to their frame,
  reliefs fused to their panel), across all 12 patterns, all modes, rotations, odd sizes and outline shapes.

## v1.1 (2026-11-16) – windows, ties
- Library: `$pat_window` (build a panel piece by piece), generator `center`, frame widths per edge, `pattern_shift()`.
- User feedback: line patterns cut through had no cross connections (unprintable, not rigid). `pattern_tied()` adds
  bars between wave ribs at their closest points (brick-bond style for parallel ribs) and spokes to ripples,
  automatically wherever cells are cut out. Two test variants added.

## v1.2 (2026-11-16) – patterns that close round a loop
- `pattern_period()`, `pattern_wrapped(p, L)`; voronoi and truchet take `wrap` (random numbers from column i mod n).
  Check used: the pattern in a window at -L/2 minus the same pattern moved by L must be empty (it is, for all 11
  repeatable patterns; unfitted it differs by 140-340 mm2).

## Prints and feedback
- (none yet)

## Open questions
- Default minimum rib (0.8 mm) and opening (1 mm) are for a 0.4 mm nozzle: confirm on a test print.
- Weave lift default (0.6 × strand thickness): check that crossings print cleanly without stringing.
