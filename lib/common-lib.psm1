Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-dialog.psm1 -Force
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1 -Force
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1 -Force

$lineSeparator="`n================================================="

$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

Function Exec-SmokeTest() {
# This is a simple check to make sure the script will run fine

    Write-Debug "Starting Smoke Test"

    try {
        Write-Debug "Stopping Windows Update Service"
        Stop-Service wuauserv

        Do-MapHKEY_USERS
        $username = Get-LoggedUsername
        $userSid = Get-UserSid $username
        $userHomeFolder = Get-UserHomeFolder $userSid

    } catch {
        $exception = $_
        Write-Debug $exception
        Write-Host "ERROR: Could init script" -BackgroundColor Red
        Exit
    }

    Write-Debug "Env setup successfull"

}

Function Do-MapHKEY_USERS() {
    Write-Debug "Creating HKU mapping"

    # Creates new PS mapping to HKEY_USERS
    # http://www.myotherpcisacloud.com/post/Accessing-HKEY_USERS-With-Powershell
    New-PSDrive HKU Registry HKEY_USERS | Out-Null
}

Function Stop-WindowsUpdateService() {
    Write-Debug "Stopping Windows Update Service"
    Stop-Service wuauserv
}

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
    $loggedUser = Get-WmiObject -Class Win32_Computersystem | select Username | foreach { -split $_."Username" } 
    $index = $loggedUser.IndexOf('\') + 1
    $loggedUser = $loggedUser.Substring($index)

    return $loggedUser
}

Function Is-BuiltInAdminLoggedInUser() {

    $result = $false

    $sid = Get-UserSid $(Get-LoggedUsername)
    $sidLast3Digits = $sid.Substring($sid.Length -3)

    if ( $sidLast3Digits -eq "500" ) {
        $result = $true
    }

    Return $result
}

function Is-UserAdministrator($username) {
    $result = $true

    $administratorsAccount = Get-WmiObject Win32_Group -filter "LocalAccount=True AND SID='S-1-5-32-544'"
    $administratorQuery = "GroupComponent = `"Win32_Group.Domain='" + $administratorsAccount.Domain + "',NAME='" + $administratorsAccount.Name + "'`""
    $user = Get-WmiObject Win32_GroupUser -filter $administratorQuery | select PartComponent | where {$_ -match "Name=`"$username`""}
    if ($user -eq $null) {
        $result = $false
    }

    return $result
}

Function Remove-CurrentUserAdminGroup() {

    if (Is-BuiltInAdminLoggedInUser) {
        Write-Host "ERROR: $env:UserName shouldn't be removed from Administrators group - removal skipped" -BackgroundColor DarkYellow
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
        $exception = $_
        Write-Debug $exception
        throw "Could not fetch SID for $username"
    }
}

function Get-UserHomeFolder($sid) {
    $userProfilePathValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -Name ProfileImagePath
    $folder = $userProfilePathValue.ProfileImagePath
    return $folder
}