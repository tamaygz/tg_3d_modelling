"""Paths for the fitting scripts. Import first: it puts the repo's tools/ on the path (artfit, svg_to_scad).
Run the scripts from the results/ folder (they read and write their .json there): cd results && python3 ../fitleaves.py"""
import os, sys, tempfile
from pathlib import Path
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
sys.path.insert(0, str(REPO / "tools"))
TMP = os.environ.get("FIT_TMP") or tempfile.mkdtemp(prefix="fit_")      # scratch files (OpenSCAD exports)
LOGO = REPO / "projects" / "bolavuit_logo"
FONTS = REPO / "lib" / "fonts"
