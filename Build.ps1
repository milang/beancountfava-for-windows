#Requires -version 7

# GitHub Actions workflow commands:
# https://pakstech.com/blog/github-actions-workflow-commands/
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions

$ErrorActionPreference = "Stop"
$homeDir = Get-Location

# copy python
Write-Host "::group::Copy Python"
$sourcePython = (Get-Command "python").Source
$sourcePythonDir = Resolve-Path (Split-Path $sourcePython)
$favaDir = (New-Item -Force -ItemType Directory $env:PUBLIC/bin/fava).FullName
Copy-Item -Recurse $sourcePythonDir $favaDir/python | Out-Null
$pythonDir = Resolve-Path $favaDir/python
$pythonScriptsDir = Resolve-Path $pythonDir/Scripts
$env:Path = $pythonDir.Path + ";" + $pythonScriptsDir.Path + ";" + $env:Path
Write-Host "::endgroup::"

# update python tools (usually both pip and setuptools are outdated)
Write-Host "::group::Update Python tools"
python -m pip install --no-cache-dir --upgrade --force-reinstall pip # "pip" already existed in "$sourcePython", but it was bound to "$sourcePython"; we "--force-reinstall" to create a new "pip" that is bound to its new home
if ($LASTEXITCODE -ne 0) { Write-Error "pip upgrade failed" }
pip install --no-cache-dir --upgrade setuptools
if ($LASTEXITCODE -ne 0) { Write-Error "setuptools install/upgrade failed" }
pip install --no-cache-dir --upgrade virtualenv
if ($LASTEXITCODE -ne 0) { Write-Error "virtualenv install/upgrade failed" }
Write-Host "`e[0m" # Reset ANSI to prevent color leak from installers
Write-Host "Python: $((Get-Command python -ErrorAction SilentlyContinue).Source)"
Write-Host "PIP: $((Get-Command pip -ErrorAction SilentlyContinue).Source)"
Write-Host "VirtualEnv: $((Get-Command virtualenv -ErrorAction SilentlyContinue).Source)"
Write-Host "::endgroup::"

# create virtualenv for fava
Write-Host "::group::Create virtualenv for fava"
Set-Location $favaDir
virtualenv app
if ($LASTEXITCODE -ne 0) { Write-Error "virtualenv creation failed" }
Write-Host "::endgroup::"

# install fava
Write-Host "::group::Install fava"
Set-Location app
./Scripts/activate
pip install --no-cache-dir --upgrade fava
if ($LASTEXITCODE -ne 0) { Write-Error "fava installation failed" }
bean-check --version
if ($LASTEXITCODE -ne 0) { Write-Error "bean-check --version failed" }
fava --version
if ($LASTEXITCODE -ne 0) { Write-Error "fava --version failed" }
Write-Host "::endgroup::"

# package fava
Write-Host "::group::Package fava"
deactivate # global function added by "./Scripts/activate"
7z a -r -mx $homeDir/fava.7z $favaDir/*
Write-Host "::endgroup::"
