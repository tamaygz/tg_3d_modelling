#!/usr/bin/env python3
"""Make a project's bundle zip self-contained: add the shared lib/ files the model uses.

    python3 tools/bundle_with_lib.py projects/<name>/<name>_<rev>.zip

The skill's --bundle zips only the project folder, but models include ../../lib/... files.
This rewrites the zip in the repo layout (projects/<name>/... + lib/...) so the .scad opens
and renders straight from the unzipped folder. tools/build.py runs it for you.
"""
import re, sys, zipfile
from pathlib import Path


def repo_root(start: Path) -> Path:
    return next(d for d in [start, *start.parents] if (d / "lib").is_dir() and (d / "CLAUDE.md").exists())


def lib_deps(proj: Path, root: Path):
    """lib files reached from the project's .scad files through include/use"""
    deps, todo = set(), list(proj.glob("*.scad"))
    while todo:
        f = todo.pop()
        if f.suffix != ".scad":
            continue
        for m in re.finditer(r"^\s*(?:include|use)\s*<([^>]+)>", f.read_text(), re.M):
            d = (f.parent / m.group(1)).resolve()
            if root / "lib" in d.parents and d not in deps:
                deps.add(d); todo.append(d)
    return sorted(deps)


def add_lib(zpath):
    zpath = Path(zpath).resolve()
    proj = zpath.parent
    root = repo_root(proj)
    prefix = proj.relative_to(root).as_posix()
    with zipfile.ZipFile(zpath) as z:
        items = [(i, z.read(i.filename)) for i in z.infolist()]
    if any(i.filename.startswith("lib/") for i, _ in items):
        print(f"{zpath.name}: already contains lib/"); return
    deps = lib_deps(proj, root)
    with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
        for i, data in items:
            z.writestr(f"{prefix}/{i.filename}", data)
        for d in deps:
            z.write(d, d.relative_to(root).as_posix())
    print(f"{zpath.name}: {len(items)} project files under {prefix}/, {len(deps)} lib files added")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    add_lib(sys.argv[1])
