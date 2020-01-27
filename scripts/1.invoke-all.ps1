#Requires -RunAsAdministrator

# Description
# ===========
# Invokes the execution of all scripts at once.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1

# Preparation
#=============================================================================

Write-Output ">> Stopping Windows Update Service$(Get-Line-Separator)"
Stop-Service wuauserv

# Real work
#=============================================================================

Write-Output "Starting Windows 10 Cleanup$(Get-Line-Separator)"

&($PSScriptRoot+"\2.disable-services.ps1")
&($PSScriptRoot+"\2.1.disable-background-apps.ps1")
&($PSScriptRoot+"\3.optimize-windows-update.ps1")
&($PSScriptRoot+"\4.remove-onedrive.ps1")
&($PSScriptRoot+"\6.optimize-user-interface.ps1")
&($PSScriptRoot+"\6.1.cleanup-taskbar.ps1")
&($PSScriptRoot+"\7.unbloat-start-menu.ps1")
&($PSScriptRoot+"\8.enable-administrator-acccount.ps1")
&($PSScriptRoot+"\5.remove-default-apps.ps1")
&($PSScriptRoot+"\9.remove-onedrive-leftovers.ps1")

Restart-Dialog