#!/usr/bin/env python3
"""Prepare a TrueType font for lib/fonts/: subset to Latin, add hinting, optionally rename.

    python3 tools/prepare_font.py SRC.ttf lib/fonts/OUT.ttf [--family "New Name"] [--note "derived from ..."]

Why: the browser OpenSCAD (WebAssembly, used by the web configurators) crashes with "RuntimeError: null
function" on any text in a TrueType font without hinting instructions: FreeType then switches to its
auto-hinter, which is broken in that build. ttfautohint adds real hinting, so FreeType uses the bytecode path.
Desktop OpenSCAD is unaffected, and glyph advances stay the same (check: tools/font_metrics.py).

Licences: a modified OFL font must not keep a Reserved Font Name (e.g. "Source" in Source Serif), so pass
--family with a new name; the copyright notice is kept. Needs fonttools and ttfautohint-py
(pip install fonttools ttfautohint-py).
"""
import argparse, io
from fontTools import subset
from fontTools.ttLib import TTFont

LATIN = "U+0020-007E,U+00A0-00FF,U+2013,U+2014,U+2018,U+2019,U+201C,U+201D"


def prepare(src, dst, family=None, note=None):
    import ttfautohint
    f = TTFont(src)
    o = subset.Options()
    o.layout_features = []; o.notdef_outline = True; o.glyph_names = True; o.name_IDs = ["*"]; o.name_languages = ["*"]
    s = subset.Subsetter(o)
    s.populate(unicodes=subset.parse_unicodes(LATIN))
    s.subset(f)
    buf = io.BytesIO(); f.save(buf)
    f = TTFont(io.BytesIO(ttfautohint.ttfautohint(in_buffer=buf.getvalue(), no_info=True)))
    if family:
        name = f["name"]
        style = name.getDebugName(2) or "Regular"
        ps = family.replace(" ", "") + "-" + style.replace(" ", "")
        for rec in list(name.names):
            if rec.nameID in (1, 3, 4, 6, 16, 17, 21, 22):
                name.removeNames(nameID=rec.nameID)
        name.setName(family, 1, 3, 1, 0x409)
        name.setName(style, 2, 3, 1, 0x409)
        name.setName(f"{family} {style}", 4, 3, 1, 0x409)
        name.setName(ps, 3, 3, 1, 0x409)
        name.setName(ps, 6, 3, 1, 0x409)
        if "CFF " in f:
            raise SystemExit("CFF fonts are not supported")
    if note:
        f["name"].setName(note, 10, 3, 1, 0x409)
    f.save(dst)
    return f


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src"); ap.add_argument("dst")
    ap.add_argument("--family", help="new family name (required when modifying a font with a Reserved Font Name)")
    ap.add_argument("--note", help="description stored in the font's name table")
    a = ap.parse_args()
    f = prepare(a.src, a.dst, a.family, a.note)
    print(f"{a.dst}: {f['name'].getDebugName(4)}, {len(f.getGlyphOrder())} glyphs, "
          f"hinted ({f['maxp'].maxSizeOfInstructions} bytes max per glyph)")


if __name__ == "__main__":
    main()
