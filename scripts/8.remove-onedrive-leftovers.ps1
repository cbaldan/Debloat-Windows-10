# This script removes OneDrive leftover files
# It has to executed after script 3.remove-onedrive.ps1 has been executed,
# logoff and then login back in
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

Write-Output "Removing OneDrive leftovers"
foreach ($directory in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    &cmd.exe /c rmdir /S /Q $directory.FullName
}

taskkill.exe /F /IM "OneDrive.exe"
&cmd.exe /c rmdir /S /Q $env:LOCALAPPDATA\Microsoft\OneDrive

