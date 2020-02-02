#Requires -RunAsAdministrator

# Description
# ===========
# For increased security, I enable the built-in Administrator
# account in Windows and demote the user account to Standard User

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-Script-Banner($MyInvocation.MyCommand.Name)

#=============================================================================

Add-Type -AssemblyName Microsoft.VisualBasic

$msg="Enable the Administrator account?`n`nThe Windows built-in admin account will be enabled and the current user will be removed from the 'Administrators' group.`n`n"
$choice = [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'YesNo,SystemModal,Question', 'Enable admin')

switch  ($choice) {
'Yes'  {
    # Thanks so some nefarious W10 bug, the password has to be set
    # in a different statement, after the account has been enabled
    $adminUser = Get-LocalUser -Name "Admin*"
    Enable-LocalUser $adminUser

    $pwd = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Administrator account password', 'Password', '*123')
    if ($pwd -ne "") {
        $pwd = ConvertTo-SecureString $pwd -AsPlainText -Force
        Set-LocalUser $adminUser -Password $pwd
    }


    Remove-UserFromAdminGroup $(Get-LoggedUsername)
    }
}
