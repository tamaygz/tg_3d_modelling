#!/usr/bin/env python3
"""Build a standalone browser configurator for a parametric OpenSCAD model.

    python3 tools/make_configurator.py projects/<name>/<name>.scad

Writes projects/<name>/<name>_configurator.html. The page embeds the model, every file it
includes/uses (libraries, .ttf fonts) and runs the real OpenSCAD (WebAssembly, loaded from a CDN)
in the browser, so the preview always matches the .scad. Re-run after editing the model.

What it reads from the .scad:
  * parameters: `name = value; // comment` lines from the top of the file down to the
    `// derived` marker (or the first module/function/table). `// ---- Section ----` lines group them.
    `part` and `$` variables are skipped.
  * parts: the `parts = [ ["id","Label","note",[dx,dy,dz],"#colour", ...], ... ]` table, if present.
    Each part is rendered separately with -D part="id". Without a table the whole model is one part.
"""
import base64, json, re, sys
from pathlib import Path

OPENSCAD_JS = "https://cdn.jsdelivr.net/npm/openscad-wasm-prebuilt@1.2.0/dist/openscad.js"
THREE = "https://cdn.jsdelivr.net/npm/three@0.160.0"


def collect_files(main: Path):
    root = main.parent.resolve()
    files, todo = {}, [main.resolve()]
    while todo:
        f = todo.pop()
        rel = f.relative_to(root).as_posix()
        if rel in files:
            continue
        if f.suffix.lower() in (".ttf", ".otf"):
            files[rel] = {"b64": base64.b64encode(f.read_bytes()).decode()}
            continue
        text = f.read_text()
        files[rel] = {"text": text}
        for m in re.finditer(r"^\s*(?:include|use)\s*<([^>]+)>", text, re.M):
            dep = (f.parent / m.group(1)).resolve()
            if root not in dep.parents and dep != root:
                sys.exit(f"refusing to embed {m.group(1)}: outside {root}")
            if not dep.exists():
                sys.exit(f"missing dependency {dep}")
            todo.append(dep)
    return files


def parse_params(text):
    params, section = [], "Parameters"
    for line in text.splitlines():
        s = line.strip()
        if re.match(r"//\s*derived", s) or re.match(r"(module|function)\s", s) or re.match(r"(parts|checks|travel|report)\s*=", s):
            break
        h = re.match(r"//\s*-{2,}\s*(.+?)\s*-{2,}\s*$", s)
        if h:
            section = h.group(1)[:1].upper() + h.group(1)[1:]
            continue
        m = re.match(r"^([A-Za-z_]\w*)\s*=\s*(.+?);\s*(?://\s*(.*))?$", s)
        if not m or m.group(1) == "part":
            continue
        name, raw, comment = m.group(1), m.group(2).strip(), (m.group(3) or "").strip()
        if raw in ("true", "false"):
            kind = "bool"
        elif re.fullmatch(r"-?\d+(\.\d+)?", raw):
            kind = "number"
        elif re.fullmatch(r'"[^"]*"', raw):
            kind = "string"
        else:
            kind = "expr"
        params.append({"name": name, "raw": raw, "type": kind, "comment": comment, "section": section})
    return params


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


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    scad = Path(sys.argv[1])
    text = scad.read_text()
    first = text.splitlines()[0] if text else ""
    title = re.sub(r"^//\s*", "", first) if first.startswith("//") else scad.stem
    model = {
        "name": scad.stem,
        "main": scad.name,
        "title": title,
        "files": collect_files(scad),
        "params": parse_params(text),
        "parts": parse_parts(text),
    }
    html = TEMPLATE.replace("__MODEL_JSON__", json.dumps(model).replace("</", "<\\/")) \
                   .replace("__OPENSCAD_JS__", OPENSCAD_JS).replace("__THREE__", THREE) \
                   .replace("__PAGE_TITLE__", scad.stem.replace("_", " ").title() + " Configurator")
    out = scad.with_name(scad.stem + "_configurator.html")
    out.write_text(html)
    print(f"{out}: {len(model['params'])} parameters, {len(model['parts'])} parts, "
          f"{len(model['files'])} embedded files, {out.stat().st_size // 1024} kB")


TEMPLATE = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>__PAGE_TITLE__</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Sans+Condensed:wght@600&display=swap">
<style>
/* Layout: workbench — parameter rail on the left, 3D stage on the right, part tray + console under the stage */
:root {
  --bg: #eef0ee; --panel: #fbfcfb; --ink: #1d2422; --muted: #5d6965; --line: #d3d9d6;
  --accent: #a8741a; --accent-ink: #ffffff; --stage: #dfe4e1; --warn: #a3471b; --ok: #2f6b4a;
  --sans: "IBM Plex Sans", system-ui, sans-serif; --mono: "IBM Plex Mono", ui-monospace, monospace;
  --display: "IBM Plex Sans Condensed", "IBM Plex Sans", system-ui, sans-serif;
  color-scheme: light;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --bg: #151a19; --panel: #1d2422; --ink: #e4e9e7; --muted: #94a19c; --line: #2f3936;
  --accent: #e0a940; --accent-ink: #1a1408; --stage: #232b29; --warn: #f08a5d; --ok: #6cc196; color-scheme: dark } }
:root[data-theme="dark"] {
  --bg: #151a19; --panel: #1d2422; --ink: #e4e9e7; --muted: #94a19c; --line: #2f3936;
  --accent: #e0a940; --accent-ink: #1a1408; --stage: #232b29; --warn: #f08a5d; --ok: #6cc196; color-scheme: dark }
* { box-sizing: border-box }
html, body { margin: 0; background: var(--bg); color: var(--ink); font: 14px/1.45 var(--sans) }
.wrap { padding-block: 16px 24px; padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px));
  display: grid; grid-template-columns: minmax(280px, 340px) minmax(0, 1fr); gap: 16px; max-width: 1600px; margin: 0 auto }
header { grid-column: 1 / -1; display: flex; flex-wrap: wrap; align-items: baseline; gap: 4px 16px }
h1 { font: 600 22px/1.2 var(--display); margin: 0; letter-spacing: .01em; text-wrap: balance }
.sub { color: var(--muted) }
.panel { background: var(--panel); border: 1px solid var(--line); border-radius: 6px }
aside { display: flex; flex-direction: column; min-width: 0 }
.actions { position: sticky; top: 0; z-index: 2; background: var(--panel); border-bottom: 1px solid var(--line); padding: 12px; display: flex; gap: 8px; flex-wrap: wrap; border-radius: 6px 6px 0 0 }
button { font: 500 13px var(--sans); border: 1px solid var(--line); background: transparent; color: var(--ink); padding: 7px 12px; border-radius: 4px; cursor: pointer }
button:hover { border-color: var(--muted) }
button.primary { background: var(--accent); color: var(--accent-ink); border-color: var(--accent); font-weight: 600 }
button:disabled { opacity: .5; cursor: default }
button:focus-visible, input:focus-visible { outline: 2px solid var(--accent); outline-offset: 1px }
form { padding: 4px 12px 12px; overflow: auto }
fieldset { border: 0; padding: 0; margin: 12px 0 0 }
legend { font: 600 11px var(--sans); letter-spacing: .08em; text-transform: uppercase; color: var(--muted); padding: 0 0 6px }
.row { display: grid; grid-template-columns: minmax(0, 1fr) 118px; gap: 2px 10px; align-items: center; padding: 6px 0; border-top: 1px dashed var(--line) }
.row label { font: 500 13px var(--mono); overflow-wrap: anywhere }
.row .help { grid-column: 1 / -1; color: var(--muted); font-size: 12px }
.row.wide { grid-template-columns: minmax(0, 1fr) }
.row.changed label::after { content: " •"; color: var(--accent) }
input[type=text], input[type=number] { width: 100%; font: 13px var(--mono); padding: 5px 7px; border: 1px solid var(--line); border-radius: 4px; background: var(--bg); color: var(--ink); font-variant-numeric: tabular-nums }
input.bad { border-color: var(--warn) }
input[type=checkbox] { width: 18px; height: 18px; accent-color: var(--accent); justify-self: start }
main { display: flex; flex-direction: column; gap: 16px; min-width: 0 }
.stage { position: relative; height: min(62vh, 640px); min-height: 320px; background: var(--stage); border: 1px solid var(--line); border-radius: 6px; overflow: hidden }
.stage canvas { display: block; width: 100%; height: 100% }
.hud { position: absolute; left: 10px; top: 10px; right: 10px; display: flex; justify-content: space-between; gap: 8px; flex-wrap: wrap; pointer-events: none }
.hud > * { pointer-events: auto }
.chip { background: var(--panel); border: 1px solid var(--line); border-radius: 4px; padding: 4px 8px; font: 12px var(--mono); font-variant-numeric: tabular-nums }
.tools { display: flex; gap: 8px; align-items: center; flex-wrap: wrap }
.tools label { font-size: 12px; color: var(--muted); display: flex; gap: 6px; align-items: center }
.status { position: absolute; left: 50%; bottom: 14px; transform: translateX(-50%); max-width: calc(100% - 20px) }
.grid2 { display: grid; grid-template-columns: minmax(0, 3fr) minmax(0, 2fr); gap: 16px }
.tray h2, .console h2 { font: 600 11px var(--sans); letter-spacing: .08em; text-transform: uppercase; color: var(--muted); margin: 0; padding: 10px 12px; border-bottom: 1px solid var(--line); display: flex; justify-content: space-between; align-items: center; gap: 8px }
.tbl { overflow-x: auto }
table { width: 100%; border-collapse: collapse; font-size: 13px }
td { padding: 6px 12px; border-top: 1px solid var(--line); white-space: nowrap }
td.num { font: 12px var(--mono); text-align: right; font-variant-numeric: tabular-nums; color: var(--muted) }
.sw { display: inline-block; width: 12px; height: 12px; border-radius: 2px; vertical-align: -1px; margin-right: 6px; border: 1px solid rgba(0,0,0,.25) }
.pill { font: 11px var(--mono); padding: 1px 6px; border-radius: 10px; border: 1px solid var(--line); color: var(--muted) }
.pill.ok { color: var(--ok); border-color: currentColor } .pill.err { color: var(--warn); border-color: currentColor }
td button { padding: 3px 8px; font-size: 12px }
pre { margin: 0; padding: 10px 12px; font: 12px/1.5 var(--mono); max-height: 260px; overflow: auto; white-space: pre-wrap; overflow-wrap: anywhere; color: var(--muted) }
pre .e { color: var(--warn) }
.note { color: var(--muted); font-size: 12px; padding: 8px 12px; border-top: 1px solid var(--line) }
@media (max-width: 900px) { .wrap { grid-template-columns: minmax(0, 1fr) } .grid2 { grid-template-columns: minmax(0, 1fr) } aside form { max-height: none } }
@media (min-width: 901px) { aside { max-height: calc(100vh - 90px); position: sticky; top: 12px } }
@media (prefers-reduced-motion: reduce) { * { transition: none !important } }
</style>
<script type="importmap">{ "imports": { "three": "__THREE__/build/three.module.js", "three/addons/": "__THREE__/examples/jsm/" } }</script>
</head>
<body>
<div class="wrap">
  <header><h1 id="title"></h1><span class="sub" id="subtitle"></span></header>
  <aside class="panel">
    <div class="actions">
      <button class="primary" id="gen" type="button">Generate</button>
      <button id="reset" type="button">Reset to defaults</button>
      <button id="dlscad" type="button">Download .scad</button>
    </div>
    <form id="form" autocomplete="off"></form>
  </aside>
  <main>
    <div class="stage" id="stage">
      <div class="hud">
        <span class="chip" id="dims">—</span>
        <div class="tools">
          <label for="explode">Pull apart <input id="explode" type="range" min="0" max="1" step="0.01" value="0"></label>
          <button id="fit" type="button" class="chip">Reset view</button>
        </div>
      </div>
      <span class="chip status" id="status">Loading OpenSCAD…</span>
    </div>
    <div class="grid2">
      <section class="panel tray">
        <h2>Parts <button id="dlall" type="button">Download all STLs</button></h2>
        <div class="tbl"><table><tbody id="parts"></tbody></table></div>
        <div class="note">STLs are exported in their assembled position. Turn them flat on the bed in your slicer, or use the repo's print files.</div>
      </section>
      <section class="panel console">
        <h2>OpenSCAD messages</h2>
        <pre id="log">Nothing yet.</pre>
      </section>
    </div>
  </main>
</div>

<script type="module">
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { STLLoader } from "three/addons/loaders/STLLoader.js";

const MODEL = __MODEL_JSON__;
const OPENSCAD_JS = "__OPENSCAD_JS__";
const $ = (id) => document.getElementById(id);
const STORE = "cfg:" + MODEL.name;

$("title").textContent = MODEL.name.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase());
$("subtitle").textContent = MODEL.title;

// ---------- embedded files ----------
const b64 = (s) => Uint8Array.from(atob(s), c => c.charCodeAt(0));
const enc = new TextEncoder();
const FILES = Object.entries(MODEL.files).map(([name, f]) => [name, f.b64 ? b64(f.b64) : enc.encode(f.text)]);

// ---------- parameter form ----------
let saved = {};
try { saved = JSON.parse(localStorage.getItem(STORE) || "{}") } catch (e) {}
const form = $("form");
const sections = {};
for (const p of MODEL.params) {
  if (!sections[p.section]) {
    const fs = document.createElement("fieldset");
    fs.innerHTML = `<legend></legend>`; fs.firstChild.textContent = p.section;
    form.appendChild(fs); sections[p.section] = fs;
  }
  const row = document.createElement("div");
  row.className = "row" + (p.type === "expr" && p.raw.length > 14 ? " wide" : "");
  const id = "p_" + p.name;
  const lab = document.createElement("label"); lab.htmlFor = id; lab.textContent = p.name;
  const inp = document.createElement("input"); inp.id = id; inp.name = p.name;
  const val = saved[p.name] ?? p.raw;
  if (p.type === "bool") { inp.type = "checkbox"; inp.checked = val === "true" }
  else if (p.type === "number") { inp.type = "number"; inp.step = "any"; inp.value = val }
  else { inp.type = "text"; inp.value = p.type === "string" ? JSON.parse(val) : val; inp.spellcheck = false }
  row.append(lab, inp);
  if (p.comment) { const h = document.createElement("div"); h.className = "help"; h.textContent = p.comment; row.appendChild(h) }
  sections[p.section].appendChild(row);
  inp.addEventListener("input", () => markChanged());
  inp.addEventListener("change", () => markChanged());
}
function rawValue(p) {
  const inp = $("p_" + p.name);
  if (p.type === "bool") return inp.checked ? "true" : "false";
  if (p.type === "string") return JSON.stringify(inp.value);
  return inp.value.trim();
}
function markChanged() {
  const cur = {};
  for (const p of MODEL.params) {
    const v = rawValue(p); cur[p.name] = v;
    const inp = $("p_" + p.name);
    inp.closest(".row").classList.toggle("changed", v !== p.raw);
    inp.classList.toggle("bad", p.type === "number" && !/^-?\d*\.?\d+$/.test(v));
  }
  try { localStorage.setItem(STORE, JSON.stringify(cur)) } catch (e) {}
}
markChanged();
form.addEventListener("submit", (e) => { e.preventDefault(); generate() });
form.addEventListener("keydown", (e) => { if (e.key === "Enter" && e.target.tagName === "INPUT") { e.preventDefault(); generate() } });
$("reset").onclick = () => {
  for (const p of MODEL.params) {
    const inp = $("p_" + p.name);
    if (p.type === "bool") inp.checked = p.raw === "true";
    else inp.value = p.type === "string" ? JSON.parse(p.raw) : p.raw;
  }
  markChanged(); generate();
};

// ---------- OpenSCAD runner (worker, main-thread fallback) ----------
const CORE = `
import { createOpenSCAD } from "${OPENSCAD_JS}";
export async function run(job) {
  const log = [];
  const o = await createOpenSCAD({ noInitialRun: true, print: s => log.push(s), printErr: s => log.push(s) });
  const m = o.getInstance(), FS = m.FS;
  const mk = p => { try { FS.mkdir(p) } catch (e) {} };
  mk("/fonts"); mk("/m");
  FS.writeFile("/fonts/fonts.conf", '<?xml version="1.0"?><fontconfig><dir>/fonts</dir></fontconfig>');
  for (const [name, data] of job.files) {
    const parts = name.split("/"); let d = "/m";
    for (const s of parts.slice(0, -1)) { d += "/" + s; mk(d) }
    FS.writeFile("/m/" + name, data);
    if (/\\.(ttf|otf)$/i.test(name)) FS.writeFile("/fonts/" + parts[parts.length - 1], data);
  }
  const args = ["/m/" + job.main, "-o", "/out.stl", "--backend=Manifold", "--export-format=binstl", "-D", 'part="' + job.part + '"'];
  for (const d of job.defs) args.push("-D", d);
  let rc = 0;
  try { rc = m.callMain(args) } catch (e) { rc = typeof e?.status === "number" ? e.status : 1; if (typeof e?.status !== "number") log.push("ERROR: " + e) }
  let stl = null; try { stl = FS.readFile("/out.stl") } catch (e) {}
  return { rc, log, stl };
}`;
const coreUrl = URL.createObjectURL(new Blob([CORE], { type: "text/javascript" }));
const WORKER = `import { run } from "${coreUrl}";
self.onmessage = async (e) => { let r; try { r = await run(e.data) } catch (err) { r = { rc: 1, log: ["ERROR: " + err], stl: null } }
  self.postMessage({ ...r, id: e.data.id }, r.stl ? [r.stl.buffer] : []) };`;
const workerUrl = URL.createObjectURL(new Blob([WORKER], { type: "text/javascript" }));

let worker = null, useMain = false, mainRun = null, pending = new Map(), jobId = 0;
function startWorker() {
  try {
    worker = new Worker(workerUrl, { type: "module" });
    worker.onmessage = (e) => { const cb = pending.get(e.data.id); pending.delete(e.data.id); cb && cb(e.data) };
    worker.onerror = (e) => { e.preventDefault?.(); if (!useMain) { useMain = true; worker = null; for (const [id, cb] of pending) cb({ retry: true }); pending.clear() } };
  } catch (e) { useMain = true }
}
async function runJob(job) {
  if (!useMain) {
    if (!worker) startWorker();
    if (!useMain) {
      const r = await new Promise((res) => { const id = ++jobId; pending.set(id, res); worker.postMessage({ ...job, id }) });
      if (!r.retry) return r;
    }
  }
  if (!mainRun) mainRun = (await import(coreUrl)).run;
  return mainRun(job);
}

// ---------- 3D stage ----------
const stage = $("stage");
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
stage.prepend(renderer.domElement);
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(35, 1, 1, 20000);
camera.up.set(0, 0, 1);
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
scene.add(new THREE.HemisphereLight(0xffffff, 0x445048, 1.6));
const sun = new THREE.DirectionalLight(0xffffff, 1.8); sun.position.set(-0.6, -1, 1.6); scene.add(sun);
const fill = new THREE.DirectionalLight(0xffffff, 0.6); fill.position.set(1, 0.8, 0.6); scene.add(fill);
const group = new THREE.Group(); scene.add(group);
const loader = new STLLoader();
const meshes = {};
function resize() { const r = stage.getBoundingClientRect(); renderer.setSize(r.width, r.height, false); camera.aspect = r.width / r.height; camera.updateProjectionMatrix() }
new ResizeObserver(resize).observe(stage); resize();
(function loop() { controls.update(); renderer.render(scene, camera); requestAnimationFrame(loop) })();

function bounds() {
  const b = new THREE.Box3();
  for (const m of Object.values(meshes)) if (m.visible) b.expandByObject(m);
  return b;
}
function fitView() {
  const b = bounds(); if (b.isEmpty()) return;
  const c = b.getCenter(new THREE.Vector3()), s = b.getSize(new THREE.Vector3());
  const r = Math.max(s.x, s.y, s.z * 2) * 0.5;
  const dist = r / Math.tan(THREE.MathUtils.degToRad(camera.fov / 2)) / Math.min(1, camera.aspect) * 1.05;
  camera.position.set(c.x - dist * 0.18, c.y - dist * 0.72, c.z + dist * 0.68);
  controls.target.copy(c); camera.near = dist / 100; camera.far = dist * 20; camera.updateProjectionMatrix();
}
function showDims() {
  const ex = +$("explode").value; $("explode").value = 0; applyExplode();
  const b = bounds(); $("explode").value = ex; applyExplode();
  if (b.isEmpty()) { $("dims").textContent = "—"; return }
  const s = b.getSize(new THREE.Vector3());
  $("dims").textContent = `${s.x.toFixed(1)} × ${s.y.toFixed(1)} × ${s.z.toFixed(1)} mm`;
}
function applyExplode() {
  const k = +$("explode").value * 1.6;
  for (const p of MODEL.parts) { const m = meshes[p.id]; if (m) m.position.set(p.explode[0] * k, p.explode[1] * k, p.explode[2] * k) }
}
$("explode").oninput = applyExplode;
$("fit").onclick = fitView;

// ---------- parts tray ----------
const state = {};
const tbody = $("parts");
for (const p of MODEL.parts) {
  const tr = document.createElement("tr"); tr.id = "row_" + p.id;
  tr.innerHTML = `<td><input type="checkbox" checked id="vis_${p.id}" aria-label="Show part"></td>
    <td><span class="sw"></span><span class="lbl"></span></td><td class="num tri"></td><td><span class="pill">waiting</span></td>
    <td><button type="button" disabled>STL</button></td>`;
  tr.querySelector(".sw").style.background = p.color;
  tr.querySelector(".lbl").textContent = p.label;
  tr.querySelector("input").onchange = (e) => { if (meshes[p.id]) meshes[p.id].visible = e.target.checked; showDims() };
  tr.querySelector("button").onclick = () => download(state[p.id]?.stl, `${MODEL.name}_${p.id}.stl`, "model/stl");
  tbody.appendChild(tr);
}
function setRow(id, pill, cls, tri) {
  const tr = $("row_" + id);
  const el = tr.querySelector(".pill"); el.textContent = pill; el.className = "pill " + (cls || "");
  tr.querySelector(".tri").textContent = tri || "";
  tr.querySelector("button").disabled = !state[id]?.stl;
}
function download(data, name, type) {
  if (!data) return;
  const a = document.createElement("a");
  a.href = URL.createObjectURL(new Blob([data], { type })); a.download = name;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 4000);
}
$("dlall").onclick = async () => {
  for (const p of MODEL.parts) if (state[p.id]?.stl) { download(state[p.id].stl, `${MODEL.name}_${p.id}.stl`, "model/stl"); await new Promise(r => setTimeout(r, 350)) }
};
$("dlscad").onclick = () => {
  let src = MODEL.files[MODEL.main].text;
  for (const p of MODEL.params) {
    const re = new RegExp("^(\\s*" + p.name.replace(/\$/g, "\\$") + "\\s*=\\s*)(.+?)(;.*)$", "m");
    src = src.replace(re, (m, a, b, c) => a + rawValue(p) + c);
  }
  download(src, MODEL.main, "text/plain");
};

// ---------- generate ----------
let gen = 0;
async function generate() {
  const my = ++gen;
  if (worker && pending.size) { worker.terminate(); worker = null; pending.clear() }
  $("gen").disabled = true;
  const defs = MODEL.params.map(p => `${p.name}=${rawValue(p)}`);
  const logOut = [];
  for (const p of MODEL.parts) setRow(p.id, "queued", "", "");
  const t0 = performance.now(); let done = 0, failed = 0, first = true;
  for (const p of MODEL.parts) {
    if (my !== gen) return;
    $("status").textContent = `Rendering ${p.label} (${done + 1}/${MODEL.parts.length})…`; $("status").hidden = false;
    setRow(p.id, "rendering", "", "");
    const t = performance.now();
    const r = await runJob({ files: FILES, main: MODEL.main, part: p.id, defs });
    if (my !== gen) return;
    done++;
    const msgs = r.log.filter(s => /WARNING|ERROR|ECHO|TRACE/.test(s) && !/localization/.test(s));
    if (msgs.length) logOut.push(`[${p.label}]`, ...msgs);
    if (meshes[p.id]) { group.remove(meshes[p.id]); meshes[p.id].geometry.dispose(); delete meshes[p.id] }
    state[p.id] = { stl: null };
    const empty = !r.stl || r.stl.length <= 84;
    if (empty) {
      const err = msgs.some(s => /ERROR/.test(s));
      if (err) failed++;
      setRow(p.id, err ? "error" : "not used", err ? "err" : "", "");
      continue;
    }
    state[p.id].stl = r.stl;
    const geo = loader.parse(r.stl.buffer.slice(r.stl.byteOffset, r.stl.byteOffset + r.stl.byteLength));
    const mat = new THREE.MeshStandardMaterial({ color: p.color, roughness: 0.55, metalness: /#(c|d|e)[0-9a-f]/i.test(p.color) ? 0.35 : 0.05 });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.visible = $("vis_" + p.id).checked;
    meshes[p.id] = mesh; group.add(mesh); applyExplode();
    if (first) { fitView(); first = false }
    setRow(p.id, `${((performance.now() - t) / 1000).toFixed(1)} s`, "ok", (geo.attributes.position.count / 3).toLocaleString() + " tris");
    showDims();
  }
  fitView(); showDims();
  $("log").innerHTML = "";
  if (!logOut.length) $("log").textContent = "No warnings or errors.";
  for (const s of logOut) { const sp = document.createElement("span"); if (/ERROR/.test(s)) sp.className = "e"; sp.textContent = s + "\n"; $("log").appendChild(sp) }
  $("status").textContent = failed ? `${failed} part(s) failed. See OpenSCAD messages.` : `Done in ${((performance.now() - t0) / 1000).toFixed(1)} s`;
  setTimeout(() => { if (my === gen && !failed) $("status").hidden = true }, 2500);
  $("gen").disabled = false;
}
$("gen").onclick = generate;
generate();
</script>
</body>
</html>
"""

if __name__ == "__main__":
    main()
