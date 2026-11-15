# Shared library

Reusable OpenSCAD building blocks. Projects live in `projects/<name>/`, so they reach these files as
`../../lib/...`. Each module documents its coordinate convention at the top of the file.

| File | Use with | What it gives you |
|---|---|---|
| `fits.scad` | `include` | ISO 286 fits: `fit_mid("H7", d)` for holes, `fit_mid("p6"/"k6"/"g6", d)` for shafts |
| `fonts.scad` | `use` | registers the bundled Liberation fonts; `font_for("serif" / "serif bold" / "sans" / "sans bold")` |
| `shapes.scad` | `use` | `plaque_2d(size, shape)` outlines: rect, rounded, chamfered, notched, arched, wave, scalloped. `profiled_slab(t, profile, r)` routed top edge: flat, roundover, chamfer, cove, ogee. `outline_groove()` single/double decorative groove. `keyhole_slot()` hanger. |
| `rail.scad` | `use` | T-rail + sliding marker system: `t_rail()` (flat, rounded or beveled top), `rail_slider()` (block, rounded, arrow or knob body; triangle, needle or no pointer), `stop_peg()` / `twin_peg()` stoppers (screw, dome, flat, hex or ball head). One `rail = [flange_w, flange_t, web_w, web_h]` spec keeps them fitting. |
| `scale.scad` | `use` | number scales: `number_row_2d()` with dot, bar, diamond or no separators; `plate_2d()`, `border_2d()`; `plate_body()` + `plate_art()` for 2-colour inlay, raised or engraved numbers |

Each style module also defines its option list (`PLAQUE_SHAPES`, `EDGE_PROFILES`, `MARKER_STYLES`…),
so a model can copy them into its `// [a, b, c]` Customizer comment.

## Example

```scad
use <../../lib/shapes.scad>
use <../../lib/rail.scad>
rail = [10, 2, 5, 3.2];
profiled_slab(12, "ogee", 3) plaque_2d([200, 60], "notched", r=10);
translate([0, 0, 12]) {
    t_rail(-90, 90, rail, "beveled", holes=[-85, 85]);
    rail_slider(rail, style="arrow");
    for (x=[-85, 85]) translate([x, 0, rail_h(rail)]) stop_peg(style="ball", shaft_l=8);
}
```

## Fonts

`fonts/` holds Liberation Serif and Sans, regular and bold (SIL Open Font License). Bundling them means
text renders the same on every machine and in the browser configurator. The WebAssembly engine finds
no system fonts, so build text models natively (`OSCAD_ENGINE=native`) when using the skill scripts.
