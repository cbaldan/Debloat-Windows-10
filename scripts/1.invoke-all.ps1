#Requires -RunAsAdministrator

# Description
# ===========
# Invokes the execution of all scripts at once.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\logoff-popup.psm1

$lineSeparator="============================"

Write-Output "Starting Windows 10 Cleanup`n"

Write-Output ">> Unblocking Scripts"$lineSeparator
cd $PSScriptRoot
ls -Recurse *.ps*1 | Unblock-File

Write-Output ">> Stopping Windows Update Service"$lineSeparator
Stop-Service wuauserv

Write-Output ">> Disabling services"$lineSeparator
&($PSScriptRoot+"\2.disable-services.ps1")

Write-Output ">> Optmizing Windows Update"$lineSeparator
&($PSScriptRoot+"\3.optimize-windows-update.ps1")

Write-Output ">> Removing OneDrive"$lineSeparator
&($PSScriptRoot+"\4.remove-onedrive.ps1")

Write-Output ">> Removing Default Apps"$lineSeparator
&($PSScriptRoot+"\5.remove-default-apps.ps1")

Write-Output ">> Optimizing User Interface"$lineSeparator
&($PSScriptRoot+"\6.optimize-user-interface.ps1")

Write-Output ">> Optimizing Start Menu"$lineSeparator
&($PSScriptRoot+"\7.unbloat-start-menu.ps1")

Write-Output ">> Enabling the administrator account"$lineSeparator
&($PSScriptRoot+"\8.enable-administrator-acccount.ps1")