#!/usr/bin/env python3
"""Build and test projects: the one command to run after changing a model or the library.

    python3 tools/build.py <project> [<project> ...] | all   [--test] [--no-outputs]

For each project (a folder under projects/ with <name>/<name>.scad):
  1. outputs  per-part STLs, print files, viewer and bundle zip (the OpenSCAD skill's asm.py --bundle --check),
              old bundle zips removed, the lib files added to the new zip, the browser configurator rebuilt.
  2. --test   every parameter variant in projects/<name>/tests.txt is built and checked: no errors, no failed
              checks, no parts in unexpected pieces, no open meshes, no overlaps deeper than 0.05 mm.
              tests.txt: one variant per line, `name = value; name = value` (# comments allowed). A line may end
              with `| ignore WORD ...` to accept problem lines containing WORD (e.g. `| ignore PIECES` for free
              artwork whose piece count changes with the text).

Needs the OpenSCAD skill's scripts (asm.py). They are found under ~/.claude/skills, or set OSCAD_SCRIPTS.
Exit code 0 = everything passed.
"""
import glob, os, re, subprocess, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import bundle_with_lib, make_configurator

ROOT = Path(__file__).resolve().parent.parent
BAD = re.compile(r"ERROR|CHECK FAIL|PIECES|NOT WATERTIGHT|NON-MANIFOLD|EMPTY or failed")
MAX_OVERLAP = 0.05      # mm; press fits and touching faces show up as ~0.00-0.01


def asm_py():
    d = os.environ.get("OSCAD_SCRIPTS")
    hits = [Path(d) / "asm.py"] if d else [Path(p) for p in glob.glob(str(Path.home() / ".claude/skills/**/openscad/scripts/asm.py"), recursive=True)]
    hits = [h for h in hits if h.exists()]
    if not hits:
        sys.exit("asm.py not found: set OSCAD_SCRIPTS to the OpenSCAD skill's scripts folder")
    return hits[0]


def run_asm(scad: Path, *flags):
    env = dict(os.environ, OSCAD_ENGINE="native")       # native OpenSCAD finds the bundled fonts
    r = subprocess.run([sys.executable, str(asm_py()), scad.name, *flags], cwd=scad.parent, env=env, capture_output=True, text=True)
    return r.stdout + r.stderr


def problems(out, allow_empty=()):
    """lines of asm.py output that mean a real problem"""
    bad = []
    lines = out.splitlines()
    for i, l in enumerate(lines):
        if BAD.search(l):
            if "EMPTY or failed" in l and (allow_empty is True or l.split(":")[0].strip() in allow_empty):
                continue
            bad.append(l.strip())
        m = re.match(r"OVERLAP (\S+) x (\S+):", l)
        if m:
            depths = [float(d) for d in re.findall(r"depth ~([\d.]+) mm", l)]
            j = i + 1
            while j < len(lines) and lines[j].startswith("   "):
                depths += [float(d) for d in re.findall(r"depth ~([\d.]+) mm", lines[j])]; j += 1
            if depths and max(depths) > MAX_OVERLAP:
                bad.append(f"OVERLAP {m.group(1)} x {m.group(2)}: {max(depths):.2f} mm deep")
    return bad


def build_outputs(name):
    proj = ROOT / "projects" / name
    scad = proj / f"{name}.scad"
    out = run_asm(scad, "--bundle", "--check", "--brief")
    bad = problems(out, allow_empty=True)               # optional parts may be empty in the default build
    zips = sorted(proj.glob(f"{name}_*.zip"), key=lambda p: p.stat().st_mtime)
    for old in zips[:-1]:
        old.unlink()
    if zips:
        bundle_with_lib.add_lib(zips[-1])
    else:
        bad.append("no bundle zip written")
    make_configurator.build(scad)
    for l in out.splitlines():
        if l.startswith(("checks:", "report:")):
            print("  " + l)
    return bad


def set_params(text, assigns):
    for k, v in assigns:
        text, n = re.subn(rf"^{re.escape(k)}\s*=\s*[^;]*;", f"{k} = {v};", text, count=1, flags=re.M)
        if n != 1:
            raise SystemExit(f"tests.txt: parameter {k!r} not found")
    return text


def run_tests(name):
    proj = ROOT / "projects" / name
    tests = proj / "tests.txt"
    if not tests.exists():
        print("  (no tests.txt)"); return []
    src = (proj / f"{name}.scad").read_text()
    failed = []
    tmp = proj / "_test.scad"
    try:
        for line in tests.read_text().splitlines():
            line = line.split("#")[0].strip()
            if not line:
                continue
            line, _, ignore = line.partition("| ignore ")
            line = line.strip()
            assigns = [tuple(s.strip() for s in a.split("=", 1)) for a in line.split(";") if a.strip()]
            tmp.write_text(set_params(src, assigns))
            bad = problems(run_asm(tmp, "--check", "--clash", "--brief"), allow_empty=True)
            bad = [b for b in bad if not any(w in b for w in ignore.split())]
            print(f"  {'FAIL' if bad else 'ok  '} {line}")
            for b in bad:
                print(f"       {b}")
            if bad:
                failed.append(line)
    finally:
        for p in proj.glob("_test*"):
            subprocess.run(["rm", "-rf", str(p)])
    return failed


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        sys.exit(__doc__)
    names = sorted(p.name for p in (ROOT / "projects").iterdir() if (p / f"{p.name}.scad").exists() and not p.name.startswith("_")) if args == ["all"] else args
    ok = True
    for name in names:
        print(f"== {name}")
        if "--no-outputs" not in sys.argv:
            bad = build_outputs(name)
            for b in bad:
                print("  PROBLEM " + b)
            ok &= not bad
        if "--test" in sys.argv:
            ok &= not run_tests(name)
    print("ALL OK" if ok else "PROBLEMS FOUND")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
