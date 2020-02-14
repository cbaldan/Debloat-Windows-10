#Requires -RunAsAdministrator

# Description
# ===========
# Invokes the execution of all scripts at once.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-MessageWithPrefix("Starting Windows 10 Cleanup")
Print-LineSeparator

$createTestUsers=$false
$uninstallDefaultApps=$true
Exec-SmokeTest $createTestUsers

$isDebloated=Is-WindowsDebloated

if ($isDebloated -eq $true) {
    Write-Host "This Windows has already been debloated on:"$(Get-DebloatDate)
} else {
    try {
        Stop-WindowsUpdateService

        $uninstallOneDrive=Check-OneDriveStatus

        &($PSScriptRoot+"\8.fix-acccount-privileges.ps1")

        if ($uninstallOneDrive) {
            &($PSScriptRoot+"\4.remove-onedrive.ps1")
        }

        # Taskbar
        &($PSScriptRoot+"\6.1.cleanup-taskbar.ps1")
        &($PSScriptRoot+"\7.unbloat-start-menu.ps1")
        # Services an internal settings
        &($PSScriptRoot+"\2.disable-services.ps1")
        &($PSScriptRoot+"\2.1.disable-background-apps.ps1")
        &($PSScriptRoot+"\3.optimize-windows-update.ps1")
        &($PSScriptRoot+"\6.optimize-user-interface.ps1")
        # The big star
        if ($uninstallDefaultApps) {
            &($PSScriptRoot+"\5.remove-default-apps.ps1")
        }

        if ($uninstallOneDrive) {
            &($PSScriptRoot+"\9.remove-onedrive-leftovers.ps1")
        }

        Create-WindowsDebloatedRegEntry

        Write-Host ""
        Print-MessageWithPrefix "Restricting script execution policy"
        Set-ExecutionPolicy Restricted -Scope CurrentUser

        Write-Host "`nWindows 10 Debloater execution complete" -BackgroundColor Green -ForegroundColor Black

        Restart-Dialog

        # Sometimes the taskbar doesn't come back up on the first attemp, so we retry!
        Restart-Process -ProcessName explorer -Retries 3

    } catch {
        Write-Host "Error while executing Debloating scripts, something went wrong" -BackgroundColor Red -ForegroundColor Black
    }
}