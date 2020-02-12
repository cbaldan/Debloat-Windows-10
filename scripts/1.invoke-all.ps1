#Requires -RunAsAdministrator

# Description
# ===========
# Invokes the execution of all scripts at once.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-MessageWithPrefix("Starting Windows 10 Cleanup")
Print-LineSeparator

$testModeEnabled=$false
Exec-SmokeTest $testModeEnabled

$isDebloated=Is-WindowsDebloated

if ($isDebloated -eq $true) {
    Write-Host "This Windows has already been debloated on:"$(Get-DebloatDate)
} else {
    try {
        Stop-WindowsUpdateService

        $removeOneDrive=Remove-OneDriveCheck

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

        Write-Host "`nWindows 10 Debloater execution complete" -BackgroundColor Green -ForegroundColor Black

        if($testModeEnabled -eq $false) {
            Restart-Dialog
        }
    } catch {
        Write-Host "Error while executing Debloating scripts, something went wrong" -BackgroundColor Red -ForegroundColor Black
    }
}