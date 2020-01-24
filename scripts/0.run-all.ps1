# WARNING:
# It's MANDATORY that the PowerShell that will run the scripts is launched
# as Administrator, else, it will fail!!!
# ==================================================
# Run these in the prompt below to enalbe scripting
#
# Set-ExecutionPolicy Unrestricted -Scope CurrentUser
# ls -Recurse *.ps*1 | Unblock-File
#
# After Windows 10 1909, OneDrive is installed after the user
# made the first login, and it seems to be downloaded from the internet.
# Make sure the OneDrive Setup process is complete before executing the
# script.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-pc-popup.psm1

Write-Output "Starting Windows 10 Cleanup`n"

$lineSeparator="===================="

Write-Output ">> Disabling services"$lineSeparator
&($PSScriptRoot+"\1.disable-services.ps1")

Write-Output ">> Optmizing Windows Update"$lineSeparator
&($PSScriptRoot+"\2.optimize-windows-update.ps1")

Write-Output ">> Removing OneDrive"$lineSeparator
&($PSScriptRoot+"\3.remove-onedrive.ps1")

Write-Output ">> Removing Default Apps"$lineSeparator
&($PSScriptRoot+"\4.remove-default-apps.ps1")

Write-Output ">> Optimizing User Interface"$lineSeparator
&($PSScriptRoot+"\5.optimize-user-interface.ps1")

Write-Output ">> Optimizing Start Menu"$lineSeparator
&($PSScriptRoot+"\6.unbloat-start-menu.ps1")

Write-Output ">> Enabling the administrator account"$lineSeparator
&($PSScriptRoot+"\7.enable-administrator-acccount.ps1")

RestartComputerPopup