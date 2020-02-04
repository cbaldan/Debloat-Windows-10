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

function Get-BuiltInAdminAccount() {

    $profiles = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
    foreach ($item in $profiles) {
        if ($item.name.substring($item.name.Length -3) -eq "500") {
            $lastSlash = $item.name.LastIndexOf('\') + 1
            $sid = $item.name.substring($lastSlash)
            Get-LocalUser -SID $sid
            return
        }
    }
}


if (Is-UserAdministrator $(Get-LoggedUsername)) {
    if (Is-BuiltInAdminLoggedInUser) {
        Write-Debug "Built-in admin account session active - account privilege fix skipped"
        Return
    } else {

        if (Is-UserAdministrator $username) {

            $adminUser = Get-BuiltInAdminAccount

            if (!$adminUser.Enabled) {
                $msg="Enable the Administrator account?`n`nThe Windows built-in admin account will be enabled and the current user will be removed from the 'Administrators' group.`n`n"
                $choice = [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'YesNo,SystemModal,Question', 'Enable admin')

                switch  ($choice) {
                    'Yes' {
                        Enable-LocalUser $adminUser

                        if ($testModeEnabled) {
                            $pwd = ""
                        } else {
                            $pwd = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the Administrator account password', 'Password', '*123')
                        }

                        if ($pwd -ne "") {
                            $pwd = ConvertTo-SecureString $pwd -AsPlainText -Force
                            Set-LocalUser $adminUser -Password $pwd
                        }
	                }
                }
            }

            Write-Host "Removing admin rights: $username"
            Remove-UserFromAdminGroup $username
            
        }
    }
}