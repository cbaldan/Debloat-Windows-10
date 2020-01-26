#Requires -RunAsAdministrator

# Description
# ===========
# This script removes OneDrive leftover files
# It has to executed after long after script 4 to allow the uninstall process to complete
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

Write-Output "Removing OneDrive leftovers"
foreach ($directory in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    &cmd.exe /c rmdir /S /Q $directory.FullName
}

&cmd.exe /c rmdir /S /Q $env:LOCALAPPDATA\Microsoft\OneDrive
