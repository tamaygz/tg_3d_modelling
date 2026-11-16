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

## Prints and feedback
- (none yet)

## Open questions
- Is 0.6 mm clearance right for the P31i case? Does the user want room for a silicone sleeve?
- Dock mode: plug fit (0.15 mm) and floor thickness needed to hold the plug straight.
- Did "adapter system" mean exchangeable inserts for different cases instead? (Could be added: one outer holder,
  thin inserts per case model.)
