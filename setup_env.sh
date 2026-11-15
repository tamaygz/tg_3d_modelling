#!/usr/bin/env bash
set -euo pipefail

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y openscad xvfb fonts-liberation git python3-venv

helper="$HOME/.claude/skills/openscad-skill"
revision=474547bb57924b5486a72552607b9910bb61da3b
if [[ ! -e "$helper" ]]; then
	git clone --branch v2.4.0 --depth 1 https://github.com/pthompson8594/openscad-skill.git "$helper"
fi
if [[ "$(git -C "$helper" rev-parse HEAD)" != "$revision" ]]; then
	printf 'Existing helper is not v2.4.0: %s\n' "$helper" >&2
	exit 1
fi

venv="$HOME/.local/share/tg_3d_modelling/build-venv"
if [[ ! -x "$venv/bin/python" ]]; then
	python3 -m venv "$venv"
fi
"$venv/bin/python" -m pip install 'numpy>=1.24,<3' 'manifold3d>=3.0,<4' 'scipy>=1.10,<2' 'pillow>=10.1,<13'
printf 'Build Python: %s/bin/python\n' "$venv"
