#Requires -RunAsAdministrator

# Description
# ===========
# This script will remove and disable OneDrive integration.
# After Windows 10 1909, OneDrive is installed after the user
# made the first login, and it seems to be downloaded from the internet.
# Make sure the OneDrive Setup process is complete - you don't see it in
# Taks Manager - before executing thescript.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-Script-Banner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername
$userSid = Get-UserSid $username
$userHomeFolder = Get-UserHomeFolder $userSid

#The PSDrive mapping has to be done in every PS1 file
New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR" | Out-Null
New-PSDrive HKU Registry HKEY_USERS | Out-Null

#=============================================================================

if ($skipOneDriveUnintall) {
    return
}

Stop-Process -name OneDrive

# Remove OneDrive
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

# Removing OneDrive leftovers
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
# check if directory is empty before removing:
if ((Get-ChildItem "$userHomeFolder\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$userHomeFolder\OneDrive"
}

# Disable OneDrive via Group Policies
force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

# Remove Onedrive from explorer sidebar
mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" | Out-Null
Set-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" | Out-Null
Set-ItemProperty "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
Remove-PSDrive "HKCR"

# Removing run hook for new users
Load-DefaultUserNtDat
#reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f | Out-Null
Remove-ItemProperty -Path "HKU:\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup"
Unload-DefaultUserNtDat

# Removing startmenu entry
Remove-Item -Force -ErrorAction SilentlyContinue "$userHomeFolder\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
Stop-Process -name explorer

# Take ownership of files to remove later
# Uninstall process has to complete before deletion is possible
foreach ($directory in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    Takeown-Folder $directory.FullName
}
Takeown-Folder $env:LOCALAPPDATA\Microsoft\OneDrive