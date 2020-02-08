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

$path="HKU:\$userSid\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
$key="GlobalUserDisabled"

$profiles = @($userSid,"DEFAULT")

foreach ($profile in $profiles) {
	# Thanks to some bug, the Key existence for a different user
	# has to be tested in the script, it will always return false
	# if tested in a module (.psm1) when the user running is not in the admin group.
	$item=Get-Item $path -EA Ignore
	$keyExists = $item.Property -contains $key

	if(!$keyExists){
		New-ItemProperty $path -Name $key -PropertyType DWORD -Value 1 | Out-Null
	}
}

# Disable Microsoft Edge pre-launch
force-mkdir "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
Set-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" 0

Unload-DefaultUserNtDat