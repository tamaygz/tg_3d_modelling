# LED kit

LED strip tracks and cable parts from [`lib/led.scad` and `lib/cable.scad`](../../lib/README.md#led-strips).
Open `led_kit_configurator.html`, pick your strip, track, corner and cable sizes, and download the STLs.

| Part | Notes |
|---|---|
| Track | channel for the strip; glue it (tape) or screw it (M3 countersunk, every 100 mm); optional side wire exit |
| Diffuser | snaps into the track's wall grooves; flat or dome; print in clear or natural PETG |
| Joiner key | slides into the T-slot under two pieces to line them up |
| End cap | closes a track end, with a hole for the strip's wires |
| Corner + corner diffuser | inward (inside edge), outward (outside edge), flat (turn in the mounting plane) |
| Cable clip / flat cable clip | round cable (snap-in) or flat lead (slide under the lip) |
| Zip-tie mount, cable duct + lid, grommet | routing; the grommet is split so you can add it with the cable already in place |

Strip sizes are typical values; measure your strip, or set `strip_type = custom` and `custom_strip = [w, t]`.
For a flat corner, cut the strip at a cut mark and bridge the corner with a solderless L-connector or two short wires.

Files: `led_kit.scad`, `led_kit_print/` (oriented for printing), `led_kit_configurator.html`, `led_kit_<rev>.zip` (bundle with lib).

Rebuild and check with `python3 tools/build.py led_kit --test` (variants in `tests.txt`).
