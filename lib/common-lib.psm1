Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-dialog.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

$lineSeparator="`n================================================="

Function Print-Script-Banner($scriptName)
{
   Write-Host "`n>> Executing: $scriptName$lineSeparator"
}

Function Print-Message-With-Banner($msg)
{
   Write-Host "`n>> $msg$lineSeparator"
}

Function Test-KeyExists($regKeyPath) {
    $exists = Get-Item $regKeyPath -EA SilentlyContinue

    If ($exists -ne $null) {
        Return $true
    }

    Return $false
}

Function Question-UserAdminsRights() {
    $choice = [Microsoft.VisualBasic.Interaction]::MsgBox('Is the current user in the Administrators group?', 'YesNo,SystemModal,Question', 'User admin rights check')

    switch  ($choice) {
    'No' {
        $collector = [Microsoft.VisualBasic.Interaction]::MsgBox('For these scripts to work properly, the current user *MUST* be in the Administrator group.', 'OkOnly,SystemModal,Question', 'User admin rights check')
        Write-Host "Script execution aborted"
        Exit
	    }
    }
}

Function Remove-CurrentUserAdminGroup() {
    Add-LocalGroupMember -Group Users -Member $env:UserName
    Remove-LocalGroupMember -Group Administrators -Member $env:UserName
}