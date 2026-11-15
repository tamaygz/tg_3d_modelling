# LED kit – design log

## v1 (2026-11-15)
- lib/led.scad: one cross-section (3 mm floor with T-slot, 1.6 mm walls, diffuser grooves) drives the track,
  diffusers, keys, end caps, corners (sweep with 12 mm straight ends) and the host recess cutter.
- lib/cable.scad: cable clip, flat cable clip, zip-tie mount, duct + snap lid, split grommet; route/notch/hole cutters.
- Checks: strip, diffuser, key, cap, corner and lid clear their mates. Diffuser and lid snaps bend 0.25 mm (probes).
  Combinations tested: all corners × flat/dome/none × 5/8/10/12 mm and IP65 × shallow/deep × glue/screw.
- Fixes during design: the duct lid's legs were too short (15% bend; now 5 mm long, about 1.4%); the dome diffuser
  needed ledges to join its legs; the end-cap hole was tangent to the top face.

## v1.1 (2026-11-15) – housekeeping
- Screw holes use the shared `csk_hole()`; geometry unchanged. 6 variants in tests.txt, all passing.

## Prints and feedback
- (none yet)

## Open questions
- Strip sizes are typical values: check them against the user's actual strips.
- Diffuser snap force in PETG; the clear-PETG wall thickness (1.0 mm) versus how much light it lets through.
