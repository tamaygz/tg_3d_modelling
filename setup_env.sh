#!/usr/bin/env bash
# Installs the native OpenSCAD toolchain and fonts (same commands as the cloud environment setup script)
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y openscad xvfb fonts-liberation
