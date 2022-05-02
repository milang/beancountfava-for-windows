#Requires -version 7

# GitHub Actions workflow commands:
# https://pakstech.com/blog/github-actions-workflow-commands/
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions

$ErrorActionPreference = "Stop"
$homeDir = Get-Location

# update python tools (usually both pip and setuptools are outdated)
Write-Host "::group::Update Python tools"
python -m pip install --no-cache-dir --upgrade pip
if ($LASTEXITCODE -ne 0) { Write-Error "pip upgrade failed" }
pip install --no-cache-dir --upgrade setuptools
if ($LASTEXITCODE -ne 0) { Write-Error "setuptools install/upgrade failed" }
pip install --no-cache-dir --upgrade virtualenv
if ($LASTEXITCODE -ne 0) { Write-Error "virtualenv install/upgrade failed" }
Write-Host "::endgroup::"

# create virtualenv for fava
Write-Host "::group::Create virtualenv for fava"
$binDir = New-Item -Force -ItemType Directory $env:PUBLIC/bin
Set-Location $binDir.FullName
Write-Host (Get-Location)
virtualenv fava
if ($LASTEXITCODE -ne 0) { Write-Error "virtualenv creation failed" }
Write-Host "::endgroup::"

# install fava
Write-Host "::group::Install fava"
Set-Location fava
./Scripts/activate
pip install --no-cache-dir --upgrade fava
if ($LASTEXITCODE -ne 0) { Write-Error "fava installation failed" }
bean-check --version
if ($LASTEXITCODE -ne 0) { Write-Error "bean-check failed" }
Write-Host "::endgroup::"

# package fava
Write-Host "::group::Package fava"
deactivate # global function added by "./Scripts/activate"
7z a -r -mx $homeDir/fava.7z ./*
Write-Host "::endgroup::"
