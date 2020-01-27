#Requires -RunAsAdministrator

# Description
# ===========
# Cleans up the taskbar by disabling the items below

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1

Write-Output ">> Executing: $($MyInvocation.MyCommand.Name)$(Get-Line-Separator)"

#=============================================================================

# Set Cortana search box hidden from taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0

# Remove Cortana button from taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCortanaButton" 0

# Remove TaskView button from taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0

# Use small buttons in Taksbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1

# Remove People button from taskbar
force-mkdir "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" "PeopleBand" 0

Stop-Process -name explorer
Start-Sleep -s 3