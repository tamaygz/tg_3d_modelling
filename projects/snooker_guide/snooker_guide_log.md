# Snooker guide – design log

## v1 (2026-11-15)
- Relief plaque from two reference images (top view and 3D view of a snooker table with numbered balls).
- Official geometry (WPBSA, checked online); balls 1.6× true scale; reds packed with 0.4 mm gaps.
- Every colour is its own part (plate=guide 3MF). Points: on/off, size, colour, position, raised/inlay, legend row.
- Depth: table base, rails, cushions, cloth; top and bottom edge profiles (new lib `profiled_slab2`); optional
  surround plate with the lib's plaque shapes, edge profiles and groove; attachment sockets in the plate
  (or in the table when the plate is off).
- Fixes: pink's number collided with the reds (moves above); roof/stand brackets get the guide's real height.
- Tool: the configurator generator now evaluates the `parts` table with OpenSCAD, so generated tables work.
- Checked 11 parameter combinations: no clashes, piece counts correct.

## Prints and feedback
- (none yet)

## Open questions
- Number and line legibility at the default size: lines are 0.6 mm, numbers 5 mm.
- Multi-colour workflow on the user's printer (17 bodies, 10+ colours): may want a reduced-colour mode.
