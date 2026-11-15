# tg_3d_modelling

Parametric 3D models (OpenSCAD) for 3D printing. Each model has its own folder under `projects/`, with the
`.scad` source, a README, a design log, ready-to-print STL/3MF files and an interactive `.html` viewer.

| Project | Description |
|---|---|
| [scoreboard](projects/scoreboard) | Wall scoreboard with sliding marker pins: configurable players, score range and steps |

Each project also has a `<name>_configurator.html`. Open it in a browser to change the parameters and download
STLs, with no install needed. Build one with `python3 tools/make_configurator.py projects/<name>/<name>.scad`.

Shared building blocks (board shapes, routed edges, rails and sliders, number scales, fonts) live in
[`lib/`](lib/README.md). Use them from new projects.

Tooling: OpenSCAD (`setup_env.sh` installs it plus fonts). Notes for Claude live in `CLAUDE.md`.
