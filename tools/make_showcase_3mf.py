#!/usr/bin/env python3
"""A Bambu Studio project (.3mf) with several plates that show what the repository makes, for MakerWorld.

    python3 tools/make_showcase_3mf.py        # -> marketing/showcase.3mf

Each part is rendered from its model with OpenSCAD (settings below), turned into its print orientation (the
`print=` tag of its parts table, "auto" = least overhang, the same search as the build tools), laid out on its
plate and written in Bambu Studio's project format: one object per part in 3D/3dmodel.model, placed on plate N
(plates are 256 mm beds in a grid, 1.2 x the bed size apart, as Bambu Studio lays them out), plates and object
names in Metadata/model_settings.config, and "Application = BambuStudio-..." so Studio opens it as a project
with its plates. Open it in Bambu Studio, choose printer and filament, slice and save: that saved project is the
print profile MakerWorld asks for.
"""
import importlib.util, math, re, subprocess, sys, tempfile, uuid, zipfile, datetime
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
from build import asm_py                     # the OpenSCAD skill's asm.py: STL reader, orientation search

_spec = importlib.util.spec_from_file_location("asm", str(asm_py()))
asm = importlib.util.module_from_spec(_spec); _spec.loader.exec_module(asm)

BED, GAP, MARGIN, SPACE = 256.0, 0.2, 10.0, 6.0     # bed size, plate gap factor (Bambu: 1/5), edge margin, part spacing
OUT = ROOT / "marketing" / "showcase.3mf"
P = ROOT / "projects"
BOX, EAR, SUN, ATT, GAL = (P/"custombox"/"custombox.scad", P/"earbuds"/"earbuds.scad", P/"sunglasses"/"sunglasses.scad",
                           P/"attachments"/"attachments.scad", P/"pattern_gallery"/"pattern_gallery.scad")

# plates: (plate name, [(object name, scad, settings, part id, print orientation), ...])
ORGANIZER = ['compart_layout="33,33,33 / 50,50 / 100"', 'height=50']
DESK = ['compart_rows=2', 'compart_cols=3', 'rise_back=20', 'rim_wave_x_amp=5', 'rim_wave_x_count=1.5', 'divider_notch=14',
        'notch_front=14', 'wall_pattern="triangular_lattice"', 'width=160', 'depth=100']


def att(t, part="plate", size="S", orient=None):
    tag = orient or ("auto" if t in ("skadis", "hook", "clamp", "pipe", "roof") or part != "plate" else "x180")
    return (f"Attachment {t}" if part == "plate" else f"Attachment {t} {part}", ATT,
            [f'attach_type="{t}"', f'attach_size="{size}"'], part, tag)


def sample(p, mode, more=()):
    return (f"Pattern {p}", GAL, ['view="sample"', f'pattern="{p}"', f'mode="{mode}"', 'sample_w=56', 'sample_h=56',
                                  'sample_shape="rounded"'] + list(more), "sample", "")


PLATES = [
    ("Organizer 3 + 2 + 1", [("Organizer box 3+2+1", BOX, ORGANIZER, "box", "")]),
    ("Desk organizer 2 x 3", [("Desk organizer 2x3", BOX, DESK, "box", "")]),
    ("Holders: sunglasses + earbuds", [("Sunglasses tray", SUN, [], "holder", ""),
                                       ("Earbuds holder (Soundcore P31i)", EAR, [], "holder", "")]),
    ("Attachment plates + test coupon", [att("wall", "coupon", orient="x180"), att("wall"), att("keyhole"), att("magnet"),
                                         att("flat"), att("skadis"), att("hook"), att("pipe"), att("clamp"),
                                         att("clamp", "attach_screw")]),
    ("Pattern samples", [sample("hex_honeycomb", "through_cut"), sample("asanoha", "through_cut"),
                         sample("girih_star_cross", "through_cut"), sample("cube_rosette", "through_cut"),
                         sample("voronoi", "through_cut"), sample("fish_scales", "through_cut"),
                         sample("basket_weave", "open_lattice"), sample("tri_weave", "open_lattice"),
                         sample("concentric_ripples", "through_cut", ['ripple_spokes=6'])]),
]


def render(scad, defs, part):
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "p.stl"
        cmd = ["openscad", "-o", str(out), "--export-format", "binstl", "-D", f'part="{part}"']
        for d in defs:
            cmd += ["-D", d]
        r = subprocess.run(cmd + [scad.name], cwd=scad.parent, capture_output=True, text=True)
        if not out.exists() or out.stat().st_size <= 84:
            raise RuntimeError(f"render failed: {scad.name} {defs} {part}: {r.stderr[-500:]}")
        warn = [l for l in r.stderr.splitlines() if "WARNING" in l and "ECHO" in l]
        return asm.read_stl(out), warn


def to_print(tri, tag):
    spec = asm.orient({"tags": {"print": tag}, "tri": tri, "id": "part"}) if tag else ""
    t = tri @ asm.rot_matrix(spec).T if spec else tri.copy()
    lo = t.reshape(-1, 3).min(0)
    t -= lo                                                       # on the bed at the origin corner
    # lay it the long way along x
    ext = t.reshape(-1, 3).max(0)
    if ext[1] > ext[0] + 0.5:
        t = t @ asm.rot_matrix("z90").T                           # a turn, not a mirror: the winding stays right
        t -= t.reshape(-1, 3).min(0)
    return t


def pack(parts):
    """shelf packing on a BED x BED plate; returns offsets (x, y) or raises if it does not fit"""
    use = BED - 2*MARGIN
    order = sorted(range(len(parts)), key=lambda i: -parts[i][1])
    pos, x, y, shelf = {}, 0.0, 0.0, 0.0
    for i in order:
        w, d = parts[i][0], parts[i][1]
        if x + w > use + 1e-6:
            x, y, shelf = 0.0, y + shelf + SPACE, 0.0
        if y + d > use + 1e-6 or w > use + 1e-6:
            raise RuntimeError("plate overflow")
        pos[i] = (x, y); x += w + SPACE; shelf = max(shelf, d)
    # centre the whole layout on the plate
    xs = [pos[i][0] + parts[i][0] for i in pos]; ys = [pos[i][1] + parts[i][1] for i in pos]
    cx, cy = (BED - max(xs))/2, (BED - max(ys))/2
    return [(pos[i][0] + cx, pos[i][1] + cy) for i in range(len(parts))]


def plate_origin(k, n):
    cols = math.ceil(math.sqrt(n) - 1e-9)                          # Bambu: compute_colum_count
    row, col = divmod(k, cols)
    return col*BED*(1 + GAP), -row*BED*(1 + GAP)


def mesh_xml(tri):
    v, f = asm.weld(tri, 5)
    f = f[(f[:, 0] != f[:, 1]) & (f[:, 1] != f[:, 2]) & (f[:, 0] != f[:, 2])]
    vs = "".join('<vertex x="%.4f" y="%.4f" z="%.4f"/>' % tuple(x) for x in v)
    ts = "".join('<triangle v1="%d" v2="%d" v3="%d"/>' % tuple(x) for x in f)
    return f"<mesh><vertices>{vs}</vertices><triangles>{ts}</triangles></mesh>", len(f)


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def main():
    objs, notes = [], []                                          # (plate index, name, tri placed in plate coords)
    for k, (pname, items) in enumerate(PLATES):
        tris = []
        for name, scad, defs, part, tag in items:
            t, warn = render(scad, defs, part)
            notes += [f"{name}: {w}" for w in warn]
            t = to_print(t, tag)
            tris.append((name, t))
            print(f"  {pname}: {name} {np.round(t.reshape(-1, 3).max(0), 1)}", flush=True)
        offs = pack([tuple(t.reshape(-1, 3).max(0)[:2]) for _, t in tris])
        for (name, t), (ox, oy) in zip(tris, offs):
            objs.append((k, name, t + np.array([ox, oy, 0])))
    n = len(PLATES)
    res, build, cfg_obj, plates = [], [], [], {k: [] for k in range(n)}
    for i, (k, name, t) in enumerate(objs):
        oid = i + 1
        m, nf = mesh_xml(t)
        res.append(f'<object id="{oid}" p:UUID="{uuid.uuid4()}" type="model" name="{esc(name)}">{m}</object>')
        ox, oy = plate_origin(k, n)
        build.append(f'<item objectid="{oid}" p:UUID="{uuid.uuid4()}" transform="1 0 0 0 1 0 0 0 1 {ox:.3f} {oy:.3f} 0" printable="1"/>')
        cfg_obj.append(f'  <object id="{oid}">\n    <metadata key="name" value="{esc(name)}"/>\n    <metadata key="extruder" value="1"/>\n'
                       f'    <metadata face_count="{nf}"/>\n    <part id="1" subtype="normal_part">\n      <metadata key="name" value="{esc(name)}"/>\n'
                       f'      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n    </part>\n  </object>')
        plates[k].append(oid)
    today = datetime.date.today().isoformat()
    meta = {"Application": "BambuStudio-02.00.00.00", "BambuStudio:3mfVersion": "1", "Title": "tg_3d_modelling showcase",
            "Designer": "tamaygz", "Description": "Box generator, holders, attachment plates and pattern samples from "
            "github.com/tamaygz/tg_3d_modelling (customize them at tamaygz.github.io/tg_3d_modelling)",
            "License": "CC BY-NC-SA", "CreationDate": today, "ModificationDate": today}
    model = ('<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" '
             'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
             'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
             'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" requiredextensions="p">\n'
             + "".join(f' <metadata name="{k}">{esc(v)}</metadata>\n' for k, v in meta.items())
             + ' <resources>\n' + "\n".join(res) + '\n </resources>\n <build p:UUID="%s">\n' % uuid.uuid4()
             + "\n".join(build) + '\n </build>\n</model>\n')
    plate_xml = []
    for k, (pname, _) in enumerate(PLATES):
        inst = "".join(f'    <model_instance>\n      <metadata key="object_id" value="{o}"/>\n      <metadata key="instance_id" value="0"/>\n'
                       f'      <metadata key="identify_id" value="{100 + o}"/>\n    </model_instance>\n' for o in plates[k])
        plate_xml.append(f'  <plate>\n    <metadata key="plater_id" value="{k + 1}"/>\n    <metadata key="plater_name" value="{esc(pname)}"/>\n'
                         f'    <metadata key="locked" value="false"/>\n{inst}  </plate>')
    config = '<?xml version="1.0" encoding="UTF-8"?>\n<config>\n' + "\n".join(cfg_obj) + "\n" + "\n".join(plate_xml) + "\n</config>\n"
    OUT.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", '<?xml version="1.0" encoding="UTF-8"?>\n<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
                   ' <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n'
                   ' <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>\n'
                   ' <Default Extension="png" ContentType="image/png"/>\n</Types>\n')
        z.writestr("_rels/.rels", '<?xml version="1.0" encoding="UTF-8"?>\n<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                   ' <Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n</Relationships>\n')
        z.writestr("3D/3dmodel.model", model)
        z.writestr("Metadata/model_settings.config", config)
    print(f"{OUT.relative_to(ROOT)}: {len(objs)} objects on {n} plates, {OUT.stat().st_size // 1024} kB")
    for x in notes:
        print("  note:", x)


if __name__ == "__main__":
    main()
