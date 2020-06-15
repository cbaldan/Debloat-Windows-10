#Requires -RunAsAdministrator

# Description
# ===========
# This script will apply MarkC's mouse acceleration fix (for 100% DPI) and
# disable some accessibility features regarding keyboard input.  Additional
# some UI elements will be changed.

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
	# MarkC's mouse acceleration fix
	Set-ItemProperty "HKU:\$profile\Control Panel\Mouse" "MouseSensitivity" "10"
	Set-ItemProperty "HKU:\$profile\Control Panel\Mouse" "MouseSpeed" "0"
	Set-ItemProperty "HKU:\$profile\Control Panel\Mouse" "MouseThreshold1" "0"
	Set-ItemProperty "HKU:\$profile\Control Panel\Mouse" "MouseThreshold2" "0"
	Set-ItemProperty "HKU:\$profile\Control Panel\Mouse" "SmoothMouseXCurve" ([byte[]](0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0xCC, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x80, 0x99, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x66, 0x26, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x33, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00))
	Set-ItemProperty "HKU:\$profile\Control Panel\Mouse" "SmoothMouseYCurve" ([byte[]](0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA8, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0x00, 0x00))

	# Disable mouse pointer hiding
	Set-ItemProperty "HKU:\$profile\Control Panel\Desktop" "UserPreferencesMask" ([byte[]](0x9e,
	0x1e, 0x06, 0x80, 0x12, 0x00, 0x00, 0x00))

	# Disable Game DVR and Game Bar
	force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
	Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowgameDVR" 0

	# Disable easy access keyboard stuff
	Set-ItemProperty "HKU:\$profile\Control Panel\Accessibility\StickyKeys" "Flags" "506"
	Set-ItemProperty "HKU:\$profile\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
	Set-ItemProperty "HKU:\$profile\Control Panel\Accessibility\ToggleKeys" "Flags" "58"

	## Explorer cutomizations
	#========================

	# Expand to open folder
	Set-ItemProperty "HKU:\$profile\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "NavPaneExpandToCurrentFolder" 1

	# Setting folder view options
	#Set-ItemProperty "HKU:\$profile\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1
	Set-ItemProperty "HKU:\$profile\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
	Set-ItemProperty "HKU:\$profile\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0
	Set-ItemProperty "HKU:\$profile\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0

	# Disable Aero-Shake Minimize feature
	Set-ItemProperty "HKU:\$profile\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisallowShaking" 1

	# Setting default explorer view to This PC
	Set-ItemProperty "HKU:\$profile\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1
}
Unload-DefaultUserNtDat

# Disable Edge desktop shortcut on new profiles
$regKeyPath="HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$regValueName="DisableEdgeDesktopShortcutCreation"
$keyExists=Test-KeyValueExists $regKeyPath  $regValueName
if ($keyExists -eq $false){
	New-ItemProperty $regKeyPath -Name DisableEdgeDesktopShortcutCreation -PropertyType DWORD -Value 1 | Out-Null
}

# Removing user folders under This PC
# Remove Desktop from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
}

# Remove Documents from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
}

# Remove Downloads from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
}

# Remove Music from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
}

# Remove Pictures from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
}

# Remove Videos from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
}

# Remove 3D Objects from This PC
$regKeyPath="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
if (Test-KeyExists($regKeyPath)){
    Remove-Item $regKeyPath
    Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
}