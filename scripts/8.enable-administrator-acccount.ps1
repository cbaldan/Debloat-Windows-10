#Requires -RunAsAdministrator

# Description
# ===========
# For increased security, I enable the built-in Administrator
# account in Windows and demote the user account to Standard User

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1

Write-Output ">> Executing: $($MyInvocation.MyCommand.Name)$(Get-Line-Separator)"

#=============================================================================

Add-Type -AssemblyName Microsoft.VisualBasic

$msg="Enable the Administrator account?`n`nThe built-in admin account will be enabled and the current user will be removed from the 'Administrators' group.`n`n"
$choice = [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'YesNo,SystemModal,Question', 'Enable admin')

	switch  ($choice) {
	'Yes'  {
        $pwd = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Administrator account password', 'Password', '*123')
        $pwd = ConvertTo-SecureString $pwd -AsPlainText -Force

        # Thanks so some nefarious W10 bug, the password has to be set
        # in a different statement, after the account has been enabled
        $adminUser = Get-LocalUser -Name "Admin*"
        Enable-LocalUser $adminUser
        Set-LocalUser $adminUser -Password $pwd

        Add-LocalGroupMember -Group Users -Member $env:UserName
        Remove-LocalGroupMember -Group Administrators -Member $env:UserName
        }
    }
