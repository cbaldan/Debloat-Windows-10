#Requires -RunAsAdministrator

# Description
# ===========
# Disables all background apps

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1

New-ItemProperty HKCU:Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications -Name GlobalUserDisabled -PropertyType DWORD -Value 1

# Disable Microsoft Edge pre-launch
force-mkdir "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
Set-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" 0