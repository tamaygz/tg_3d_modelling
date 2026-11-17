#!/usr/bin/env python3
"""Build a standalone browser configurator for a parametric OpenSCAD model.

    python3 tools/make_configurator.py projects/<name>/<name>.scad

Writes projects/<name>/<name>_configurator.html. The page embeds the model, every file it
includes/uses (shared lib/ files, .ttf fonts) and runs the real OpenSCAD (WebAssembly, loaded from
a CDN) in the browser, so the preview always matches the .scad. Re-run after editing the model or lib/.

What it reads from the .scad (OpenSCAD Customizer conventions, so the built-in Customizer works too):
  * sections: `/* [Section name] */`. Reading stops at `/* [Hidden] */` (or `// derived`, or the
    first module/function/parts table). Older `// ---- Section ----` headings also work.
  * parameters: `name = value;` with the description on the `//` line(s) just above, and an
    optional trailing `// [a, b, c]` (dropdown) or `// [min:step:max]` (number limits).
    A trailing comment without brackets is used as the description. `part` and `$` variables are skipped.
  * parts: the `parts = [ ["id","Label","note",[dx,dy,dz],"#colour", ...], ... ]` table, if present.
    Each part is rendered separately with -D part="id". Without a table the whole model is one part.
"""
import base64, json, re, sys
from pathlib import Path

OPENSCAD_JS = "https://cdn.jsdelivr.net/npm/openscad-wasm-prebuilt@1.2.0/dist/openscad.js"
THREE = "https://cdn.jsdelivr.net/npm/three@0.160.0"
TEMPLATE = (Path(__file__).parent / "configurator_template.html").read_text()


def repo_root(start: Path) -> Path:
    for d in [start, *start.parents]:
        if (d / "lib").is_dir() and (d / "CLAUDE.md").exists():
            return d
    return start


def collect_files(main: Path, root: Path):
    files, todo = {}, [main.resolve()]
    while todo:
        f = todo.pop()
        rel = f.relative_to(root).as_posix()
        if rel in files:
            continue
        if f.suffix.lower() in (".ttf", ".otf", ".stl", ".png"):
            files[rel] = {"b64": base64.b64encode(f.read_bytes()).decode()}
            continue
        text = f.read_text()
        files[rel] = {"text": text}
        refs = [m.group(1) for m in re.finditer(r"^\s*(?:include|use)\s*<([^>]+)>", text, re.M)]
        refs += [m.group(1) for m in re.finditer(r'import\s*\(\s*(?:file\s*=\s*)?"([^"]+)"', text)]   # SVG/DXF/STL artwork
        for ref in refs:
            dep = (f.parent / ref).resolve()
            if root not in dep.parents:
                sys.exit(f"refusing to embed {ref}: outside {root}")
            if not dep.exists():
                sys.exit(f"missing dependency {dep}")
            todo.append(dep)
    return files


def parse_options(spec):
    """'[a, b, c]' -> ('select', [...]); '[0:1:10]' or '[0:10]' -> ('range', [min, step, max])"""
    body = spec.strip()[1:-1]
    if re.fullmatch(r"\s*-?[\d.]+\s*(:\s*-?[\d.]+\s*){1,2}", body):
        n = [float(v) for v in body.split(":")]
        return ("range", [n[0], n[1], n[2]] if len(n) == 3 else [n[0], None, n[1]])
    vals = [v.strip().strip('"') for v in body.split(",") if v.strip()]
    return ("select", [v.split(":")[0] for v in vals])   # Customizer also allows value:label


def parse_params(text):
    params, section, desc = [], "Parameters", []
    for line in text.splitlines():
        s = line.strip()
        if re.match(r"/\*\s*\[\s*Hidden\s*\]\s*\*/", s, re.I) or re.match(r"//\s*derived", s) \
                or re.match(r"(module|function)\s", s) or re.match(r"(parts|checks|travel|report)\s*=", s):
            break
        h = re.match(r"/\*\s*\[\s*(.+?)\s*\]\s*\*/", s) or re.match(r"//\s*-{2,}\s*(.+?)\s*-{2,}\s*$", s)
        if h:
            section = h.group(1)[:1].upper() + h.group(1)[1:]
            desc = []
            continue
        if s.startswith("//"):
            desc.append(s[2:].strip())
            continue
        m = re.match(r"^([A-Za-z_]\w*)\s*=\s*(.+?);\s*(?://\s*(.*))?$", s)
        if not m:
            desc = []
            continue
        name, raw, trail = m.group(1), m.group(2).strip(), (m.group(3) or "").strip()
        comment, opts = " ".join(desc), None
        desc = []
        if name == "part":
            continue
        om = re.match(r"^(\[[^\]]*\])\s*(.*)$", trail)
        if om:
            opts = parse_options(om.group(1))
            comment = comment or om.group(2)
        elif trail:
            comment = comment or trail
        if raw in ("true", "false"):
            kind = "bool"
        elif re.fullmatch(r"-?\d+(\.\d+)?", raw):
            kind = "number"
        elif re.fullmatch(r'"[^"]*"', raw):
            kind = "string"
        else:
            kind = "expr"
        p = {"name": name, "raw": raw, "type": kind, "comment": comment, "section": section}
        if opts and opts[0] == "select":
            p["options"] = opts[1]
        elif opts and opts[0] == "range":
            p["range"] = opts[1]
        params.append(p)
    return params


def eval_parts(scad: Path):
    """Ask OpenSCAD for the evaluated `parts` table (works when the table is built with expressions)."""
    import json as _json, subprocess, tempfile
    tmp = scad.with_name("_parts_probe.scad")
    # $all_parts: the library then lists parts that only exist with some settings too (slide track, fin, ball joint)
    tmp.write_text(f'$all_parts = true;\ninclude <{scad.name}>\necho(PARTS_JSON=parts);\n')
    try:
        out = subprocess.run(["openscad", "-o", str(tmp.with_suffix(".echo")), "-D", 'part="__none__"', str(tmp)],
                             capture_output=True, text=True, timeout=300)
        txt = out.stdout + out.stderr
        echo = tmp.with_suffix(".echo")
        if echo.exists():
            txt += echo.read_text(); echo.unlink()
        m = re.search(r"PARTS_JSON = (\[.*\])\s*$", txt, re.M)
        if not m:
            return None
        rows = _json.loads(m.group(1).replace("undef", "null"))
    except Exception:
        return None
    finally:
        tmp.unlink(missing_ok=True)
    parts, pal = [], ["#9aa4ad", "#c9a13b", "#7a2e1c", "#3f6f8f", "#555555"]
    for r in rows:
        if not r or not isinstance(r[0], str) or r[0].startswith("hw_"):
            continue
        vec = r[3] if len(r) > 3 and isinstance(r[3], list) else [0, 0, 0]
        col = r[4] if len(r) > 4 and isinstance(r[4], str) and r[4].startswith("#") else pal[len(parts) % len(pal)]
        parts.append({"id": r[0], "label": r[1] if len(r) > 1 and r[1] else r[0], "color": col,
                      "explode": [float(v) for v in vec]})
    return parts


def parse_parts(text):
    m = re.search(r"^parts\s*=\s*\[(.*?)^\];", text, re.M | re.S)
    if not m:
        return [{"id": "all", "label": "Model", "color": "#9aa4ad", "explode": [0, 0, 0]}]
    parts, pal = [], ["#9aa4ad", "#c9a13b", "#7a2e1c", "#3f6f8f", "#555555"]
    for row in re.finditer(r'\[\s*"([^"]+)"\s*(?:,\s*"([^"]*)")?\s*(?:,\s*"[^"]*")?\s*(?:,\s*\[([^\]]*)\])?\s*(?:,\s*"(#[0-9a-fA-F]{3,8})")?', m.group(1)):
        pid, label, vec, col = row.groups()
        if pid.startswith("hw_"):
            continue
        try:
            ex = [float(v) for v in (vec or "0,0,0").split(",")]
        except ValueError:
            ex = [0, 0, 0]
        parts.append({"id": pid, "label": label or pid, "color": col or pal[len(parts) % len(pal)], "explode": ex})
    return parts


def build(scad):
    scad = Path(scad)
    text = scad.read_text()
    first = text.splitlines()[0] if text else ""
    title = re.sub(r"^//\s*", "", first) if first.startswith("//") else scad.stem
    root = repo_root(scad.resolve().parent)
    model = {
        "name": scad.stem,
        "main": scad.resolve().relative_to(root).as_posix(),
        "title": title,
        "files": collect_files(scad, root),
        "params": parse_params(text),
        "parts": eval_parts(scad) or parse_parts(text),
    }
    html = TEMPLATE.replace("__MODEL_JSON__", json.dumps(model).replace("</", "<\\/")) \
                   .replace("__OPENSCAD_JS__", OPENSCAD_JS).replace("__THREE__", THREE) \
                   .replace("__PAGE_TITLE__", scad.stem.replace("_", " ").title() + " Configurator")
    out = scad.with_name(scad.stem + "_configurator.html")
    out.write_text(html)
    print(f"{out}: {len(model['params'])} parameters, {len(model['parts'])} parts, "
          f"{len(model['files'])} embedded files, {out.stat().st_size // 1024} kB")
    return out


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    build(sys.argv[1])


if __name__ == "__main__":
    main()
