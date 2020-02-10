Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-dialog.psm1 -Force
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1 -Force
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1 -Force

$lineSeparator="`n================================================="

$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

$debloatPath="HKLM:\Software\Microsoft\Windows\CurrentVersion"
$debloatedItemName="WindowsDebloatedOn"

Function Exec-SmokeTest($testModeEnabled) {
# This is a simple check to make sure the script will run fine

    Write-Debug "Starting Smoke Test"

    try {
        Write-Debug "Stopping Windows Update Service"
        Stop-Service wuauserv

        Do-MapHKEY_USERS
        $username=Get-LoggedUsername
        $userSid=Get-UserSid $username
        Get-UserHomeFolder $userSid | Out-Null

        $isDebloated=Is-WindowsDebloated

        Write-Debug "testModeEnabled: $testModeEnabled`nisDebloated: $isDebloated"

        if ($testModeEnabled -and ($isDebloated -eq $false)) {
            Create-TestAccounts
        }

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

Function Load-DefaultUserNtDat() {
    $index = $env:USERPROFILE.LastIndexOf('\')
    $usersFolder = $env:USERPROFILE.Substring(0,$index)
    reg load HKU\DEFAULT "$usersFolder\Default\NTUSER.DAT" | Out-Null
}

Function Unload-DefaultUserNtDat() {
    reg unload HKU\DEFAULT | Out-Null
    # Force release of NTUSER.DAT
    # https://jrich523.wordpress.com/2012/03/06/powershell-loading-and-unloading-registry-hives/
    [gc]::collect()
}

Function Stop-WindowsUpdateService() {
    Write-Debug "Stopping Windows Update Service"
    Stop-Service wuauserv
}

Function Is-WindowsDebloated() {

    $isDebloated=$true

    $windowsDebloated = Test-KeyValueExists $debloatPath $debloatedItemName

    if (!$windowsDebloated) {
        $isDebloated=$false
    }

    return $isDebloated
}

Function Get-DebloatDate() {
	return (Get-ItemProperty -Path $debloatPath -Name $debloatedItemName).$debloatedItemName
}

Function Create-WindowsDebloatedRegEntry() {
    $debloatedItemValue=(Get-Date).ToString()
    New-ItemProperty $debloatPath -Name $debloatedItemName -PropertyType String -Value $debloatedItemValue | Out-Null
}

Function Create-TestAccounts() {
    Print-Message-With-Prefix("Creating test accounts")
    New-LocalUser -Name "T1a" -Description "Admin test account" -NoPassword
    Add-LocalGroupMember -Group Administrators -Member "T1a"
    Set-LocalUser -Name "T1a" -PasswordNeverExpires $true

    New-LocalUser -Name "T2" -Description "User test account" -NoPassword
    Add-LocalGroupMember -Group Users -Member "T2"
    Set-LocalUser -Name "T2" -PasswordNeverExpires $true
}

Function Print-Script-Banner($scriptName)
{
   Write-Host "`n>> Executing: $scriptName$lineSeparator"
}

Function Print-Message-With-Prefix($msg)
{
   Write-Host ">> $msg"
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

Function Remove-UserFromAdminGroup($username) {

    if (Is-BuiltInAdminLoggedInUser) {
        Write-Host "ERROR: $env:UserName shouldn't be removed from Administrators group - removal skipped" -BackgroundColor DarkYellow
        Return
    }

    Write-Host "Removing admin rights: $username"
    Add-LocalGroupMember -Member $username -SID S-1-5-32-545    #Users group
    Remove-LocalGroupMember -Member $username -SID S-1-5-32-544 #Admin group
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

function Get-BuiltInAdminAccountSID() {
    $sidArray=Get-WmiObject -Class Win32_UserAccount | Select SID | Where-Object {$_.sid -like "*-500"}
    return $sidArray[0].SID
}

Function Remove-OneDriveCheck() {

    Print-Message-With-Prefix("Checking OneDrive status")

    $removeOneDrive=$false

    $isOneDriveRunning = Get-Process "OneDrive" -ErrorAction SilentlyContinue
    if ($isOneDriveRunning) {
        Write-Debug "OneDrive is runnin' happily!"
        $removeOneDrive=$true
    } else {
        $oneDriveSetupRunning = Get-Process "OneDriveSetup" -ErrorAction SilentlyContinue
        if ($oneDriveSetupRunning) {
            Write-Host "OneDriveSetup is running" -BackgroundColor Yellow -ForegroundColor Black

            $msg="`nIt's not possible to uninstall OneDrive at this time because its setup is still running - it is executed on user's first login.`n`nOK:`tSkip uninstallation`nCANCEL:`tAbort script execution`n`n`n"
            $choice = [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'OkCancel,SystemModal,Question', 'Skip OneDrive Uninstall?')

            switch  ($choice) {
                'Ok' {
                    $removeOneDrive=$false
	            }#Ok
                'Cancel' {
                    Write-Host "Debloater execution has been canceled!" -BackgroundColor Yellow -ForegroundColor Black
                    exit
	            }#Ok
            }#switch
          
        }
    }

    return $removeOneDrive
}