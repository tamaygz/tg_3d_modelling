#!/usr/bin/env python3
"""Make a project's bundle zip self-contained: add the shared lib/ files the model uses.

    python3 tools/bundle_with_lib.py projects/<name>/<name>_<rev>.zip

The skill's --bundle zips only the project folder, but models include ../../lib/... files.
This rewrites the zip in the repo layout (projects/<name>/... + lib/...) so the .scad opens
and renders straight from the unzipped folder. Run it after every `asm.py --bundle`.
"""
import re, sys, zipfile
from pathlib import Path

zpath = Path(sys.argv[1]).resolve()
proj = zpath.parent
root = next(d for d in [proj, *proj.parents] if (d / "lib").is_dir() and (d / "CLAUDE.md").exists())
prefix = proj.relative_to(root).as_posix()

with zipfile.ZipFile(zpath) as z:
    items = [(i, z.read(i.filename)) for i in z.infolist()]
if any(i.filename.startswith("lib/") for i, _ in items):
    sys.exit(f"{zpath.name}: already contains lib/")

deps, todo = set(), [p for p in proj.glob("*.scad")]
while todo:
    f = todo.pop()
    if f.suffix != ".scad":
        continue
    for m in re.finditer(r"^\s*(?:include|use)\s*<([^>]+)>", f.read_text(), re.M):
        d = (f.parent / m.group(1)).resolve()
        if root / "lib" in d.parents and d not in deps:
            deps.add(d); todo.append(d)

with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
    for i, data in items:
        z.writestr(f"{prefix}/{i.filename}", data)
    for d in sorted(deps):
        z.write(d, d.relative_to(root).as_posix())
print(f"{zpath.name}: {len(items)} project files under {prefix}/, {len(deps)} lib files added")
