#!/usr/bin/env python3
"""One self-contained .scad file from a project and the library files it includes or uses.

    python3 tools/flatten_scad.py projects/custombox/custombox.scad            # -> custombox_makerworld.scad
    python3 tools/flatten_scad.py projects/custombox/custombox.scad out.scad

For hosts that take a single file, such as MakerWorld's Parametric Model Maker (its own "Customize" button).
Layout of the result: the project's header and Customizer settings first (the customizer stops at the first
module or function), then `/* [Hidden] */` and every library file once, then the rest of the project.

`use` keeps a library's variables and top-level code private; inlined, they become global. So the tool refuses
(and says why) when that would change the model: a top-level name assigned in two files, a special variable
($fn, ...) set at a library's top level, or a library that draws something at its top level. Check the result
by rendering both files and comparing (the tool does a quick check with --verify).
"""
import re, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INC = re.compile(r'^\s*(include|use)\s*<([^>]+)>\s*;?\s*$')
ASSIGN = re.compile(r'^([A-Za-z_$][A-Za-z0-9_]*)\s*=(?!=)')
DEF = re.compile(r'^\s*(module|function)\b')


def statements(text):
    """top-level statements of OpenSCAD source: [(line number, text)], comments and strings blanked"""
    src = re.sub(r"/\*.*?\*/", lambda m: re.sub(r"[^\n]", " ", m.group(0)), text, flags=re.S)
    src = re.sub(r"//[^\n]*", "", src)
    src = re.sub(r'"(\\.|[^"\\\n])*"', '""', src)
    out, cur, start, depth, line = [], [], None, 0, 0
    for ch in src:
        if ch == "\n":
            line += 1
        if start is None and not ch.isspace():
            start = line
        if start is not None:
            cur.append(ch)
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
            if ch == "}" and depth == 0 and "".join(cur).lstrip().startswith("module"):
                out.append((start, "".join(cur).strip())); cur, start = [], None
        elif ch == ";" and depth == 0:
            out.append((start, "".join(cur).strip())); cur, start = [], None
    return out


def collect(path, seen, order):
    """depth-first list of library files (each once), in the order OpenSCAD would need them"""
    for line in path.read_text().split("\n"):
        m = INC.match(line)
        if m:
            dep = (path.parent / m.group(2)).resolve()
            if dep not in seen:
                seen.add(dep)
                collect(dep, seen, order)
                order.append(dep)


def lib_body(path):
    """the file without its include/use lines"""
    return [l for l in path.read_text().split("\n") if not INC.match(l)]


def check(main, libs):
    problems, owner, texts = [], {}, {}            # identical duplicate definitions are harmless
    for f in [main] + libs:
        text = "\n".join("" if INC.match(l) else l for l in f.read_text().split("\n"))
        for i, st in statements(text):
            if INC.match(st):
                continue
            d = re.match(r"^(module|function)\s+([A-Za-z_][A-Za-z0-9_]*)", st)
            if d:
                key = d.group(1) + " " + d.group(2)
                norm = re.sub(r"\s+", " ", st)
                if key in owner and owner[key] != f and texts.get(key) != norm:
                    problems.append(f"{key} is defined in {owner[key].relative_to(ROOT)} and {f.relative_to(ROOT)}")
                owner.setdefault(key, f); texts.setdefault(key, norm)
                continue
            m = ASSIGN.match(st)
            if m:
                name = m.group(1)
                if name.startswith("$") and f != main:
                    problems.append(f"{f.relative_to(ROOT)}:{i+1}: sets {name} at its top level (would apply to everything)")
                elif name in owner and owner[name] != f:
                    problems.append(f"{name} is assigned in {owner[name].relative_to(ROOT)} and {f.relative_to(ROOT)}")
                owner.setdefault(name, f)
            elif f != main:
                problems.append(f"{f.relative_to(ROOT)}:{i+1}: draws at its top level: {st[:60]}")
    return problems


def flatten(main, out):
    seen, libs = set(), []
    collect(main, seen, libs)
    problems = check(main, libs)
    if problems:
        sys.exit("flatten_scad: cannot inline safely:\n  " + "\n  ".join(problems))
    lines = main.read_text().split("\n")
    hidden = next((i for i, l in enumerate(lines) if l.strip().startswith("/* [Hidden] */")), None)
    if hidden is None:
        sys.exit("flatten_scad: the project has no /* [Hidden] */ section")
    head = [l for l in lines[:hidden] if not INC.match(l)]
    tail = lines[hidden:]
    rel = lambda p: p.relative_to(ROOT).as_posix()
    parts = [f"// {main.name} with its library inlined into one file (tools/flatten_scad.py); do not edit:",
             f"// change {rel(main)} and lib/ in https://github.com/tamaygz/tg_3d_modelling and regenerate.",
             "// Licence: CC BY-NC-SA 4.0 (see LICENSE in the repository)."] + head
    parts += ["/* [Hidden] */", "", "// ======================= library (inlined) ======================="]
    for f in libs:
        parts += ["", f"// ----------------------- {rel(f)} -----------------------"] + lib_body(f)
    parts += ["", f"// ======================= {main.name}: the rest ======================="] + tail
    out.write_text("\n".join(parts) + "\n")
    return libs


def render(path, defs, tmp):
    stl = Path(tmp) / (path.stem + ".stl")
    cmd = ["openscad", "-o", str(stl), "--export-format", "asciistl"] + sum((["-D", d] for d in defs), []) + [str(path)]
    r = subprocess.run(cmd, cwd=path.parent, capture_output=True, text=True)
    if not stl.exists():
        raise RuntimeError(r.stderr[-400:])
    return sorted(l.strip() for l in stl.read_text().split("\n") if l.strip().startswith("vertex"))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        sys.exit(__doc__)
    src = Path(args[0]).resolve()
    out = Path(args[1]).resolve() if len(args) > 1 else src.with_name(src.stem + "_makerworld.scad")
    libs = flatten(src, out)
    print(f"{out.relative_to(ROOT)}: {len(libs)} library files inlined, {out.stat().st_size // 1024} kB")
    if "--verify" in sys.argv:
        variants = [['part="all"']] + [v.split(";") for v in [a[len("--variant="):] for a in sys.argv if a.startswith("--variant=")]]
        with tempfile.TemporaryDirectory() as tmp:
            for defs in variants:
                defs = [d.strip() for d in defs if d.strip()]
                a, b = render(src, defs, tmp), render(out, defs, tmp)
                print(("  same geometry" if a == b else "  DIFFERENT geometry") + f" ({len(a)//3} triangles): {'; '.join(defs)}")
                if a != b:
                    sys.exit(1)


if __name__ == "__main__":
    main()
