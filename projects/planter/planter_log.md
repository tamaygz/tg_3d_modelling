# Self-watering planter – design log

## v1 (2026-11-28)
- New project from the user's brief: a self-watering pot with the reservoir below (stacked pots), on the side, or
  below with a side intake; a water level float with cute toppers; water-tight walls and floor; a configurable
  cone (foot and rim radius, height); a styled upper band (pattern + line style), "see custombox".
- Research (Printables / MakerWorld / Instructables planters, Lechuza instructions, self-watering patents, Prusa
  water-tight printing tests) gave the extra features: wick basket filled with soil (or rope wicks), air gap
  between water and soil, overflow hole at the highest water level, fill shaft that doubles as the float guide,
  min / max float indicator, drain holes from the soil into the reservoir, saucer, lugs for hanging cords, a holder
  for a capacitive soil moisture sensor with a cable notch, a drip irrigation line clip, and a sealed side tank
  (bird-bath principle) for much more water.
- Library:
  - `lib/shell.scad`: tapered walls. The outline scaled about the z axis is a pyramid frustum; every facet is a
    flat trapezoid and the wall unrolls exactly into a fan (`shell_taper_frame`, `shell_taper_at`,
    `shell_taper_strip_pts`, `shell_wrap_taper`), so patterns keep their true size. Polar rims and line shapes
    (`shell_rim_round`, `shell_wave`: wave, zigzag, scallop, petal), `shell_inset_pts`, `shell_ngon_pts`,
    `shell_area`, `shell_pt_at`, `shell_dist_at_dir`, `shell_joints`.
  - `lib/patterns.scad`: `$pat_window` may be turned (third element) and clipped to a polygon (`$pat_clip`).
  - `lib/container.scad`: `container_wall_taper()`: solid tapered wall, patterned band above a line function,
    plain zones, openings with collars, bead / groove along the line, rolled lip.
  - `lib/core.scad`: COL_TERRACOTTA, COL_SAGE, COL_WATER, COL_PETAL.
- Decisions:
  - Two parts for soil and water (insert on a stepped ledge) instead of a separator plate: the insert prints
    upright without supports, the wick basket is its own part (bottom on the bed, 45 degree collar that seats in
    the insert's floor) and stands on the pot floor, carrying the middle of the insert.
  - The float guide is a tube rising from the pot floor into the insert's fill shaft (telescoping, it also lines
    up the insert); the float is an open-bottom bell printed with 0 % infill, the rod comes out through a ring of
    spokes at the top of the shaft. The report gives the float's spare lift; under 2 g it warns.
  - Tower and tank lean with the pot wall (a sheared cylinder: horizontal sections stay round, overhang = the
    wall's lean); the float, rod and topper lean with them. A web fills the narrow crotch between tank and wall.
  - Through-cut bands only above the insert's floor (the insert holds the soil); lower, the band is raised.
  - Tapered walls are built as one solid wall with the pattern's openings cut out of it afterwards. Two facets
    that each carry their own copy of a hole crossing their joint leave slivers. Near each joint every other
    facet's cut is grown (up to 0.25 mm) so it contains its neighbour's; very sharp joints get a plain post.
    Reliefs: a relief layer minus the spaces between the ribs, level by level (fluted, fish scales keep their
    profile); the first cut starts 0.2 mm inside the wall.
- Fixes found by the checks: wall foot exactly on z = 0 touched the tank's bottom face (foot now 0.02 mm up); the
  end of the unrolled loop wrapped to its start (zone missing on one side of the tower); cap thread out of phase
  with the neck; holder tabs poked through rounded corners; the wick basket hit the float guide in small pots
  (it moves away from the guide, shrinks, or is left out for rope wicks); urns: the upright fill shaft must fit
  at the insert's top too; one scale for the insert must be the tightest, not the average.
- Open:
  - A squircle with `aspect = 0.7` and the default raised honeycomb leaves one 0.05 mm fragment at a joint on the
    band's top edge (harmless, but the one-piece check flags it); not in the tests.
  - Attachment plates: the tapered round wall has no flat zone for the socket; a flat back for wall planters
    would need a D-shaped outline.

## Prints and feedback
- (none yet)

## How the user works
- Wants generalised, configurable solutions; library first; commit and push between steps.
