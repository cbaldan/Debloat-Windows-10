#Requires -RunAsAdministrator

# Description
# ===========
# Disables all background apps

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-Script-Banner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername
$userSid = Get-UserSid $username

#The PSDrive mapping has to be done in every PS1 file
New-PSDrive HKU Registry HKEY_USERS | Out-Null
Load-DefaultUserNtDat

#=============================================================================

## Disable Background apps

# Current user
$path="HKU:\$userSid\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
$key="GlobalUserDisabled"
New-ItemProperty $path -Name $key -PropertyType DWORD -Value 1 | Out-Null

# Default profile
# 2020-02-09: Even with the item present in C:\Users\Default\NTUSER.DATA file, new profiles won't
# have the item cloned from the default profile. Bug?
#$userSid="DEFAULT"
#$path="HKU:\$userSid\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
#force-mkdir $path
#New-ItemProperty $path -Name $key -PropertyType DWORD -Value 1 | Out-Null
#Start-Sleep -Seconds 5
#Unload-DefaultUserNtDat


# Disable Microsoft Edge pre-launch
force-mkdir "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
Set-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" 0
