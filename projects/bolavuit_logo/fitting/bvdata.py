import _env
import sys, re, math
import svg_to_scad as S
s = open(_env.LOGO / 'reference' / 'bolavuit.svg').read()
d = re.search(r'id="STR"[^>]*d="([^"]+)"', s).group(1)
H = 1716
REG = [[[(x, H - y) for x, y in c] for c in r] for r in S.regions(S.flatten_path(d, 0.25))]
LEAVES_L = [6, 7, 12, 15, 3, 10, 17, 13, 19]
LEAVES_R = [5, 8, 11, 16, 4, 9, 18, 14, 20]
