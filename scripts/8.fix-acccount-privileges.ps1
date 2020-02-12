#Requires -RunAsAdministrator

# Description
# ===========
# For increased security, I enable the built-in Administrator
# account in Windows and demote the user account to Standard User

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force
Add-Type -AssemblyName Microsoft.VisualBasic

Print-ScriptBanner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername

#=============================================================================
if (Is-BuiltInAdminLoggedInUser) {
    Write-Debug "Built-in admin account session active - account privilege fix skipped"
    Return
} else {
    $adminUserSid = Get-BuiltInAdminAccountSID
	$adminUser = Get-LocalUser -SID $adminUserSid

    if($testModeEnabled) {
        Remove-UserFromAdminGroup $username

        Enable-LocalUser $adminUser
        $pwd = ConvertTo-SecureString "" -AsPlainText -Force
        Set-LocalUser $adminUser -Password $pwd
                
    } else {

        $msg="Enable the Administrator account?`n`nThe Windows built-in admin account will be enabled and the current user will be removed from the 'Administrators' group.`n`n"
        $choice = [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'YesNo,SystemModal,Question', 'Enable admin')

        switch  ($choice) {
            'Yes' {
                if (Is-UserAdministrator $username) {
                    Remove-UserFromAdminGroup $username
                }

                Enable-LocalUser $adminUser

                $pwd = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Administrator account password', 'Password', '*123')

                if ($pwd -ne "") {
                    $pwd = ConvertTo-SecureString $pwd -AsPlainText -Force
                    Set-LocalUser $adminUser -Password $pwd
                }
	        }#Yes
        }#switch
    } #testMode
}