#Requires -version 7

# GitHub Actions workflow commands:
# https://pakstech.com/blog/github-actions-workflow-commands/
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions

$ErrorActionPreference = "Stop"

# update python tools (usually both pip and setuptools are outdated)
Write-Host "::group::Update Python tools"
pip list --outdated
python -m pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir --upgrade setuptools
Write-Host "::endgroup::"
