#Requires -RunAsAdministrator

# Description
# ===========
# Cleans up the taskbar by disabling the items below

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-ScriptBanner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername
$userSid = Get-UserSid $username

#The PSDrive mapping has to be done in every PS1 file
New-PSDrive HKU Registry HKEY_USERS | Out-Null
Load-DefaultUserNtDat

#=============================================================================

$profiles = @($userSid,"DEFAULT")

foreach ($profile in $profiles) {
	# Set Cortana search box hidden from taskbar
	Set-ItemProperty "HKU:\$profile\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0

	# Remove Cortana button from taskbar
	Set-ItemProperty "HKU:\$profile\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCortanaButton" 0

	# Remove TaskView button from taskbar
	Set-ItemProperty "HKU:\$profile\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0

	# Use small buttons in Taksbar
	Set-ItemProperty "HKU:\$profile\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1
}
# 2019-02-08: Unloading the DEFAULT profile at this point is causing an ERROR
#Unload-DefaultUserNtDat

Restart-Explorer