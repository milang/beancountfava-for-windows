#Requires -version 7

$ErrorActionPreference = "Stop"

Write-Error "This is a problem..."

Write-Host -NoNewline "Current directory: "
Write-Host -ForegroundColor Yellow (Get-Location)

Get-Command git
git --version

Get-Command python
python --version

Get-Command pip
pip --version
