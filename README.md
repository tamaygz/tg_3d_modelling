# tg_3d_modelling

Parametric 3D models (OpenSCAD) for 3D printing, built from a shared library of reusable parts.

## Projects

| Project | Description |
|---|---|
| [scoreboard](projects/scoreboard) | Wall scoreboard with sliding marker pins: configurable players, score range, steps, styles and mounting |
| [snooker_guide](projects/snooker_guide) | Wall plaque showing the snooker table setup, ball positions and points, in multi-colour relief |
| [bolavuit_logo](projects/bolavuit_logo) | Bola Vuit logo as a 2-colour plaque: exact from the original SVG, or rebuilt from adjustable elements |
| [led_kit](projects/led_kit) | LED strip tracks, diffusers, joiners, end caps, corners, and cable clips, ducts and grommets |
| [attachments](projects/attachments) | Universal snap-in mounting plates (wall, keyhole, Skådis, hook, magnet, stand, glue, ceiling) and a test coupon |

Every project folder has the same contents:

| File | What it is |
|---|---|
| `<name>.scad` | the model; all settings at the top, in OpenSCAD Customizer format |
| `<name>_configurator.html` | open in a browser to change settings, see the model in 3D and download STLs (no install) |
| `<name>_print/` | print-ready files, oriented for the bed (STL, multi-colour 3MF) |
| `<name>_parts/` | each part as modelled, in its assembled position |
| `<name>_<rev>.zip` | everything bundled, including the library files the model needs |
| `<name>.html` | 3D viewer of the default build |
| `README.md`, `<name>_log.md` | how to use it; design log with decisions, print feedback and open questions |
| `tests.txt` | parameter variants that are built and checked automatically |

## Library

[`lib/`](lib/README.md) holds the building blocks all projects share: core atoms, board shapes and routed edges, rails
and sliders, number scales, snap-in attachment plates, LED strip tracks, cable parts, emblem and logo elements, fits
and bundled fonts. Projects only lay these out; anything reusable goes into the library.

## Tools

| Command | What it does |
|---|---|
| `python3 tools/build.py <project> --test` | rebuild a project's outputs (parts, print files, bundle, configurator) and check every variant in its `tests.txt`; `all` does every project |
| `python3 tools/make_configurator.py projects/<name>/<name>.scad` | only rebuild the browser configurator |
| `python3 tools/svg_to_scad.py art.svg out.scad --prefix XX` | convert SVG artwork into exact OpenSCAD polygons |
| `python3 tools/font_metrics.py` | regenerate the font width tables after adding a font to `lib/fonts/` |
| `python3 tools/artfit.py overlay exported.svg reference.png out.png` | compare a model's 2D output with reference artwork |
| `bash setup_env.sh` | install the native Linux build toolchain and helper |
| `./setup_env.ps1` | install the Windows build helper and Python environment |

`build.py` uses the OpenSCAD skill's `asm.py` (found under `~/.claude/skills`, or set `OSCAD_SCRIPTS`).
The setup scripts install helper v2.4.0 and an isolated Python environment. The Linux script uses `apt-get`
and requires permission to install packages. On Windows, install Git, Python and OpenSCAD first, then run:

```powershell
./setup_env.ps1
$env:PATH = 'C:\Program Files\OpenSCAD;C:\Program Files\Git\usr\bin;' + $env:PATH
$env:OSCAD_SCRIPTS = "$HOME\.claude\skills\openscad-skill\openscad\scripts"
& "$env:LOCALAPPDATA\tg_3d_modelling\build-venv\Scripts\python.exe" tools/build.py scoreboard --test
```

Adjust the paths if OpenSCAD or Git is installed elsewhere. On Linux, run builds with
`~/.local/share/tg_3d_modelling/build-venv/bin/python` after setup.

## Adding a project

1. Copy `projects/_template/` to `projects/<name>/` and rename its files to `<name>.*`.
2. Replace the model. Keep the layout: library includes, `part`, Customizer sections, `/* [Hidden] */` with derived
   values, the `parts` / `checks` / `report` tables, then 2D shapes, solids and the assembly.
3. Use the library first (`lib/README.md`). Move anything reusable you write into it.
4. List the parameter combinations worth checking in `tests.txt`.
5. Run `python3 tools/build.py <name> --test`, fill in the README and log, and add the project to the table above
   and to `CLAUDE.md`.
