#Requires -RunAsAdministrator

# Description
# ===========
# Runs only the script that optimize user UI for second users

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

$username = Get-LoggedUsername

Print-Message-With-Banner("Starting User UI Cleanup")

&($PSScriptRoot+"\6.optimize-user-interface.ps1")
&($PSScriptRoot+"\6.1.cleanup-taskbar.ps1")
&($PSScriptRoot+"\7.unbloat-start-menu.ps1")

if (Is-UserAdministrator $(Get-LoggedUsername)) {
    if (Is-BuiltInAdminLoggedInUser) {
        Write-Debug "Built-in admin account in session - User demotion skipped"
        Return
    } else {

        $choice = [Microsoft.VisualBasic.Interaction]::MsgBox('Remove current user from Administrators group?', 'YesNo,SystemModal,Question', 'Remove user from admin group check')

        switch  ($choice) {
        'Yes' {
            Remove-CurrentUserAdminGroup
	        }
        }
    }
}