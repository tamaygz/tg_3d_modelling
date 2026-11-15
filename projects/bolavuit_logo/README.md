# Bola Vuit logo

The Bola Vuit logo (8-ball, laurel wreath, ribbon banner, lettering) as a printable 2-colour plaque.
Open `bolavuit_logo_configurator.html` to set the size, background and style, and download the STLs.

| Setting | Options |
|---|---|
| `source` | **exact** (default): the original artwork, element by element, from `reference/bolavuit.svg`. **rebuilt**: the same design from the generic elements in `lib/emblem.scad`, fitted to the original (0.90 overlap overall); then leaf layout, banner style, bow, text and ball number can be changed |
| `logo_width` | width of the artwork in mm (lines are 0.95 mm at 120 mm; keep it ≥ 102 mm for a 0.4 mm nozzle) |
| `show_ball`, `show_wreath`, `show_banner`, `show_text` | use any element on its own |
| `base_shape` | silhouette (follows the outline), square (the original artboard), round, none |
| `art_style` | raised (white on a black base) or inlay (flush, 2-colour) |

**Exact means exact:** rasterised at the original's 1809 × 1716 px, the exact version and `reference/bolavuit.png`
differ only in edge anti-aliasing. No pixel differs further than 2 px from an edge.

**Rebuilt, element by element** (overlap with the exact artwork, measured on the OpenSCAD output):
leaves 0.95–0.99 each, ball crescent 0.90, numeral 0.87, lettering 0.85, banner pieces 0.90–0.96
(the thin outlines score lower on overlap but sit within a few px), whole logo **0.90**. How it was fitted, with
all scripts and results: [`fitting/`](fitting/README.md).

**Fonts:** the original lettering font could not be identified among about 120 freely licensed fonts (it is warped
and its exact letterforms do not match any of them). The closest is **Source Serif 4 Bold**, which the rebuilt
version uses; the "8" is closest to **Lato Bold**. Rockwell Extra Bold was tested and does not match (0.72): it is a
slab serif with a round O. If the real font turns up, see `fitting/README.md` to refit the letters with it.

The elements live in the shared library, so other projects can use them: [`lib/emblems/bolavuit.scad`](../../lib/emblems/bolavuit.scad)
(exact) and [`lib/emblem.scad`](../../lib/emblem.scad) (generic generators).

Files: `bolavuit_logo.scad`, `reference/` (original SVG and PNG), `bolavuit_logo_print/` (base + artwork 3MF),
`bolavuit_logo_configurator.html`, `bolavuit_logo_348f127.zip` (bundle with lib).
