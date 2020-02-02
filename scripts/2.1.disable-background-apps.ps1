#Requires -RunAsAdministrator

# Description
# ===========
# Disables all background apps

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-Script-Banner($MyInvocation.MyCommand.Name)

#=============================================================================

New-ItemProperty HKCU:Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications -Name GlobalUserDisabled -PropertyType DWORD -Value 1 | Out-Null

# Disable Microsoft Edge pre-launch
force-mkdir "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
Set-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" 0