# Earbuds holder – design log

## v1 (2026-11-16)
- Holder for an earbuds charging case with presets (Soundcore P31i first), three poses, patterned walls, front
  grip cut-out, cable opening (floor or any wall; pass-through or plug dock; lay-in slot) and snap-in mounting.
- Built on the new `lib/container.scad` (walls with framed openings, floor, mounting boss), which was extracted
  from custombox so that custombox, earbuds and sunglasses share it; grip cut-out is `shell_rim_dip()`.
- Decisions: "adapter system" read as the attachment plates (wall, keyhole, Skådis, hook, magnet, glue, ceiling).
  Seam of the wrapped wall at the back left corner, so openings in the middle of a wall never cross it.
  Openings are cut in 2D (unrolled wall / floor plan) and get a plain collar; no 3D cuts.
- Sizes: P31i, AirPods Pro 2, AirPods 4 and Sony XM5 checked against maker / review pages; the other presets
  are from memory of the makers' specifications and marked "verify" in the README.

## v1.1 (2026-11-16) – mounting built into the wall
- The mounting boss behind the back wall is gone: the back wall carries a solid zone with the sockets
  (`container_mount()` in lib/container.scad). Pattern centred on the front wall (`anchor`).

## v1.2 (2026-11-16) – no seam where the wall closes
- User report: with Voronoi the pattern did not match where the wall's two ends meet. Cause: random patterns do
  not repeat (and earbuds / sunglasses never fitted any pattern to the perimeter). Now every wall that runs all
  round uses `pattern_wrapped()`: cells scaled to fit, wavelength fitted, Voronoi / Truchet repeat after one round.
  Measured: mismatch at the seam 140-340 mm2 before, none after, for all patterns.

## v1.3 (2026-11-17) – flush mounting zone, chamfers, fin everywhere, all parts in the configurator
- User feedback (4 points): (1) the mounting zone still stood out behind the wall: it is now flush outside, the
  sockets are cut in from behind and the extra thickness is a pad with 45° edges on the INSIDE; the inside face
  stays closed. (2) Sharp edges on parts that stand out: slide carriage, ball-joint adapter and fin base are
  chamfered. (3) Fin option now in every container project. (4) The fin was missing in the configurators because
  they read the parts list at default settings: the tools now read every possible part (`$all_parts`).

## Prints and feedback
- (none yet)

## Open questions
- Is 0.6 mm clearance right for the P31i case? Does the user want room for a silicone sleeve?
- Dock mode: plug fit (0.15 mm) and floor thickness needed to hold the plug straight.
- Did "adapter system" mean exchangeable inserts for different cases instead? (Could be added: one outer holder,
  thin inserts per case model.)
