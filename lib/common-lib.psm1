Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-dialog.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

$lineSeparator="`n================================================="

$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

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

    if ($exists -ne $null) {
        Return $true
    }

    Return $false
}

function Test-KeyValueExists($regKeyPath, $regValueName) {
    $keyExists = (Get-Item $regKeyPath -EA Ignore).Property -contains $regValueName

    return $keyExists
}

Function Get-LoggedUsername() {
    $loggedUser = get-wmiobject -Class Win32_Computersystem | select Username | foreach { -split $_."Username" } 
    $index = $loggedUser.IndexOf('\') + 1
    $loggedUser = $loggedUser.Substring($index)

    return $loggedUser
}

Function Is-BuiltInAdmin() {

    $result = $false

    $sid = Get-UserSid $(Get-LoggedUsername)
    $sidLast3Digits = $sid.Substring($sid.Length -3)

    if ( $sidLast3Digits -eq "500" ) {
        $result = $true
    }

    Return $result
}

Function Check-AdminsRights() {

    if (Is-BuiltInAdmin) {
        Return
    }

    $loggedUser = Get-LoggedUsername
    if ($loggedUser -ne $env:USERNAME){
        Write-Host "For these scripts to work properly, the current user *MUST* be in the Administrators group." -BackgroundColor Red
        Write-Host "Script execution aborted" -BackgroundColor Red
        Exit
    }
    
}

Function Remove-CurrentUserAdminGroup() {

    if (Is-BuiltInAdmin) {
        Write-Host "$env:UserName shouldn't be removed from Administrators group - removal skipped"
        Return
    }

    Add-LocalGroupMember -Group Users -Member $env:UserName
    Remove-LocalGroupMember -Group Administrators -Member $env:UserName
}

function Get-UserSid($username)
{
    try{
        $domain = $env:COMPUTERNAME
        $user = $username

        $objUser = New-Object System.Security.Principal.NTAccount($domain, $user)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])

        return $strSID.Value
    } catch {
        throw "Could not fetch SID for $username"
    }
}
