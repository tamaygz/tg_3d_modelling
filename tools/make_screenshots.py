#!/usr/bin/env python3
"""Render the pictures used in the READMEs.

    python3 tools/make_screenshots.py <project> [<project> ...] | lib | all

Each project (and lib/examples) lists its pictures in a `shots.txt`, one per line:

    image.png | name = value; name = value | rx,rz | model.scad

  image.png   written to <folder>/images/
  assignments parameters for this picture (may be empty); passed to OpenSCAD with -D
  rx,rz       camera: tilt from above (0 = top view, 90 = from the side) and turn (default 60,25);
              add `,ortho` for a view without perspective
  model.scad  optional; default is the project's own model (lib/examples: required)

Uses OpenSCAD's preview renderer (fast) under xvfb, so it needs `openscad`, `xvfb-run` and ImageMagick's `convert`.
Pictures are cropped to the model and reduced to 96 colours to keep the repository small. Re-run it after a visible change to a model.
"""
import subprocess, sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SIZE = "900,640"


def shots_of(folder: Path, default_scad):
    f = folder / "shots.txt"
    if not f.exists():
        return []
    out = []
    for line in f.read_text().splitlines():
        line = line.split("#")[0].strip()
        if not line:
            continue
        cols = [c.strip() for c in line.split("|")] + ["", "", ""]
        scad = folder / cols[3] if cols[3] else default_scad
        if scad is None:
            sys.exit(f"{f}: '{cols[0]}' needs a model file in the fourth column")
        out.append((folder, cols[0], cols[1], cols[2] or "60,25", scad))
    return out


def render(shot):
    folder, name, assigns, view, scad = shot
    img = folder / "images" / name
    img.parent.mkdir(exist_ok=True)
    v = [x.strip() for x in view.split(",")]
    cmd = ["xvfb-run", "-a", "openscad", "-o", str(img), f"--imgsize={SIZE}", "--viewall", "--autocenter",
           f"--camera=0,0,0,{v[0]},0,{v[1]},0", "--colorscheme=Tomorrow"]
    if "ortho" in v:
        cmd.append("--projection=o")
    for a in assigns.split(";"):
        if a.strip():
            cmd += ["-D", a.strip().replace(" = ", "=")]
    r = subprocess.run(cmd + [scad.name], cwd=scad.parent, capture_output=True, text=True)
    if not img.exists() or "ERROR" in r.stderr:
        return f"FAILED {img.relative_to(ROOT)}: {(r.stderr.strip().splitlines() or ['no picture'])[-1][:200]}"
    subprocess.run(["convert", str(img), "-trim", "+repage", "-bordercolor", "#f8f8f8", "-border", "24", "-strip", "-colors", "96", str(img)], check=False)   # crop to the model
    return f"{img.relative_to(ROOT)}  ({img.stat().st_size//1024} kB)"


def main():
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    projects = sorted(p.name for p in (ROOT / "projects").iterdir() if (p / "shots.txt").exists())
    names = projects + ["lib"] if args == ["all"] else args
    shots = []
    for n in names:
        if n == "lib":
            shots += shots_of(ROOT / "lib" / "examples", None)
        else:
            shots += shots_of(ROOT / "projects" / n, ROOT / "projects" / n / f"{n}.scad")
    if not shots:
        sys.exit("no shots.txt found for " + ", ".join(names))
    with ThreadPoolExecutor(4) as ex:
        results = list(ex.map(render, shots))
    print("\n".join(results))
    sys.exit(1 if any(r.startswith("FAILED") for r in results) else 0)


if __name__ == "__main__":
    main()
