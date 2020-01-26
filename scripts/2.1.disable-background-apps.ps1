#Requires -RunAsAdministrator

# Description
# ===========
# Disables all background apps

New-ItemProperty HKCU:Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications -Name GlobalUserDisabled -PropertyType DWORD -Value 1