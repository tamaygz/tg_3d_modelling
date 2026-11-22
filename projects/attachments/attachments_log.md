# Attachments – design log

## v1 (2026-11-15)
- Bayonet-slide socket: tabs (2 per side, 2.5 mm reach) drop through windows and slide l/4 to lock under a
  2 mm lip. 4.5 mm deep, 0.2 mm clearance. Lock key fills the slide gap.
- Plate types: wall (2× countersunk Ø4.5), keyhole (Ø9 head), skadis (4.6 mm tabs, 5.3 mm gap, 6 mm latch),
  hook (rail/rod/door, hook_gap), magnet (round pockets), stand (two kickstand fins), flat (glue grooves).
- Checked: plate lifts out freely at the entry position and is held when locked (S/M/L);
  every type clear of the coupon, one piece each.

## v2 (2026-11-15) – snap fit
- User asked for plates that simply snap into place. Replaced the bayonet slide + key with push-in snaps:
  2 cantilever arms per end (1.2 mm, fixed at the corners, free at the centre), 0.8 mm bumps with a 45°
  lead-in and a steep retention ramp; grooves in the socket end walls; pry notch below the plate.
- Arms bend 0.6 mm on the way in, under 1% strain on S, about 0.3% on M. Seated plates sit with no preload; pulled back
  0.4 mm, the bumps catch. Solid 4 mm corners carry the load.
- Socket is now plate length + 3 mm (was + a quarter of the length), so bigger plates fit smaller boards.

## v3 (2026-11-15) – roof
- New type `roof`: ceiling bracket. A 5 mm stem runs up behind the host from the plate's middle (0.6 mm clear of
  the snap arms, checked) to a 5 mm ceiling flange with 4 countersunk screws (room side) and two gussets.
  `roof_angle` 45–135° sets the angle between host and ceiling; checked at 70/90/110° for S and L.

## v3.1 (2026-11-15) – housekeeping
- lib/attach.scad gained host helpers (attach_xs with fit-to-span, attach_y, attach_fits incl. thickness,
  attach_sockets, attach_plates, attach_opts, attach_parts_row). 16 variants in tests.txt, all passing.

## v4 (2026-11-16) – slide track, fin, ball joint
- New types `slide` (dovetail track with rounded edges 16/10 x 4.5 mm, 0.25 mm play; horizontal through-channel or
  vertical drop-on with a closed top) and `fin` (track + blade; mounts on the host's bottom: `attach_face()`).
- Ball joint for every type: ball plate -> slotted cup on an adapter that carries a standard socket, so all plate
  types work unchanged. 6 petals, 20° past the equator, 0.48 mm bend, strain 1.4% (asserted < 2%), tilt 37° each
  way, tapered cup + lock ring to clamp. probe = 4 puts the ball at the cup's mouth.
- One call per host: `attach_all(part, ...)` draws all parts, `attach_rows()` lists them.
- Not printed: ring clamping force, track play, fin stiffness are untested.

## v4.1 (2026-11-17) – flush mounting zone, chamfers, fin everywhere, all parts in the configurator
- User feedback (4 points): (1) the mounting zone still stood out behind the wall: it is now flush outside, the
  sockets are cut in from behind and the extra thickness is a pad with 45° edges on the INSIDE; the inside face
  stays closed. (2) Sharp edges on parts that stand out: slide carriage, ball-joint adapter and fin base are
  chamfered. (3) Fin option now in every container project. (4) The fin was missing in the configurators because
  they read the parts list at default settings: the tools now read every possible part (`$all_parts`).

## v5 (2026-11-22) – clamp and pipe claw
- From the user's pictures (a printed C-clamp with a wavy knob, conduit clips M16–M32). Clamp: spine, upper jaw,
  lower jaw with a threaded boss, 45° gussets, chamfered edges, joined only to the plate's middle (snap arms stay
  free); printed screw with knob and 45° pad (new lib/thread.scad: ISO coarse threads as one helical surface,
  0.25 mm play per side, checked: rod in its hole does not touch). Pipe claw: opening chosen for about 1.5% strain
  (split-ring formula, asserted < 2%), 45° lead-in tips.

## Prints and feedback
- (none yet)

## Open questions
- Snap force: is SNAP_B = 0.8 mm right on the user's printer? Print the coupon first.
- Socket ceilings in hosts are 40–65 mm bridges (host prints back-down): does sag rub the plate?
- Skådis: check the 40 mm hook spacing against a real board.
