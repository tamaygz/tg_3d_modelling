$ErrorActionPreference = 'Stop'

$helper = Join-Path $HOME '.claude\skills\openscad-skill'
$revision = '474547bb57924b5486a72552607b9910bb61da3b'
$patch = Join-Path $PSScriptRoot 'tools\openscad-windows.patch'
if (-not (Test-Path $helper)) {
    git clone --branch v2.4.0 --depth 1 https://github.com/pthompson8594/openscad-skill.git $helper
    if ($LASTEXITCODE -ne 0) { throw 'Could not clone the OpenSCAD helper.' }
}
if ((git -C $helper rev-parse HEAD) -ne $revision) {
    throw "Existing helper is not v2.4.0: $helper"
}
git -C $helper apply --reverse --check --quiet $patch
if ($LASTEXITCODE -ne 0) {
    git -C $helper apply --check --quiet $patch
    if ($LASTEXITCODE -ne 0) { throw "Cannot apply the Windows compatibility patch to $helper." }
    git -C $helper apply $patch
    if ($LASTEXITCODE -ne 0) { throw 'Could not apply the Windows compatibility patch.' }
}

$venv = Join-Path $env:LOCALAPPDATA 'tg_3d_modelling\build-venv'
$python = Join-Path $venv 'Scripts\python.exe'
if (-not (Test-Path $python)) {
    py -3 -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the Python build environment.' }
}
& $python -m pip install 'numpy>=1.24,<3' 'manifold3d>=3.0,<4' 'scipy>=1.10,<2' 'pillow>=10.1,<13'
if ($LASTEXITCODE -ne 0) { throw 'Could not install the Python build dependencies.' }
Write-Output "Build Python: $python"