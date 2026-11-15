# Shared library

Reusable OpenSCAD building blocks. Projects live in `projects/<name>/`, so they reach these files as
`../../lib/...`. Each module documents its coordinate convention at the top of the file.

| File | Use with | What it gives you |
|---|---|---|
| `fits.scad` | `include` | ISO 286 fits: `fit_mid("H7", d)` for holes, `fit_mid("p6"/"k6"/"g6", d)` for shafts |
| `fonts.scad` | `use` | registers the bundled Liberation fonts; `font_for("serif" / "serif bold" / "sans" / "sans bold")` |
| `shapes.scad` | `use` | `plaque_2d(size, shape)` outlines: rect, rounded, chamfered, notched, arched, wave, scalloped. `profiled_slab(t, profile, r)` routed top edge: flat, roundover, chamfer, cove, ogee. `outline_groove()` single/double decorative groove. `keyhole_slot()` hanger. |
| `rail.scad` | `use` | T-rail + sliding marker system: `t_rail()` (flat, rounded or beveled top), `rail_slider()` (block, rounded, arrow or knob body; triangle, needle or no pointer), `stop_peg()` / `twin_peg()` stoppers (screw, dome, flat, hex or ball head). One `rail = [flange_w, flange_t, web_w, web_h]` spec keeps them fitting. |
| `attach.scad` | `use` | universal mounting: `attach_socket(size)` cutter for a host's back, `attach_plate(type, size)` in wall, keyhole, skadis, hook, magnet, stand or flat. Plates snap in. Sizes S 30×30, M 45×40, L 60×50 mm. |
| `led.scad` | `use` | LED strip system from one cross-section: `led_track()` (glue or screw mount, side wire exit), `led_diffuser()` (flat or dome, snaps in), `led_key()` joiner, `led_end_cap()` with cable hole, `led_corner()` + `led_corner_diffuser()` (inward, outward, flat), `led_recess()` cutter to sink a track into a host |
| `cable.scad` | `use` | `cable_clip()` (round, snap-in), `flat_cable_clip()`, `tie_mount()`, `cable_duct()` + `cable_duct_lid()` (snap), `cable_grommet()` (split); host cutters `cable_route(pts)`, `cable_notch()`, `cable_hole()`. Adhesive or M3-screw mounting |
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

## Attachment plates

One socket, many plates. The host cuts `attach_socket(size)` into its back face (z=0, body at z>0). Push a plate
straight in and it snaps: two flexible arms at each end (1.2 mm thick, bending 0.6 mm on the way in, under 1%
strain) carry bumps with a 45° lead-in that click into grooves in the socket's end walls. The plate's solid
corners carry the load, so hanging or standing cannot unsnap it. To remove a plate, put a flat screwdriver in the
notch below it and lever it out. Keep plate features out of the end strips (`attach_strip()`) where the arms are.

| Type | Mounts to | Notes |
|---|---|---|
| wall | wall, with 2 countersunk wood screws (Ø4.5, head 8.5) | screw the plate to the wall, then hang the host on it |
| keyhole | a screw or nail head in the wall | head up to Ø9 × 2 mm |
| skadis | IKEA Skådis pegboard | hooks 4.6 mm wide for 5 × 15 mm slots in a 5 mm board; M/L plates have two hooks 40 mm apart. Hosts with several plates keep them on the 40 mm grid. Community-measured sizes, not IKEA's: check against your board. |
| hook | a rod, rail, wire shelf or door of thickness `hook_gap` | |
| magnet | steel surfaces | pockets for round magnets (default 10 × 3), glued in from the wall side |
| stand | a table | two fins make a kickstand; `stand_reach` = plate centre to the host's bottom edge |
| flat | glue or double-sided tape | grooved back for a better bond |

Host rules: the socket needs `attach_socket_len(size)` of height (plate + 3 mm pry notch) and `ATTACH_T` (4.5 mm) of depth, plus a floor
behind it. Its ceiling is printed as a bridge as wide as the socket (40–65 mm) when the host prints back-down;
the plate has 0.2 mm headroom. Test the fit first with `projects/attachments` (coupon + plate + key).

## LED strips

`spec = led_spec(led_strip_dims("10mm"), "shallow")` sets the cross-section; pass it to every LED module.

| Strip preset | Size used (w × t) |
|---|---|
| 5mm, 8mm | 5 × 2, 8 × 2 |
| 10mm, 12mm | 10 × 2.5, 12 × 2.5 |
| 8mm IP65, 10mm IP65 | 10 × 4.5, 12 × 4.8 (silicone coated) |
| custom | your own [w, t] |

These are typical values; strips vary by maker, so check the datasheet. The seat adds 0.3 mm play per side.
"shallow" puts the diffuser 3.5 mm above the strip; "deep" puts it 8 mm above, for less visible LED dots.

- **Joining:** a 20 mm key slides into the T-slot under both pieces.
- **Corners:** inward (inside edge, opening faces the corner), outward (wraps over an outside edge), flat (turns
  in the mounting plane: cut the strip and bridge it with an L-connector or wires there). Corners have 12 mm straight
  ends so keys fit. Matching corner diffusers come from the same sweep.
- **Diffusers:** print them in clear or natural PETG; the legs bend 0.25 mm as they click into the wall grooves.
- **Embedding:** `led_recess()` cuts a slot so a track sits flush in a host, e.g. lighting behind a scoreboard's numbers.

## Cables

Mounting parts sit on z=0 with the cable along +X; `mount="screw"` adds a countersunk M3 tab. The duct lid's
legs bend 0.25 mm over ramped beads. Host cutters work like `attach_socket()`: the host face is z=0 and its
body is z>0. `cable_route([[x,y], ...], w, d)` cuts a groove along a polyline, for example in a board's back
from an LED track to the edge.

## Fonts

`fonts/` holds Liberation Serif and Sans, regular and bold (SIL Open Font License). Bundling them means
text renders the same on every machine and in the browser configurator. The WebAssembly engine finds
no system fonts, so build text models natively (`OSCAD_ENGINE=native`) when using the skill scripts.
