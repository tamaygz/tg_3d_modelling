# Sunglasses holder – design log

## v1 (2026-11-16)
- Tray for folded glasses: size presets, nose support ridge, front grip cut-out, patterned walls, higher back,
  snap-in mounting. Same construction as projects/earbuds (lib/container.scad), without the cable opening.
- Nose support: hull of a floor pad and a round top bar; solid ground is added under it when the floor is cut through.

## v1.1 (2026-11-16) – mounting built into the wall
- Same change as earbuds: solid mounting zone in the back wall instead of a boss behind it; pattern centred on the front.

## v1.2 (2026-11-16) – nose ridge
- User report: a wide, low nose (34 wide, 22 high) showed a mirrored shape under the floor: the top radius was
  larger than the height, so the hull reached below z = 0. The ridge is now `container_ridge()` in lib/container.scad:
  top radius limited to the height, clipped at the floor and at the inside of the walls.
- User request: front / back slope (`nose_run_front`, `nose_run_back`) and a domed top (`nose_crown`) so the
  glasses do not hook behind the ridge. Defaults 2 / 8 mm and 0.6.

## v1.3 (2026-11-16) – no seam where the wall closes
- User report: with Voronoi the pattern did not match where the wall's two ends meet. Cause: random patterns do
  not repeat (and earbuds / sunglasses never fitted any pattern to the perimeter). Now every wall that runs all
  round uses `pattern_wrapped()`: cells scaled to fit, wavelength fitted, Voronoi / Truchet repeat after one round.
  Measured: mismatch at the seam 140-340 mm2 before, none after, for all patterns.

## v1.4 (2026-11-17) – flush mounting zone, chamfers, fin everywhere, all parts in the configurator
- User feedback (4 points): (1) the mounting zone still stood out behind the wall: it is now flush outside, the
  sockets are cut in from behind and the extra thickness is a pad with 45° edges on the INSIDE; the inside face
  stays closed. (2) Sharp edges on parts that stand out: slide carriage, ball-joint adapter and fin base are
  chamfered. (3) Fin option now in every container project. (4) The fin was missing in the configurators because
  they read the parts list at default settings: the tools now read every possible part (`$all_parts`).

## v1.5 (2026-11-22) – mounting zone flush inside, grows outward; shallower socket
- Mounting zone reversed (user request): flush with the INSIDE face of the back wall, using the wall's own
  thickness; only what the socket still needs grows outward behind the wall as a pad with 45° edges (flat at the
  bottom on the floor). The inside is the same as without a mount, so the extra depth that used to make room for
  an inside pad is gone. Socket 4.0 mm + 1.2 mm closed back = 5.2 mm (was 4.5 + 1.5 = 6.0); plates unchanged in
  how they swap, every type keeps the same socket. Magnet default 8 × 2 mm.

## Prints and feedback
- (none yet)

## Open questions
- Typical sizes only: confirm against the user's glasses.
- Should the glasses hang with open temples instead (a hook-style holder)? This version stores them folded.
