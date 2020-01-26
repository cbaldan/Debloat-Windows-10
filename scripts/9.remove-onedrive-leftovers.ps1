#Requires -RunAsAdministrator

# Description
# ===========
# This script removes OneDrive leftover files
# It has to executed after long after script 4 to allow the uninstall process to complete
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

# Removing OneDrive leftovers
foreach ($directory in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    Remove-Item -Recurse -Force $directory.FullName
}

Remove-Item -Recurse -Force  $env:LOCALAPPDATA\Microsoft\OneDrive