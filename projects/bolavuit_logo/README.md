# Bola Vuit logo

The Bola Vuit logo (8-ball, laurel wreath, ribbon banner, lettering) as a printable 2-colour plaque.
Open `bolavuit_logo_configurator.html` to set the size, background and style, and download the STLs.

| Setting | Options |
|---|---|
| `source` | **exact** (default): the original artwork, element by element, from `reference/bolavuit.svg`. **rebuilt**: the same design from adjustable generic elements (leaf count and shape, banner style, font, text, ball number) |
| `logo_width` | width of the artwork in mm (lines are 0.95 mm at 120 mm; keep it ≥ 102 mm for a 0.4 mm nozzle) |
| `show_ball`, `show_wreath`, `show_banner`, `show_text` | use any element on its own |
| `base_shape` | silhouette (follows the outline), square (the original artboard), round, none |
| `art_style` | raised (white on a black base) or inlay (flush, 2-colour) |

**Exact means exact:** rasterised at the original's 1809 × 1716 px, the exact version and `reference/bolavuit.png`
differ only in edge anti-aliasing. No pixel differs further than 2 px from an edge.

The elements live in the shared library, so other projects can use them: [`lib/emblems/bolavuit.scad`](../../lib/emblems/bolavuit.scad)
(exact) and [`lib/emblem.scad`](../../lib/emblem.scad) (generic generators).

Files: `bolavuit_logo.scad`, `reference/` (original SVG and PNG), `bolavuit_logo_print/` (base + artwork 3MF),
`bolavuit_logo_configurator.html`, `bolavuit_logo_70c1615.zip` (bundle with lib).
