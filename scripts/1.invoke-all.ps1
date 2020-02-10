#Requires -RunAsAdministrator

# Description
# ===========
# Invokes the execution of all scripts at once.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

$testModeEnabled=$false
Exec-SmokeTest $testModeEnabled
$isDebloated=Is-WindowsDebloated
$removeOneDrive=Remove-OneDriveCheck

if ($isDebloated -eq $true) {
    Write-Host "This Windows has already been debloated on:"$(Get-DebloatDate)
} else {
    Stop-WindowsUpdateService

    &($PSScriptRoot+"\8.fix-acccount-privileges.ps1")
    &($PSScriptRoot+"\4.remove-onedrive.ps1")
    &($PSScriptRoot+"\6.1.cleanup-taskbar.ps1")
    &($PSScriptRoot+"\7.unbloat-start-menu.ps1")

    &($PSScriptRoot+"\2.disable-services.ps1")
    &($PSScriptRoot+"\2.1.disable-background-apps.ps1")
    &($PSScriptRoot+"\3.optimize-windows-update.ps1")

    &($PSScriptRoot+"\6.optimize-user-interface.ps1")

    &($PSScriptRoot+"\5.remove-default-apps.ps1")
    &($PSScriptRoot+"\9.remove-onedrive-leftovers.ps1")

    Create-WindowsDebloatedRegEntry

	Write-Debug "testModeEnabled: $testModeEnabled"
    if($testModeEnabled -eq $false) {
        Restart-Dialog
    }
}