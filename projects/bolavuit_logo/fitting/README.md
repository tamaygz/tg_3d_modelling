# How the rebuilt logo was fitted

The rebuilt version of the logo uses the generic elements in `lib/emblem.scad`. Their parameters were fitted
to the exact artwork (`lib/emblems/bolavuit_data.scad`, converted from `reference/bolavuit.svg`) by maximising
the overlap (IoU) between a Python model of each element and the exact shape. The Python models use the
same formulas as the OpenSCAD modules, and `compare_scad.py` re-measures the OpenSCAD result to prove it.

Run from this folder with `python3 <script>` (needs numpy, scipy, Pillow; temporary files go to the scratchpad
path set in the scripts).

| Step | Script | Result |
|---|---|---|
| Exact artwork as polygons | `bvdata.py` (uses `tools/svg_to_scad.py`) | 29 regions |
| Leaves: shape, size, position, angle | `fitleaves.py` | IoU 0.945–0.986 per leaf; width ∝ sin(πt)^0.62, 27% of length, straight |
| Two bottom leaves (merged with the banner outline in the SVG) | `fitlow.py` | IoU 0.971 (visible parts) |
| Generic wreath (groups of 1 inner + 2 outer leaves) | `fitlaurel2.py` | IoU 0.747 for the whole branch; the fitted list reaches 0.963 |
| Banner pieces: band, tails, folds, strip | `fitband.py`, `fittail2.py`, `fitpieces.py` | band 0.963, tail 0.930, fold 0.904 (interiors) |
| Whole banner incl. bow, legs, ears, stroke | `fitjoint2.py` | see the project log |
| Ball: ring, disc, crescent | `fitball.py` | ring 0.82 (20 px stroke), disc exact circle, crescent 0.90 |
| Numeral "8" font | `fit8.py` | Lato Bold 0.87 (best of 32 sans/serif fonts) |
| Lettering font | `fontaffine.py` → `font_ranking.log` | Source Serif 4 Bold 0.861, Eczar 0.858 … (≈120 fonts) |
| Letter placement | `letterfit_ss4.py`, `pairfit.py` | B 0.86, O 0.89, L+A 0.86, V+U 0.86, I 0.95, T 0.90 |
| Write `lib/emblems/bolavuit_rebuilt.scad` | `export_scad.py` | |
| Check in OpenSCAD | `compare_scad.py`, `overlay.py` | per element and whole logo |

Font identification: the lettering is warped (verticals lean towards the middle, the baseline is arched), and no
freely licensed font matches it closely. The closest are Source Serif 4, Eczar, Roboto Serif and Bookman Demi
Italic (the last fits B and O best but not I and T). Rockwell Extra Bold (suggested) scored 0.72: a slab serif with a
round O, unlike the logo's bracketed serifs and narrow oval O. If the original font turns up, add its .ttf to
`lib/fonts/`, run `letterfit_ss4.py` / `pairfit.py` with it and re-export.
