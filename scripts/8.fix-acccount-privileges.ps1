#Requires -RunAsAdministrator

# Description
# ===========
# For increased security, I enable the built-in Administrator
# account in Windows and demote the user account to Standard User

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force
Add-Type -AssemblyName Microsoft.VisualBasic

Print-Script-Banner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername

#=============================================================================

if (Is-UserAdministrator $(Get-LoggedUsername)) {
    if (Is-BuiltInAdminLoggedInUser) {
        Write-Debug "Built-in admin account session active - account privilege fix skipped"
        Return
    } else {

        if (Is-UserAdministrator $username) {

            $adminUser = Get-BuiltInAdminAccount

            if ($adminUser.Enabled) {
                Remove-UserFromAdminGroup $username
            } else {

                if($testModeEnabled) {
                    Enable-LocalUser $adminUser
                    Remove-UserFromAdminGroup $username
                } else {

                    $msg="Enable the Administrator account?`n`nThe Windows built-in admin account will be enabled and the current user will be removed from the 'Administrators' group.`n`n"
                    $choice = [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'YesNo,SystemModal,Question', 'Enable admin')

                    switch  ($choice) {
                        'Yes' {
							if ($adminUser -eq $null){
                                $adminUserSid = Get-BuiltInAdminAccountSID
								Enable-LocalUser -SID $adminUserSid
								$adminUser = Get-BuiltInAdminAccount
							}

                            if ($testModeEnabled) {
                                $pwd = ""
                            } else {
                                $pwd = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Administrator account password', 'Password', '*123')
                            }

                            if ($pwd -ne "") {
                                $pwd = ConvertTo-SecureString $pwd -AsPlainText -Force
                                Set-LocalUser $adminUser -Password $pwd
                            }

                            Remove-UserFromAdminGroup $username
	                    }#Yes
                    }#switch
                } #testMode
            }#else !admin.Enabled
        }
    }
}