#Requires -RunAsAdministrator

# Description
# ===========
# This script removes OneDrive leftover files
# It has to executed after long after script 4 to allow the uninstall process to complete

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-ScriptBanner($MyInvocation.MyCommand.Name)

#=============================================================================

#Necessary to succeed in files removal
Stop-RestartProcess -ProcessName explorer -RestartProcess $true

# Removing OneDrive leftovers
foreach ($directory in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    Remove-Item -ErrorAction SilentlyContinue -Recurse -Force $directory.FullName
}

$userLocalAppData="$userHomeFolder\AppData\Local"
$localUserOneDriveFolder = "$userLocalAppData\Microsoft\OneDrive"
if (Test-Path $localUserOneDriveFolder) {
    Remove-Item -Recurse -Force  $localUserOneDriveFolder
}