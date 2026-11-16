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

## Prints and feedback
- (none yet)

## Open questions
- Typical sizes only: confirm against the user's glasses.
- Should the glasses hang with open temples instead (a hook-style holder)? This version stores them folded.
