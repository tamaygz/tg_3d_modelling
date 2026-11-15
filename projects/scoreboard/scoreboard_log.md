# Scoreboard – design log

## v1 (2026-11-15)
- Parametric: players, base range, step list, number pitches, board split.
- Parts: board halves + dowels, number plates + black inlay (3MF), main and step rails per player,
  one slider design (rotated 180° for lower tracks), end stopper pegs, two-pin column divider.
- Default board is 356 × 76 mm, split at the divider into 248 mm + 109 mm halves.
- Checks: clash and fit checks pass; 3- and 4-player variants also build.

## v1.1 (2026-11-15)
- Fix: `steps = []` now means no second dimension. Before, it drew a step column with a lone "0", or
  crashed when `zero_step = false`. Now the step plate, step rail, divider and second slider are left
  out, the main rail runs to an end stopper, and a split board is cut between the two middle numbers.
- Fix: one-number ranges (`[0:-1]` loops) no longer run backwards; all loops use an explicit step `[a:1:b]`.
- Default build unchanged (same size and volume); checks pass. Tested: no steps ± zero_step, 3 players,
  unsplit, a single step, a single main number.

## v2 (2026-11-15)
- Configurable styles: board shape, edge profile, groove, marker, pointer, stopper head, rail top,
  number plate style, font, separator, plus presets (classic, modern, victorian, pub, minimal).
  Styles come from the shared `lib/` (shapes, rail, scale, fonts); the model now only lays them out.
- Parameters in OpenSCAD Customizer format, so they work in OpenSCAD's Customizer too.
- Fix: number plates grow to fit the widest label (bold sans "100" ran into the border; serif cleared it by 0.3 mm).
- Default (custom = classic) build is the same apart from slightly longer plate ends; checks pass
  for every preset (minimal has no separate number parts, by design).

## v3 (2026-11-15)
- Mounting moved to the shared attachment system: sockets in the back take any plate from `lib/attach.scad`
  (wall, keyhole, skadis, hook, magnet, stand, flat). The built-in keyhole slots are gone (keyhole plate instead).
- Parameters: attach_type (default keyhole), attach_size, attach_count, lock_key, and options per type.
- Sockets are spread over the back, shifted clear of the split dowels; Skådis spacing snaps to 40 mm.
  An assert explains when a plate size is too tall for the board.
- Checked: every type, S/M/L, 1–4 plates; plates have 0.2 mm clearance in their sockets.

## v3.1 (2026-11-15)
- Attachment plates now snap straight in (lib change); the lock key and `lock_key` parameter are gone.
  Sockets are shorter (plate + 3 mm notch), so size L fits a 2-player board.

## v3.2 (2026-11-15)
- New attachment type `roof` (ceiling bracket); the stem reach is computed from the board's top edge + `roof_gap`;
  `roof_angle` tilts the board. Checked at 90° and 75°.

## Prints and feedback
- (none yet)

## Open questions
- Is the slider friction enough on a real print? A detent bump may be needed.
- Is the press fit for the stopper pegs right on the user's printer?
